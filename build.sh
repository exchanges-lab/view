#!/bin/sh
# Build script for Cloudflare Pages
# Generates auth-config.js from environment variables
#
# Set these in Cloudflare Pages > Settings > Environment Variables:
#   API_BASE_URL       - Backend API URL (e.g. https://api.yourdomain.com)
#   GOOGLE_CLIENT_ID   - Google OAuth Client ID
#   ALLOWED_EMAILS     - Comma-separated email whitelist (e.g. alice@gmail.com,bob@gmail.com)

API_BASE_URL="${API_BASE_URL:-https://xxx.xxx.com}"
GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID:-xxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com}"
ALLOWED_EMAILS="${ALLOWED_EMAILS:-your-email@gmail.com}"

cat > frontend/auth-config.js << JSEOF
window.API_CONFIG = { baseUrl: '${API_BASE_URL}' };

const AUTH_CONFIG = {
    clientId: '${GOOGLE_CLIENT_ID}',
    onSuccess: (user) => {
        console.log('Authentication successful:', user.email);
    },
    onError: (error) => {
        console.error('Authentication error:', error);
    }
};

window.AUTH_CONFIG = AUTH_CONFIG;
window.ALLOWED_EMAILS = '${ALLOWED_EMAILS}'.split(',').map(e => e.trim());
JSEOF

echo "Generated auth-config.js with API_BASE_URL=${API_BASE_URL}"
