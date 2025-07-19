# cloudflare-dyndns-fritzbox

A dynamic DNS service that updates Cloudflare DNS records, running behind a Caddy reverse proxy with HTTPS support.

## Quick Setup

1. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

2. **Configure your domain:**
   Edit the `.env` file and update `DOMAIN_NAME` to your actual domain:
   ```bash
   nano .env
   ```

3. **Generate certificates:**
   ```bash
   ./generate-cert.sh
   ```

4. **Start the services:**
   ```bash
   docker-compose up -d
   ```

## Configuration

The service is configured via the `.env` file:
- `DOMAIN_NAME`: The domain name for accessing the service (e.g., `dyndns.yourdomain.com`)

Make sure your domain points to the server where this is running and that ports 80 and 443 are accessible from the internet.

## Usage

Access the service at `https://yourdomain.com` (replace with your configured domain) to update DNS records.
