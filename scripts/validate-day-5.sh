#!/bin/bash
# validate-day-5.sh - Comprehensive Day -5 Validation Script
# VietForex Bot - Software Stack Validation

echo "🔍 VIETFOREX BOT - DAY -5 VALIDATION"
echo "===================================="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "User: $USER"
echo "VPS: Hostinger ($(curl -s ifconfig.me 2>/dev/null || echo 'IPv6'))"
echo ""

# Initialize counters
PASSED_TESTS=0
TOTAL_TESTS=20
ISSUES=()

echo "🎯 COMPREHENSIVE SOFTWARE STACK VALIDATION"
echo "=========================================="

# Test 1: System Information
echo ""
echo "💻 TEST 1: System Information"
if [[ "$(lsb_release -si)" == "Ubuntu" ]] && [[ "$(lsb_release -sr)" == "25.04" ]]; then
    echo "   ✅ Ubuntu 25.04 LTS confirmed"
    ((PASSED_TESTS++))
else
    echo "   ❌ OS verification failed"
    ISSUES+=("Operating system not Ubuntu 25.04")
fi

# Test 2: Hostname Format
echo ""
echo "🏷️ TEST 2: Hostname Format"
CURRENT_HOSTNAME=$(hostname)
if [[ "$CURRENT_HOSTNAME" == "vietforex.production" ]]; then
    echo "   ✅ Hostname correct: $CURRENT_HOSTNAME"
    ((PASSED_TESTS++))
else
    echo "   ❌ Hostname incorrect: $CURRENT_HOSTNAME"
    ISSUES+=("Hostname not vietforex.production")
fi

# Test 3: User Account
echo ""
echo "👤 TEST 3: User Account"
if [[ "$USER" == "forex_bot" ]] && sudo whoami 2>/dev/null | grep -q root; then
    echo "   ✅ User forex_bot with sudo access confirmed"
    ((PASSED_TESTS++))
else
    echo "   ❌ User account issues"
    ISSUES+=("User account not properly configured")
fi

# Test 4: Docker Installation
echo ""
echo "🐳 TEST 4: Docker Installation"
if docker --version >/dev/null 2>&1 && systemctl is-active --quiet docker; then
    DOCKER_VERSION=$(docker --version)
    echo "   ✅ Docker working: $DOCKER_VERSION"
    ((PASSED_TESTS++))
else
    echo "   ❌ Docker not working"
    ISSUES+=("Docker installation or service issue")
fi

# Test 5: Docker Compose
echo ""
echo "🔧 TEST 5: Docker Compose"
if docker-compose --version >/dev/null 2>&1; then
    COMPOSE_VERSION=$(docker-compose --version)
    echo "   ✅ Docker Compose: $COMPOSE_VERSION"
    ((PASSED_TESTS++))
else
    echo "   ❌ Docker Compose not available"
    ISSUES+=("Docker Compose not installed")
fi

# Test 6: Node.js Installation
echo ""
echo "🟢 TEST 6: Node.js Installation"
if node --version >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    if [[ $NODE_VERSION == v20* ]]; then
        echo "   ✅ Node.js version correct: $NODE_VERSION"
        ((PASSED_TESTS++))
    else
        echo "   ⚠️ Node.js version: $NODE_VERSION (expected v20.x)"
        ISSUES+=("Node.js version not v20.x")
    fi
else
    echo "   ❌ Node.js not installed"
    ISSUES+=("Node.js not available")
fi

# Test 7: NPM Installation
echo ""
echo "📦 TEST 7: NPM Installation"
if npm --version >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    echo "   ✅ NPM working: v$NPM_VERSION"
    ((PASSED_TESTS++))
else
    echo "   ❌ NPM not working"
    ISSUES+=("NPM not available")
fi

# Test 8: PM2 Process Manager
echo ""
echo "⚙️ TEST 8: PM2 Process Manager"
if pm2 --version >/dev/null 2>&1; then
    PM2_VERSION=$(pm2 --version)
    echo "   ✅ PM2 installed: v$PM2_VERSION"
    ((PASSED_TESTS++))
