package main

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/voidarchive/bazi/api/internal/config"
	"github.com/voidarchive/bazi/api/internal/database"
)

func main() {
	// Setup zerolog
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stdout})

	// Load configuration
	cfg := config.Load()

	log.Info().Msg("🚀 Starting API Server")
	log.Info().Str("environment", cfg.Environment).Msg("Configuration loaded")

	// Initialize database connection pool (optional, can be used when needed)
	ctx := context.Background()
	if cfg.DatabaseURL != "" {
		log.Info().Msg("Connecting to database...")
		pool, err := database.NewPool(ctx, cfg.DatabaseURL)
		if err != nil {
			log.Warn().Err(err).Msg("Failed to connect to database")
		} else {
			defer pool.Close()
			if err := pool.Ping(ctx); err != nil {
				log.Warn().Err(err).Msg("Failed to ping database")
			} else {
				log.Info().Msg("✓ Database connected")
			}
		}
	}

	// Create Echo instance
	e := echo.New()
	e.HideBanner = true
	e.HidePort = true

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())

	// Routes
	e.GET("/", func(c echo.Context) error {
		return c.JSON(http.StatusOK, map[string]string{
			"message": "API Server Running",
			"status":  "ok",
		})
	})

	e.GET("/health", func(c echo.Context) error {
		return c.JSON(http.StatusOK, map[string]string{
			"status": "healthy",
		})
	})

	// Start server in a goroutine
	go func() {
		log.Info().Str("port", cfg.Port).Msg("✓ Server listening")
		log.Info().Str("url", "http://localhost:"+cfg.Port+"/health").Msg("✓ Health check endpoint")
		if err := e.Start(":" + cfg.Port); err != nil && err != http.ErrServerClosed {
			log.Fatal().Err(err).Msg("Server error")
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	// Graceful shutdown
	log.Info().Msg("Server shutting down...")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := e.Shutdown(shutdownCtx); err != nil {
		log.Fatal().Err(err).Msg("Error during server shutdown")
	}

	log.Info().Msg("✓ Server stopped")
}
