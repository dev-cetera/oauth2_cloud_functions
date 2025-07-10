package createfirebasetoken

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"firebase.google.com/go/v4/auth"
)

type GitHubUserInfo struct {
	ID        int64  `json:"id"`
	Login     string `json:"login"`
	Name      string `json:"name"`
	AvatarURL string `json:"avatar_url"`
	Email     string `json:"email"`
}

func CreateGitHubFirebaseToken(w http.ResponseWriter, r *http.Request) {
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

	req, _ := http.NewRequest("GET", "https://api.github.com/user", nil)

	req.Header.Add("Authorization", "Bearer "+reqBody.AccessToken)
	req.Header.Add("Accept", "application/vnd.github+json")
	req.Header.Add("X-GitHub-Api-Version", "2022-11-28")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("Error contacting GitHub API: %v", err)
		http.Error(w, "Failed to contact GitHub API", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Printf("GitHub API returned non-OK status: %d", resp.StatusCode)
		http.Error(w, "Failed to verify GitHub token", http.StatusUnauthorized)
		return
	}

	var userInfo GitHubUserInfo
	if err := json.NewDecoder(resp.Body).Decode(&userInfo); err != nil {
		http.Error(w, "Failed to parse GitHub user info", http.StatusInternalServerError)
		return
	}

	if userInfo.Email == "" {
		log.Printf("User %s has a private email. Proceeding without one.", userInfo.Login)
	}

	uid := strconv.FormatInt(userInfo.ID, 10)
	displayName := userInfo.Name
	if displayName == "" {
		displayName = userInfo.Login
	}

	user, err := firebaseAuthClient.GetUser(context.Background(), uid)
	if err != nil {
		if !auth.IsUserNotFound(err) {
			http.Error(w, "Error looking up Firebase user", http.StatusInternalServerError)
			return
		}

		params := (&auth.UserToCreate{}).
			UID(uid).
			DisplayName(displayName).
			PhotoURL(userInfo.AvatarURL)
		
		if userInfo.Email != "" {
			params.Email(userInfo.Email)
		}

		userRecord, createErr := firebaseAuthClient.CreateUser(context.Background(), params)
		if createErr != nil {
			http.Error(w, "Failed to create new Firebase user", http.StatusInternalServerError)
			return
		}
		log.Printf("Successfully created new user via GitHub: %s\n", userRecord.UID)
	} else {
		updateParams := (&auth.UserToUpdate{}).
			DisplayName(displayName).
			PhotoURL(userInfo.AvatarURL)
		if _, updateErr := firebaseAuthClient.UpdateUser(context.Background(), uid, updateParams); updateErr != nil {
			log.Printf("Warning: failed to update user %s: %v", uid, updateErr)
		}
		log.Printf("User %s already exists, info updated.", user.UID)
	}

	customToken, err := firebaseAuthClient.CustomToken(context.Background(), uid)
	if err != nil {
		http.Error(w, "Failed to create Firebase custom token", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"firebase_token": customToken})
}