# Starter Repo

This is a starter repo to work with SvelteKit and Go.

## 🚀 Quick Start

### Prerequisites
- Go 1.25+
- Node.js 18+
- pnpm
- [Air](https://github.com/air-verse/air) - for Go hot reload

```bash
# Install Air (for Go hot reload)
go install github.com/air-verse/air@latest

# Clone repository
git clone https://github.com/voidarchive/bazi.git
cd bazi

# Set up environment
cp api/.env.example api/.env
cp web/.env.example web/.env
# Edit .env files with your configuration

# Install web dependencies
cd web && pnpm install && cd ..

# Start both servers with hot reload
make dev
```

## 📁 Project Structure

```
BAZI/
├── api/                 # Go API server
│   ├── cmd/            # Application entry points
│   │   └── api/        # Main API server
│   └── internal/       # Private application code
│       ├── config/     # Configuration management
│       └── database/   # Database connection setup
│
├── web/                # SvelteKit application
│   └── src/
│       ├── lib/        # Shared utilities
│       │   ├── assets/ # Static assets
│       │   └── utils.ts # Utility functions
│       └── routes/     # SvelteKit routes
│           ├── +layout.svelte
│           └── +page.svelte
│
└── docs/               # Documentation
```

## 🛠️ Tech Stack

### Frontend
- **SvelteKit 5** - Modern web framework
- **TailwindCSS 4** - Utility-first CSS
- **TypeScript** - Type safety
- **Cloudflare Workers** - Edge deployment ready

### Backend
- **Go 1.25** - High-performance API server
- **Echo v4** - Fast and minimalist web framework
- **zerolog** - Zero-allocation structured logging
- **Viper** - Configuration management (.env + environment variables)
- **PostgreSQL** - Database (optional)
- **pgx/v5** - PostgreSQL driver
- **Air** - Hot reload for development

### Development
- **pnpm** - Fast package manager
- **Prettier** - Code formatting
- **ESLint** - Linting

## 🔧 Available Commands

### Development (using Makefile)
```bash
make dev            # Start both API and Web servers (with hot reload)
make api            # Start API server only with hot reload (:8080)
make api-no-reload  # Start API server without hot reload
make web            # Start Web dev server only (:5173)
make build          # Build both projects for production
make test           # Run API tests
```

### Manual Commands

**Backend:**
```bash
cd api
air                            # Start with hot reload (recommended)
go run cmd/api/main.go         # Start without hot reload
go build -o bin/api ./cmd/api/main.go  # Build binary
go test ./...                  # Run tests
```

**Frontend:**
```bash
cd web
pnpm install                   # Install dependencies
pnpm dev                       # Start dev server (:5173)
pnpm build                     # Build for production
pnpm preview                   # Preview production build
pnpm check                     # Type check
pnpm lint                      # Lint code
pnpm format                    # Format code
```

## 📊 Current State

**Backend:**
- ✅ Echo v4 web framework with middleware (Logger, Recover, CORS)
- ✅ zerolog structured logging with colored console output
- ✅ Hot reload with Air
- ✅ Graceful shutdown
- ✅ Database connection setup (PostgreSQL ready)
- ✅ Environment-based configuration

**Frontend:**
- ✅ SvelteKit 5 hello world page
- ✅ TailwindCSS 4 configured
- ✅ TypeScript configured
- ✅ Hot reload with Vite
- ✅ ESLint + Prettier set up

**Development:**
- ✅ `make dev` - Start both servers with hot reload
- ✅ Colored log prefixes for easy debugging
- ✅ Cloudflare Workers deployment ready

Ready to build! 🎉
