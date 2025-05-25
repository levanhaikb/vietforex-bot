#!/bin/bash
# Day -4: Project Structure & Environment Setup Script
# VietForex Bot - Hostinger VPS

echo "📁 DAY -4: PROJECT STRUCTURE & ENVIRONMENT SETUP"
echo "==============================================="
echo "Date: $(date)"
echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "User: $USER"
echo ""

# Verify we're on the correct server
if [[ "$(hostname)" != "vietforex.production" ]]; then
    echo "❌ Not running on vietforex.production server"
    exit 1
fi

echo "✅ Running on correct server: $(hostname)"
echo ""

# Navigate to project directory and clean up any previous errors
cd ~/vietforex.bot.project
rm -rf "{"  # Remove any error folders

# Create comprehensive project structure
echo "📁 Creating comprehensive project structure..."

# Create main directories one by one to avoid bash expansion issues
mkdir -p cau.hinh.chinh
mkdir -p cau.hinh.chinh/api
mkdir -p cau.hinh.chinh/database
mkdir -p cau.hinh.chinh/redis
mkdir -p cau.hinh.chinh/telegram
mkdir -p cau.hinh.chinh/security
mkdir -p cau.hinh.chinh/monitoring

mkdir -p mau.template
mkdir -p mau.template/pairs
mkdir -p mau.template/strategies
mkdir -p mau.template/models
mkdir -p mau.template/indicators
mkdir -p mau.template/regimes

mkdir -p du.lieu.tho
mkdir -p du.lieu.tho/eurusd
mkdir -p du.lieu.tho/gbpusd
mkdir -p du.lieu.tho/usdjpy
mkdir -p du.lieu.tho/economic
mkdir -p du.lieu.tho/sentiment

mkdir -p du.lieu.xu.ly
mkdir -p du.lieu.xu.ly/features
mkdir -p du.lieu.xu.ly/indicators
mkdir -p du.lieu.xu.ly/regime
mkdir -p du.lieu.xu.ly/preprocessed

mkdir -p mo.hinh
mkdir -p mo.hinh/lstm
mkdir -p mo.hinh/transformer
mkdir -p mo.hinh/ensemble
mkdir -p mo.hinh/validation
mkdir -p mo.hinh/deployment

mkdir -p tin.hieu
mkdir -p tin.hieu/generation
mkdir -p tin.hieu/validation
mkdir -p tin.hieu/broadcast
mkdir -p tin.hieu/analytics
mkdir -p tin.hieu/history

mkdir -p kiem.chung
mkdir -p kiem.chung/backtesting
mkdir -p kiem.chung/validation
mkdir -p kiem.chung/performance
mkdir -p kiem.chung/statistical

mkdir -p doanh.nghiep
mkdir -p doanh.nghiep/scaling
mkdir -p doanh.nghiep/white.label
mkdir -p doanh.nghiep/enterprise
mkdir -p doanh.nghiep/partnerships

mkdir -p phan.tich
mkdir -p phan.tich/performance
mkdir -p phan.tich/user
mkdir -p phan.tich/market
mkdir -p phan.tich/financial
mkdir -p phan.tich/technical

mkdir -p quoc.te
mkdir -p quoc.te/multi.language
mkdir -p quoc.te/localization
mkdir -p quoc.te/regional
mkdir -p quoc.te/compliance

mkdir -p doi.moi
mkdir -p doi.moi/research
mkdir -p doi.moi/experimental
mkdir -p doi.moi/innovation
mkdir -p doi.moi/patents

mkdir -p mo.rong
mkdir -p mo.rong/plugins
mkdir -p mo.rong/integrations
mkdir -p mo.rong/apis
mkdir -p mo.rong/third.party

# Development folders
mkdir -p src
mkdir -p src/api.server
mkdir -p src/api.server/routes
mkdir -p src/api.server/middleware
mkdir -p src/api.server/services
mkdir -p src/api.server/utils
mkdir -p src/api.server/tests

mkdir -p src/colab
mkdir -p src/colab/notebooks
mkdir -p src/colab/scripts
mkdir -p src/colab/models
mkdir -p src/colab/data
mkdir -p src/colab/analysis

mkdir -p src/telegram.bot
mkdir -p src/telegram.bot/commands
mkdir -p src/telegram.bot/handlers
mkdir -p src/telegram.bot/services
mkdir -p src/telegram.bot/templates

mkdir -p src/database
mkdir -p src/database/schemas
mkdir -p src/database/migrations
mkdir -p src/database/seeds
mkdir -p src/database/backups

mkdir -p src/monitoring
mkdir -p src/monitoring/metrics
mkdir -p src/monitoring/alerts
mkdir -p src/monitoring/dashboards
mkdir -p src/monitoring/reports

# Configuration folders
mkdir -p configs
mkdir -p configs/environments
mkdir -p configs/environments/development
mkdir -p configs/environments/testing
mkdir -p configs/environments/staging
mkdir -p configs/environments/production

