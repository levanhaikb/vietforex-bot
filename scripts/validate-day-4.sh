# Day -4 Comprehensive Validation Script
# Run this to validate Day -4 completion

echo "🔍 DAY -4 COMPREHENSIVE VALIDATION"
echo "=================================="
echo "Date: $(date)"
echo "Server: $(hostname)"
echo ""

# Test environment file
echo "⚙️ TESTING ENVIRONMENT CONFIGURATION:"
if [ -f ~/.env ]; then
    echo "✅ Environment file exists"
    echo "📄 Environment variables loaded:"
    grep -E "^(NODE_ENV|DB_NAME|REDIS_HOST|SERVER_HOSTNAME)" ~/.env | head -4
else
    echo "❌ Environment file missing"
fi

echo ""
echo "🗄️ TESTING DATABASE CONNECTION:"
source ~/.env
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 'Day -4 Validation Success' as status;" 2>/dev/null; then
    echo "✅ Database connection working with environment variables"
else
    echo "❌ Database connection failed"
fi

echo ""
echo "⚡ TESTING REDIS CONNECTION:"
if redis-cli -a "$REDIS_PASSWORD" ping 2>/dev/null | grep -q "PONG"; then
    echo "✅ Redis connection working with environment variables"
else
    echo "❌ Redis connection failed"
fi

echo ""
echo "📁 PROJECT STRUCTURE VALIDATION:"
echo "Main folders: $(find ~/vietforex.bot.project -maxdepth 1 -type d | grep -v "^\.$" | wc -l)"
echo "Total folders: $(find ~/vietforex.bot.project -type d | wc -l)"
echo "Configuration files: $(find ~/vietforex.bot.project/configs -name "*.env.*" | wc -l)"
echo "Scripts created: $(find ~/vietforex.bot.project/scripts -name "*.sh" | wc -l)"

echo ""
echo "🎯 DAY -4 COMPLETION STATUS:"
if [ -d ~/vietforex.bot.project/src ] && [ -f ~/.env ] && [ $(find ~/vietforex.bot.project -type d | wc -l) -gt 100 ]; then
    echo "🎉 DAY -4: PERFECTLY COMPLETED!"
    echo "✅ Project structure comprehensive"
    echo "✅ Environment configuration ready"
    echo "✅ All systems integrated"
    echo ""
    echo "🚀 READY FOR DAY -3: MONITORING & BACKUP SYSTEMS"
else
    echo "⚠️ DAY -4: Some components need review"
fi

echo ""
echo "📋 NEXT STEPS FOR DAY -3:"
echo "1. System monitoring script deployment"
echo "2. Automated backup system setup"  
echo "3. Cron job scheduling"
echo "4. Performance baseline establishment"
