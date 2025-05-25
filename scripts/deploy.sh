#!/bin/bash
# VietForex Bot Deployment Script for Hostinger

echo "🚀 DEPLOYING VIETFOREX BOT TO HOSTINGER VPS"
echo "==========================================="

# Verify Hostinger environment
if [[ "$(hostname)" =~ ^[a-z0-9]+(\.[a-z0-9]+)*$ ]]; then
    echo "✅ Deploying to Hostinger VPS: $(hostname)"
else
    echo "❌ Not running on Hostinger-compliant hostname"
    exit 1
fi

# Create project directory with dot naming
PROJECT_DIR="$HOME/vietforex.bot.project"
mkdir -p "$PROJECT_DIR"

# Copy files
cp -r src/* "$PROJECT_DIR/"
cp configs/.env.hostinger "$PROJECT_DIR/.env"

# Install dependencies
cd "$PROJECT_DIR"
npm install

# Start with PM2
pm2 start ecosystem.config.js --env production

echo "✅ VietForex Bot deployed successfully on Hostinger!"
echo "🌐 Server: $(hostname) @ $(curl -s ifconfig.me)"
