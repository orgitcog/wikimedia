# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions CI/CD workflows for automated testing and deployment
  - CI workflow for PHP and JavaScript linting and testing
  - CD workflow for automated deployment to staging and production
- Makefile for simplified build, install, and deploy commands
- Installation script (`scripts/install.sh`) for automated setup
- Build script (`scripts/build.sh`) for creating deployment packages
- Deployment script (`scripts/deploy.sh`) for automated deployments
- Health check script (`scripts/health-check.sh`) for deployment verification
- Comprehensive documentation for build, install, and deploy processes
- Environment configuration examples in `.env` file
- Docker improvements for development workflow
- Security scanning in CI pipeline
- Automated dependency caching in GitHub Actions
- Multi-PHP version testing matrix (8.2, 8.3)

### Changed
- Enhanced docker-compose.yml with better environment variable support
- Improved development environment setup process
- Standardized deployment practices following Wikimedia guidelines

### Infrastructure
- Added `.github/workflows/` directory structure
- Added `scripts/` directory for automation scripts
- Created deployment package structure
- Implemented backup mechanism for deployments

### Documentation
- Updated README.md with build/install/deploy instructions
- Added inline documentation to all scripts
- Documented deployment workflow and best practices
- Added health check verification steps

## [1.46.0] - Previous Release

See RELEASE-NOTES-1.46 for detailed release notes.
