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
