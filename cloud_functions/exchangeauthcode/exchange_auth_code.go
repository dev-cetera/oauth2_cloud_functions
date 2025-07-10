package exchangeauthcode

import (
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"
)

type providerSecrets struct {
	ID     string
	Secret string
}

var secretsFromEnv map[string]providerSecrets

var AllowedOrigins []string

func init() {
	originsStr := os.Getenv("ALLOWED_ORIGINS")
	if originsStr == "" {
		log.Fatal("FATAL: ALLOWED_ORIGINS environment variable is not set!")
		return
	}
	rawOrigins := strings.Split(originsStr, ",")
	AllowedOrigins = make([]string, len(rawOrigins))

	for i, origin := range rawOrigins {
		AllowedOrigins[i] = strings.TrimSpace(origin)
	}

	secretsFromEnv = make(map[string]providerSecrets)

	loadSecretsForProvider("facebook", "OAUTH_CLIENT_ID_FACEBOOK", "OAUTH_CLIENT_SECRET_FACEBOOK")
	loadSecretsForProvider("github", "OAUTH_CLIENT_ID_GITHUB", "OAUTH_CLIENT_SECRET_GITHUB")
	loadSecretsForProvider("google", "OAUTH_CLIENT_ID_GOOGLE", "OAUTH_CLIENT_SECRET_GOOGLE")
	loadSecretsForProvider("instagram", "OAUTH_CLIENT_ID_INSTAGRAM", "OAUTH_CLIENT_SECRET_INSTAGRAM")
	loadSecretsForProvider("linkedin", "OAUTH_CLIENT_ID_LINKEDIN", "OAUTH_CLIENT_SECRET_LINKEDIN")
	loadSecretsForProvider("microsoft", "OAUTH_CLIENT_ID_MICROSOFT", "OAUTH_CLIENT_SECRET_MICROSOFT")
	loadSecretsForProvider("tiktok", "OAUTH_CLIENT_ID_TIKTOK", "OAUTH_CLIENT_SECRET_TIKTOK")
	loadSecretsForProvider("x", "OAUTH_CLIENT_ID_X_TWITTER", "OAUTH_CLIENT_SECRET_X_TWITTER")
}

func loadSecretsForProvider(providerKey, idEnvKey, secretEnvKey string) {
	clientID := os.Getenv(idEnvKey)
	clientSecret := os.Getenv(secretEnvKey)
	secretsFromEnv[providerKey] = providerSecrets{
		ID:     clientID,
		Secret: clientSecret,
	}
}

func ExchangeAuthCode(w http.ResponseWriter, r *http.Request) {
	path := strings.TrimPrefix(r.URL.Path, "/")
	switch path {
	case "google":
		tokenURL := "https://oauth2.googleapis.com/token"
		customizer := func(req *http.Request, data url.Values, finalData FinalInputData) {
			req.Header.Set("Accept", "application/json")
		}
		exchangeCode(w, r, path, tokenURL, customizer)
		return
	case "facebook":
		tokenURL := "https://graph.facebook.com/v19.0/oauth/access_token"
		exchangeCode(w, r, path, tokenURL, nil)
		return
	case "instagram":
		tokenURL := "https://api.instagram.com/oauth/access_token"
		exchangeCode(w, r, path, tokenURL, nil)
		return
	case "linkedin":
		tokenURL := "https://www.linkedin.com/oauth/v2/accessToken"
		exchangeCode(w, r, path, tokenURL, nil)
		return
	case "github":
		tokenURL := "https://github.com/login/oauth/access_token"
		customizer := func(req *http.Request, data url.Values, finalData FinalInputData) {
			req.Header.Set("Accept", "application/json")
		}
		exchangeCode(w, r, path, tokenURL, customizer)
		return
	case "tiktok":
		tokenURL := "https://open.tiktokapis.com/v2/oauth/token/"
		customizer := func(req *http.Request, data url.Values, finalData FinalInputData) {
			data.Set("client_key", data.Get("client_id"))
			data.Del("client_id")
		}
		exchangeCode(w, r, path, tokenURL, customizer)
		return
	case "x_twitter":
		tokenURL := "https://api.twitter.com/2/oauth2/token"
		customizer := func(req *http.Request, data url.Values, finalData FinalInputData) {
			if finalData.CodeVerifier != nil {
				data.Set("code_verifier", *finalData.CodeVerifier)
			}
			req.SetBasicAuth(finalData.ClientID, finalData.ClientSecret)
			data.Del("client_id")
			data.Del("client_secret")
		}
		exchangeCode(w, r, path, tokenURL, customizer)
		return
	case "microsoft":
		microsoftTenant := os.Getenv("MICROSOFT_TENANT_ID")
		if microsoftTenant == "" {
			microsoftTenant = "common"
		}
		microsoftTokenURL := fmt.Sprintf("https://login.microsoftonline.com/%s/oauth2/v2.0/token", microsoftTenant)
		microsoftCustomizer := func(req *http.Request, data url.Values, finalData FinalInputData) {
			req.SetBasicAuth(finalData.ClientID, finalData.ClientSecret)
			data.Del("client_id")
			data.Del("client_secret")
			data.Set("scope", "openid profile email")
			if finalData.CodeVerifier != nil {
				data.Set("code_verifier", *finalData.CodeVerifier)
			}
		}
		exchangeCode(w, r, "microsoft", microsoftTokenURL, microsoftCustomizer)
		return
	default:
		http.NotFound(w, r)
		return
	}
}
