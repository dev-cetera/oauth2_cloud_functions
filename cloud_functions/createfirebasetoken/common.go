// File: common.go
package createfirebasetoken

import (
	"context"
	"log"
	"net/http"
	"os"
	"strings"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
)

var (
	firebaseAuthClient *auth.Client
	AllowedOrigins     []string
)

func init() {
	// --- 1. Initialize Allowed Origins (MANDATORY) ---
	log.Println("Initializing CORS Allowed Origins...")
	originsStr := os.Getenv("ALLOWED_ORIGINS")
	if originsStr == "" {
		// This will cause the function to fail fast if not configured.
		log.Fatal("FATAL: ALLOWED_ORIGINS environment variable is not set!")
	}
	rawOrigins := strings.Split(originsStr, ",")
	AllowedOrigins = make([]string, len(rawOrigins))
	for i, origin := range rawOrigins {
		AllowedOrigins[i] = strings.TrimSpace(origin)
	}
	log.Printf("INFO: Loaded allowed origins: %v", AllowedOrigins)

	// --- 2. Initialize Firebase Admin SDK ---
	log.Println("Initializing Firebase Admin SDK...")
	if firebaseAuthClient != nil {
		return // Already initialized
	}
	app, err := firebase.NewApp(context.Background(), nil)
	if err != nil {
		log.Fatalf("error initializing Firebase app: %v\n", err)
	}
	client, err := app.Auth(context.Background())
	if err != nil {
		log.Fatalf("error getting Firebase Auth client: %v\n", err)
	}
	firebaseAuthClient = client
	log.Println("Firebase Admin SDK initialized successfully.")
}

// setCorsHeaders is a shared utility function.
func setCorsHeaders(w http.ResponseWriter, r *http.Request) {
	origin := r.Header.Get("Origin")
	// This now correctly uses the populated global AllowedOrigins slice.
	for _, allowed := range AllowedOrigins {
		if allowed == origin {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			break
		}
	}
	w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
}
