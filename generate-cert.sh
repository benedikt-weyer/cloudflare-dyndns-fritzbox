#!/usr/bin/env bash

# Script to generate self-signed SSL certificates for localhost and machine IP
# Usage: ./generate-cert.sh

set -e

DOMAIN="localhost"
MACHINE_IP="192.168.178.21"
CERT_DIR="./certs"
KEY_FILE="$CERT_DIR/privkey.pem"
CERT_FILE="$CERT_DIR/cert.pem"

# Create certs directory if it doesn't exist
mkdir -p "$CERT_DIR"

echo "Generating self-signed certificate for $DOMAIN and $MACHINE_IP..."

# Check if we have openssl available locally
if command -v openssl >/dev/null 2>&1; then
    echo "Using local OpenSSL..."
    # Generate private key
    openssl genrsa -out "$KEY_FILE" 2048
    echo "✓ Private key generated: $KEY_FILE"
    
    # Create certificate with SAN for both localhost and IP
    openssl req -new -x509 -key "$KEY_FILE" -out "$CERT_FILE" -days 365 \
        -subj "/C=DE/ST=State/L=City/O=Organization/CN=$DOMAIN" \
        -addext "subjectAltName=DNS:$DOMAIN,IP:$MACHINE_IP"
    echo "✓ Certificate generated: $CERT_FILE"
    
    # Set proper permissions
    chmod 600 "$KEY_FILE"
    chmod 644 "$CERT_FILE"
else
    echo "OpenSSL not found locally, using Docker..."
    # Use Docker to generate certificates with SAN for both localhost and IP
    docker run --rm \
        -v "$(pwd)/certs:/certs" \
        -u "$(id -u):$(id -g)" \
        alpine/openssl req -new -x509 \
        -keyout /certs/privkey.pem \
        -out /certs/cert.pem \
        -days 365 -nodes \
        -subj "/C=DE/ST=State/L=City/O=Organization/CN=$DOMAIN" \
        -addext "subjectAltName=DNS:$DOMAIN,IP:$MACHINE_IP"
    
    echo "✓ Certificate generated using Docker"
    
    # Set proper permissions
    chmod 600 "$KEY_FILE" 2>/dev/null || echo "Note: Could not set permissions on $KEY_FILE"
    chmod 644 "$CERT_FILE" 2>/dev/null || echo "Note: Could not set permissions on $CERT_FILE"
fi

echo ""
echo "Certificate generation complete!"
echo "Certificate valid for 365 days"
echo ""
echo "Files created:"
echo "  Private key: $KEY_FILE"
echo "  Certificate: $CERT_FILE"
echo ""
echo "⚠️  Note: This is a self-signed certificate. Browsers will show a security warning."
echo "   You'll need to accept the certificate manually in your browser."
echo ""
echo "To regenerate the certificate, simply run this script again." 