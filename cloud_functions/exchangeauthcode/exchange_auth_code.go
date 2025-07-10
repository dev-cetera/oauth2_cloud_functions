package exchangeauthcode

import (
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

	loadSecretsForProvider("google", "OAUTH_CLIENT_ID_GOOGLE", "OAUTH_CLIENT_SECRET_GOOGLE")
	loadSecretsForProvider("facebook", "OAUTH_CLIENT_ID_FACEBOOK", "OAUTH_CLIENT_SECRET_FACEBOOK")
	loadSecretsForProvider("github", "OAUTH_CLIENT_ID_GITHUB", "OAUTH_CLIENT_SECRET_GITHUB")
	loadSecretsForProvider("instagram", "OAUTH_CLIENT_ID_INSTAGRAM", "OAUTH_CLIENT_SECRET_INSTAGRAM")
	loadSecretsForProvider("linkedin", "OAUTH_CLIENT_ID_LINKEDIN", "OAUTH_CLIENT_SECRET_LINKEDIN")
	loadSecretsForProvider("tiktok", "OAUTH_CLIENT_ID_TIKTOK", "OAUTH_CLIENT_SECRET_TIKTOK")
	loadSecretsForProvider("x", "OAUTH_CLIENT_ID_X", "OAUTH_CLIENT_SECRET_X")
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

	var tokenURL string
	var customizer func(*http.Request, url.Values, FinalInputData)

	switch path {
	case "google":
		tokenURL = "https://oauth2.googleapis.com/token"
	case "facebook":
		tokenURL = "https://graph.facebook.com/v19.0/oauth/access_token"
	case "instagram":
		tokenURL = "https://api.instagram.com/oauth/access_token"
	case "linkedin":
		tokenURL = "https://www.linkedin.com/oauth/v2/accessToken"
	case "github":
		tokenURL = "https://github.com/login/oauth/access_token"
		customizer = func(req *http.Request, data url.Values, finalData FinalInputData) {
			req.Header.Set("Accept", "application/json")
		}
	case "tiktok":
		tokenURL = "https://open.tiktokapis.com/v2/oauth/token/"
		customizer = func(req *http.Request, data url.Values, finalData FinalInputData) {
			data.Set("client_key", data.Get("client_id"))
			data.Del("client_id")
		}
	case "x":
		tokenURL = "https://api.twitter.com/2/oauth2/token"
		customizer = func(req *http.Request, data url.Values, finalData FinalInputData) {
			if finalData.CodeVerifier != "" {
				data.Set("code_verifier", finalData.CodeVerifier)
			}
			req.SetBasicAuth(finalData.ClientID, finalData.ClientSecret)
			data.Del("client_id")
			data.Del("client_secret")
		}
	default:
		http.NotFound(w, r)
		return
	}

	exchangeCode(w, r, path, tokenURL, customizer)
}
