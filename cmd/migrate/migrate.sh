#!/bin/bash

# Used for local development

ENV_FILE=".env.local"

source $ENV_FILE

go run cmd/migrate/main.go cmd/migrate/migration.go cmd/migrate/seed.go  "$@"