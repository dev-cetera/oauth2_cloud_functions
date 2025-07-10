package exchangeauthcode

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
)

type InputData struct {
	Code         *string `json:"code,omitempty"`
	RedirectURI  *string `json:"redirect_uri,omitempty"`
	ClientID     *string `json:"client_id,omitempty"`
	ClientSecret *string `json:"client_secret,omitempty"`
	CodeVerifier *string `json:"code_verifier,omitempty"`
}

type FinalInputData struct {
	Code         string
	RedirectURI  string
	ClientID     string
	ClientSecret string
	CodeVerifier string
}

func setCorsHeaders(w http.ResponseWriter, r *http.Request) {
	origin := r.Header.Get("Origin")
	for _, allowed := range AllowedOrigins {
		if allowed == origin {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			break
		}
	}
	w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
}

func exchangeCode(w http.ResponseWriter, r *http.Request, provider, tokenURL string, customizer func(*http.Request, url.Values, FinalInputData)) {
	setCorsHeaders(w, r)
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}
	if r.Method != http.MethodPost {
		http.Error(w, "Only POST method is allowed", http.StatusMethodNotAllowed)
		return
	}

	var reqBody InputData
	if err := json.NewDecoder(r.Body).Decode(&reqBody); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	envID := ""
	envSecret := ""
	if envSecrets, ok := secretsFromEnv[provider]; ok {
		envID = envSecrets.ID
		envSecret = envSecrets.Secret
	}

	finalClientID := ""
	if reqBody.ClientID != nil {
		finalClientID = *reqBody.ClientID
	} else {
		finalClientID = envID
	}

	finalClientSecret := ""
	if reqBody.ClientSecret != nil {
		finalClientSecret = *reqBody.ClientSecret
	} else {
		finalClientSecret = envSecret
	}

	finalData := FinalInputData{
		ClientID:     finalClientID,
		ClientSecret: finalClientSecret,
	}

	if reqBody.Code != nil {
		finalData.Code = *reqBody.Code
	}

	if reqBody.RedirectURI != nil {
		finalData.RedirectURI = *reqBody.RedirectURI
	}

	if reqBody.CodeVerifier != nil {
		finalData.CodeVerifier = *reqBody.CodeVerifier
	}

	if finalData.Code == "" {
		http.Error(w, "Missing required parameter: code", http.StatusBadRequest)
		return
	}

	if finalData.RedirectURI == "" {
		http.Error(w, "Missing required parameter: redirect_uri", http.StatusBadRequest)
		return
	}

	if finalData.ClientID == "" {
		http.Error(w, "Missing required parameter: client_id", http.StatusBadRequest)
		return
	}

	if finalData.ClientSecret == "" {
		http.Error(w, "Missing required parameter: client_secret", http.StatusBadRequest)
		return
	}

	data := url.Values{}
	data.Set("code", finalData.Code)
	data.Set("redirect_uri", finalData.RedirectURI)
	data.Set("grant_type", "authorization_code")
	data.Set("client_id", finalData.ClientID)
	data.Set("client_secret", finalData.ClientSecret)

	req, err := http.NewRequest("POST", tokenURL, nil)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to create request: %v", err), http.StatusInternalServerError)
		return
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	if customizer != nil {
		customizer(req, data, finalData)
	}

	req.Body = io.NopCloser(strings.NewReader(data.Encode()))
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to contact token endpoint: %v", err), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, "Failed to read response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(resp.StatusCode)
	w.Write(body)
}
