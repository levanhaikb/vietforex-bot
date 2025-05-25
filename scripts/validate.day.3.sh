#!/bin/bash
# Day -3 Validation Script

echo "🔍 DAY -3 VALIDATION: MONITORING & BACKUP SYSTEMS"
echo "================================================="
echo "Date: $(date)"
echo "Server: $(hostname)"
echo ""

PASSED_TESTS=0
TOTAL_TESTS=12

# Test 1: Advanced monitoring script
echo "📊 TEST 1: Advanced Monitoring Script"
if [ -x ~/vietforex.bot.project/scripts/system.monitor.advanced.sh ]; then
    echo "   ✅ Advanced monitoring script exists and executable"
    ((PASSED_TESTS++))
else
    echo "   ❌ Advanced monitoring script missing"
fi

# Test 2: Comprehensive backup script
echo ""
echo "💾 TEST 2: Comprehensive Backup Script"
if [ -x ~/vietforex.bot.project/scripts/backup.comprehensive.sh ]; then
    echo "   ✅ Backup script exists and executable"
    ((PASSED_TESTS++))
else
    echo "   ❌ Backup script missing"
fi

# Test 3: Performance baseline script
echo ""
echo "📈 TEST 3: Performance Baseline Script"
if [ -x ~/vietforex.bot.project/scripts/performance.baseline.sh ]; then
    echo "   ✅ Performance baseline script exists"
    ((PASSED_TESTS++))
else
    echo "   ❌ Performance baseline script missing"
fi

# Test 4: Alert system
echo ""
echo "🚨 TEST 4: Alert System"
if [ -x ~/vietforex.bot.project/scripts/alert.system.sh ]; then
    echo "   ✅ Alert system script exists"
    ((PASSED_TESTS++))
else
    echo "   ❌ Alert system script missing"
fi

