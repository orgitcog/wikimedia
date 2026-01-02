#!/bin/bash
# MediaWiki Health Check Script
# Verify deployment and system health

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}MediaWiki Health Check${NC}"
echo "======================"
echo ""

ERRORS=0
WARNINGS=0

# Check HTTP response
check_http() {
    echo "Checking HTTP response..."
    
    URL="${MW_SERVER:-http://localhost:8080}"
    
    if command -v curl &> /dev/null; then
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || echo "000")
        
        if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "302" ]; then
            echo -e "${GREEN}✓${NC} HTTP check passed (status: $HTTP_CODE)"
        else
            echo -e "${RED}✗${NC} HTTP check failed (status: $HTTP_CODE)"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "${YELLOW}⚠${NC} curl not found, skipping HTTP check"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    echo ""
}

# Check PHP version
check_php() {
    echo "Checking PHP..."
    
    if command -v php &> /dev/null; then
        PHP_VERSION=$(php -r "echo PHP_VERSION;")
        echo -e "${GREEN}✓${NC} PHP version: $PHP_VERSION"
        
        # Check required extensions
        REQUIRED_EXTS=("ctype" "dom" "fileinfo" "iconv" "intl" "json" "mbstring" "xml")
        for ext in "${REQUIRED_EXTS[@]}"; do
            if php -m | grep -q "^$ext$"; then
                echo -e "${GREEN}  ✓${NC} Extension $ext loaded"
            else
                echo -e "${RED}  ✗${NC} Extension $ext NOT loaded"
                ERRORS=$((ERRORS + 1))
            fi
        done
    else
        echo -e "${RED}✗${NC} PHP not found"
        ERRORS=$((ERRORS + 1))
    fi
    
    echo ""
}

# Check file permissions
check_permissions() {
    echo "Checking file permissions..."
    
    WRITABLE_DIRS=("cache" "images")
    
    for dir in "${WRITABLE_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            if [ -w "$dir" ]; then
                echo -e "${GREEN}✓${NC} Directory $dir is writable"
            else
                echo -e "${RED}✗${NC} Directory $dir is NOT writable"
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo -e "${YELLOW}⚠${NC} Directory $dir does not exist"
            WARNINGS=$((WARNINGS + 1))
        fi
    done
    
    echo ""
}

# Check configuration
check_config() {
    echo "Checking configuration..."
    
    if [ -f "LocalSettings.php" ]; then
        echo -e "${GREEN}✓${NC} LocalSettings.php exists"
    else
        echo -e "${YELLOW}⚠${NC} LocalSettings.php not found (needs installation)"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    if [ -f "composer.json" ]; then
        echo -e "${GREEN}✓${NC} composer.json exists"
    else
        echo -e "${RED}✗${NC} composer.json not found"
        ERRORS=$((ERRORS + 1))
    fi
    
    echo ""
}

# Check dependencies
check_dependencies() {
    echo "Checking dependencies..."
    
    if [ -d "vendor" ]; then
        echo -e "${GREEN}✓${NC} Composer dependencies installed"
    else
        echo -e "${RED}✗${NC} Composer dependencies NOT installed"
        ERRORS=$((ERRORS + 1))
    fi
    
    if [ -d "node_modules" ]; then
        echo -e "${GREEN}✓${NC} Node.js dependencies installed"
    else
        echo -e "${YELLOW}⚠${NC} Node.js dependencies NOT installed"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    echo ""
}

# Check database
check_database() {
    echo "Checking database..."
    
    if [ -f "LocalSettings.php" ]; then
        # Try to get database info from maintenance script
        if php maintenance/run.php showJobs &>/dev/null; then
            echo -e "${GREEN}✓${NC} Database connection successful"
        else
            echo -e "${YELLOW}⚠${NC} Could not verify database connection"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo -e "${YELLOW}⚠${NC} Database check skipped (not installed)"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    echo ""
}

# Summary
print_summary() {
    echo "========================================="
    echo "Health Check Summary"
    echo "========================================="
    
    if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}All checks passed!${NC}"
        exit 0
    elif [ $ERRORS -eq 0 ]; then
        echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
        exit 0
    else
        echo -e "${RED}Errors: $ERRORS${NC}"
        echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
        exit 1
    fi
}

# Main
main() {
    check_php
    check_config
    check_dependencies
    check_permissions
    check_database
    check_http
    print_summary
}

main "$@"
