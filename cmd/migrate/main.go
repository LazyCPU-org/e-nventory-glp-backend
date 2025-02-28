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
	var seed bool
	var verbose bool
	var forceVersion int
	var clean bool

	// Define command line flags
	flag.StringVar(&migrationDir, "path", "migrations", "Directory with migration files")
	flag.BoolVar(&up, "up", false, "Apply all up migrations")
	flag.BoolVar(&down, "down", false, "Apply all down migrations")
	flag.IntVar(&steps, "steps", 0, "Number of migrations to apply (up or down)")
	flag.BoolVar(&seed, "seed", false, "Run data seeding after migration")
	flag.BoolVar(&verbose, "verbose", false, "Enable verbose logging")
	flag.IntVar(&forceVersion, "force", -1, "Force migration version (requires -clean)")
	flag.BoolVar(&clean, "clean", false, "Clean dirty state")
	flag.Parse()

	if !up && !down && steps == 0 && forceVersion == -1 && !clean {
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
	dbUser := getEnv("DB_USER", "pguser")
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

	// Get current version before migration
	version, dirty, err := m.Version()
	if err != nil && err != migrate.ErrNilVersion {
		log.Printf("Warning: couldn't get current migration version: %v", err)
	} else if err == migrate.ErrNilVersion {
		log.Println("Current migration state: No migrations applied yet")
	} else {
		log.Printf("Current migration state: Version %d, Dirty: %v", version, dirty)
		if dirty {
			log.Println("Warning: Database is in a dirty state. You may need to fix it manually.")
		}
	}

	// Handle force version and clean options
	if clean || forceVersion >= 0 {
		if forceVersion >= 0 {
			log.Printf("Forcing migration version to %d", forceVersion)
			if err := m.Force(forceVersion); err != nil {
				log.Fatalf("Error forcing version: %v", err)
			}
			log.Printf("Successfully forced version to %d", forceVersion)
		} else if clean && dirty {
			// Just clean the current version
			log.Printf("Cleaning dirty state for version %d", version)
			if err := m.Force(int(version)); err != nil {
				log.Fatalf("Error cleaning dirty state: %v", err)
			}
			log.Printf("Successfully cleaned dirty state for version %d", version)
		}

		// Get version after forcing
		newVersion, newDirty, err := m.Version()
		if err == nil {
			log.Printf("Updated migration state: Version %d, Dirty: %v", newVersion, newDirty)
		}
	}

	// Run migrations based on flags
	if up {
		log.Println("Applying UP migrations...")
		if steps > 0 {
			log.Printf("Applying %d UP steps", steps)
			if err := m.Steps(steps); err != nil {
				if err == migrate.ErrNoChange {
					log.Println("No changes to apply")
				} else {
					log.Fatalf("Error applying UP migrations: %v", err)
				}
			} else {
				log.Printf("%d UP steps applied successfully", steps)
			}
		} else {
			log.Println("Applying all pending UP migrations")
			if err := m.Up(); err != nil {
				if err == migrate.ErrNoChange {
					log.Println("No changes to apply")
				} else {
					log.Fatalf("Error applying UP migrations: %v", err)
				}
			} else {
				log.Println("All UP migrations applied successfully")
			}
		}
	}

	if down {
		log.Println("Applying DOWN migrations...")
		if steps > 0 {
			log.Printf("Applying %d DOWN steps", steps)
			if err := m.Steps(-steps); err != nil {
				if err == migrate.ErrNoChange {
					log.Println("No changes to apply")
				} else {
					log.Fatalf("Error applying DOWN migrations: %v", err)
				}
			} else {
				log.Printf("%d DOWN steps applied successfully", steps)
			}
		} else {
			log.Println("Applying all DOWN migrations")
			if err := m.Down(); err != nil {
				if err == migrate.ErrNoChange {
					log.Println("No changes to apply")
				} else {
					log.Fatalf("Error applying DOWN migrations: %v", err)
				}
			} else {
				log.Println("All DOWN migrations applied successfully")
			}
		}
	}

	// Get version after migration
	newVersion, newDirty, err := m.Version()
	if err != nil && err != migrate.ErrNilVersion {
		log.Printf("Warning: couldn't get updated migration version: %v", err)
	} else if err == migrate.ErrNilVersion {
		log.Println("Updated migration state: No migrations applied")
	} else {
		log.Printf("Updated migration state: Version %d, Dirty: %v", newVersion, newDirty)
	}

	// Run data seeding if requested
	if seed {
		log.Println("Seeding data...")
		if err := runSeeding(dbURL); err != nil {
			log.Fatalf("Error seeding data: %v", err)
		}
		log.Println("Data seeding completed successfully")
	}
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}

// SeedData populates the database with initial data
func runSeeding(dbURL string) error {
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	defer db.Close()

	// Check database connection
	if err := db.Ping(); err != nil {
		return fmt.Errorf("database connection failed: %w", err)
	}

	// Begin transaction
	tx, err := db.Begin()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}

	// Example seed operations
	if _, err := tx.Exec(`INSERT INTO users (username, email) 
						  VALUES ('admin', 'admin@example.com')
						  ON CONFLICT (username) DO NOTHING`); err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to seed users: %w", err)
	}

	// Add more seed operations here

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	return nil
}