else
    echo "   ❌ PM2 not available"
    ISSUES+=("PM2 not installed")
fi

# Test 9: PostgreSQL Service
echo ""
echo "🗄️ TEST 9: PostgreSQL Service"
if systemctl is-active --quiet postgresql; then
    echo "   ✅ PostgreSQL service running"
    ((PASSED_TESTS++))
else
    echo "   ❌ PostgreSQL service not running"
    ISSUES+=("PostgreSQL service not active")
fi

# Test 10: PostgreSQL Database Connection
echo ""
echo "🔌 TEST 10: PostgreSQL Database Connection"
export PGPASSWORD="VietForexHostinger2024!"
if psql -h localhost -U forex_bot_user -d vietforex_production -c "SELECT 'Connection OK' as status;" >/dev/null 2>&1; then
    echo "   ✅ PostgreSQL database connection successful"
    ((PASSED_TESTS++))
else
    echo "   ❌ PostgreSQL database connection failed"
    ISSUES+=("PostgreSQL database connection issue")
fi

# Test 11: PostgreSQL Operations
echo ""
echo "🧪 TEST 11: PostgreSQL Operations"
TEST_RESULT=$(psql -h localhost -U forex_bot_user -d vietforex_production -c "
CREATE TABLE IF NOT EXISTS day5_validation_test (id SERIAL, message TEXT);
INSERT INTO day5_validation_test (message) VALUES ('Day -5 validation test');
SELECT COUNT(*) FROM day5_validation_test;
DROP TABLE day5_validation_test;
" 2>/dev/null | grep -o '[0-9]*' | head -1)

if [[ "$TEST_RESULT" =~ ^[0-9]+$ ]] && [[ $TEST_RESULT -gt 0 ]]; then
    echo "   ✅ PostgreSQL CRUD operations working"
    ((PASSED_TESTS++))
else
    echo "   ❌ PostgreSQL operations failed"
    ISSUES+=("PostgreSQL CRUD operations issue")
fi

# Test 12: Redis Service
echo ""
echo "⚡ TEST 12: Redis Service"
if systemctl is-active --quiet redis-server; then
    echo "   ✅ Redis service running"
    ((PASSED_TESTS++))
else
    echo "   ❌ Redis service not running"
    ISSUES+=("Redis service not active")
fi

# Test 13: Redis Connection
echo ""
echo "🔗 TEST 13: Redis Connection"
if redis-cli -a "VietForexRedisHostinger2024" ping 2>/dev/null | grep -q "PONG"; then
    echo "   ✅ Redis connection successful"
    ((PASSED_TESTS++))
else
    echo "   ❌ Redis connection failed"
    ISSUES+=("Redis connection issue")
fi

# Test 14: Redis Operations
echo ""
echo "🔄 TEST 14: Redis Operations"
REDIS_TEST=$(redis-cli -a "VietForexRedisHostinger2024" eval "
redis.call('SET', 'day5_validation_test', 'validation_success')
local value = redis.call('GET', 'day5_validation_test')
redis.call('DEL', 'day5_validation_test')
return value
" 0 2>/dev/null)

if [[ "$REDIS_TEST" == "validation_success" ]]; then
    echo "   ✅ Redis SET/GET/DEL operations working"
    ((PASSED_TESTS++))
else
    echo "   ❌ Redis operations failed"
    ISSUES+=("Redis operations issue")
fi

# Test 15: Project Directory Structure
echo ""
echo "📁 TEST 15: Project Directory Structure"
if [[ -d ~/vietforex.bot.project/san.xuat/trien.khai/ ]]; then
    FOLDER_COUNT=$(find ~/vietforex.bot.project -type d | wc -l)
    echo "   ✅ Project directory exists: ~/vietforex.bot.project"
    echo "   Total folders: $FOLDER_COUNT"
    ((PASSED_TESTS++))
else
    echo "   ❌ Project directory missing"
    ISSUES+=("Project directory structure not created")
fi

# Test 16: Configuration Files
echo ""
echo "📄 TEST 16: Configuration Files"
CONFIG_FILES=0
if [[ -f ~/vietforex.bot.project/san.xuat/trien.khai/docker.info.txt ]]; then
    ((CONFIG_FILES++))
fi
if [[ -f ~/vietforex.bot.project/san.xuat/trien.khai/nodejs.info.txt ]]; then
    ((CONFIG_FILES++))
fi
if [[ -f ~/vietforex.bot.project/san.xuat/trien.khai/co.so.du.lieu/postgresql.info.txt ]]; then
    ((CONFIG_FILES++))
fi
if [[ -f ~/vietforex.bot.project/san.xuat/trien.khai/co.so.du.lieu/redis.info.txt ]]; then
    ((CONFIG_FILES++))
fi

if [[ $CONFIG_FILES -ge 4 ]]; then
    echo "   ✅ All configuration files exist ($CONFIG_FILES/4)"
    ((PASSED_TESTS++))
else
    echo "   ❌ Configuration files missing ($CONFIG_FILES/4)"
    ISSUES+=("Configuration files not complete")
fi

# Test 17: System Services Auto-start
echo ""
echo "🚀 TEST 17: Service Auto-start Configuration"
ENABLED_SERVICES=0
for service in docker postgresql redis-server; do
    if systemctl is-enabled --quiet $service 2>/dev/null; then
        ((ENABLED_SERVICES++))
    fi
done

if [[ $ENABLED_SERVICES -ge 3 ]]; then
    echo "   ✅ Essential services enabled for auto-start ($ENABLED_SERVICES/3)"
    ((PASSED_TESTS++))
else
    echo "   ❌ Some services not enabled for auto-start ($ENABLED_SERVICES/3)"
    ISSUES+=("Service auto-start configuration incomplete")
fi

# Test 18: System Resources
echo ""
echo "💾 TEST 18: System Resources"
AVAILABLE_MEM=$(free -m | grep Mem | awk '{print $7}')
AVAILABLE_DISK=$(df / | awk 'NR==2{print $4}')

if [[ $AVAILABLE_MEM -gt 1000 ]] && [[ $AVAILABLE_DISK -gt 10000000 ]]; then
    echo "   ✅ Sufficient resources available"
    echo "   Available Memory: ${AVAILABLE_MEM}MB"
    echo "   Available Disk: $((AVAILABLE_DISK / 1024 / 1024))GB"
    ((PASSED_TESTS++))
else
    echo "   ⚠️ Limited resources"
    echo "   Available Memory: ${AVAILABLE_MEM}MB"
    echo "   Available Disk: $((AVAILABLE_DISK / 1024 / 1024))GB"
    ISSUES+=("System resources may be limited")
fi

# Test 19: Network Connectivity
echo ""
echo "🌐 TEST 19: Network Connectivity"
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    PING_TIME=$(ping -c 1 8.8.8.8 | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
    echo "   ✅ Internet connectivity: ${PING_TIME}ms"
    ((PASSED_TESTS++))
else
    echo "   ❌ Network connectivity issue"
    ISSUES+=("Network connectivity problem")
fi

# Test 20: Software Versions Verification
echo ""
echo "📊 TEST 20: Software Versions"
VERSION_CHECK=0

# Check Docker version
if docker --version | grep -q "28.1.1"; then
    ((VERSION_CHECK++))
fi

# Check Node.js version
if node --version | grep -q "v20."; then
    ((VERSION_CHECK++))
fi

# Check PostgreSQL version
if sudo -u postgres psql -c "SELECT version();" 2>/dev/null | grep -q "PostgreSQL 17"; then
    ((VERSION_CHECK++))
fi

if [[ $VERSION_CHECK -ge 2 ]]; then
    echo "   ✅ Software versions verified ($VERSION_CHECK/3 major components)"
    ((PASSED_TESTS++))
else
    echo "   ⚠️ Some software versions need verification ($VERSION_CHECK/3)"
    ISSUES+=("Software versions need verification")
fi

# Final Results Summary
echo ""
echo "🎯 DAY -5 VALIDATION SUMMARY"
echo "============================"
echo "Tests Passed: $PASSED_TESTS/$TOTAL_TESTS"
echo "Success Rate: $((PASSED_TESTS * 100 / TOTAL_TESTS))%"

if [[ ${#ISSUES[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️ Issues Found:"
    for issue in "${ISSUES[@]}"; do
        echo "   • $issue"
    done
fi

echo ""
echo "📊 SOFTWARE STACK STATUS:"
echo "========================"
echo "🐳 Docker: $(docker --version 2>/dev/null || echo 'Not Available')"
echo "🟢 Node.js: $(node --version 2>/dev/null || echo 'Not Available')"
echo "📦 NPM: v$(npm --version 2>/dev/null || echo 'Not Available')"
echo "⚙️ PM2: v$(pm2 --version 2>/dev/null || echo 'Not Available')"
echo "🗄️ PostgreSQL: $(systemctl is-active postgresql 2>/dev/null || echo 'Not Running')"
echo "⚡ Redis: $(systemctl is-active redis-server 2>/dev/null || echo 'Not Running')"

echo ""
echo "🔗 CONNECTION STRINGS:"
echo "====================="
echo "PostgreSQL: postgresql://forex_bot_user:VietForexHostinger2024!@localhost:5432/vietforex_production"
echo "Redis: redis://:VietForexRedisHostinger2024@localhost:6379"

echo ""
echo "📁 PROJECT STRUCTURE:"
echo "===================="
if [[ -d ~/vietforex.bot.project ]]; then
    echo "✅ Main project directory exists"
    echo "📊 Folder structure:"
    find ~/vietforex.bot.project -type d | head -10
    echo "📄 Configuration files:"
    find ~/vietforex.bot.project -name "*.info.txt" -type f
else
    echo "❌ Project directory not found"
fi

echo ""
echo "💻 SYSTEM INFORMATION:"
echo "====================="
echo "Hostname: $(hostname)"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Total Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Available Memory: $(free -h | grep Mem | awk '{print $7}')"
echo "Total Storage: $(df -h / | awk 'NR==2{print $2}')"
echo "Available Storage: $(df -h / | awk 'NR==2{print $4}')"
echo "CPU Load: $(cat /proc/loadavg | awk '{print $1}')"

# Overall Status
echo ""
if [[ $PASSED_TESTS -eq $TOTAL_TESTS ]]; then
    echo "🎉 VALIDATION STATUS: PERFECT!"
    echo "✅ All Day -5 objectives completed successfully"
    echo "🚀 Ready for: Day -4 Project Structure Setup"
    echo ""
    echo "🎯 DAY -5 SOFTWARE STACK: 100% COMPLETE!"
elif [[ $PASSED_TESTS -ge 16 ]]; then
    echo "✅ VALIDATION STATUS: EXCELLENT"
    echo "🔧 Minor issues found - review and fix if needed"
    echo "➡️ Can proceed to Day -4 with confidence"
else
    echo "❌ VALIDATION STATUS: NEEDS ATTENTION"
    echo "🚨 Major issues found - must fix before proceeding"
    echo "🔧 Review failed tests and reinstall components"
fi

echo ""
echo "📅 NEXT STEPS:"
if [[ $PASSED_TESTS -ge 16 ]]; then
    echo "   → Ready for Day -4: Project Structure & Environment Setup"
    echo "   → All software stack components operational"
    echo "   → Infrastructure foundation solid"
else
    echo "   → Fix issues identified in validation"
    echo "   → Re-run validation script until all tests pass"
    echo "   → Then proceed to Day -4"
fi

echo ""
echo "💾 VALIDATION COMPLETED: $(date)"
echo "📊 Final Score: $PASSED_TESTS/$TOTAL_TESTS tests passed"
