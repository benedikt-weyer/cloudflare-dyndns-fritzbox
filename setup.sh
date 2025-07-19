#!/usr/bin/env bash

# Setup script for Cloudflare DynDNS with Caddy
# This script copies the example.env to .env if it doesn't exist

set -e

echo "Setting up Cloudflare DynDNS environment..."

# Check if .env already exists
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled. Existing .env file preserved."
        exit 0
    fi
fi

# Copy example.env to .env
if [ -f "example.env" ]; then
    cp example.env .env
    echo "✅ Created .env file from example.env"
else
    echo "❌ example.env file not found!"
    exit 1
fi

echo ""
echo "🔧 Next steps:"
echo "1. Edit the .env file and update the DOMAIN_NAME to your actual domain"
echo "2. Make sure your domain points to this server's IP address"
echo "3. Ensure ports 80 and 443 are accessible from the internet"
echo "4. Run 'docker-compose up -d' to start the services"
echo ""
echo "💡 Pro tip: You can edit the .env file with: nano .env" 