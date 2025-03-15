package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
)

func main() {
	// Serve OpenAPI JSON
	http.HandleFunc("/openapi.json", func(w http.ResponseWriter, r *http.Request) {
		docPath := filepath.Join("docs", "openapi3.json")
		doc, err := os.ReadFile(docPath)
		if err != nil {
			log.Printf("Error reading OpenAPI doc: %v", err)
			http.Error(w, "Could not load OpenAPI document", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		if _, err := w.Write(doc); err != nil {
			log.Printf("Error writing response: %v", err)
		}
	})

	// Serve Swagger UI static files under /docs/ path
	swaggerUIPath := filepath.Join("docs", "swagger-ui")
	fs := http.FileServer(http.Dir(swaggerUIPath))
	http.Handle("/docs/", http.StripPrefix("/docs/", fs))

	// Serve Swagger UI index.html at /docs root
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/docs/index.html", http.StatusMovedPermanently)
	})

	fmt.Println("Starting OpenAPI server on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
