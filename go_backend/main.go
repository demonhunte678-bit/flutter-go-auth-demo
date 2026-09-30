package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

// Demo credentials and secret token used for educational purposes.
const (
	validUsername    = "john"
	validPassword    = "1122334455"
	adminSecretToken = "admin-secret-token-xyz"
	bearerPrefix     = "Bearer "
	serverPort       = ":8080"
)

// LoginRequest models the incoming JSON credentials payload.
type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// Response represents the standard JSON API response structure.
// The omitempty tags ensure unused fields are omitted from JSON outputs (YAGNI).
type Response struct {
	Message string `json:"message"`
	Token   string `json:"token,omitempty"`
	Data    string `json:"data,omitempty"`
}

// DRY Helper: Sends a standardized JSON response with proper headers and status code.
func sendJSON(w http.ResponseWriter, statusCode int, response Response) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(response)
}

func main() {
	// -------------------------------------------------------------------------
	// 1. AUTHENTICATION ENDPOINT: /login
	// -------------------------------------------------------------------------
	// Authentication answers: "Who are you?"
	// - The client submits credentials (username and password).
	// - The server verifies the credentials against the user database/store.
	// - If valid, an access token is issued so subsequent requests can prove identity.
	// - If invalid, the server responds with 401 Unauthorized.
	http.HandleFunc("/login", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		var req LoginRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			sendJSON(w, http.StatusBadRequest, Response{
				Message: "Invalid request payload",
			})
			return
		}

		// Verify identity (Authentication)
		if req.Username == validUsername && req.Password == validPassword {
			sendJSON(w, http.StatusOK, Response{
				Message: "Login successful",
				Token:   adminSecretToken,
			})
		} else {
			sendJSON(w, http.StatusUnauthorized, Response{
				Message: "Invalid username or password incorrect",
			})
		}
	})

	// -------------------------------------------------------------------------
	// 2. AUTHORIZATION ENDPOINT: /admin-dashboard
	// -------------------------------------------------------------------------
	// Authorization answers: "What are you allowed to do?"
	// - The client sends the Bearer token in the 'Authorization' HTTP header.
	// - The server inspects the token to check if the caller has permissions.
	// - If the token matches required privileges, access to protected data is granted (200 OK).
	// - If the token is missing or insufficient, access is denied (403 Forbidden).
	http.HandleFunc("/admin-dashboard", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		authHeader := r.Header.Get("Authorization")
		expectedHeader := bearerPrefix + adminSecretToken

		// Verify permissions (Authorization)
		if authHeader != expectedHeader {
			sendJSON(w, http.StatusForbidden, Response{
				Message: "You Don't have permission to access this resource (Unauthorized/Forbidden)",
			})
			return
		}

		// Access granted: return protected data
		sendJSON(w, http.StatusOK, Response{
			Message: "Admin Dashboard Data",
			Data:    "Hi Manager, this is a very secret Data",
		})
	})

	fmt.Printf("Server running on port %s\n", serverPort)
	log.Fatal(http.ListenAndServe(serverPort, nil))
}
