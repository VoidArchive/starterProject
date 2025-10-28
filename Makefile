.PHONY: dev api web build test

# Load .env if present and export its vars
ifneq (,$(wildcard .env))
include .env
export $(shell sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' .env)
endif

# Development
dev:
	@echo "🚀 Starting both API and Web servers..."
	@echo "   API: Hot reload enabled with Air"
	@echo "   Web: Hot reload enabled with Vite"
	@echo "   Logs will be prefixed with [API] and [WEB]"
	@echo ""
	@trap 'kill 0' INT; \
	(cd api && air 2>&1 | sed -u 's/^/\x1b[36m[API]\x1b[0m /') & \
	(cd web && pnpm dev 2>&1 | sed -u 's/^/\x1b[35m[WEB]\x1b[0m /') & \
	wait

api:
	@echo "🚀 Starting API server with hot reload..."
	@cd api && air

api-no-reload:
	@echo "🚀 Starting API server (no hot reload)..."
	@cd api && go run cmd/api/main.go

web:
	@echo "🌐 Starting Web dev server..."
	@cd web && pnpm dev

# Build
build:
	@echo "🔨 Building API..."
	@cd api && go build -o bin/api ./cmd/api/main.go
	@echo "✓ API built: api/bin/api"
	@echo "🔨 Building Web..."
	@cd web && pnpm build
	@echo "✓ Web built: web/.svelte-kit/output"

# Run backend tests
test:
	@echo "🧪 Running API tests..."
	@cd api && go test ./... -v