mkdir -p configs/docker
mkdir -p configs/docker/api
mkdir -p configs/docker/database
mkdir -p configs/docker/redis
mkdir -p configs/docker/nginx

mkdir -p configs/deployment
mkdir -p configs/deployment/scripts
mkdir -p configs/deployment/workflows
mkdir -p configs/deployment/ci.cd

# Documentation and utility folders
mkdir -p docs
mkdir -p docs/api
mkdir -p docs/architecture
mkdir -p docs/deployment
mkdir -p docs/user.guides
mkdir -p docs/technical

mkdir -p scripts
mkdir -p logs
mkdir -p tmp
mkdir -p uploads
mkdir -p downloads

echo "✅ Project structure created successfully!"

# Create comprehensive environment files
echo ""
echo "⚙️ Creating environment configuration files..."

# Production environment file
cat > configs/environments/production/.env.production << 'EOF'
# VietForex Bot Production Environment - Hostinger VPS
# Generated on $(date)
# Server: vietforex.production (145.79.13.123)

# ==============================================
# SERVER CONFIGURATION
# ==============================================
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# Server Information
SERVER_PROVIDER=Hostinger
SERVER_LOCATION=Netherlands
SERVER_IP=145.79.13.123
SERVER_HOSTNAME=vietforex.production
DATACENTER=Netherlands

# ==============================================
# DATABASE CONFIGURATION (PostgreSQL v17.5)
# ==============================================
DB_HOST=localhost
DB_PORT=5432
DB_NAME=vietforex_production
DB_USER=forex_bot_user
DB_PASSWORD=VietForexHostinger2024!

# PostgreSQL Connection String
DATABASE_URL=postgresql://forex_bot_user:VietForexHostinger2024!@localhost:5432/vietforex_production

# Database Pool Configuration
DB_POOL_MIN=2
DB_POOL_MAX=10
DB_TIMEOUT=30000

# ==============================================
# REDIS CACHE CONFIGURATION
# ==============================================
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=VietForexRedisHostinger2024
REDIS_DB=0

# Redis Connection String
REDIS_URL=redis://:VietForexRedisHostinger2024@localhost:6379

# Redis Configuration
REDIS_MAX_MEMORY=256mb
REDIS_MEMORY_POLICY=allkeys-lru
REDIS_PERSISTENCE=rdb+aof

# ==============================================
# SECURITY CONFIGURATION
# ==============================================
JWT_SECRET=VietForex_JWT_Secret_Hostinger_2024_Production
API_KEY=VietForex_API_Key_Hostinger_2024_Production
ENCRYPTION_KEY=VietForex_Encryption_Key_2024_Production

# Session Configuration
SESSION_SECRET=VietForex_Session_Secret_2024_Production
SESSION_TIMEOUT=3600000

# CORS Configuration
CORS_ORIGIN=https://vietforex.production,http://localhost:3000
CORS_CREDENTIALS=true

# ==============================================
# TELEGRAM BOT CONFIGURATION
# ==============================================
TELEGRAM_BOT_TOKEN=
TELEGRAM_WEBHOOK_URL=https://vietforex.production/webhook/telegram
TELEGRAM_API_URL=https://api.telegram.org/bot

# Telegram Configuration
TELEGRAM_WEBHOOK_SECRET=VietForex_Telegram_Webhook_Secret_2024
TELEGRAM_MAX_CONNECTIONS=100
TELEGRAM_ALLOWED_UPDATES=message,callback_query

# ==============================================
# GOOGLE COLAB INTEGRATION
# ==============================================
COLAB_API_ENDPOINT=
COLAB_API_KEY=
COLAB_WEBHOOK_URL=https://vietforex.production/webhook/colab

# Colab Configuration
COLAB_TIMEOUT=300000
COLAB_RETRY_ATTEMPTS=3
COLAB_RETRY_DELAY=5000

# ==============================================
# TRADING CONFIGURATION
# ==============================================
# Default Trading Pairs
DEFAULT_PAIRS=EURUSD,GBPUSD,USDJPY
PRIMARY_PAIR=EURUSD

# Signal Configuration
SIGNAL_EXPIRY_TIME=14400000
SIGNAL_CONFIDENCE_THRESHOLD=0.6
MAX_SIGNALS_PER_DAY=50

# Risk Management
DEFAULT_RISK_LEVEL=medium
MAX_POSITION_SIZE=0.1
DEFAULT_STOP_LOSS=30
DEFAULT_TAKE_PROFIT=60

# ==============================================
# APPLICATION CONFIGURATION
# ==============================================
# Logging
LOG_LEVEL=info
LOG_FILE=/home/forex_bot/vietforex.bot.project/logs/app.log
LOG_MAX_SIZE=10mb
LOG_MAX_FILES=5

# Performance
MAX_MEMORY_USAGE=500mb
REQUEST_TIMEOUT=30000
RATE_LIMIT_WINDOW=3600000
RATE_LIMIT_MAX_REQUESTS=1000

