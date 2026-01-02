# Workflow Diagram

Visual representation of the build, install, and deployment workflow.

## Development Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                     Developer Workstation                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. Clone Repository                                             │
│     └─> git clone https://github.com/orgitcog/wikimedia.git    │
│                                                                   │
│  2. Install Dependencies                                         │
│     └─> make install                                            │
│         ├─> Install PHP dependencies (Composer)                 │
│         ├─> Install Node.js dependencies (npm)                  │
│         ├─> Setup environment (.env)                            │
│         └─> Initialize database                                 │
│                                                                   │
│  3. Development                                                  │
│     └─> make serve  OR  make dev                               │
│         ├─> Start development server (http://localhost:4000)    │
│         └─> OR Docker-based environment (http://localhost:8080) │
│                                                                   │
│  4. Make Changes                                                 │
│     └─> Edit code, add features, fix bugs                      │
│                                                                   │
│  5. Test Locally                                                 │
│     └─> make test                                               │
│         ├─> PHP linting (composer lint)                         │
│         ├─> JS linting (npm lint)                               │
│         ├─> PHP unit tests (phpunit)                            │
│         └─> JS tests (jest)                                     │
│                                                                   │
│  6. Commit & Push                                                │
│     └─> git add . && git commit -m "..." && git push           │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GitHub Actions CI                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Triggered on: Push / Pull Request                              │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  PHP Lint    │  │   JS Lint    │  │  PHP Tests   │         │
│  │              │  │              │  │              │         │
│  │ ✓ Syntax     │  │ ✓ ESLint     │  │ ✓ PHP 8.2    │         │
│  │ ✓ PHPCS      │  │ ✓ Stylelint  │  │ ✓ PHP 8.3    │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   JS Tests   │  │Docker Build  │  │   Security   │         │
│  │              │  │              │  │              │         │
│  │ ✓ Jest       │  │ ✓ Config     │  │ ✓ Vuln Scan  │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                   │
│  Result: ✅ All Checks Passed                                   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    Merge to Main Branch
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Release & Deployment                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. Create Release Tag                                           │
│     └─> git tag -a v1.46.1 -m "Release 1.46.1"                 │
│         git push --tags                                          │
│                                                                   │
│  OR Manual Workflow Dispatch                                     │
│     └─> GitHub Actions → CD → Run workflow                      │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   GitHub Actions CD - Build                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. Checkout Code                                                │
│  2. Setup PHP & Node.js                                          │
│  3. Install Production Dependencies                              │
│     ├─> composer install --no-dev --optimize-autoloader        │
│     └─> npm ci --production                                     │
│  4. Build Assets                                                 │
│     ├─> npm run doc                                             │
│     └─> npm run minify:svg                                      │
│  5. Create Package                                               │
│     └─> tar -czf mediawiki-build-{sha}.tar.gz                  │
│  6. Upload Artifact                                              │
│     └─> actions/upload-artifact@v4                             │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                 Deploy to Staging Environment                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. Download Build Artifact                                      │
│  2. Create Backup                                                │
│     └─> tar -czf backup-{timestamp}.tar.gz                     │
│  3. Deploy Package                                               │
│     └─> Extract and copy files to staging server               │
│  4. Post-Deployment Tasks                                        │
│     ├─> php maintenance/run.php update                         │
│     ├─> Clear caches                                            │
│     └─> Rebuild localization cache                             │
│  5. Health Checks                                                │
│     └─> bash scripts/health-check.sh                           │
│                                                                   │
│  Result: ✅ Staging Deployment Successful                       │
│  URL: https://staging.example.com                                │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Manual Testing & Approval
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│               Deploy to Production Environment                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ⚠️  Requires Manual Approval                                    │
│                                                                   │
│  1. Review Staging                                               │
│  2. Approve Production Deployment                                │
│  3. Create Backup                                                │
│  4. Deploy Package                                               │
│  5. Post-Deployment Tasks                                        │
│  6. Health Checks                                                │
│  7. Monitor & Verify                                             │
│                                                                   │
│  Result: ✅ Production Deployment Successful                    │
│  URL: https://example.com                                        │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Commands

### Installation
```bash
make install        # Full installation
make dev           # Docker development environment
```

### Development
```bash
make serve         # Start dev server
make test          # Run all tests
make lint          # Run all linters
```

### Building
```bash
make build         # Build for production
make package       # Create deployment package
```

### Deployment
```bash
make deploy DEPLOY_ENV=staging     # Deploy to staging
make deploy DEPLOY_ENV=production  # Deploy to production
```

### Health Check
```bash
bash scripts/health-check.sh       # Verify system health
```

## Deployment Safety Checklist

Before deploying to production:

- [ ] All CI tests passing
- [ ] Code reviewed and approved
- [ ] Tested in staging environment
- [ ] Database backup completed
- [ ] Team notified of deployment
- [ ] Rollback plan ready
- [ ] Monitoring enabled
- [ ] Manual approval obtained

## Rollback Procedure

If issues occur after deployment:

```bash
# 1. Stop affected services
systemctl stop apache2

# 2. Restore from backup
cd /var/www/mediawiki
tar -xzf /path/to/backup-YYYYMMDD-HHMMSS.tar.gz

# 3. Restore database (if needed)
mysql mediawiki < backup-database.sql

# 4. Clear caches
rm -rf cache/*

# 5. Restart services
systemctl start apache2

# 6. Verify health
bash scripts/health-check.sh
```

## Directory Structure

```
mediawiki/
├── .github/
│   └── workflows/
│       ├── ci.yml           # Continuous Integration
│       └── cd.yml           # Continuous Deployment
├── scripts/
│   ├── install.sh           # Installation automation
│   ├── build.sh             # Build automation
│   ├── deploy.sh            # Deployment automation
│   └── health-check.sh      # Health verification
├── Makefile                 # Command shortcuts
├── .env.example             # Configuration template
├── BUILD.md                 # Build documentation
├── DEPLOYMENT.md            # Deployment guide
├── CI-CD.md                 # CI/CD documentation
├── QUICKSTART.md            # Quick reference
├── IMPLEMENTATION.md        # Implementation summary
└── WORKFLOW.md              # This file
```

## Environment Variables

Key configuration in `.env`:

```bash
# Server
MW_SERVER=http://localhost:8080
MW_SCRIPT_PATH=/w
MW_DOCKER_PORT=8080

# Database
MW_DBTYPE=sqlite
MW_DBPATH=/var/www/html/w/cache/sqlite

# Admin
MEDIAWIKI_USER=Admin
MEDIAWIKI_PASSWORD=dockerpass

# Deployment
STAGING_DEPLOY_HOST=staging.example.com
PROD_DEPLOY_HOST=production.example.com
```

## GitHub Actions Workflows

### CI Workflow
- Triggers: Push to main/master, Pull requests
- Duration: ~5-10 minutes
- Jobs: 6 parallel jobs
- Purpose: Code quality and testing

### CD Workflow
- Triggers: Version tags, Manual dispatch
- Duration: ~10-15 minutes
- Jobs: 3 sequential jobs (build → staging → production)
- Purpose: Automated deployment

## Support & Resources

- **Documentation**: See `*.md` files in repository root
- **Issues**: https://bugs.mediawiki.org/
- **IRC**: #mediawiki on Libera Chat
- **MediaWiki Docs**: https://www.mediawiki.org/

---

This workflow provides a complete development, testing, and deployment pipeline following Wikimedia best practices and industry standards.
