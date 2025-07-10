package createfirebasetoken

import (
	"context"
	"encoding/json"
	"log"
	"net/http"

	"firebase.google.com/go/v4/auth"
)

type LinkedInUserInfo struct {
	Sub     string `json:"sub"`
	Name    string `json:"name"`
	Picture string `json:"picture"`
	Email   string `json:"email"`
}

func CreateLinkedInFirebaseToken(w http.ResponseWriter, r *http.Request) {
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

	req, _ := http.NewRequest("GET", "https://api.linkedin.com/v2/userinfo", nil)
	req.Header.Add("Authorization", "Bearer "+reqBody.AccessToken)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil || resp.StatusCode != http.StatusOK {
		http.Error(w, "Failed to verify LinkedIn token", http.StatusUnauthorized)
		return
	}
	defer resp.Body.Close()

	var userInfo LinkedInUserInfo
	if err := json.NewDecoder(resp.Body).Decode(&userInfo); err != nil {
		http.Error(w, "Failed to parse LinkedIn user info", http.StatusInternalServerError)
		return
	}

	uid := userInfo.Sub

	_, err = firebaseAuthClient.GetUser(context.Background(), uid)

	if err != nil {
		if !auth.IsUserNotFound(err) {
			http.Error(w, "Error looking up Firebase user", http.StatusInternalServerError)
			return
		}
		params := (&auth.UserToCreate{}).
			UID(uid).
			DisplayName(userInfo.Name).
			PhotoURL(userInfo.Picture).
			Email(userInfo.Email)

		userRecord, createErr := firebaseAuthClient.CreateUser(context.Background(), params)
		if createErr != nil {
			http.Error(w, "Failed to create new Firebase user", http.StatusInternalServerError)
			return
		}
		log.Printf("Successfully created new user via LinkedIn: %s\n", userRecord.UID)
	}

	customToken, err := firebaseAuthClient.CustomToken(context.Background(), uid)
	if err != nil {
		http.Error(w, "Failed to create Firebase custom token", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"firebase_token": customToken})
}
