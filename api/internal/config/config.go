package config

import (
	"github.com/spf13/viper"
)

// Config holds all configuration for the application
type Config struct {
	DatabaseURL string `mapstructure:"DATABASE_URL"`
	Port        string `mapstructure:"PORT"`
	JWTSecret   string `mapstructure:"JWT_SECRET"`
	Environment string `mapstructure:"ENV"`
}

// Load reads configuration from environment variables using Viper
func Load() *Config {
	viper.SetConfigFile(".env")
	viper.AutomaticEnv()

	// Set defaults
	viper.SetDefault("PORT", "8080")
	viper.SetDefault("ENV", "development")

	// Read .env file if it exists (optional)
	viper.ReadInConfig() // Ignore error if .env doesn't exist

	cfg := &Config{}
	viper.Unmarshal(cfg)

	return cfg
}
