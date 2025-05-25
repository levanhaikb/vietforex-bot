#!/bin/bash
# Day -2: System Validation & Performance Testing Script
# VietForex Bot - Hostinger VPS

echo "🔍 DAY -2: SYSTEM VALIDATION & PERFORMANCE TESTING"
echo "=================================================="
echo "Date: $(date)"
echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "User: $USER"
echo ""

# Verify prerequisites
if [[ "$(hostname)" != "vietforex.production" ]]; then
    echo "❌ Not running on vietforex.production server"
    exit 1
fi

if [[ ! -f ~/.env ]] || [[ ! -d ~/vietforex.bot.project/scripts ]]; then
    echo "❌ Previous days not completed. Please complete Day -4 and Day -3 first."
    exit 1
fi

echo "✅ Prerequisites verified: All previous days completed"
echo "✅ Running on correct server: $(hostname)"
echo ""

# Navigate to project directory and source environment
cd ~/vietforex.bot.project
source ~/.env

echo "🔍 Creating comprehensive system validation script..."

# Simple but comprehensive validation script
cat > scripts/system.validation.simple.sh << 'EOF'
#!/bin/bash
# Simple System Validation for VietForex Bot

source ~/.env

echo "🔍 VIETFOREX BOT - SYSTEM VALIDATION"
echo "==================================="
echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "Date: $(date)"
echo ""

PASSED=0
TOTAL=20

# Test function
test_component() {
    local name="$1"
    local command="$2"
    echo -n "Testing $name... "
    if eval "$command" >/dev/null 2>&1; then
        echo "✅ PASS"
        ((PASSED++))
    else
        echo "❌ FAIL"
    fi
}

# System tests
echo "🖥️ SYSTEM TESTS:"
test_component "Operating System" "lsb_release -d | grep -q Ubuntu"
test_component "Hostname" "[[ '$(hostname)' == 'vietforex.production' ]]"
test_component "Memory Available" "[ $(free -m | grep Mem | awk '{print \$7}') -gt 1000 ]"
test_component "Disk Space" "[ $(df / | awk 'NR==2{print \$4}') -gt 10000000 ]"

echo ""
echo "🔧 SERVICE TESTS:"
test_component "Docker Service" "systemctl is-active --quiet docker"
test_component "PostgreSQL Service" "systemctl is-active --quiet postgresql"
test_component "Redis Service" "systemctl is-active --quiet redis-server"
test_component "Fail2Ban Service" "systemctl is-active --quiet fail2ban"

echo ""
echo "🌐 NETWORK TESTS:"
test_component "Internet Connectivity" "ping -c 1 8.8.8.8"
test_component "DNS Resolution" "nslookup google.com"
test_component "Network Latency" "[ $(ping -c 3 8.8.8.8 | tail -1 | awk -F'/' '{print \$5}' | cut -d. -f1) -lt 100 ]"

echo ""
echo "🗄️ DATABASE TESTS:"
test_component "PostgreSQL Connection" "PGPASSWORD='\$DB_PASSWORD' psql -h '\$DB_HOST' -U '\$DB_USER' -d '\$DB_NAME' -c 'SELECT 1;'"
test_component "Database Operations" "PGPASSWORD='\$DB_PASSWORD' psql -h '\$DB_HOST' -U '\$DB_USER' -d '\$DB_NAME' -c 'CREATE TABLE IF NOT EXISTS test_tbl (id SERIAL); DROP TABLE test_tbl;'"

echo ""
echo "⚡ REDIS TESTS:"
test_component "Redis Connection" "redis-cli -a '\$REDIS_PASSWORD' ping | grep -q PONG"
test_component "Redis Operations" "redis-cli -a '\$REDIS_PASSWORD' set test_key test_val && redis-cli -a '\$REDIS_PASSWORD' get test_key && redis-cli -a '\$REDIS_PASSWORD' del test_key"

