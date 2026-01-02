# Quick Reference Guide

Quick command reference for MediaWiki build, install, and deployment.

## Installation

```bash
# Quick install
bash scripts/install.sh

# Or with Make
make install

# Docker-based development
make dev
```

## Development

```bash
# Start development server
make serve
# Access at http://localhost:4000

# Or with Docker
make docker-up
# Access at http://localhost:8080/w
```

## Building

```bash
# Build for deployment
make build

# Build output in build/ directory
```

## Testing

```bash
# All tests
make test

# Specific tests
make test-php      # PHP unit tests
make test-js       # JavaScript tests
make lint          # All linters
```

## Deployment

```bash
# Deploy to staging
make deploy DEPLOY_ENV=staging

# Deploy to production (requires confirmation)
make deploy DEPLOY_ENV=production

# Health check
bash scripts/health-check.sh
```

## Maintenance

```bash
# Clean caches and build artifacts
make clean

# Update dependencies
make update

# View all commands
make help
```

## File Structure

```
.github/workflows/    # CI/CD workflows
scripts/             # Automation scripts
  ├── install.sh     # Installation
  ├── build.sh       # Build process
  ├── deploy.sh      # Deployment
  └── health-check.sh # Health verification
Makefile             # Command shortcuts
BUILD.md             # Build documentation
DEPLOYMENT.md        # Deployment guide
CHANGELOG.md         # Version history
.env.example         # Configuration template
```

## Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
# Edit .env with your settings
```

## Docker Commands

```bash
# Start containers
docker compose up -d

# Stop containers  
docker compose down

# View logs
docker compose logs -f

# Execute commands
docker compose exec mediawiki bash
```

## Troubleshooting

```bash
# Check health
bash scripts/health-check.sh

# View logs
tail -f cache/*.log

# Reset installation
rm -f LocalSettings.php
make install
```

## CI/CD

- `.github/workflows/ci.yml` - Continuous Integration
- `.github/workflows/cd.yml` - Continuous Deployment

Workflows run automatically on:
- Push to main/master branches
- Pull requests
- Tag pushes (for deployment)

## Documentation

- [README.md](README.md) - Overview
- [BUILD.md](BUILD.md) - Build guide
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment guide
- [DEVELOPERS.md](DEVELOPERS.md) - Development setup
- [INSTALL](INSTALL) - Installation details
- [CHANGELOG.md](CHANGELOG.md) - Change history

## Support

- MediaWiki Docs: https://www.mediawiki.org/
- IRC: #mediawiki on Libera Chat
- Issues: https://bugs.mediawiki.org/
