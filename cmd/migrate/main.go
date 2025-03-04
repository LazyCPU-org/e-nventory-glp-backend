package main

import (
	"database/sql"
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

// CustomLogger implements migrate.Logger interface
type CustomLogger struct {
	verbose bool
}

func (l *CustomLogger) Printf(format string, v ...interface{}) {
	log.Printf(format, v...)
}

func (l *CustomLogger) Verbose() bool {
	return l.verbose
}

func main() {
	var migrationDir string
	var up bool
	var down bool
	var steps int
	var verbose bool
	var forceVersion int
	var clean bool
	var seed bool
	var seedFile string

	// Define command line flags
	flag.StringVar(&migrationDir, "path", "migrations", "Directory with migration files")
	flag.BoolVar(&up, "up", false, "Apply all up migrations")
	flag.BoolVar(&down, "down", false, "Apply all down migrations")
	flag.IntVar(&steps, "steps", 0, "Number of migrations to apply (up or down)")
	flag.BoolVar(&seed, "seed", false, "Run data seeding after migration")
	flag.StringVar(&seedFile, "seedfile", "seeds/data_creation.sql", "Path to seed file")
	flag.BoolVar(&verbose, "verbose", false, "Enable verbose logging")
	flag.IntVar(&forceVersion, "force", -1, "Force migration version (requires -clean)")
	flag.BoolVar(&clean, "clean", false, "Clean dirty state")
	flag.Parse()

	if !up && !down && !seed && steps == 0 && forceVersion == -1 && !clean {
		flag.Usage()
		os.Exit(1)
	}

	// Set up verbose logging if requested
	if verbose {
		log.Println("Verbose logging enabled")
	}

	// Construct database connection string from environment variables
	dbHost := getEnv("DB_HOST", "localhost")
	dbPort := getEnv("DB_PORT", "5432")
	dbName := getEnv("DB_NAME", "e-glp")
	dbUser := getEnv("DB_USER", "postgres")
	dbPassword := getEnv("POSTGRES_PASSWORD", "devpassword")

	dbURL := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
		dbUser, dbPassword, dbHost, dbPort, dbName)

	log.Printf("Checking if database %s exists...", dbName)

	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Failed to connect to postgres: %v", err)
	}
	defer db.Close()

	// Check if database exists
	var exists bool
	err = db.QueryRow("SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = $1)", dbName).Scan(&exists)
	if err != nil {
		log.Fatalf("Error checking if database exists: %v", err)
	}

	// Create database if it doesn't exist
	if !exists {
		log.Printf("Database %s does not exist. Creating...", dbName)
		_, err = db.Exec(fmt.Sprintf("CREATE DATABASE %s", dbName))
		if err != nil {
			log.Fatalf("Error creating database: %v", err)
		}
		log.Printf("Database %s created successfully", dbName)
	} else {
		log.Printf("Database %s already exists", dbName)
	}

	// Log connection details (mask password for security)
	log.Printf("Connecting to database %s on %s:%s as user %s", dbName, dbHost, dbPort, dbUser)

	// List available migration files
	log.Printf("Looking for migration files in: %s", migrationDir)
	if verbose {
		// List migration files
		files, err := os.ReadDir(migrationDir)
		if err != nil {
			log.Printf("Warning: couldn't read migration directory: %v", err)
		} else {
			log.Println("Available migration files:")
			for _, file := range files {
				log.Printf("  - %s", file.Name())
			}
		}
	}

	// Initialize the migrator
	m, err := migrate.New(
		fmt.Sprintf("file://%s", migrationDir),
		dbURL,
	)

	if err != nil {
		log.Fatalf("Migration initialization failed: %v", err)
	}

	// Set the custom logger with verbose flag
	m.Log = &CustomLogger{verbose: verbose}

	log.Printf("Migration initialized successfully using %s directory", migrationDir)

	applyMigration(m, clean, forceVersion, steps, up, down, seed, dbURL, seedFile)
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}