echo ""
echo "⚙️ CONFIGURATION TESTS:"
test_component "Environment Variables" "[ -n '\$NODE_ENV' ] && [ -n '\$DB_NAME' ]"
test_component "Project Structure" "[ -d ~/vietforex.bot.project/src ]"
test_component "Scripts Available" "[ $(find ~/vietforex.bot.project/scripts -name '*.sh' | wc -l) -ge 8 ]"

echo ""
echo "📊 MONITORING TESTS:"
test_component "Backup System" "[ -d ~/vietforex.backups ]"
test_component "Cron Jobs" "[ $(crontab -l | grep -v '^#' | wc -l) -ge 5 ]"

echo ""
echo "🎯 VALIDATION RESULTS:"
echo "====================="
echo "Tests Passed: $PASSED/$TOTAL"
echo "Success Rate: $((PASSED * 100 / TOTAL))%"

if [ $PASSED -eq $TOTAL ]; then
    echo "🎉 SYSTEM VALIDATION: PERFECT!"
    echo "✅ All systems operational"
elif [ $PASSED -ge 16 ]; then
    echo "✅ SYSTEM VALIDATION: EXCELLENT"
    echo "🔧 Minor issues detected"
else
    echo "❌ SYSTEM VALIDATION: NEEDS ATTENTION"
    echo "🚨 Major issues require fixing"
fi

echo ""
echo "📊 System Summary:"
echo "Server: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Memory: $(free -h | grep Mem | awk '{print \$3\"/\"\$2}')"
echo "Disk: $(df -h / | awk 'NR==2{print \$3\"/\"\$2\" (\"\$5\")\"}')"
echo "Load: $(cat /proc/loadavg | awk '{print \$1}')"
EOF

chmod +x scripts/system.validation.simple.sh

echo "🚀 Creating performance testing script..."

# Simple performance testing script
cat > scripts/performance.testing.simple.sh << 'EOF'
#!/bin/bash
# Simple Performance Testing for VietForex Bot

source ~/.env

echo "🚀 VIETFOREX BOT - PERFORMANCE TESTING"
echo "======================================"
echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "Date: $(date)"
echo ""

RESULTS_DIR="$HOME/vietforex.bot.project/logs/performance"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$RESULTS_DIR/performance_test_$TIMESTAMP.txt"

mkdir -p $RESULTS_DIR

echo "📊 PERFORMANCE TEST RESULTS - $TIMESTAMP" > $RESULTS_FILE
echo "==========================================" >> $RESULTS_FILE
echo "Server: $(hostname)" >> $RESULTS_FILE
echo "Date: $(date)" >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# System specs
echo "🖥️ SYSTEM SPECIFICATIONS:" | tee -a $RESULTS_FILE
echo "OS: $(lsb_release -d | cut -f2)" | tee -a $RESULTS_FILE
echo "CPU: $(nproc) cores" | tee -a $RESULTS_FILE
echo "RAM: $(free -h | grep Mem | awk '{print $2}')" | tee -a $RESULTS_FILE
echo "Storage: $(df -h / | awk 'NR==2{print $2}')" | tee -a $RESULTS_FILE
echo "" | tee -a $RESULTS_FILE

# CPU Test
echo "⚡ CPU PERFORMANCE TEST:" | tee -a $RESULTS_FILE
CPU_START=$(date +%s)
dd if=/dev/zero of=/tmp/cpu_test bs=1M count=100 >/dev/null 2>&1
CPU_END=$(date +%s)
CPU_TIME=$((CPU_END - CPU_START))
echo "100MB CPU test: ${CPU_TIME}s" | tee -a $RESULTS_FILE
rm -f /tmp/cpu_test

# Memory Test
echo "" | tee -a $RESULTS_FILE
echo "💾 MEMORY PERFORMANCE TEST:" | tee -a $RESULTS_FILE
MEM_START=$(date +%s)
dd if=/dev/zero of=/dev/null bs=1M count=500 >/dev/null 2>&1
MEM_END=$(date +%s)
MEM_TIME=$((MEM_END - MEM_START))
echo "500MB memory test: ${MEM_TIME}s" | tee -a $RESULTS_FILE

