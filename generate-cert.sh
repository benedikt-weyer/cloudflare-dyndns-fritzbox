#!/usr/bin/env bash

# Script to generate self-signed SSL certificates for localhost and configured domain
# Usage: ./generate-cert.sh

set -e

# Load environment variables from .env file if it exists
if [ -f ".env" ]; then
    echo "Loading configuration from .env file..."
    export $(grep -v '^#' .env | grep -v '^$' | xargs)
else
    echo "⚠️  No .env file found. Run './setup.sh' first to create one."
    echo "Using localhost as fallback domain."
fi

# Use domain from environment or default to localhost
DOMAIN="${DOMAIN_NAME:-localhost}"
CERT_DIR="./certs"
KEY_FILE="$CERT_DIR/privkey.pem"
CERT_FILE="$CERT_DIR/cert.pem"

# Create certs directory if it doesn't exist
mkdir -p "$CERT_DIR"

echo "Generating self-signed certificate for $DOMAIN..."

# Check if we have openssl available locally
if command -v openssl >/dev/null 2>&1; then
    echo "Using local OpenSSL..."
    # Generate private key
    openssl genrsa -out "$KEY_FILE" 2048
    echo "✓ Private key generated: $KEY_FILE"
    
    # Create certificate with SAN for both localhost and configured domain
    if [ "$DOMAIN" = "localhost" ]; then
        # For localhost, also include 127.0.0.1
        openssl req -new -x509 -key "$KEY_FILE" -out "$CERT_FILE" -days 365 \
            -subj "/C=DE/ST=State/L=City/O=Organization/CN=$DOMAIN" \
            -addext "subjectAltName=DNS:$DOMAIN,IP:127.0.0.1"
    else
        # For custom domain, include both localhost and the custom domain
        openssl req -new -x509 -key "$KEY_FILE" -out "$CERT_FILE" -days 365 \
            -subj "/C=DE/ST=State/L=City/O=Organization/CN=$DOMAIN" \
            -addext "subjectAltName=DNS:$DOMAIN,DNS:localhost,IP:127.0.0.1"
    fi
    echo "✓ Certificate generated: $CERT_FILE"
    
    # Set proper permissions
    chmod 600 "$KEY_FILE"
    chmod 644 "$CERT_FILE"
else
    echo "OpenSSL not found locally, using Docker..."
    # Use Docker to generate certificates with SAN for both localhost and configured domain
    if [ "$DOMAIN" = "localhost" ]; then
        # For localhost, also include 127.0.0.1
        docker run --rm \
            -v "$(pwd)/certs:/certs" \
            -u "$(id -u):$(id -g)" \
            alpine/openssl req -new -x509 \
            -keyout /certs/privkey.pem \
            -out /certs/cert.pem \
            -days 365 -nodes \
            -subj "/C=DE/ST=State/L=City/O=Organization/CN=$DOMAIN" \
            -addext "subjectAltName=DNS:$DOMAIN,IP:127.0.0.1"
    else
        # For custom domain, include both localhost and the custom domain
        docker run --rm \
            -v "$(pwd)/certs:/certs" \
            -u "$(id -u):$(id -g)" \
            alpine/openssl req -new -x509 \
            -keyout /certs/privkey.pem \
            -out /certs/cert.pem \
            -days 365 -nodes \
            -subj "/C=DE/ST=State/L=City/O=Organization/CN=$DOMAIN" \
            -addext "subjectAltName=DNS:$DOMAIN,DNS:localhost,IP:127.0.0.1"
    fi
    
    echo "✓ Certificate generated using Docker"
    
    # Set proper permissions
    chmod 600 "$KEY_FILE" 2>/dev/null || echo "Note: Could not set permissions on $KEY_FILE"
    chmod 644 "$CERT_FILE" 2>/dev/null || echo "Note: Could not set permissions on $CERT_FILE"
fi

echo ""
echo "Certificate generation complete!"
echo "Certificate valid for 365 days"
echo ""
echo "Certificate details:"
echo "  Primary domain: $DOMAIN"
if [ "$DOMAIN" != "localhost" ]; then
    echo "  Also valid for: localhost, 127.0.0.1"
else
    echo "  Also valid for: 127.0.0.1"
fi
echo ""
echo "Files created:"
echo "  Private key: $KEY_FILE"
echo "  Certificate: $CERT_FILE"
echo ""
echo "⚠️  Note: This is a self-signed certificate. Browsers will show a security warning."
echo "   You'll need to accept the certificate manually in your browser."
echo ""
if [ "$DOMAIN" != "localhost" ]; then
    echo "💡 Tip: Make sure '$DOMAIN' points to this server's IP address in DNS."
    echo ""
fi
echo "To regenerate the certificate (e.g., after changing domain), simply run this script again." 