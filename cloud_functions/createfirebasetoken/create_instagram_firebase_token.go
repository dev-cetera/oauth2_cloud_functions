package createfirebasetoken

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"firebase.google.com/go/v4/auth"
)

// InstagramUserInfo represents data from Instagram's basic profile endpoint.
type InstagramUserInfo struct {
	ID       string `json:"id"` // Unique, stable User ID
	Username string `json:"username"`
}

// CreateInstagramFirebaseToken is the public Cloud Function entry point for Instagram.
func CreateInstagramFirebaseToken(w http.ResponseWriter, r *http.Request) {
	// Assumes setCorsHeaders() is defined in a common.go file within the same package.
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

	// 1. Verify the Instagram token by calling the /me endpoint.
	url := fmt.Sprintf("https://graph.instagram.com/me?fields=id,username&access_token=%s", reqBody.AccessToken)
	req, _ := http.NewRequest("GET", url, nil)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil || resp.StatusCode != http.StatusOK {
		http.Error(w, "Failed to verify Instagram token", http.StatusUnauthorized)
		return
	}
	defer resp.Body.Close()

	var userInfo InstagramUserInfo
	if err := json.NewDecoder(resp.Body).Decode(&userInfo); err != nil {
		http.Error(w, "Failed to parse Instagram user info", http.StatusInternalServerError)
		return
	}

	// 2. Get or Create Firebase User.
	uid := userInfo.ID

	// First, check if the user exists. We only care about the error, so we
	// use the blank identifier `_` for the user record here.
	_, err = firebaseAuthClient.GetUser(context.Background(), uid)

	// We only enter this block if GetUser returned an error.
	if err != nil {
		// Check if the error was specifically "user not found".
		if !auth.IsUserNotFound(err) {
			// If it's some other error (network, etc.), fail the request.
			http.Error(w, "Error looking up Firebase user", http.StatusInternalServerError)
			return
		}

		// The user was not found, so we create them now.
		params := (&auth.UserToCreate{}).
			UID(uid).
			DisplayName(userInfo.Username) // Instagram doesn't provide a full name or photo URL here

		// --- THIS IS THE FIX ---
		// Declare `userRecord` with `:=` to create a new variable scoped to this block.
		userRecord, createErr := firebaseAuthClient.CreateUser(context.Background(), params)
		if createErr != nil {
			http.Error(w, "Failed to create new Firebase user", http.StatusInternalServerError)
			return
		}

		// The userRecord is now correctly used for logging.
		log.Printf("Successfully created new user via Instagram: %s\n", userRecord.UID)
	}

	// 3. Mint the Custom Token for the user (who now definitely exists).
	customToken, err := firebaseAuthClient.CustomToken(context.Background(), uid)
	if err != nil {
		http.Error(w, "Failed to create Firebase custom token", http.StatusInternalServerError)
		return
	}

	// 4. Send the token back to the client.
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"firebase_token": customToken})
}
