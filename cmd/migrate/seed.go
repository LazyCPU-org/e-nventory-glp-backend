package main

import (
	"database/sql"
	"fmt"
	"os"
)

// SeedData populates the database with initial data
func runSeeding(dbURL, seedFile string) error {
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	defer db.Close()

	// Check database connection
	if err := db.Ping(); err != nil {
		return fmt.Errorf("database connection failed: %w", err)
	}

	// Check if seed file exists
	if _, err := os.Stat(seedFile); os.IsNotExist(err) {
		return fmt.Errorf("seed file not found: %s", seedFile)
	}

	// Read the seed file
	seedSQL, err := os.ReadFile(seedFile)
	if err != nil {
		return fmt.Errorf("failed to read seed file: %w", err)
	}

	// Begin transaction
	tx, err := db.Begin()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}

	// Execute the seed SQL
	if _, err := tx.Exec(string(seedSQL)); err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to execute seed SQL: %w", err)
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	return nil
}
