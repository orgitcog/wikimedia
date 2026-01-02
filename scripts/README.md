# Scripts Directory

Automation scripts for MediaWiki build, install, deploy, and maintenance operations.

## Available Scripts

### 1. install.sh (3.5KB)
**Purpose**: Automated installation and setup

**Usage**:
```bash
bash scripts/install.sh
```

**What it does**:
- ✅ Checks system requirements (PHP, Composer, Node.js)
- ✅ Installs PHP dependencies via Composer
- ✅ Installs Node.js dependencies via npm
- ✅ Creates `.env` file from template
- ✅ Initializes SQLite database
- ✅ Provides clear progress indicators

**Requirements**:
- PHP 8.2+
- Composer
- Node.js 18+ (optional but recommended)

**Example Output**:
```
MediaWiki Installation Script
================================
Checking requirements...
✓ PHP 8.3.6 found
✓ Composer found
✓ Node.js v18.0.0 found

Installing PHP dependencies...
✓ PHP dependencies installed

Installing Node.js dependencies...
✓ Node.js dependencies installed

Creating .env file...
✓ .env file created

Initializing database...
✓ Database initialized

Installation Complete!
```

---

### 2. build.sh (3.9KB)
**Purpose**: Build production-ready deployment packages

**Usage**:
```bash
bash scripts/build.sh
```

**What it does**:
- ✅ Cleans previous build artifacts
- ✅ Installs production dependencies (no dev packages)
- ✅ Builds and minifies assets
- ✅ Creates compressed deployment package
- ✅ Generates build manifest with Git info
- ✅ Verifies build integrity

**Output**:
- `build/mediawiki-YYYYMMDD-HHMMSS.tar.gz` - Deployment package
- `build/manifest.json` - Build metadata

**Excludes from package**:
- `.git*` files
- `node_modules`
- `tests`
- `.github`
- `cache/*`
- `*.log`
- `.env` files
- `LocalSettings.php`

**Example manifest.json**:
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

---

### 3. deploy.sh (6.4KB)
**Purpose**: Deploy MediaWiki to staging or production

**Usage**:
```bash
# Deploy to staging
bash scripts/deploy.sh staging

# Deploy to production
bash scripts/deploy.sh production

# Rollback
bash scripts/deploy.sh rollback
```

**What it does**:
- ✅ Loads environment-specific configuration
- ✅ Checks prerequisites (build exists)
- ✅ Runs pre-deployment checks (git status)
- ✅ Creates automatic backups
- ✅ Deploys to remote server
- ✅ Runs post-deployment tasks
- ✅ Performs health checks
- ✅ Provides rollback instructions

**Environment Variables**:
```bash
# Staging
STAGING_DEPLOY_HOST=staging.example.com
STAGING_DEPLOY_PATH=/var/www/mediawiki

# Production
PROD_DEPLOY_HOST=production.example.com
PROD_DEPLOY_PATH=/var/www/mediawiki

# Common
DEPLOY_USER=deploy
BACKUP_DIR=backups
```

**Safety Features**:
- Requires explicit confirmation for production
- Creates backup before deployment
- Validates uncommitted changes
- Provides rollback mechanism

**Deployment Methods Supported**:
- rsync (direct file sync)
- scp + tar (package transfer)
- Ansible playbooks
- Kubernetes manifests
- Custom commands

---

### 4. health-check.sh (4.7KB)
**Purpose**: Verify system health and configuration

**Usage**:
```bash
bash scripts/health-check.sh
```

**What it checks**:
- ✅ PHP version and required extensions
- ✅ Configuration files (LocalSettings.php, composer.json)
- ✅ Dependency installation (vendor/, node_modules/)
- ✅ File permissions (cache/, images/)
- ✅ Database connectivity
- ✅ HTTP endpoint response

**Exit Codes**:
- `0` - All checks passed
- `1` - Errors found