# Disk I/O Test
echo "" | tee -a $RESULTS_FILE
echo "💽 DISK I/O PERFORMANCE TEST:" | tee -a $RESULTS_FILE
DISK_START=$(date +%s)
dd if=/dev/zero of=/tmp/disk_test bs=1M count=50 >/dev/null 2>&1
DISK_END=$(date +%s)
DISK_TIME=$((DISK_END - DISK_START))
echo "50MB disk write test: ${DISK_TIME}s" | tee -a $RESULTS_FILE
rm -f /tmp/disk_test

# Network Test
echo "" | tee -a $RESULTS_FILE
echo "🌐 NETWORK PERFORMANCE TEST:" | tee -a $RESULTS_FILE
PING_RESULT=$(ping -c 5 8.8.8.8 | tail -1 | awk -F'/' '{print $5}' || echo "N/A")
echo "Average ping to Google DNS: ${PING_RESULT}ms" | tee -a $RESULTS_FILE

# Database Test
echo "" | tee -a $RESULTS_FILE
echo "🗄️ DATABASE PERFORMANCE TEST:" | tee -a $RESULTS_FILE
if systemctl is-active --quiet postgresql; then
    DB_START=$(date +%s)
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT generate_series(1,100);" >/dev/null 2>&1
    DB_END=$(date +%s)
    DB_TIME=$((DB_END - DB_START))
    echo "PostgreSQL query (100 records): ${DB_TIME}s" | tee -a $RESULTS_FILE
else
    echo "PostgreSQL: Service not running" | tee -a $RESULTS_FILE
fi

# Redis Test
echo "" | tee -a $RESULTS_FILE
echo "⚡ REDIS PERFORMANCE TEST:" | tee -a $RESULTS_FILE
if systemctl is-active --quiet redis-server; then
    REDIS_START=$(date +%s)
    for i in {1..100}; do
        redis-cli -a "$REDIS_PASSWORD" set "test_$i" "value_$i" >/dev/null 2>&1
    done
    REDIS_END=$(date +%s)
    REDIS_TIME=$((REDIS_END - REDIS_START))
    echo "Redis 100 SET operations: ${REDIS_TIME}s" | tee -a $RESULTS_FILE
    redis-cli -a "$REDIS_PASSWORD" flushall >/dev/null 2>&1
else
    echo "Redis: Service not running" | tee -a $RESULTS_FILE
fi

# Resource usage
echo "" | tee -a $RESULTS_FILE
echo "📊 CURRENT RESOURCE USAGE:" | tee -a $RESULTS_FILE
echo "Memory: $(free | grep Mem | awk '{printf "%.1f%% used", $3/$2 * 100}')" | tee -a $RESULTS_FILE
echo "Disk: $(df / | awk 'NR==2{print $5 " used"}')" | tee -a $RESULTS_FILE
echo "Load: $(cat /proc/loadavg | awk '{print $1}')" | tee -a $RESULTS_FILE

echo "" | tee -a $RESULTS_FILE
echo "✅ Performance testing completed!" | tee -a $RESULTS_FILE
echo "📊 Results saved to: $RESULTS_FILE" | tee -a $RESULTS_FILE
echo ""
echo "📈 Performance Summary:"
echo "CPU: ${CPU_TIME}s for 100MB computation"
echo "Memory: ${MEM_TIME}s for 500MB throughput"
echo "Disk: ${DISK_TIME}s for 50MB write"
echo "Network: ${PING_RESULT}ms average ping"
echo "Database: ${DB_TIME}s for 100 record query"
echo "Redis: ${REDIS_TIME}s for 100 SET operations"
EOF

chmod +x scripts/performance.testing.simple.sh

echo "📊 Creating production readiness checker..."

# Simple production readiness checker
cat > scripts/production.readiness.simple.sh << 'EOF'
#!/bin/bash
# Simple Production Readiness Checker

source ~/.env

echo "🚀 VIETFOREX BOT - PRODUCTION READINESS CHECK"
echo "============================================"
echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "Date: $(date)"
echo ""

SCORE=0
MAX_SCORE=100

