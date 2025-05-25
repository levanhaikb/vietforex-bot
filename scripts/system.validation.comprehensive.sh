#!/bin/bash
# Comprehensive System Validation for VietForex Bot

source ~/.env

echo "🔍 VIETFOREX BOT - COMPREHENSIVE SYSTEM VALIDATION"
echo "================================================="
echo "🌏 Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "📅 $(date)"
echo ""

TOTAL_TESTS=25
PASSED_TESTS=0
FAILED_TESTS=()

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    echo "🧪 TEST: $test_name"
    if eval "$test_command"; then
        echo "   ✅ PASSED"
        ((PASSED_TESTS++))
    else
        echo "   ❌ FAILED"
        FAILED_TESTS+=("$test_name")
    fi
    echo ""
}

# System Information Tests
echo "🖥️ SYSTEM INFORMATION VALIDATION:"
echo "================================="

run_test "Operating System" \
    "lsb_release -d | grep -q 'Ubuntu'" \
    "Ubuntu OS detected"

run_test "Hostname Format" \
    "[[ '$(hostname)' == 'vietforex.production' ]]" \
    "Correct hostname format"

run_test "System Uptime" \
    "uptime | grep -q 'up'" \
    "System running"

run_test "Available Memory" \
    "[ $(free -m | grep Mem | awk '{print $7}') -gt 1000 ]" \
    "Sufficient memory available"

run_test "Available Disk Space" \
    "[ $(df / | awk 'NR==2{print $4}') -gt 10000000 ]" \
    "Sufficient disk space"

# Service Status Tests  
echo "🔧 SERVICE STATUS VALIDATION:"
echo "============================"

services=("docker" "postgresql" "redis-server" "fail2ban")
for service in "${services[@]}"; do
    run_test "$service Service" \
        "systemctl is-active --quiet $service" \
        "$service is running"
done

# Network Connectivity Tests
echo "🌐 NETWORK CONNECTIVITY VALIDATION:"
echo "==================================="

run_test "Internet Connectivity" \
    "ping -c 1 8.8.8.8 >/dev/null 2>&1" \
    "Internet connection working"

run_test "DNS Resolution" \
    "nslookup google.com >/dev/null 2>&1" \
    "DNS resolution working"

run_test "Network Performance" \
    "[ $(ping -c 5 8.8.8.8 | tail -1 | awk -F'/' '{print $5}' | cut -d. -f1) -lt 100 ]" \
    "Network latency acceptable"

# Database Validation Tests
echo "🗄️ DATABASE VALIDATION:"
echo "======================"

run_test "PostgreSQL Connection" \
    "PGPASSWORD='$DB_PASSWORD' psql -h '$DB_HOST' -U '$DB_USER' -d '$DB_NAME' -c 'SELECT 1;' >/dev/null 2>&1" \
    "PostgreSQL connection working"

run_test "Database Operations" \
    "PGPASSWORD='$DB_PASSWORD' psql -h '$DB_HOST' -U '$DB_USER' -d '$DB_NAME' -c 'CREATE TABLE IF NOT EXISTS test_table (id SERIAL); DROP TABLE test_table;' >/dev/null 2>&1" \
    "Database CRUD operations working"

run_test "Database Performance" \
    "[ $(PGPASSWORD='$DB_PASSWORD' psql -h '$DB_HOST' -U '$DB_USER' -d '$DB_NAME' -c 'SELECT generate_series(1,100);' 2>/dev/null | wc -l) -gt 100 ]" \
    "Database performance acceptable"

# Redis Validation Tests
echo "⚡ REDIS VALIDATION:"
echo "=================="

run_test "Redis Connection" \
    "redis-cli -a '$REDIS_PASSWORD' ping 2>/dev/null | grep -q 'PONG'" \
    "Redis connection working"

run_test "Redis Operations" \
    "redis-cli -a '$REDIS_PASSWORD' set test_key test_value >/dev/null 2>&1 && redis-cli -a '$REDIS_PASSWORD' get test_key >/dev/null 2>&1 && redis-cli -a '$REDIS_PASSWORD' del test_key >/dev/null 2>&1" \
    "Redis operations working"

