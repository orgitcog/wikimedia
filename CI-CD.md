# CI/CD Guide

Comprehensive guide to Continuous Integration and Continuous Deployment for MediaWiki.

## Table of Contents

- [Overview](#overview)
- [CI Workflow](#ci-workflow)
- [CD Workflow](#cd-workflow)
- [GitHub Actions Setup](#github-actions-setup)
- [Environment Configuration](#environment-configuration)
- [Secrets Management](#secrets-management)
- [Best Practices](#best-practices)

## Overview

This repository implements automated CI/CD using GitHub Actions, following Wikimedia best practices:

- **Continuous Integration (CI)**: Automated testing on every push/PR
- **Continuous Deployment (CD)**: Automated deployment to staging/production
- **Security Scanning**: Vulnerability checks on dependencies
- **Multi-Version Testing**: Test across multiple PHP versions

## CI Workflow

### Trigger Events

The CI workflow (`.github/workflows/ci.yml`) runs on:

```yaml
on:
  push:
    branches: [ main, master, copilot/** ]
  pull_request:
    branches: [ main, master ]
```

### Jobs

#### 1. PHP Linting

```yaml
- Validate composer.json
- Install dependencies (with caching)
- Run PHP lint
- Run PHP CodeSniffer
```

**Purpose**: Catch syntax errors and style violations early.

#### 2. JavaScript Linting

```yaml
- Setup Node.js
- Install dependencies (with caching)
- Run ESLint
- Run Stylelint
```

**Purpose**: Ensure JavaScript and CSS code quality.

#### 3. PHP Unit Tests

```yaml
- Test on PHP 8.2 and 8.3
- Install dependencies
- Run PHPUnit tests
```

**Purpose**: Verify functionality across PHP versions.

#### 4. JavaScript Tests

```yaml
- Setup Node.js
- Install dependencies
- Run Jest tests
```

**Purpose**: Validate JavaScript functionality.

#### 5. Docker Build Test

```yaml
- Setup Docker Buildx
- Validate docker-compose.yml
```

**Purpose**: Ensure Docker configuration is valid.

#### 6. Security Scanning

```yaml
- Install dependencies
- Run security checker
```

**Purpose**: Detect vulnerabilities in dependencies.

### Optimization Features

- **Dependency Caching**: Speeds up builds
- **Parallel Jobs**: Run tests concurrently
- **Matrix Strategy**: Test multiple PHP versions
- **Fail Fast**: Stop on critical errors

## CD Workflow

### Trigger Events

The CD workflow (`.github/workflows/cd.yml`) runs on:

```yaml
on:
  push:
    tags:
      - 'v*.*.*'      # Version tags
      - 'REL*'        # Release tags
  workflow_dispatch:  # Manual trigger
```

### Jobs

#### 1. Build

```yaml
- Checkout code
- Setup PHP and Node.js
- Install production dependencies
- Build assets
- Create deployment package
- Upload artifact
```

**Output**: `mediawiki-build-{sha}.tar.gz`

#### 2. Deploy to Staging

```yaml
- Download build artifact
- Deploy to staging environment
- Run health checks
```

**Trigger**: On version tags or manual deployment to staging

#### 3. Deploy to Production

```yaml
- Download build artifact
- Deploy to production environment
- Run health checks
- Send notifications
```

**Trigger**: Manual deployment only, requires approval

### Environment Protection

Production deployments require:
- Manual approval
- Confirmation input
- Review from authorized users

## GitHub Actions Setup

### Repository Configuration

1. **Enable GitHub Actions**
   - Go to Settings > Actions > General
   - Allow all actions and reusable workflows

2. **Set up Environments**
   - Go to Settings > Environments
   - Create `staging` environment
   - Create `production` environment
   - Add protection rules to production

3. **Configure Secrets**
   - Go to Settings > Secrets and variables > Actions
   - Add required secrets (see below)

### Required Secrets

#### For Deployment

```bash
# SSH deployment
DEPLOY_SSH_KEY          # SSH private key
DEPLOY_HOST_STAGING     # Staging server hostname
DEPLOY_HOST_PRODUCTION  # Production server hostname
DEPLOY_USER             # Deployment user

# Database (if needed)
DB_PASSWORD_STAGING
DB_PASSWORD_PRODUCTION
```

#### For Notifications (Optional)

```bash
SLACK_WEBHOOK_URL       # Slack notifications
EMAIL_NOTIFICATION      # Email notifications
```

### Environment Variables

Set in `.github/workflows/` or repository variables:

```yaml
env:
  PHP_VERSION: '8.2'
  NODE_VERSION: '18'
  COMPOSER_CACHE_DIR: ~/.composer/cache
```

## Environment Configuration

### Staging Environment

Configure in GitHub:
1. Go to Settings > Environments > staging
2. Set environment variables:
   ```
   STAGING_URL=https://staging.example.com
   ```
3. No approval required

### Production Environment

Configure in GitHub:
1. Go to Settings > Environments > production
2. Set environment variables:
   ```
   PRODUCTION_URL=https://example.com
   ```
3. Add required reviewers
4. Set deployment branches to `main` only

## Secrets Management

### Adding Secrets

Via GitHub UI:
1. Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Add name and value
4. Save

Via GitHub CLI:
```bash
gh secret set DEPLOY_SSH_KEY < ~/.ssh/deploy_key
gh secret set DB_PASSWORD_PRODUCTION
```

### Using Secrets in Workflows

```yaml
steps:
  - name: Deploy
    env:
      SSH_KEY: ${{ secrets.DEPLOY_SSH_KEY }}
      DB_PASS: ${{ secrets.DB_PASSWORD_PRODUCTION }}
    run: |
      echo "$SSH_KEY" > ~/.ssh/id_rsa
      chmod 600 ~/.ssh/id_rsa
```

### Security Best Practices

1. **Never commit secrets** to the repository
2. **Use environment-specific secrets**
3. **Rotate secrets regularly**
4. **Limit secret access** to necessary jobs
5. **Audit secret usage** regularly

## Workflow Customization

### Modify CI Workflow

Edit `.github/workflows/ci.yml`:

```yaml
# Add new job
my-custom-job:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Custom step
      run: echo "Custom command"
```

### Modify CD Workflow

Edit `.github/workflows/cd.yml`:

```yaml
# Add deployment step
- name: Custom deployment
  run: |
    # Your deployment commands
    rsync -avz . user@server:/path/
```

### Add New Workflow

Create `.github/workflows/my-workflow.yml`:

```yaml
name: My Workflow
on:
  schedule:
    - cron: '0 0 * * *'  # Daily
jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Daily task"
```

## Monitoring and Debugging

### View Workflow Runs

1. Go to Actions tab
2. Select workflow
3. Click on run to see details

### Debug Failed Workflows

```yaml
# Enable debug logging
- name: Debug info
  run: |
    echo "::debug::Debug message"
    echo "::warning::Warning message"
    echo "::error::Error message"
```

### Re-run Failed Jobs

1. Go to failed workflow run
2. Click "Re-run jobs"
3. Select "Re-run failed jobs"

## Best Practices

### Workflow Design

1. **Keep workflows simple**: One purpose per workflow
2. **Use caching**: Speed up builds
3. **Fail fast**: Stop on critical errors
4. **Use matrices**: Test multiple versions
5. **Parallelize**: Run independent jobs concurrently

### Security

1. **Pin action versions**: Use specific versions
2. **Limit permissions**: Use minimal required permissions
3. **Scan dependencies**: Regular security checks
4. **Audit logs**: Review workflow runs
5. **Protected branches**: Require status checks

### Performance

1. **Cache dependencies**: Reduce install time
2. **Use artifacts**: Share data between jobs
3. **Concurrent jobs**: Maximize parallelization
4. **Optimize checkout**: Use shallow clones
5. **Self-hosted runners**: For faster builds

### Maintenance

1. **Update actions regularly**: Keep dependencies current
2. **Monitor workflow duration**: Optimize slow steps
3. **Clean up old runs**: Remove obsolete artifacts
4. **Document changes**: Update this guide
5. **Test workflows**: Use `workflow_dispatch` for testing

## Integration with Other Tools

### Slack Notifications

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Email Notifications

```yaml
- name: Send email
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 587
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
```

### Code Coverage

```yaml
- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage.xml
    fail_ci_if_error: true
```

## Troubleshooting

### Common Issues

#### Workflow Not Triggering

- Check trigger conditions
- Verify branch names
- Review GitHub Actions settings

#### Permission Errors

```yaml
permissions:
  contents: read
  packages: write
```

#### Cache Issues

```bash
# Clear cache
gh cache delete --all
```

#### Timeout Errors

```yaml
jobs:
  my-job:
    timeout-minutes: 60  # Increase timeout
```

## Examples

### Complete CI/CD Pipeline

1. **Developer pushes code**
2. **CI runs automatically**
   - Lint code
   - Run tests
   - Build application
3. **If tests pass**
   - Merge to main
   - Tag release
4. **CD triggers**
   - Build deployment package
   - Deploy to staging
   - Run health checks
5. **Manual approval**
   - Review staging
   - Approve production
6. **Deploy to production**
   - Deploy package
   - Run migrations
   - Health checks
   - Send notifications

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Action Marketplace](https://github.com/marketplace?type=actions)
- [MediaWiki CI/CD](https://www.mediawiki.org/wiki/Continuous_integration)

## Conclusion

This CI/CD setup provides automated testing and deployment for MediaWiki, following industry best practices and Wikimedia standards. Customize workflows to match your specific requirements while maintaining security and reliability.
