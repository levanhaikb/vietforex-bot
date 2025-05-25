#!/bin/bash
# Environment Switcher Script

if [ -z "$1" ]; then
    echo "Usage: $0 [development|production|testing]"
    echo "Current environment files:"
    ls -la ~/vietforex.bot.project/configs/environments/*/
    exit 1
fi

ENV=$1
ENV_FILE=~/vietforex.bot.project/configs/environments/$ENV/.env.$ENV

if [ -f "$ENV_FILE" ]; then
    cp "$ENV_FILE" ~/vietforex.bot.project/.env
    echo "✅ Switched to $ENV environment"
    echo "📄 Active config: .env (copied from $ENV_FILE)"
else
    echo "❌ Environment file not found: $ENV_FILE"
    exit 1
fi
