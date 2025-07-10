package createfirebasetoken

import (
	"context"
	"encoding/json"
	"log"
	"net/http"

	"firebase.google.com/go/v4/auth"
)

type TikTokUserInfo struct {
	OpenID      string `json:"open_id"`
	AvatarURL   string `json:"avatar_url_100"`
	DisplayName string `json:"display_name"`
}

func CreateTikTokFirebaseToken(w http.ResponseWriter, r *http.Request) {
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

	url := "https://open.tiktokapis.com/v2/user/info/?fields=open_id,avatar_url_100,display_name"
	req, _ := http.NewRequest("GET", url, nil)
	req.Header.Add("Authorization", "Bearer "+reqBody.AccessToken)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil || resp.StatusCode != http.StatusOK {
		http.Error(w, "Failed to verify TikTok token", http.StatusUnauthorized)
		return
	}
	defer resp.Body.Close()

	var responseData struct {
		Data struct {
			User TikTokUserInfo `json:"user"`
		} `json:"data"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&responseData); err != nil {
		http.Error(w, "Failed to parse TikTok user info", http.StatusInternalServerError)
		return
	}

	userInfo := responseData.Data.User
	uid := userInfo.OpenID

	_, err = firebaseAuthClient.GetUser(context.Background(), uid)

	if err != nil {
		if !auth.IsUserNotFound(err) {
			http.Error(w, "Error looking up Firebase user", http.StatusInternalServerError)
			return
		}

		params := (&auth.UserToCreate{}).
			UID(uid).
			DisplayName(userInfo.DisplayName).
			PhotoURL(userInfo.AvatarURL)

		userRecord, createErr := firebaseAuthClient.CreateUser(context.Background(), params)
		if createErr != nil {
			http.Error(w, "Failed to create new Firebase user", http.StatusInternalServerError)
			return
		}
		log.Printf("Successfully created new user via TikTok: %s\n", userRecord.UID)
	}

	customToken, err := firebaseAuthClient.CustomToken(context.Background(), uid)
	if err != nil {
		http.Error(w, "Failed to create Firebase custom token", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"firebase_token": customToken})
}
