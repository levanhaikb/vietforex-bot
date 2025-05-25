#!/bin/bash
# Project Initialization Script

echo "🚀 INITIALIZING VIETFOREX BOT PROJECT"
echo "===================================="

# Set production environment by default
~/vietforex.bot.project/scripts/switch.environment.sh production

# Set proper permissions
chmod 755 ~/vietforex.bot.project/scripts/*.sh
chmod 600 ~/vietforex.bot.project/configs/environments/*/.env.* 2>/dev/null
chmod 600 ~/vietforex.bot.project/.env 2>/dev/null

echo "✅ Project initialized successfully!"
echo "📁 Structure: ~/vietforex.bot.project/"
echo "⚙️ Environment: production"
echo "🔗 Database: vietforex_production"
echo "⚡ Cache: Redis ready"