**Example Output**:
```
MediaWiki Health Check
======================

Checking PHP...
✓ PHP version: 8.3.6
  ✓ Extension ctype loaded
  ✓ Extension dom loaded
  ✓ Extension json loaded

Checking configuration...
✓ LocalSettings.php exists
✓ composer.json exists

Checking dependencies...
✓ Composer dependencies installed
✓ Node.js dependencies installed

Checking file permissions...
✓ Directory cache is writable
✓ Directory images is writable

Checking HTTP response...
✓ HTTP check passed (status: 200)

=========================================
Health Check Summary
=========================================
All checks passed!
```

---

## Integration with Makefile

All scripts can be called via Makefile:

```bash
make install        # → scripts/install.sh
make build          # → scripts/build.sh
make deploy         # → scripts/deploy.sh
make health-check   # → scripts/health-check.sh
```

## Integration with CI/CD

Scripts are used in GitHub Actions workflows:

### CI Workflow (`.github/workflows/ci.yml`)
- Uses `health-check.sh` for validation

### CD Workflow (`.github/workflows/cd.yml`)
- Uses `build.sh` for package creation
- Uses `deploy.sh` for deployment
- Uses `health-check.sh` for verification

## Customization

### Modify Build Process
Edit `scripts/build.sh`:
```bash
# Add custom build steps
build_custom_assets() {
    echo "Building custom assets..."
    npm run custom-build
}
```

### Modify Deployment
Edit `scripts/deploy.sh`:
```bash
# Change deployment method
deploy() {
    # Add your deployment commands
    rsync -avz ./ $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/
}
```

### Add Health Checks
Edit `scripts/health-check.sh`:
```bash
# Add custom checks
check_custom() {
    echo "Checking custom component..."
    # Your check logic
}
```

## Error Handling

All scripts include:
- `set -e` - Exit on error
- Color-coded output (red/green/yellow)
- Clear error messages
- Progress indicators
- Validation checks

## Dependencies

Scripts require:
- **Bash**: Version 4.0+
- **Standard Unix tools**: tar, gzip, date, etc.
- **Git**: For version information
- **PHP**: For MediaWiki operations
- **Composer**: For dependency management
- **Node.js/npm**: For asset building (optional)

## Environment Variables

Common variables used by scripts:

```bash
# Paths
MW_SERVER=http://localhost:8080
MW_SCRIPT_PATH=/w

# Deployment
DEPLOY_USER=deploy
DEPLOY_HOST=server.example.com
DEPLOY_PATH=/var/www/mediawiki
BACKUP_DIR=backups

# Colors (used internally)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
```

## Troubleshooting

### Permission Denied
```bash
chmod +x scripts/*.sh
```

### Script Not Found
```bash
# Run from repository root
cd /path/to/mediawiki
bash scripts/install.sh
```

### Errors During Execution
```bash
# Enable debug mode
bash -x scripts/install.sh
```

## Best Practices

1. **Always run from repository root**
2. **Check requirements first**: `bash scripts/health-check.sh`
3. **Test in staging before production**
4. **Review script output for errors**
5. **Keep backups of configuration files**
6. **Use environment variables for customization**
7. **Don't modify scripts directly; use environment variables**

## Security Considerations

- Scripts never store passwords in plaintext
- Use environment variables for secrets
- Always validate input parameters
- Check file permissions before operations
- Create backups before destructive operations
- Use explicit confirmations for production

## Contributing

When modifying scripts:
1. Test thoroughly in development
2. Update documentation
3. Follow existing code style
4. Add error handling
5. Include progress indicators
6. Update this README

## Support

For issues with scripts:
- Check [TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- Review script output for errors
- Enable debug mode: `bash -x script.sh`
- Open an issue on GitHub
- Contact on IRC: #mediawiki

## License

These scripts are part of MediaWiki and are licensed under GPL-2.0-or-later.

---

**Last Updated**: 2024-01-02  
**Script Version**: 1.0.0  
**Compatible with**: MediaWiki 1.46+
