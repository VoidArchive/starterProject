#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  BAZI Monorepo Build Size Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function to format bytes
format_size() {
    numfmt --to=iec-i --suffix=B --format="%.2f" $1 2>/dev/null || echo "$1 bytes"
}

echo "📦 Frontend (SvelteKit)"
echo "────────────────────────────────────────────────────"

# Check if frontend build exists
if [ -d "web/.svelte-kit" ]; then
    SVELTE_KIT_SIZE=$(du -sb web/.svelte-kit 2>/dev/null | cut -f1)
    echo -e "${BLUE}Build output:${NC}        $(format_size $SVELTE_KIT_SIZE)"
else
    echo -e "${YELLOW}⚠ No build found${NC} (run: cd web && pnpm build)"
fi

# Node modules size
if [ -d "web/node_modules" ]; then
    NODE_MODULES_SIZE=$(du -sb web/node_modules 2>/dev/null | cut -f1)
    echo -e "${BLUE}node_modules:${NC}        $(format_size $NODE_MODULES_SIZE)"
fi

# Count dependencies
if [ -f "web/package.json" ]; then
    DEV_DEPS=$(grep -c '"@' web/package.json || echo "0")
    echo -e "${BLUE}Dependencies:${NC}        ~$DEV_DEPS packages"
fi

# Production build size (if exists)
if [ -d "web/.svelte-kit/cloudflare" ]; then
    PROD_SIZE=$(du -sb web/.svelte-kit/cloudflare 2>/dev/null | cut -f1)
    echo -e "${GREEN}Production build:${NC}    $(format_size $PROD_SIZE)"
fi

echo
echo "🔧 Backend (Go)"
echo "────────────────────────────────────────────────────"

# Build Go binary
echo -e "${YELLOW}Building Go binary...${NC}"
cd api

# Check if main.go exists
if [ -f "cmd/api/main.go" ]; then
    MAIN_FILE="cmd/api/main.go"
elif [ -f "main.go" ]; then
    MAIN_FILE="main.go"
else
    echo -e "${RED}✗ No main.go found${NC}"
    MAIN_FILE=""
fi

if [ -n "$MAIN_FILE" ]; then
    # Build binary
    go build -o /tmp/bazi-backend $MAIN_FILE 2>/dev/null || echo -e "${RED}Build failed (no main.go with main package?)${NC}"

    if [ -f "/tmp/bazi-backend" ]; then
        BINARY_SIZE=$(stat -c%s /tmp/bazi-backend 2>/dev/null || stat -f%z /tmp/bazi-backend)
        echo -e "${BLUE}Binary (debug):${NC}      $(format_size $BINARY_SIZE)"

        # Optimized build
        go build -ldflags="-s -w" -o /tmp/bazi-backend-optimized $MAIN_FILE 2>/dev/null
        if [ -f "/tmp/bazi-backend-optimized" ]; then
            OPT_SIZE=$(stat -c%s /tmp/bazi-backend-optimized 2>/dev/null || stat -f%z /tmp/bazi-backend-optimized)
            echo -e "${GREEN}Binary (optimized):${NC}  $(format_size $OPT_SIZE)"
            SAVINGS=$((BINARY_SIZE - OPT_SIZE))
            echo -e "${GREEN}Size reduction:${NC}      $(format_size $SAVINGS) ($(((SAVINGS * 100) / BINARY_SIZE))%)"
        fi

        # Cleanup
        rm -f /tmp/bazi-backend /tmp/bazi-backend-optimized
    fi
else
    echo -e "${YELLOW}Skipping build - no main.go yet${NC}"
fi

# SQLC generated code size
if [ -d "sqlc" ]; then
    SQLC_SIZE=$(du -sb sqlc 2>/dev/null | cut -f1)
    SQLC_FILES=$(find sqlc -name "*.go" | wc -l)
    echo -e "${BLUE}SQLC generated:${NC}      $(format_size $SQLC_SIZE) ($SQLC_FILES files)"
fi

# Go dependencies
if [ -f "go.mod" ]; then
    GO_DEPS=$(grep -c "^\s*github.com\|^\s*golang.org" go.mod || echo "0")
    echo -e "${BLUE}Dependencies:${NC}        $GO_DEPS packages"
fi

cd ..

echo
echo "📊 Total Repository Size"
echo "────────────────────────────────────────────────────"

# Git repository size
if [ -d ".git" ]; then
    GIT_SIZE=$(du -sb .git 2>/dev/null | cut -f1)
    echo -e "${BLUE}Git history:${NC}         $(format_size $GIT_SIZE)"
fi

# Total size
TOTAL_SIZE=$(du -sb . 2>/dev/null | cut -f1)
echo -e "${BLUE}Total (with deps):${NC}   $(format_size $TOTAL_SIZE)"

# Size without dependencies
TOTAL_NO_DEPS=$TOTAL_SIZE
if [ -n "$NODE_MODULES_SIZE" ]; then
    TOTAL_NO_DEPS=$((TOTAL_NO_DEPS - NODE_MODULES_SIZE))
fi
echo -e "${GREEN}Total (no deps):${NC}     $(format_size $TOTAL_NO_DEPS)"

echo
echo "💡 Tips:"
echo "────────────────────────────────────────────────────"
echo "• Frontend: Run 'cd web && pnpm build' to create production build"
echo "• Backend:  Optimized build uses -ldflags=\"-s -w\" to strip debug info"
echo "• Docker:   Multi-stage builds can reduce final image to ~20MB"
echo "• Analyze:  Use 'pnpm --filter web exec vite-bundle-visualizer' for bundle analysis"
echo
