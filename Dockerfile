FROM golang:1.22-alpine AS builder

WORKDIR /code

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Build both the main app and migration tool
RUN go build -o /code/main .
RUN go build -o /code/migrator ./cmd/migrate

FROM alpine:latest

WORKDIR /app

# Install necessary dependencies for PostgreSQL client
RUN apk add --no-cache postgresql-client

# Copy both binaries
COPY --from=builder /code/main /usr/local/bin/main
COPY --from=builder /code/migrator /usr/local/bin/migrator

# Copy migrations directory
COPY migrations ./migrations

# Copy environment files
COPY .env* ./

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 5000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/bin/main"]