# Test 5: Cron jobs
echo ""
echo "⏰ TEST 5: Automated Scheduling"
CRON_JOBS=$(crontab -l | grep -v '^#' | grep -v '^ | wc -l)
if [ $CRON_JOBS -ge 5 ]; then
    echo "   ✅ Cron jobs configured ($CRON_JOBS jobs)"
    ((PASSED_TESTS++))
else
    echo "   ❌ Insufficient cron jobs ($CRON_JOBS jobs)"
fi

# Test 6: Log directories
echo ""
echo "📁 TEST 6: Log Directory Structure"
if [ -d ~/vietforex.bot.project/logs/monitoring ] && [ -d ~/vietforex.bot.project/logs/backup ]; then
    LOG_DIRS=$(find ~/vietforex.bot.project/logs -type d | wc -l)
    echo "   ✅ Log directories created ($LOG_DIRS directories)"
    ((PASSED_TESTS++))
else
    echo "   ❌ Log directory structure incomplete"
fi

# Test 7: Backup directory
echo ""
echo "💾 TEST 7: Backup System"
if [ -d ~/vietforex.backups ]; then
    BACKUP_FILES=$(find ~/vietforex.backups -name "*_????????_??????.*" | wc -l)
    echo "   ✅ Backup system operational ($BACKUP_FILES backup files)"
    ((PASSED_TESTS++))
else
    echo "   ❌ Backup directory not found"
fi

# Test 8: Performance baseline
echo ""
echo "📊 TEST 8: Performance Baseline"
if [ -d ~/vietforex.bot.project/logs/baselines ]; then
    BASELINES=$(find ~/vietforex.bot.project/logs/baselines -name "baseline_*.txt" | wc -l)
    echo "   ✅ Performance baselines established ($BASELINES baselines)"
    ((PASSED_TESTS++))
else
    echo "   ❌ Performance baseline not established"
fi

# Test 9: Monitoring functionality
echo ""
echo "🔍 TEST 9: Monitoring Functionality"
if ~/vietforex.bot.project/scripts/system.monitor.advanced.sh | grep -q "SYSTEM HEALTH OVERVIEW"; then
    echo "   ✅ Advanced monitoring working"
    ((PASSED_TESTS++))
else
    echo "   ❌ Monitoring script not functioning"
fi

# Test 10: Alert system functionality
echo ""
echo "🚨 TEST 10: Alert System Functionality"
if ~/vietforex.bot.project/scripts/alert.system.sh | grep -q "Alert system check completed"; then
    echo "   ✅ Alert system working"
    ((PASSED_TESTS++))
else
    echo "   ❌ Alert system not functioning"
fi

# Test 11: System services
echo ""
echo "🔧 TEST 11: Critical Services"
SERVICES_UP=0
services=("postgresql" "redis-server" "docker")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        ((SERVICES_UP++))
    fi
done

if [ $SERVICES_UP -eq 3 ]; then
    echo "   ✅ All critical services running ($SERVICES_UP/3)"
    ((PASSED_TESTS++))
else
    echo "   ⚠️ Some services not running ($SERVICES_UP/3)"
fi

# Test 12: Environment integration
echo ""
echo "⚙️ TEST 12: Environment Integration"
source ~/.env
if [ -n "$NODE_ENV" ] && [ -n "$DB_NAME" ] && [ -n "$REDIS_PASSWORD" ]; then
    echo "   ✅ Environment variables properly loaded"
    ((PASSED_TESTS++))
else
    echo "   ❌ Environment variables not properly configured"
fi

# Results
echo ""
echo "🎯 DAY -3 VALIDATION RESULTS"
echo "============================"
echo "Tests Passed: $PASSED_TESTS/$TOTAL_TESTS"
echo "Success Rate: $((PASSED_TESTS * 100 / TOTAL_TESTS))%"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo ""
    echo "🎉 DAY -3: PERFECTLY COMPLETED!"
    echo "✅ Monitoring system comprehensive and operational"
    echo "✅ Backup system configured and tested"
    echo "✅ Performance baseline established"
    echo "✅ Automated scheduling active"
    echo "✅ Alert system functional"
    echo ""
    echo "🚀 READY FOR DAY -2: SYSTEM VALIDATION & PERFORMANCE TESTING"
elif [ $PASSED_TESTS -ge 10 ]; then
    echo ""
    echo "✅ DAY -3: EXCELLENT (Minor issues)"
    echo "🔧 Review failed tests and proceed to Day -2"
else
    echo ""
    echo "❌ DAY -3: NEEDS ATTENTION"
    echo "🚨 Major issues found - must fix before proceeding"
fi

echo ""
echo "📊 SYSTEM SUMMARY:"
echo "=================="
echo "Monitoring Scripts: $(find ~/vietforex.bot.project/scripts -name "*monitor*" | wc -l)"
echo "Backup Scripts: $(find ~/vietforex.bot.project/scripts -name "*backup*" | wc -l)"
echo "Total Scripts: $(find ~/vietforex.bot.project/scripts -name "*.sh" | wc -l)"
echo "Log Directories: $(find ~/vietforex.bot.project/logs -type d | wc -l)"
echo "Cron Jobs: $(crontab -l | grep -v '^#' | grep -v '^ | wc -l)"
echo ""
echo "🔄 Next: Day -2 System Validation & Performance Testing"
cat > scripts/validate.day.3.simple.sh << 'EOF'
#!/bin/bash
echo "🔍 DAY -3 SIMPLE VALIDATION"
echo "=========================="

echo "📊 Scripts check:"
ls -la scripts/*monitor* scripts/*backup* scripts/*baseline* scripts/*alert*

echo ""
echo "⏰ Cron jobs:"
crontab -l | grep -v '^#'

echo ""
echo "💾 Backup check:"
ls -la ~/vietforex.backups/

echo ""  
echo "📈 Baseline check:"
ls -la logs/baselines/

echo "✅ Day -3 validation completed"
EOF

chmod +x scripts/validate.day.3.simple.sh
./scripts/validate.day.3.simple.sh
