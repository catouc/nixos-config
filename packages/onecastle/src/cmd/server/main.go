package main

import (
	"flag"
	"log"
	"net/http"
	"os"

	"onecastle/internal/db"
	"onecastle/internal/handlers"
	"github.com/rs/cors"
)

func main() {
	addr := flag.String("addr", ":8080", "listen address")
	connStr := flag.String("db", "postgres://onecastle:onecastle@localhost:5432/onecastle?sslmode=disable", "postgres connection string")
	uploadDir := flag.String("uploads", "./uploads", "upload directory")
	frontendDir := flag.String("frontendDir", "./frontend", "frontend directory")
	flag.Parse()

	// ensure upload dir exists
	if err := os.MkdirAll(*uploadDir, 0755); err != nil {
		log.Fatalf("create upload dir: %v", err)
	}
	handlers.SetUploadDir(*uploadDir)

	// connect + migrate
	if err := db.Connect(*connStr); err != nil {
		log.Fatalf("db connect: %v", err)
	}
	if err := db.Migrate(); err != nil {
		log.Fatalf("db migrate: %v", err)
	}

	mux := http.NewServeMux()

	// API routes
	mux.HandleFunc("GET /api/locations", handlers.GetLocations)
	mux.HandleFunc("POST /api/locations", handlers.CreateLocation)
	mux.HandleFunc("PUT /api/locations/{id}", handlers.UpdateLocation)
	mux.HandleFunc("DELETE /api/locations/{id}", handlers.DeleteLocation)

	mux.HandleFunc("GET /api/zones", handlers.GetZones)
	mux.HandleFunc("POST /api/zones", handlers.CreateZone)
	mux.HandleFunc("PUT /api/zones/{id}", handlers.UpdateZone)
	mux.HandleFunc("DELETE /api/zones/{id}", handlers.DeleteZone)

	mux.HandleFunc("GET /api/containers", handlers.GetContainers)
	mux.HandleFunc("GET /api/containers/{id}", handlers.GetContainer)
	mux.HandleFunc("POST /api/containers", handlers.CreateContainer)
	mux.HandleFunc("PUT /api/containers/{id}", handlers.UpdateContainer)
	mux.HandleFunc("DELETE /api/containers/{id}", handlers.DeleteContainer)

	mux.HandleFunc("GET /api/items", handlers.GetItems)
	mux.HandleFunc("POST /api/items", handlers.CreateItem)
	mux.HandleFunc("PUT /api/items/{id}", handlers.UpdateItem)
	mux.HandleFunc("DELETE /api/items/{id}", handlers.DeleteItem)

	mux.HandleFunc("GET /api/search", handlers.Search)
	mux.HandleFunc("GET /api/export", handlers.Export)
	mux.HandleFunc("POST /api/import", handlers.Import)

	mux.HandleFunc("GET /uploads/{filename}", handlers.ServePhoto)

	// Frontend — serve static files
	mux.Handle("/", http.FileServer(http.Dir(*frontendDir)))

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders: []string{"Content-Type"},
	})

	log.Printf("OneCastle listening on %s", *addr)
	log.Fatal(http.ListenAndServe(*addr, c.Handler(mux)))
}
