#!/bin/bash
# MediaWiki Build Script
# Following Wikimedia best practices for build automation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}MediaWiki Build Script${NC}"
echo "======================"
echo ""

# Configuration
BUILD_DIR="build"
PACKAGE_NAME="mediawiki-$(date +%Y%m%d-%H%M%S).tar.gz"

# Clean previous build
clean_build() {
    echo "Cleaning previous build..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    echo -e "${GREEN}✓${NC} Build directory cleaned"
    echo ""
}

# Install production dependencies
install_prod_deps() {
    echo "Installing production dependencies..."
    
    # PHP dependencies
    composer install --no-dev --prefer-dist --no-progress --optimize-autoloader
    echo -e "${GREEN}✓${NC} PHP dependencies installed"
    
    # Node.js dependencies (if available)
    if command -v npm &> /dev/null; then
        npm ci --production
        echo -e "${GREEN}✓${NC} Node.js dependencies installed"
    fi
    
    echo ""
}

# Build assets
build_assets() {
    echo "Building assets..."
    
    if command -v npm &> /dev/null; then
        # Build documentation if available
        npm run doc || echo -e "${YELLOW}Documentation build skipped${NC}"
        
        # Minify SVG assets
        npm run minify:svg || echo -e "${YELLOW}SVG minification skipped${NC}"
        
        echo -e "${GREEN}✓${NC} Assets built"
    else
        echo -e "${YELLOW}npm not found, skipping asset build${NC}"
    fi
    
    echo ""
}

# Create deployment package
create_package() {
    echo "Creating deployment package..."
    
    # Files and directories to exclude
    EXCLUDE_PATTERNS=(
        ".git*"
        "node_modules"
        "tests"
        ".github"
        "cache/*"
        "*.log"
        ".env"
        ".env.*"
        "LocalSettings.php"
        "docker-compose.override.yml"
        "build"
        ".phan"
        ".vscode"
        ".idea"
        "*.swp"
        "*~"
    )
    
    # Build tar command with excludes
    EXCLUDE_ARGS=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        EXCLUDE_ARGS="$EXCLUDE_ARGS --exclude='$pattern'"
    done
    
    # Create tarball
    eval "tar -czf '$BUILD_DIR/$PACKAGE_NAME' $EXCLUDE_ARGS ."
    
    echo -e "${GREEN}✓${NC} Package created: $BUILD_DIR/$PACKAGE_NAME"
    
    # Show package size
    PACKAGE_SIZE=$(du -h "$BUILD_DIR/$PACKAGE_NAME" | cut -f1)
    echo "Package size: $PACKAGE_SIZE"
    echo ""
}

# Generate build manifest
generate_manifest() {
    echo "Generating build manifest..."
    
    cat > "$BUILD_DIR/manifest.json" << EOF
{
  "build_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
  "git_branch": "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')",
  "package": "$PACKAGE_NAME",
  "php_version": "$(php -r 'echo PHP_VERSION;')",
  "node_version": "$(node --version 2>/dev/null || echo 'not installed')"
}
EOF
    
    echo -e "${GREEN}✓${NC} Manifest generated"
    echo ""
}

# Verify build
verify_build() {
    echo "Verifying build..."
    
    if [ -f "$BUILD_DIR/$PACKAGE_NAME" ]; then
        echo -e "${GREEN}✓${NC} Build verification passed"
    else
        echo -e "${RED}✗${NC} Build verification failed"
        exit 1
    fi
    
    echo ""
}

# Main build flow
main() {
    clean_build
    install_prod_deps
    build_assets
    create_package
    generate_manifest
    verify_build
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Build Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Build artifacts:"
    echo "  Package: $BUILD_DIR/$PACKAGE_NAME"
    echo "  Manifest: $BUILD_DIR/manifest.json"
    echo ""
    echo "To deploy, run:"
    echo "  make deploy DEPLOY_ENV=staging"
    echo ""
}

main "$@"
