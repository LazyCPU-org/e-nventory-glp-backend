package main

import (
	"log"

	"github.com/golang-migrate/migrate/v4"
)

func applyMigration(m *migrate.Migrate, clean bool, forceVersion int, steps int, up bool, down bool, seed bool, dbURL string, seedFile string) {
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
		if err := runSeeding(dbURL, seedFile); err != nil {
			log.Fatalf("Error seeding data: %v", err)
		}
		log.Println("Data seeding completed successfully")
	}
}