# Monitoring
HEALTH_CHECK_INTERVAL=60000
PERFORMANCE_MONITORING=true
ERROR_REPORTING=true

# ==============================================
# EXTERNAL SERVICES
# ==============================================
# Market Data Providers
ALPHA_VANTAGE_API_KEY=
FINNHUB_API_KEY=
FXCM_API_KEY=

# Email Configuration (Optional)
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
EMAIL_FROM=noreply@vietforex.production

# ==============================================
# DEVELOPMENT & DEBUGGING
# ==============================================
DEBUG=false
VERBOSE_LOGGING=false
API_DOCUMENTATION=false
SWAGGER_ENABLED=false

# Testing
TEST_MODE=false
MOCK_TRADING=false
DEMO_SIGNALS=false
EOF

# Development environment file
cat > configs/environments/development/.env.development << 'EOF'
# VietForex Bot Development Environment
NODE_ENV=development
PORT=3001
HOST=localhost

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=vietforex_development
DB_USER=forex_bot_user
DB_PASSWORD=VietForexHostinger2024!

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=VietForexRedisHostinger2024
REDIS_DB=1

# Security (weaker for development)
JWT_SECRET=dev_jwt_secret_2024
API_KEY=dev_api_key_2024

# Development Features
DEBUG=true
VERBOSE_LOGGING=true
API_DOCUMENTATION=true
SWAGGER_ENABLED=true
TEST_MODE=true
MOCK_TRADING=true
DEMO_SIGNALS=true

# Telegram Bot (Test Bot)
TELEGRAM_BOT_TOKEN=
TELEGRAM_WEBHOOK_URL=http://localhost:3001/webhook/telegram
EOF

# Create basic utility scripts
echo ""
echo "🛠️ Creating utility scripts..."

# System information script
cat > scripts/system.info.sh << 'EOF'
#!/bin/bash
# System Information Script

echo "🖥️ VIETFOREX BOT SYSTEM INFORMATION"
echo "=================================="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "IP: $(curl -s ifconfig.me)"
echo ""

echo "💻 SYSTEM SPECS:"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "Storage: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
echo "CPU Load: $(cat /proc/loadavg | awk '{print $1}')"
echo ""

echo "🔧 SERVICES STATUS:"
services=("docker" "postgresql" "redis-server")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "✅ $service: RUNNING"
    else
        echo "❌ $service: STOPPED"
    fi
done
EOF

chmod +x scripts/system.info.sh

# Environment switcher script
cat > scripts/switch.environment.sh << 'EOF'
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
EOF

chmod +x scripts/switch.environment.sh

# Project initialization script
cat > scripts/init.project.sh << 'EOF'
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
EOF

chmod +x scripts/init.project.sh

# Create README files
cat > README.md << 'EOF'
# 🚀 VietForex Bot Project

## 📊 Current Status: Day -4 Complete
- ✅ Project Structure: Complete
- ✅ Environment Setup: Ready
- ✅ Infrastructure: Operational
- ⏳ Next: Day -3 Monitoring & Backup

## 🏗️ Project Structure
vietforex.bot.project/
├── cau.hinh.chinh/     # Main configurations
├── src/                # Source code
├── configs/            # Environment configurations
├── scripts/            # Utility scripts
└── docs/               # Documentation

## 🚀 Quick Start
```bash
# Initialize project
./scripts/init.project.sh

# Check system status
./scripts/system.info.sh

# Switch environments
./scripts/switch.environment.sh production
📞 Support

Server: vietforex.production (Hostinger)
Environment: Production ready
Database: PostgreSQL 17.5
Cache: Redis with authentication
EOF

Run project initialization
echo ""
echo "🚀 Running project initialization..."
./scripts/init.project.sh
echo ""
echo "🎯 DAY -4 SETUP COMPLETED!"
echo "=========================="
echo "📁 Project structure: ~/vietforex.bot.project/"
echo "⚙️ Environment: Production ready"
echo "📊 Total folders: $(find ~/vietforex.bot.project -type d | wc -l)"
echo "📄 Total files: $(find ~/vietforex.bot.project -type f | wc -l)"
echo ""
echo "🔍 Quick validation:"
Quick validation
if [ -f ~/.env ] && [ -d ~/vietforex.bot.project/src ]; then
echo "✅ Basic validation passed"
echo "📁 Structure: $(find ~/vietforex.bot.project -maxdepth 1 -type d | wc -l) main folders"
echo "⚙️ Environment: .env file created"
echo "🛠️ Scripts: $(find ~/vietforex.bot.project/scripts -name "*.sh" | wc -l) utility scripts"
else
echo "⚠️ Some components may need attention"
fi
echo ""
echo "🚀 Ready for: Day -3 Monitoring & Backup Systems"
echo ""
echo "Next steps:"
echo "1. Run: ls -la ~/vietforex.bot.project/"
echo "2. Run: ./scripts/system.info.sh"
echo "3. Ready for Day -3 setup"
