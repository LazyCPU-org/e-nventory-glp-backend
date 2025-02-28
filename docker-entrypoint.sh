#!/bin/sh
set -e

# Error handler function
handle_migration_error() {
    echo "Migration failed! Rolling back migrations..."
    /usr/local/bin/migrator -down
    exit 1
}

# Run database migrations if requested
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Running database migrations..."
    
    # Wait for PostgreSQL to be ready
    echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
    until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
        echo "PostgreSQL is unavailable - sleeping"
        sleep 1
    done
    
    echo "PostgreSQL is up - executing migrations"
    # Execute migrations but trap errors
    /usr/local/bin/migrator -up || handle_migration_error
    
    # Run seeding if requested
    if [ "$RUN_SEED" = "true" ]; then
        echo "Seeding database..."
        /usr/local/bin/migrator -seed || handle_migration_error
    fi
fi

# Execute the main command
exec "$@"