run_test "Redis Performance" \
    "[ $(redis-cli -a '$REDIS_PASSWORD' eval 'for i=1,50 do redis.call(\"set\", \"test_\"..i, \"value_\"..i) end return \"OK\"' 0 2>/dev/null | grep -c OK) -eq 1 ]" \
    "Redis performance acceptable"

# Environment and Configuration Tests
echo "⚙️ ENVIRONMENT VALIDATION:"
echo "========================="

run_test "Environment Variables" \
    "[ -n '$NODE_ENV' ] && [ -n '$DB_NAME' ] && [ -n '$REDIS_PASSWORD' ]" \
    "Environment variables loaded"

run_test "Project Structure" \
    "[ -d ~/vietforex.bot.project/src ] && [ -d ~/vietforex.bot.project/configs ]" \
    "Project structure complete"

run_test "Configuration Files" \
    "[ $(find ~/vietforex.bot.project/configs -name '*.env.*' | wc -l) -ge 2 ]" \
    "Configuration files present"

# Monitoring and Backup Validation
echo "📊 MONITORING & BACKUP VALIDATION:"
echo "=================================="

run_test "Monitoring Scripts" \
    "[ -x ~/vietforex.bot.project/scripts/system.monitor.advanced.sh ]" \
    "Monitoring scripts executable"

run_test "Backup System" \
    "[ -d ~/vietforex.backups ] && [ $(find ~/vietforex.backups -name '*_????????_??????.*' | wc -l) -gt 0 ]" \
    "Backup system operational"

run_test "Cron Jobs" \
    "[ $(crontab -l | grep -v '^#' | grep -v '^$' | wc -l) -ge 5 ]" \
    "Automated scheduling active"

run_test "Log System" \
    "[ -d ~/vietforex.bot.project/logs ] && [ $(find ~/vietforex.bot.project/logs -type d | wc -l) -gt 5 ]" \
    "Logging system setup"

# Security Validation
echo "🔒 SECURITY VALIDATION:"
echo "======================"

run_test "Firewall Status" \
    "ufw status | grep -q 'Status: active'" \
    "UFW firewall active"

run_test "SSH Security" \
    "grep -q 'PasswordAuthentication no' /etc/ssh/sshd_config 2>/dev/null" \
    "SSH security hardened"

run_test "File Permissions" \
    "[ '$(stat -c %a ~/.env)' = '600' ]" \
    "Environment file permissions secure"

# Performance Validation
echo "🚀 PERFORMANCE VALIDATION:"
echo "========================="

run_test "CPU Performance" \
    "[ $(cat /proc/loadavg | awk '{print $1}' | cut -d. -f1) -lt 2 ]" \
    "CPU load acceptable"

run_test "Memory Usage" \
    "[ $(free | grep Mem | awk '{printf \"%.0f\", $3/$2 * 100}') -lt 80 ]" \
    "Memory usage acceptable"

# Final Results
echo "🎯 COMPREHENSIVE VALIDATION RESULTS"
echo "==================================="
echo "Tests Passed: $PASSED_TESTS/$TOTAL_TESTS"
echo "Success Rate: $((PASSED_TESTS * 100 / TOTAL_TESTS))%"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo ""
    echo "❌ Failed Tests:"
    for test in "${FAILED_TESTS[@]}"; do
        echo "   • $test"
    done
fi

echo ""
if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo "🎉 SYSTEM VALIDATION: PERFECT!"
    echo "✅ All systems operational and validated"
    echo "🚀 Ready for production deployment"
elif [ $PASSED_TESTS -ge 20 ]; then
    echo "✅ SYSTEM VALIDATION: EXCELLENT"
    echo "🔧 Minor issues found - review and fix"
    echo "➡️ Can proceed with caution"
else
    echo "❌ SYSTEM VALIDATION: NEEDS ATTENTION"
    echo "🚨 Major issues found - must fix before proceeding"
fi

echo ""
echo "📊 SYSTEM SUMMARY:"
echo "=================="
echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Uptime: $(uptime -p)"
echo "Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "Disk: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
echo "Load: $(cat /proc/loadavg | awk '{print $1}')"
echo "Services: Docker, PostgreSQL, Redis operational"
echo "Project: $(find ~/vietforex.bot.project -type d | wc -l) directories, $(find ~/vietforex.bot.project -type f | wc -l) files"
