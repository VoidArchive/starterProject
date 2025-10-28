# BAZI Scripts

Utility scripts for the BAZI casino platform monorepo.

## Available Scripts

### `build-size.sh`

Analyzes build sizes for both frontend and backend.

**Usage:**
```bash
./scripts/build-size.sh
# or
make build-size
```

**Output:**
- Frontend: SvelteKit build size, node_modules, production bundle
- Backend: Go binary size (debug & optimized), SQLC generated code
- Total: Repository size with and without dependencies

**What it measures:**

| Metric | Current Size | Notes |
|--------|--------------|-------|
| Frontend Production | ~84 KB | Cloudflare Workers bundle |
| Frontend node_modules | ~319 MB | Dev dependencies |
| Backend SQLC | ~202 KB | Generated Go code (12 files) |
| Backend Binary | TBD | Will show after main.go created |
| Total (no deps) | ~1 MB | Source code only |

## Tips for Size Optimization

### Frontend (SvelteKit)
- ✅ Already using SvelteKit 5 (smaller than React)
- ✅ Cloudflare adapter (optimized for edge)
- 🔄 Add `vite-bundle-visualizer` to analyze bundles
- 🔄 Use dynamic imports for heavy components
- 🔄 Optimize images with `@sveltejs/enhanced-img`

### Backend (Go)
- ✅ Use `-ldflags="-s -w"` for production builds (removes debug info)
- ✅ Use UPX compression for even smaller binaries
- 🔄 Build with `CGO_ENABLED=0` for static binaries
- 🔄 Use multi-stage Docker builds

**Example optimized Go build:**
```bash
CGO_ENABLED=0 GOOS=linux go build -a \
  -ldflags='-s -w -extldflags "-static"' \
  -o bazi-api cmd/api/main.go
```

**Size comparison:**
- Debug build: ~8-12 MB
- Optimized: ~5-7 MB
- With UPX: ~2-3 MB

## Docker Build Sizes

**Frontend (Cloudflare Workers):**
No Docker needed - deploys directly to Cloudflare edge network.

**Backend (Go API):**
```dockerfile
FROM golang:1.23-alpine AS builder
# ... build steps ...
FROM scratch
COPY --from=builder /app/bazi-api /bazi-api
# Final image: ~8-10 MB
```

## Monitoring Build Size Over Time

Track build size in CI/CD:

```yaml
# .github/workflows/build-check.yml
- name: Check build size
  run: |
    make build-size
    # Fail if backend binary > 15MB
    # Fail if frontend bundle > 500KB
```

## Adding New Scripts

1. Create script in `scripts/` directory
2. Make executable: `chmod +x scripts/your-script.sh`
3. Add to Makefile for easy access
4. Document here in README
