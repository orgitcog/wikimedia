# Build Guide

This guide covers building MediaWiki for production deployment following Wikimedia best practices.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Build Process](#build-process)
- [Build Customization](#build-customization)
- [Continuous Integration](#continuous-integration)
- [Troubleshooting](#troubleshooting)

## Overview

The MediaWiki build process prepares the codebase for deployment by:

1. Installing production dependencies
2. Optimizing the autoloader
3. Building and minifying assets
4. Creating deployment packages
5. Generating build manifests

## Prerequisites

### Required Software

- **PHP 8.2+** with extensions:
  - ctype, dom, fileinfo, iconv, intl
  - json, libxml, mbstring, openssl
  - xml, xmlreader
- **Composer** (latest stable)
- **Node.js 18+** and npm
- **Git** (for version information)

### Optional Software

- **Docker** (for containerized builds)
- **GNU Make** (for simplified commands)

## Quick Start

### Using Make

```bash
make build
```

### Using Script Directly

```bash
bash scripts/build.sh
```

### Using Composer

```bash
composer install --no-dev --optimize-autoloader
npm ci --production
```

## Build Process

### Step-by-Step

#### 1. Install Production Dependencies

Install PHP dependencies without development packages:

```bash
composer install --no-dev --prefer-dist --optimize-autoloader
```

This:
- Excludes development dependencies
- Uses distribution packages (faster)
- Optimizes the autoloader for production

Install Node.js dependencies:

```bash
npm ci --production
```

#### 2. Build Assets

Build documentation:

```bash
npm run doc
```

Minify SVG assets:

```bash
npm run minify:svg
```

#### 3. Create Deployment Package

The build script creates a compressed tarball excluding:
- `.git*` files
- `node_modules`
- `tests`
- `.github`
- `cache` contents
- Log files
- Environment files
- Local configuration

```bash
tar -czf build/mediawiki-YYYYMMDD-HHMMSS.tar.gz \
  --exclude='.git*' \
  --exclude='node_modules' \
  --exclude='tests' \
  .
```

#### 4. Generate Build Manifest

Creates `build/manifest.json` with:

```json
{
  "build_date": "2024-01-02T12:00:00Z",
  "git_commit": "abc123...",
  "git_branch": "main",
  "package": "mediawiki-20240102-120000.tar.gz",
  "php_version": "8.2.0",
  "node_version": "v18.0.0"
}
```

### Build Output

After a successful build:

```
build/
├── mediawiki-20240102-120000.tar.gz  # ~50-100MB
└── manifest.json                      # Build metadata
```

## Build Customization

### Modifying the Build Script

Edit `scripts/build.sh` to customize:

#### Add Custom Build Steps

```bash
# After build_assets() function
build_custom_assets() {
    echo "Building custom assets..."
    # Your custom build commands
    npm run custom-build
    echo -e "${GREEN}✓${NC} Custom assets built"
    echo ""
}
```

#### Exclude Additional Files

```bash
EXCLUDE_PATTERNS=(
    ".git*"
    "node_modules"
    "tests"
    # Add your patterns
    "*.log"
    "tmp/*"
    "vendor-backup"
)
```

#### Change Package Naming

```bash
PACKAGE_NAME="mediawiki-v${VERSION}-$(date +%Y%m%d).tar.gz"
```

### Environment-Specific Builds

Create build variants:

```bash
# Development build
composer install  # includes dev dependencies
npm install

# Production build  
composer install --no-dev --optimize-autoloader
npm ci --production

# Minimal build
composer install --no-dev --no-scripts --optimize-autoloader
```

## Build Automation

### Local Automation

Use the Makefile for common workflows:

```bash
# Full build with tests
make test && make build

# Quick build (skip tests)
make build

# Build and deploy
make build && make deploy DEPLOY_ENV=staging
```

### CI/CD Automation

The `.github/workflows/ci.yml` automatically:
- Runs on every push to main/master
- Tests code with linters
- Runs unit tests
- Builds deployment packages
- Uploads build artifacts

### Makefile Targets

Available build-related targets:

```bash
make build          # Full build process
make build-assets   # Build frontend assets only
make build-docs     # Build documentation only
make package        # Create deployment package
make clean          # Clean build artifacts
```

## Continuous Integration

### GitHub Actions CI

The CI workflow (`.github/workflows/ci.yml`) includes:

#### PHP Linting
- PHP syntax validation
- Composer validation
- PHP CodeSniffer checks

#### JavaScript Linting
- ESLint checks
- Stylelint for CSS
- Grunt tasks

#### Unit Tests
- PHPUnit tests (multiple PHP versions)
- Jest tests for JavaScript
- Coverage reporting

#### Security Scanning
- Dependency vulnerability checks
- Composer security checker

#### Docker Build Test
- Validates docker-compose.yml
- Tests container configuration

### CD Workflow

The CD workflow (`.github/workflows/cd.yml`) handles:

#### Build Stage
- Checkout code
- Install dependencies
- Build assets
- Create deployment package
- Upload artifacts

#### Deploy Stage
- Download build artifacts
- Deploy to staging/production
- Run post-deployment tasks
- Health checks

### Local CI Testing

Test CI workflows locally:

```bash
# Run linters
make lint

# Run tests
make test

# Run security checks
composer audit
npm audit
```

## Build Performance

### Optimization Tips

1. **Use Caching**
   ```bash
   # Cache Composer dependencies
   composer install --prefer-dist
   
   # Cache npm dependencies
   npm ci
   ```

2. **Parallel Builds**
   ```bash
   # Use multiple CPU cores
   composer install --optimize-autoloader
   npm ci --prefer-offline
   ```

3. **Skip Unnecessary Steps**
   ```bash
   # Skip dev dependencies
   composer install --no-dev
   
   # Skip optional scripts
   composer install --no-scripts
   ```

### Build Time Expectations

- **Initial build**: 3-5 minutes
- **Incremental build**: 30-60 seconds
- **Full rebuild**: 2-3 minutes
- **CI build**: 5-10 minutes

## Troubleshooting

### Common Issues

#### Composer Memory Limit

```bash
# Increase PHP memory limit
php -d memory_limit=-1 /usr/local/bin/composer install
```

#### npm Install Failures

```bash
# Clear npm cache
npm cache clean --force
rm -rf node_modules
npm install
```

#### Permission Errors

```bash
# Fix ownership
chown -R $USER:$USER .

# Fix permissions
chmod -R 755 scripts/
```

#### Missing Dependencies

```bash
# Install build dependencies
sudo apt-get install php-cli php-intl php-mbstring
sudo apt-get install nodejs npm
```

### Build Verification

Verify the build:

```bash
# Check package contents
tar -tzf build/mediawiki-*.tar.gz | head -20

# Verify manifest
cat build/manifest.json

# Check package size
du -h build/mediawiki-*.tar.gz
```

### Debug Mode

Enable verbose output:

```bash
# Bash debug mode
bash -x scripts/build.sh

# Composer verbose
composer install -vvv

# npm verbose
npm install --verbose
```

## Best Practices

1. **Always build from clean state**
   ```bash
   make clean
   make build
   ```

2. **Version your builds**
   - Tag releases in Git
   - Include version in package names
   - Maintain build manifests

3. **Test builds before deployment**
   - Run health checks
   - Verify package contents
   - Test in staging environment

4. **Automate builds**
   - Use CI/CD pipelines
   - Standardize build process
   - Document custom steps

5. **Monitor build times**
   - Track build duration
   - Optimize slow steps
   - Use caching effectively

## Additional Resources

- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment guide
- [DEVELOPERS.md](DEVELOPERS.md) - Development setup
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [MediaWiki Manual](https://www.mediawiki.org/wiki/Manual:Contents)

## Examples

### Complete Build Workflow

```bash
# 1. Update dependencies
make update

# 2. Run tests
make test

# 3. Build for production
make build

# 4. Verify build
bash scripts/health-check.sh

# 5. Deploy to staging
make deploy DEPLOY_ENV=staging

# 6. Test staging

# 7. Deploy to production
make deploy DEPLOY_ENV=production
```

### Docker Build

```bash
# Build Docker image
docker build -t mediawiki:latest .

# Tag for deployment
docker tag mediawiki:latest registry.example.com/mediawiki:v1.46

# Push to registry
docker push registry.example.com/mediawiki:v1.46
```

### Multi-Environment Build

```bash
#!/bin/bash
ENVIRONMENTS="dev staging production"

for env in $ENVIRONMENTS; do
    echo "Building for $env..."
    ENV=$env make build
    mv build/mediawiki-*.tar.gz build/mediawiki-$env.tar.gz
done
```

## Conclusion

This build guide provides comprehensive instructions for building MediaWiki following Wikimedia best practices. Adapt these procedures to your specific requirements while maintaining the core principles of reproducible, automated builds.
