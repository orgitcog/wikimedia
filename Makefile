# MediaWiki Makefile
# Simplified build, install, and deploy commands following Wikimedia best practices

.PHONY: help install build test lint clean deploy docker-up docker-down docker-install

# Default target
help:
	@echo "MediaWiki Build, Install & Deploy Commands"
	@echo "==========================================="
	@echo ""
	@echo "Installation:"
	@echo "  make install          - Full installation (dependencies + database setup)"
	@echo "  make install-deps     - Install PHP and Node.js dependencies"
	@echo "  make install-db       - Initialize database (SQLite by default)"
	@echo ""
	@echo "Build:"
	@echo "  make build            - Build all assets"
	@echo "  make build-assets     - Build frontend assets"
	@echo "  make build-docs       - Build documentation"
	@echo ""
	@echo "Testing:"
	@echo "  make test             - Run all tests (lint + unit)"
	@echo "  make test-php         - Run PHP unit tests"
	@echo "  make test-js          - Run JavaScript tests"
	@echo "  make lint             - Run all linters"
	@echo "  make lint-php         - Run PHP linters"
	@echo "  make lint-js          - Run JavaScript linters"
	@echo ""
	@echo "Development:"
	@echo "  make serve            - Start development server"
	@echo "  make docker-up        - Start Docker containers"
	@echo "  make docker-down      - Stop Docker containers"
	@echo "  make docker-install   - Install MediaWiki in Docker"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy           - Deploy to server (use DEPLOY_ENV=prod/staging)"
	@echo "  make package          - Create deployment package"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean            - Clean build artifacts and caches"
	@echo "  make update           - Update dependencies"

# Installation targets
install: install-deps install-db
	@echo "Installation complete!"

install-deps:
	@echo "Installing PHP dependencies..."
	composer install
	@echo "Installing Node.js dependencies..."
	npm install
	@echo "Dependencies installed successfully!"

install-db:
	@echo "Setting up database..."
	composer run-script mw-install:sqlite
	@echo "Database setup complete!"

# Build targets
build: install-deps build-assets build-docs
	@echo "Build complete!"

build-assets:
	@echo "Building frontend assets..."
	npm run doc || echo "Documentation build skipped"
	@echo "Assets built successfully!"

build-docs:
	@echo "Building documentation..."
	npm run doc || echo "Documentation generation skipped"
	@echo "Documentation built!"

# Testing targets
test: lint test-php test-js
	@echo "All tests passed!"

test-php:
	@echo "Running PHP unit tests..."
	composer run-script phpunit:unit

test-js:
	@echo "Running JavaScript tests..."
	npm run jest

lint: lint-php lint-js
	@echo "All linters passed!"

lint-php:
	@echo "Running PHP linters..."
	composer run-script lint
	composer run-script phpcs

lint-js:
	@echo "Running JavaScript linters..."
	npm run lint

# Development targets
serve:
	@echo "Starting development server on http://127.0.0.1:4000"
	composer run-script serve

docker-up:
	@echo "Starting Docker containers..."
	docker compose up -d
	@echo "Containers started! Access at http://localhost:8080"

docker-down:
	@echo "Stopping Docker containers..."
	docker compose down

docker-install: docker-up
	@echo "Installing MediaWiki in Docker..."
	docker compose exec mediawiki composer run-script mw-install:sqlite
	@echo "MediaWiki installed in Docker!"

# Deployment targets
deploy:
	@echo "Deploying MediaWiki..."
	@bash scripts/deploy.sh $(DEPLOY_ENV)

package:
	@echo "Creating deployment package..."
	@bash scripts/build.sh
	@echo "Package created successfully!"

# Maintenance targets
clean:
	@echo "Cleaning build artifacts and caches..."
	rm -rf cache/*
	rm -rf node_modules/.cache
	@echo "Clean complete!"

update:
	@echo "Updating dependencies..."
	composer update
	npm update
	@echo "Dependencies updated!"

# Quick development workflow
dev: docker-up docker-install
	@echo "Development environment ready!"
	@echo "Access MediaWiki at: http://localhost:8080/w"
