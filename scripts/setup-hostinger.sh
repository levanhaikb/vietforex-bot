#!/bin/bash
# Hostinger VPS Setup Script

echo "🚀 HOSTINGER VPS SETUP FOR VIETFOREX BOT"
echo "========================================"

# Check if running on Hostinger VPS
if [[ "$(hostname)" =~ ^[a-z0-9]+(\.[a-z0-9]+)*$ ]]; then
    echo "✅ Hostname format compliant with Hostinger"
    echo "🏷️  Current hostname: $(hostname)"
else
    echo "❌ Hostname not compliant with Hostinger requirements"
    echo "⚠️  Please set hostname to dot format (e.g., vietforex.production)"
    exit 1
fi

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Node.js
echo "🟢 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install databases
echo "🗄️ Installing PostgreSQL and Redis..."
sudo apt install -y postgresql postgresql-contrib redis-server

# Setup firewall
echo "🛡️ Configuring firewall..."
sudo ufw allow 2222/tcp
sudo ufw allow 80/tcp  
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw --force enable

echo "✅ Hostinger VPS setup completed!"
echo "🎯 Ready for VietForex Bot deployment"
