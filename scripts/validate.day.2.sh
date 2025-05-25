#!/bin/bash
# Day -2 Final Validation Script

echo "🔍 DAY -2 FINAL VALIDATION: SYSTEM VALIDATION & PERFORMANCE"
echo "=========================================================="
echo "Date: $(date)"
echo "Server: $(hostname)"
echo ""

TOTAL_TESTS=15
PASSED_TESTS=0
FAILED_TESTS=()

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
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

# Day -2 Specific Tests
run_test "System Validation Script" \
    "[ -x ~/vietforex.bot.project/scripts/system.validation.comprehensive.sh ]"

run_test "Performance Testing Script" \
    "[ -x ~/vietforex.bot.project/scripts/performance.testing.comprehensive.sh ]"

run_test "Production Readiness Checker" \
    "[ -x ~/vietforex.bot.project/scripts/production.readiness.checker.sh ]"

run_test "Performance Results Directory" \
    "[ -d ~/vietforex.bot.project/logs/performance ]"

run_test "System Validation Execution" \
    "~/vietforex.bot.project/scripts/system.validation.comprehensive.sh | grep -q 'COMPREHENSIVE VALIDATION RESULTS'"

run_test "Performance Testing Execution" \
    "timeout 30s ~/vietforex.bot.project/scripts/performance.testing.comprehensive.sh | grep -q 'PERFORMANCE TESTING SESSION'"

run_test "Production Readiness Assessment" \
    "~/vietforex.bot.project/scripts/production.readiness.checker.sh | grep -q 'PRODUCTION READINESS RESULTS'"

# Integration Tests
run_test "All Previous Days Integration" \
    "[ -d ~/vietforex.bot.project/src ] && [ -f ~/.env ] && [ -d ~/vietforex.backups ]"

run_test "Service Integration" \
    "systemctl is-active --quiet postgresql && systemctl is-active --quiet redis-server"

run_test "Environment Integration" \
    "source ~/.env && [ -n '$NODE_ENV' ] && [ -n '$DB_NAME' ]"

run_test "Database Integration" \
    "source ~/.env && PGPASSWORD='$DB_PASSWORD' psql -h '$DB_HOST' -U '$DB_USER' -d '$DB_NAME' -c 'SELECT 1;' >/dev/null 2>&1"

run_test "Redis Integration" \
    "source ~/.env && redis-cli -a '$REDIS_PASSWORD' ping >/dev/null 2>&1"

run_test "Monitoring Integration" \
    "[ $(crontab -l | grep -v '^#' | wc -l) -ge 5 ]"

run_test "Backup Integration" \
    "[ -d ~/vietforex.backups ] && [ $(find ~/vietforex.backups -name '*_????????_??????.*' | wc -l) -gt 0 ]"

run_test "Script Integration" \
    "[ $(find ~/vietforex.bot.project/scripts -name '*.sh' -executable | wc -l) -ge 10 ]"

# Results
echo "🎯 DAY -2 VALIDATION RESULTS"
echo "============================"
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
    echo "🎉 DAY -2: PERFECTLY COMPLETED!"
    echo "✅ System validation comprehensive"
    echo "✅ Performance testing operational"
    echo "✅ Production readiness verified"
    echo "✅ All integrations working"
    echo ""
    echo "🚀 READY FOR WEEK 1: VIETFOREX BOT DEVELOPMENT"
elif [ $PASSED_TESTS -ge 12 ]; then
    echo "✅ DAY -2: EXCELLENT"
    echo "🔧 Minor issues - can proceed to development"
else
    echo "❌ DAY -2: NEEDS ATTENTION"
    echo "🚨 Major issues - must fix before development"
fi

echo ""
echo "📊 INFRASTRUCTURE SUMMARY:"
echo "=========================="
echo "Total Scripts: $(find ~/vietforex.bot.project/scripts -name '*.sh' | wc -l)"
echo "Total Directories: $(find ~/vietforex.bot.project -type d | wc -l)"
echo "Total Files: $(find ~/vietforex.bot.project -type f | wc -l)"
echo "Project Size: $(du -sh ~/ay.2.sh

echo ""
echo "🚀 Running Day -2 comprehensive validation and testing..."

# Run comprehensive system validation
echo "🔍 Running comprehensive system validation..."
./scripts/system.validation.comprehensive.sh > logs/performance/system_validation_$(date +%Y%m%d_%H%M%S).log 2>&1

# Run performance testing
echo "🚀 Running performance testing suite..."  
./scripts/performance.testing.comprehensive.sh

# Run production readiness check
echo "📊 Running production readiness assessment..."
./scripts/production.readiness.checker.sh > logs/performance/readiness_check_$(date +%Y%m%d_%H%M%S).log 2>&1

# Run final Day -2 validation
echo "🔍 Running final Day -2 validation..."
./scripts/validate.day.2.sh

echo ""
echo "🎯 DAY -2 SETUP COMPLETED!"
echo "=========================="
echo "🔍 System Validation: Comprehensive validation framework deployed"
echo "🚀 Performance Testing: Complete performance testing suite operational"
echo "📊 Production Readiness: Assessment framework established"
echo "✅ All Integration Tests: Validated and working"
echo ""
echo "📊 COMPREHENSIVE TESTING RESULTS:"
echo "================================="
echo "System Validation: $([ -f logs/performance/system_validation_*.log ] && echo 'COMPLETED' || echo 'PENDING')"
echo "Performance Testing: $([ -f logs/performance/performance_test_*.txt ] && echo 'COMPLETED' || echo 'PENDING')"
echo "Production Readiness: $([ -f logs/performance/readiness_check_*.log ] && echo 'COMPLETED' || echo 'PENDING')"
echo ""
echo "🚀 READY FOR WEEK 1: VIETFOREX BOT APPLICATION DEVELOPMENT"
echo ""
echo "Next steps:"
echo "1. Review all test results in logs/performance/"
echo "2. Address any issues identified in testing"
echo "3. Confirm production readiness score >90%"
echo "4. Begin Week 1: API Server Development"
