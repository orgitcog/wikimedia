#!/bin/bash
# MediaWiki Deployment Script
# Following Wikimedia best practices for deployment automation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}MediaWiki Deployment Script${NC}"
echo "============================"
echo ""

# Configuration
DEPLOY_ENV="${1:-staging}"
BUILD_DIR="build"
DEPLOY_USER="${DEPLOY_USER:-deploy}"
BACKUP_DIR="${BACKUP_DIR:-backups}"

# Load environment-specific configuration
load_config() {
    case "$DEPLOY_ENV" in
        production|prod)
            DEPLOY_HOST="${PROD_DEPLOY_HOST:-production.example.com}"
            DEPLOY_PATH="${PROD_DEPLOY_PATH:-/var/www/mediawiki}"
            echo -e "${BLUE}Deploying to: PRODUCTION${NC}"
            ;;
        staging|stage)
            DEPLOY_HOST="${STAGING_DEPLOY_HOST:-staging.example.com}"
            DEPLOY_PATH="${STAGING_DEPLOY_PATH:-/var/www/mediawiki}"
            echo -e "${BLUE}Deploying to: STAGING${NC}"
            ;;
        *)
            echo -e "${RED}ERROR: Unknown environment '$DEPLOY_ENV'${NC}"
            echo "Usage: $0 [production|staging]"
            exit 1
            ;;
    esac
    echo ""
}

# Check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check if build exists
    if [ ! -d "$BUILD_DIR" ] || [ -z "$(ls -A $BUILD_DIR/*.tar.gz 2>/dev/null)" ]; then
        echo -e "${RED}ERROR: No build found. Run 'make build' first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓${NC} Build artifacts found"
    
    # Get latest build package
    PACKAGE=$(ls -t $BUILD_DIR/*.tar.gz | head -1)
    echo "Package: $PACKAGE"
    echo ""
}

# Pre-deployment checks
pre_deploy_checks() {
    echo "Running pre-deployment checks..."
    
    # Check git status
    if [ -d .git ]; then
        if [ -n "$(git status --porcelain)" ]; then
            echo -e "${YELLOW}WARNING: Working directory has uncommitted changes${NC}"
            read -p "Continue anyway? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi
    
    echo -e "${GREEN}✓${NC} Pre-deployment checks passed"
    echo ""
}

# Create backup
create_backup() {
    echo "Creating backup..."
    
    mkdir -p "$BACKUP_DIR"
    BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    # In a real deployment, this would backup from the remote server
    # For now, we'll create a local backup
    if [ -f LocalSettings.php ]; then
        tar -czf "$BACKUP_DIR/$BACKUP_NAME" \
            LocalSettings.php \
            images/ \
            cache/ 2>/dev/null || true
        
        echo -e "${GREEN}✓${NC} Backup created: $BACKUP_DIR/$BACKUP_NAME"
    else
        echo -e "${YELLOW}No LocalSettings.php found, skipping backup${NC}"
    fi
    
    echo ""
}

# Deploy to server
deploy() {
    echo "Deploying to $DEPLOY_ENV environment..."
    
    echo -e "${BLUE}Deployment configuration:${NC}"
    echo "  Host: $DEPLOY_HOST"
    echo "  Path: $DEPLOY_PATH"
    echo "  User: $DEPLOY_USER"
    echo "  Package: $PACKAGE"
    echo ""
    
    # In a real deployment, you would use one of these methods:
    # 
    # 1. rsync deployment:
    # rsync -avz --exclude='.git' --exclude='cache/*' \
    #   ./ $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/
    #
    # 2. scp + extract:
    # scp $PACKAGE $DEPLOY_USER@$DEPLOY_HOST:/tmp/
    # ssh $DEPLOY_USER@$DEPLOY_HOST "cd $DEPLOY_PATH && tar -xzf /tmp/$(basename $PACKAGE)"
    #
    # 3. Ansible:
    # ansible-playbook -i inventory deploy.yml --extra-vars "env=$DEPLOY_ENV"
    #
    # 4. Kubernetes:
    # kubectl apply -f k8s/$DEPLOY_ENV/
    
    echo -e "${YELLOW}NOTE: This is a template deployment script.${NC}"
    echo "Add your actual deployment commands above."
    echo ""
    
    echo -e "${GREEN}✓${NC} Deployment prepared (dry-run mode)"
    echo ""
}

# Post-deployment tasks
post_deploy() {
    echo "Running post-deployment tasks..."
    
    # In a real deployment, you would run:
    # - Database migrations
    # - Cache clearing
    # - Service restarts
    # - Health checks
    
    echo "Tasks to run on remote server:"
    echo "  1. Run database update: php maintenance/run.php update"
    echo "  2. Clear cache: rm -rf cache/*"
    echo "  3. Rebuild localization cache"
    echo "  4. Run health checks"
    echo ""
    
    echo -e "${GREEN}✓${NC} Post-deployment tasks listed"
    echo ""
}

# Health check
health_check() {
    echo "Running health checks..."
    
    # In a real deployment, you would check:
    # - HTTP response codes
    # - Database connectivity
    # - Cache availability
    # - File permissions
    
    echo "Health checks to perform:"
    echo "  1. Check HTTP response: curl -I http://$DEPLOY_HOST"
    echo "  2. Check database: php maintenance/run.php showJobs"
    echo "  3. Verify configuration"
    echo ""
    
    echo -e "${GREEN}✓${NC} Health check template ready"
    echo ""
}

# Rollback function
rollback() {
    echo -e "${YELLOW}Rollback functionality${NC}"
    echo "To rollback, restore from backup:"
    echo "  Latest backup: $(ls -t $BACKUP_DIR/*.tar.gz 2>/dev/null | head -1)"
    echo ""
}

# Main deployment flow
main() {
    load_config
    check_prerequisites
    pre_deploy_checks
    
    # Confirmation for production
    if [[ "$DEPLOY_ENV" == "production" || "$DEPLOY_ENV" == "prod" ]]; then
        echo -e "${RED}WARNING: You are about to deploy to PRODUCTION!${NC}"
        read -p "Are you sure? Type 'deploy' to confirm: " CONFIRM
        if [ "$CONFIRM" != "deploy" ]; then
            echo "Deployment cancelled."
            exit 0
        fi
        echo ""
    fi
    
    create_backup
    deploy
    post_deploy
    health_check
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Deployment Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Environment: $DEPLOY_ENV"
    echo "Host: $DEPLOY_HOST"
    echo ""
    echo "Next steps:"
    echo "  1. Verify the deployment at http://$DEPLOY_HOST"
    echo "  2. Monitor logs for errors"
    echo "  3. Test critical functionality"
    echo ""
    echo "If issues occur, rollback with:"
    echo "  bash scripts/deploy.sh rollback"
    echo ""
}

# Handle rollback command
if [ "$1" == "rollback" ]; then
    rollback
    exit 0
fi

main "$@"
