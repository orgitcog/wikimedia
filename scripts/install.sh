#!/bin/bash
# MediaWiki Installation Script
# Following Wikimedia best practices for automated installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}MediaWiki Installation Script${NC}"
echo "================================"
echo ""

# Check requirements
check_requirements() {
    echo "Checking requirements..."
    
    # Check PHP
    if ! command -v php &> /dev/null; then
        echo -e "${RED}ERROR: PHP is not installed${NC}"
        exit 1
    fi
    
    PHP_VERSION=$(php -r "echo PHP_VERSION;")
    echo -e "${GREEN}✓${NC} PHP $PHP_VERSION found"
    
    # Check Composer
    if ! command -v composer &> /dev/null; then
        echo -e "${RED}ERROR: Composer is not installed${NC}"
        echo "Install from: https://getcomposer.org/"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} Composer found"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}WARNING: Node.js is not installed${NC}"
        echo "Some features may not work. Install from: https://nodejs.org/"
    else
        NODE_VERSION=$(node --version)
        echo -e "${GREEN}✓${NC} Node.js $NODE_VERSION found"
    fi
    
    echo ""
}

# Install PHP dependencies
install_php_deps() {
    echo "Installing PHP dependencies..."
    composer install --no-interaction
    echo -e "${GREEN}✓${NC} PHP dependencies installed"
    echo ""
}

# Install Node.js dependencies
install_node_deps() {
    if command -v npm &> /dev/null; then
        echo "Installing Node.js dependencies..."
        npm install
        echo -e "${GREEN}✓${NC} Node.js dependencies installed"
        echo ""
    else
        echo -e "${YELLOW}Skipping Node.js dependencies (npm not found)${NC}"
        echo ""
    fi
}

# Setup environment file
setup_env() {
    if [ ! -f .env ]; then
        echo "Creating .env file..."
        cat > .env << EOF
MW_SCRIPT_PATH=/w
MW_SERVER=http://localhost:8080
MW_DOCKER_PORT=8080
MEDIAWIKI_USER=Admin
MEDIAWIKI_PASSWORD=dockerpass
XDEBUG_CONFIG=
XDEBUG_ENABLE=true
XHPROF_ENABLE=true
MW_DOCKER_UID=$(id -u)
MW_DOCKER_GID=$(id -g)
EOF
        echo -e "${GREEN}✓${NC} .env file created"
        echo ""
    else
        echo -e "${YELLOW}.env file already exists, skipping${NC}"
        echo ""
    fi
}

# Initialize database
init_database() {
    echo "Initializing database..."
    
    if [ ! -f LocalSettings.php ]; then
        echo "Running MediaWiki installer..."
        composer run-script mw-install:sqlite
        echo -e "${GREEN}✓${NC} Database initialized"
        echo ""
    else
        echo -e "${YELLOW}LocalSettings.php exists, skipping database initialization${NC}"
        echo "To reinstall, remove LocalSettings.php and run again"
        echo ""
    fi
}

# Main installation flow
main() {
    check_requirements
    install_php_deps
    install_node_deps
    setup_env
    init_database
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "To start the development server, run:"
    echo "  make serve"
    echo "  OR"
    echo "  composer run-script serve"
    echo ""
    echo "Then access MediaWiki at: http://localhost:4000"
    echo ""
    echo "For Docker-based development:"
    echo "  make docker-up"
    echo "  make docker-install"
    echo ""
}

main "$@"
