package createfirebasetoken

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"firebase.google.com/go/v4/auth"
)

type FacebookUserInfo struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	Email   string `json:"email"`
	Picture struct {
		Data struct {
			URL string `json:"url"`
		} `json:"data"`
	} `json:"picture"`
}

func CreateFacebookFirebaseToken(w http.ResponseWriter, r *http.Request) {
	setCorsHeaders(w, r)
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}
	if r.Method != http.MethodPost {
		http.Error(w, "Only POST method is allowed", http.StatusMethodNotAllowed)
		return
	}

	var reqBody struct {
		AccessToken string `json:"accessToken"`
	}
	if err := json.NewDecoder(r.Body).Decode(&reqBody); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	url := fmt.Sprintf("https://graph.facebook.com/me?fields=id,name,email,picture&access_token=%s", reqBody.AccessToken)
	req, _ := http.NewRequest("GET", url, nil)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil || resp.StatusCode != http.StatusOK {
		http.Error(w, "Failed to verify Facebook token", http.StatusUnauthorized)
		return
	}
	defer resp.Body.Close()

	var userInfo FacebookUserInfo
	if err := json.NewDecoder(resp.Body).Decode(&userInfo); err != nil {
		http.Error(w, "Failed to parse Facebook user info", http.StatusInternalServerError)
		return
	}

	uid := userInfo.ID
	_, err = firebaseAuthClient.GetUser(context.Background(), uid)
	if err != nil {
		if !auth.IsUserNotFound(err) {
			http.Error(w, "Error looking up Firebase user", http.StatusInternalServerError)
			return
		}
		params := (&auth.UserToCreate{}).
			UID(uid).
			Email(userInfo.Email).
			DisplayName(userInfo.Name).
			PhotoURL(userInfo.Picture.Data.URL)

		userRecord, createErr := firebaseAuthClient.CreateUser(context.Background(), params)
		if createErr != nil {
			http.Error(w, "Failed to create new Firebase user", http.StatusInternalServerError)
			return
		}
		log.Printf("Successfully created new user via Facebook: %s\n", userRecord.UID)
	}

	customToken, err := firebaseAuthClient.CustomToken(context.Background(), uid)
	if err != nil {
		http.Error(w, "Failed to create Firebase custom token", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"firebase_token": customToken})
}
