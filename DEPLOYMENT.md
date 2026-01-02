# Deployment Guide

This guide covers deployment best practices for MediaWiki following Wikimedia standards.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Deployment](#quick-deployment)
- [Build Process](#build-process)
- [Deployment Methods](#deployment-methods)
- [Environment Configuration](#environment-configuration)
- [Health Checks](#health-checks)
- [Rollback Procedures](#rollback-procedures)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before deploying MediaWiki, ensure you have:

- PHP 8.2 or higher with required extensions
- Composer installed
- Node.js 18+ and npm (for asset building)
- Database server (MariaDB, MySQL, PostgreSQL, or SQLite)
- Web server (Apache or Nginx)
- SSH access to deployment servers (for remote deployments)

## Quick Deployment

### Using Make

The simplest way to deploy:

```bash
# Build the deployment package
make build

# Deploy to staging
make deploy DEPLOY_ENV=staging

# Deploy to production (requires confirmation)
make deploy DEPLOY_ENV=production
```

### Using Scripts Directly

```bash
# 1. Build
bash scripts/build.sh

# 2. Deploy
bash scripts/deploy.sh staging
# or
bash scripts/deploy.sh production
```

## Build Process

The build process creates an optimized deployment package:

1. **Clean previous builds**: Removes old build artifacts
2. **Install production dependencies**: 
   - PHP dependencies with `composer install --no-dev`
   - Optimized autoloader
3. **Build assets**:
   - Generate documentation
   - Minify SVG assets
   - Compile frontend resources
4. **Create deployment package**: 
   - Excludes development files
   - Creates compressed tarball
5. **Generate manifest**: Build metadata with Git info

### Build Artifacts

After building, you'll find:

```
build/
├── mediawiki-YYYYMMDD-HHMMSS.tar.gz  # Deployment package
└── manifest.json                      # Build metadata
```

### Customizing the Build

Edit `scripts/build.sh` to customize:
- Excluded files/directories
- Asset compilation steps
- Package naming conventions
- Manifest contents

## Deployment Methods

### 1. rsync Deployment

Best for traditional server deployments:

```bash
# In scripts/deploy.sh, uncomment:
rsync -avz --exclude='.git' --exclude='cache/*' \
  ./ $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/
```

### 2. Package Deployment

Deploy pre-built packages:

```bash
# In scripts/deploy.sh, uncomment:
scp $PACKAGE $DEPLOY_USER@$DEPLOY_HOST:/tmp/
ssh $DEPLOY_USER@$DEPLOY_HOST "cd $DEPLOY_PATH && tar -xzf /tmp/$(basename $PACKAGE)"
```

### 3. Container Deployment

For Docker/Kubernetes:

```bash
# Build container image
docker build -t mediawiki:latest .

# Push to registry
docker push your-registry/mediawiki:latest

# Deploy with Kubernetes
kubectl apply -f k8s/production/
```

### 4. Ansible Deployment

For infrastructure as code:

```bash
ansible-playbook -i inventory/production deploy.yml
```

## Environment Configuration

### Staging Environment

Set environment variables in your CI/CD or `.env`:

```bash
STAGING_DEPLOY_HOST=staging.example.com
STAGING_DEPLOY_PATH=/var/www/mediawiki
DEPLOY_USER=deploy
```

### Production Environment

```bash
PROD_DEPLOY_HOST=production.example.com
PROD_DEPLOY_PATH=/var/www/mediawiki
DEPLOY_USER=deploy
```

### LocalSettings.php

Important configuration considerations:

```php
// In LocalSettings.php
$wgDBserver = "localhost";
$wgDBname = "mediawiki";
$wgDBuser = "wiki_user";
$wgDBpassword = "secure_password";

// Security
$wgSecretKey = "...";
$wgUpgradeKey = "...";

// Cache configuration
$wgMainCacheType = CACHE_REDIS;
$wgSessionCacheType = CACHE_REDIS;
```

**Never commit LocalSettings.php to version control!**

## Post-Deployment Tasks

After deploying, run these maintenance tasks on the server:

### 1. Update Database Schema

```bash
php maintenance/run.php update --quick
```

### 2. Rebuild Localization Cache

```bash
php maintenance/run.php rebuildLocalisationCache
```

### 3. Clear Caches

```bash
rm -rf cache/*
php maintenance/run.php purgeCache
```

### 4. Run Jobs

```bash
php maintenance/run.php runJobs
```

## Health Checks

### Automated Health Check

```bash
bash scripts/health-check.sh
```

This checks:
- HTTP response
- PHP configuration
- Required extensions
- File permissions
- Database connectivity
- Dependencies

### Manual Verification

1. **Check website**: Visit your MediaWiki URL
2. **Check logs**: Review error logs for issues
3. **Test functionality**: 
   - Create/edit pages
   - Upload files
   - Search
   - User authentication

### Monitoring

Set up monitoring for:
- HTTP uptime
- Response times
- Error rates
- Database performance
- Disk space
- Memory usage

## Rollback Procedures

### Automatic Backup

The deployment script creates backups before each deployment:

```
backups/
└── backup-YYYYMMDD-HHMMSS.tar.gz
```

### Rolling Back

1. **Stop the application** (if necessary)
2. **Restore from backup**:
   ```bash
   cd /var/www/mediawiki
   tar -xzf /path/to/backup-YYYYMMDD-HHMMSS.tar.gz
   ```
3. **Restore database** (if schema changed):
   ```bash
   mysql mediawiki < backup-database.sql
   ```
4. **Clear caches**
5. **Restart services**

### Emergency Rollback

Use the rollback helper:

```bash
bash scripts/deploy.sh rollback
```

## Deployment Checklist

Before deploying to production:

- [ ] All tests passing in CI
- [ ] Code reviewed and approved
- [ ] Database migrations tested
- [ ] Backup completed
- [ ] Maintenance window scheduled
- [ ] Team notified
- [ ] Rollback plan ready
- [ ] Monitoring enabled

During deployment:

- [ ] Deploy to staging first
- [ ] Test on staging
- [ ] Deploy to production
- [ ] Run post-deployment tasks
- [ ] Health checks passing
- [ ] Monitor for errors

After deployment:

- [ ] Verify functionality
- [ ] Check logs
- [ ] Monitor performance
- [ ] Update documentation
- [ ] Notify team of completion

## Troubleshooting

### Common Issues

#### Permission Errors

```bash
# Fix directory permissions
chown -R www-data:www-data /var/www/mediawiki
chmod -R 755 /var/www/mediawiki
chmod -R 775 /var/www/mediawiki/cache
chmod -R 775 /var/www/mediawiki/images
```

#### Database Connection Failed

- Check database credentials in LocalSettings.php
- Verify database server is running
- Check firewall rules
- Test connection: `php maintenance/run.php showJobs`

#### Missing Dependencies

```bash
# Reinstall dependencies
composer install --no-dev
npm install --production
```

#### Cache Issues

```bash
# Clear all caches
rm -rf cache/*
php maintenance/run.php purgeCache
```

### Getting Help

- MediaWiki Documentation: https://www.mediawiki.org/
- Deployment Guide: https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki
- Wikimedia IRC: #mediawiki on Libera Chat
- Mailing Lists: https://lists.wikimedia.org/

## Best Practices

1. **Always deploy to staging first**
2. **Run database backups before deploying**
3. **Use version tags for production deployments**
4. **Monitor deployments actively**
5. **Have a rollback plan ready**
6. **Document configuration changes**
7. **Keep secrets out of version control**
8. **Test post-deployment tasks in staging**
9. **Use deployment windows for large changes**
10. **Coordinate with team members**

## Advanced Topics

### Blue-Green Deployment

Set up two identical environments and switch traffic:

```bash
# Deploy to green environment
deploy-to green

# Test green environment
test-environment green

# Switch traffic to green
switch-traffic green

# Keep blue as fallback
```

### Canary Deployment

Gradually roll out to users:

```bash
# Deploy to 10% of servers
deploy-canary 10%

# Monitor for issues
monitor-metrics

# Increase to 50%
deploy-canary 50%

# Full rollout
deploy-canary 100%
```

### GitOps Workflow

Use Git as source of truth:

```bash
# Make changes in Git
git commit -m "Update configuration"
git push

# Automated deployment via CI/CD
# GitHub Actions deploys automatically
```

## Security Considerations

- Keep MediaWiki and extensions updated
- Use HTTPS for all deployments
- Implement proper file permissions
- Enable security headers
- Use secrets management (e.g., HashiCorp Vault)
- Regular security audits
- Monitor for vulnerabilities
- Implement rate limiting
- Use Web Application Firewall (WAF)

## Conclusion

This deployment guide provides a foundation for deploying MediaWiki following Wikimedia best practices. Adapt these procedures to your specific infrastructure and requirements.

For more information, see:
- [DEVELOPERS.md](DEVELOPERS.md) - Development environment setup
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [INSTALL](INSTALL) - Installation instructions