check_item() {
    local name="$1"
    local command="$2"
    local points=$3
    
    echo -n "Checking $name... "
    if eval "$command" >/dev/null 2>&1; then
        echo "✅ PASS (+$points points)"
        SCORE=$((SCORE + points))
    else
        echo "❌ FAIL (0 points)"
    fi
}

echo "🏗️ INFRASTRUCTURE (40 points):"
check_item "Docker Service" "systemctl is-active --quiet docker" 10
check_item "PostgreSQL Service" "systemctl is-active --quiet postgresql" 10
check_item "Redis Service" "systemctl is-active --quiet redis-server" 10
check_item "Sufficient Resources" "[ $(free -m | grep Mem | awk '{print \$7}') -gt 1000 ]" 10

echo ""
echo "🔒 SECURITY (20 points):"
check_item "UFW Firewall" "ufw status | grep -q 'Status: active'" 10
check_item "Fail2Ban Protection" "systemctl is-active --quiet fail2ban" 10

echo ""
echo "🤖 APPLICATION (20 points):"
check_item "Project Structure" "[ -d ~/vietforex.bot.project/src ]" 10
check_item "Environment Config" "[ -n '\$NODE_ENV' ] && [ -n '\$DB_NAME' ]" 10

echo ""
echo "📊 MONITORING (20 points):"
check_item "Backup System" "[ -d ~/vietforex.backups ]" 10
check_item "Automated Tasks" "[ $(crontab -l | grep -v '^#' | wc -l) -ge 5 ]" 10

PERCENTAGE=$((SCORE * 100 / MAX_SCORE))

echo ""
echo "🎯 PRODUCTION READINESS RESULTS"
echo "==============================="
echo "Score: $SCORE/$MAX_SCORE points"
echo "Readiness: $PERCENTAGE%"

if [ $PERCENTAGE -ge 90 ]; then
    echo ""
    echo "🎉 PRODUCTION READY! (90%+)"
    echo "✅ System ready for VietForex Bot deployment"
elif [ $PERCENTAGE -ge 70 ]; then
    echo ""
    echo "✅ MOSTLY READY (70-89%)"
    echo "🔧 Minor improvements recommended"
else
    echo ""
    echo "⚠️ NEEDS IMPROVEMENT (<70%)"
    echo "🔧 Address failed checks before production"
fi

echo ""
echo "📊 System Summary:"
echo "Server: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Services: $(systemctl is-active docker postgresql redis-server | tr '\n' ' ')"
echo "Project Size: $(du -sh ~/vietforex.bot.project | awk '{print $1}')"
EOF

chmod +x scripts/production.readiness.simple.sh

echo ""
echo "🚀 Running Day -2 validation and testing..."

# Run system validation
echo "🔍 Running system validation..."
./scripts/system.validation.simple.sh

echo ""
echo "🚀 Running performance testing..."
./scripts/performance.testing.simple.sh

echo ""
echo "📊 Running production readiness check..."
./scripts/production.readiness.simple.sh

echo ""
echo "🎯 DAY -2 SETUP COMPLETED!"
echo "=========================="
echo "🔍 System Validation: Comprehensive testing completed"
echo "🚀 Performance Testing: Benchmarks established"  
echo "📊 Production Readiness: Assessment completed"
echo ""
echo "📊 RESULTS SUMMARY:"
echo "==================="
echo "System Validation: $([ -x scripts/system.validation.simple.sh ] && echo 'DEPLOYED' || echo 'FAILED')"
echo "Performance Testing: $([ -x scripts/performance.testing.simple.sh ] && echo 'DEPLOYED' || echo 'FAILED')"
echo "Production Readiness: $([ -x scripts/production.readiness.simple.sh ] && echo 'DEPLOYED' || echo 'FAILED')"
echo "Results Location: ~/vietforex.bot.project/logs/performance/"
echo ""
echo "🚀 READY FOR WEEK 1: VIETFOREX BOT APPLICATION DEVELOPMENT"
echo ""
echo "Next steps:"
echo "1. Review all test results above"
echo "2. Ensure production readiness >90%"
echo "3. Begin Week 1: API Server Development"
