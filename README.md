# E-nventory
# Dashboard Backend for Delivery Business

## Overview

E-nventory provides a comprehensive backend system for managing delivery operations across multiple physical locations. The system handles user authentication, authorization, data management, and analytics for delivery operations.

## Technical Stack

- Go 1.22
- Standard library SSE implementation
- PostgreSQL for persistent storage
- Redis for caching and session management
- In-memory state management for real-time updates

## System Requirements

- Go 1.22 or higher
- Minimum 1GB RAM
- PostgreSQL 14+
- Redis 6+ (for caching and real-time updates)

## Architecture

### User Hierarchy
- **Superadmins**: Global access to all system features and data
- **Admins**: Access to data across all locations
- **Supervisors/Managers**: Location-specific access to delivery employee data
- **Delivery Employees**: Access to personal performance data only

### Data Organization
- Company-wide metrics and analytics
- Location-specific operations and performance data
- Individual delivery metrics and history

## API Documentation

- Authentication: JWT
- Base URL: `/api/v1`

## Key Endpoints:

### Authentication
- `POST /auth/login` - User login and JWT token generation
- `POST /auth/refresh` - Refresh JWT token
- `POST /auth/logout` - Invalidate current token

### User Management
- `GET /users` - List users (filtered by role and location)
- `POST /users` - Create new user
- `GET /users/:id` - Get user details
- `PUT /users/:id` - Update user
- `DELETE /users/:id` - Delete user
- `POST /users/:id/role` - Assign role to user

### Location Management
- `GET /locations` - List all locations
- `POST /locations` - Create new location
- `GET /locations/:id` - Get location details
- `PUT /locations/:id` - Update location
- `DELETE /locations/:id` - Delete location
- `GET /locations/:id/stats` - Get location statistics
- `GET /locations/:id/employees` - List employees at location
- `GET /locations/:id/supervisors` - List supervisors at location

### Supervisor Management
- `GET /supervisors` - List all supervisors
- `GET /supervisors/:id/employees` - List employees assigned to supervisor
- `POST /supervisors/:id/employees` - Assign employee to supervisor
- `DELETE /supervisors/:id/employees/:employeeId` - Remove employee assignment

### Delivery Management
- `GET /deliveries` - List deliveries (filtered by location, date, status)
- `POST /deliveries` - Create new delivery
- `GET /deliveries/:id` - Get delivery details
- `PUT /deliveries/:id` - Update delivery
- `GET /employees/:id/deliveries` - Get employee's deliveries
- `GET /employees/:id/stats` - Get employee performance statistics

### Analytics
- `GET /analytics/company` - Company-wide analytics (superadmin only)
- `GET /analytics/locations/:id` - Location analytics (admin+ access)
- `GET /analytics/supervisors/:id` - Supervisor team analytics
- `GET /analytics/employees/:id` - Individual employee analytics

## Database Schema

### Key Tables
- `users` - User accounts and authentication
- `roles` - User roles and permissions
- `locations` - Physical operation locations
- `supervisors` - Supervisor assignments and metadata
- `employees` - Delivery employee data
- `deliveries` - Delivery records
- `analytics` - Performance metrics and statistics

## Setup Instructions

- Clone the repository
- Configure environment variables in `.env` file
- Set up the PostgreSQL database and run migrations
- Initialize Redis instance
- Build and run the application

## Development

- Install Go 1.22
- Run `go mod tidy`
- Copy `.env.example` to `.env.local`, `.env.dev` or `.env.production` and configure
- Start the development server: `go run main.go`

## Migrations
- To execute the migration configuration use the following commands
```terminal
    # Apply all pending migrations
    go run cmd/migrate/main.go -up

    # Apply specific number of migrations
    go run cmd/migrate/main.go -up -steps 2

    # Rollback all migrations
    go run cmd/migrate/main.go -down

    # Rollback specific number of migrations
    go run cmd/migrate/main.go -down -steps 1

    # Run migrations and seed data
    go run cmd/migrate/main.go -up -seed

    # To clean the dirty state at the current version (-verbose is used for debugging):
    go run cmd/migrate/main.go -clean -verbose

    # Or to force a specific version (e.g., go back to clean version - 1):
    go run cmd/migrate/main.go -force 1 -verbose
```

## Production Deployment

- Build the application: `go build -o e-nventory-backend`
- Configure environment variables for production
- Set up nginx as reverse proxy
- Configure SSL/TLS certificates
- Set up monitoring with Prometheus and Grafana

## Docker Deployment

- Ensure you have Docker installed.
- Build the Docker image: `docker build -t e-nventory-backend .`
- Run the Docker container: `docker run -p 5000:5000 e-nventory-backend`

- Alternatively, use Docker Compose:
  - Ensure you have Docker Compose installed.
  - Run `docker compose up -d` to build and start the application and database.

- Environment configuration:
  - Create environment-specific files (`.env.dev`, `.env.staging`, `.env.prod`)
  - Run with `docker compose --env-file .env.prod up -d`

- To run migrations when deploying we should use the following:
  - Normal setup without migrations: `docker compose up`
  - Startup with migrations (using override file): `docker compose -f docker-compose.yaml -f docker-compose.migrate.yaml up`
  - Startup with migrations and seeding (using environment variables): `RUN_MIGRATIONS=true RUN_SEED=true docker-compose up`
  - Run migrations only (without starting the application): `docker compose run --rm app /usr/local/bin/migrator -up`
  - For specific environments: `APP_ENV=staging RUN_MIGRATIONS=true docker compose up`

## Security Considerations

- JWT-based authentication with proper expiration and refresh mechanisms
- Role-based access control for all endpoints
- Rate limiting to prevent brute force attacks
- CORS policy strictly configured for frontend domains
- Input validation and sanitization on all user inputs
- Database connection encryption and prepared statements
- Regular security audits and dependency updates

## Scaling Considerations

- Horizontal scaling with multiple backend instances
- Database connection pooling and optimization
- Redis caching for frequently accessed data
- Load balancer configuration for traffic distribution
- Separate read/write database replicas for high load scenarios
- Asynchronous processing for non-critical operations

## Contributing

- Fork the repository
- Create a feature branch
- Commit your changes
- Push to the branch
- Create a Pull Request

## License
MIT License