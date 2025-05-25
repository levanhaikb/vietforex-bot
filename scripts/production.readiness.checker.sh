#!/bin/bash
# Production Readiness Checker for VietForex Bot

source ~/.env

echo "🚀 VIETFOREX BOT - PRODUCTION READINESS CHECKER"
echo "=============================================="
echo "🌏 Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "📅 $(date)"
echo ""

READINESS_SCORE=0
MAX_SCORE=100
CRITICAL_ISSUES=()
WARNINGS=()

# Scoring function
add_score() {
    local points=$1
    local description="$2"
    READINESS_SCORE=$((READINESS_SCORE + points))
    echo "✅ +$points points: $description"
}

add_warning() {
    local description="$1"
    WARNINGS+=("$description")
    echo "⚠️ WARNING: $description"
}

add_critical() {
    local description="$1"
    CRITICAL_ISSUES+=("$description")
    echo "🚨 CRITICAL: $description"
}

echo "🔍 PRODUCTION READINESS ASSESSMENT:"
echo "==================================="

# Infrastructure Readiness (25 points)
echo ""
echo "🏗️ INFRASTRUCTURE READINESS (25 points):"
if systemctl is-active --quiet docker; then
    add_score 5 "Docker service operational"
else
    add_critical "Docker service not running"
fi

if systemctl is-active --quiet postgresql; then
    add_score 5 "PostgreSQL service operational"
else
    add_critical "PostgreSQL service not running"
fi

if systemctl is-active --quiet redis-server; then
    add_score 5 "Redis service operational"
else
    add_critical "Redis service not running"
fi

if [ $(df / | awk 'NR==2{print $5}' | cut -d% -f1) -lt 80 ]; then
    add_score 5 "Sufficient disk space available"
else
    add_warning "Disk usage approaching limits"
fi

if [ $(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}') -lt 70 ]; then
    add_score 5 "Memory usage within acceptable limits"
else
    add_warning "High memory usage detected"
fi

# Security Readiness (20 points)
echo ""
echo "🔒 SECURITY READINESS (20 points):"
if ufw status | grep -q "Status: active"; then
    add_score 5 "UFW firewall active"
else
    add_critical "UFW firewall not active"
fi

if systemctl is-active --quiet fail2ban; then
    add_score 5 "Fail2Ban intrusion protection active"
else
    add_warning "Fail2Ban not running"
fi

if [ "$(stat -c %a ~/.env)" = "600" ]; then
    add_score 5 "Environment file permissions secure"
else
    add_warning "Environment file permissions not secure"
fi

if grep -q "PasswordAuthentication no" /etc/ssh/sshd_config 2>/dev/null; then
    add_score 5 "SSH password authentication disabled"
else
    add_warning "SSH security not fully hardened"
fi

# Application Readiness (20 points)
echo ""
echo "🤖 APPLICATION READINESS (20 points):"
if [ -d ~/vietforex.bot.project/src ] && [ $(find ~/vietforex.bot.project/src -type d | wc -l) -gt 5 ]; then
    add_score 5 "Application structure complete"
else
    add_critical "Application structure incomplete"
fi

if [ -f ~/.env ] && [ -n "$NODE_ENV" ] && [ -n "$DB_NAME" ]; then
    add_score 5 "Environment configuration complete"
else
    add_critical "Environment configuration incomplete"
fi

if [ $(find ~/vietforex.bot.project/configs -name "*.env.*" | wc -l) -ge 2 ]; then
    add_score 5 "Multiple environment configurations available"
else
    add_warning "Limited environment configurations"
fi

if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    add_score 5 "Database connectivity verified"
else
    add_critical "Database connectivity failed"
fi

# Monitoring & Backup Readiness (15 points)
echo ""
echo "📊 MONITORING & BACKUP READINESS (15 points):"
if [ -x ~/vietforex.bot.project/scripts/system.monitor.advanced.sh ]; then
    add_score 3 "Advanced monitoring system available"
else
    add_warning "Advanced monitoring not available"
fi

if [ -x ~/vietforex.bot.project/scripts/backup.comprehensive.sh ]; then
    add_score 3 "Comprehensive backup system available"
else
    add_critical "Backup system not available"
fi

if [ $(crontab -l | grep -v '^#' | grep -v '^ | wc -l) -ge 5 ]; then
    add_score 3 "Automated scheduling configured"
else
    add_warning "Insufficient automated tasks"
fi

if [ -d ~/vietforex.backups ] && [ $(find ~/vietforex.backups -name "*_????????_??????.*" | wc -l) -gt 0 ]; then
    add_score 3 "Backup system tested and operational"
else
    add_warning "Backup system not tested"
fi

if [ -d ~/vietforex.bot.project/logs ] && [ $(find ~/vietforex.bot.project/logs -type d | wc -l) -gt 3 ]; then
    add_score 3 "Logging system established"
else
    add_warning "Logging system incomplete"
fi

# Performance Readiness (10 points)
echo ""
echo "🚀 PERFORMANCE READINESS (10 points):"
if [ $(cat /proc/loadavg | awk '{print $1}' | cut -d. -f1) -lt 2 ]; then
    add_score 3 "System load acceptable"
else
    add_warning "High system load detected"
fi

if ping -c 3 8.8.8.8 >/dev/null 2>&1; then
    PING_TIME=$(ping -c 3 8.8.8.8 | tail -1 | awk -F'/' '{print $5}' | cut -d. -f1)
    if [ $PING_TIME -lt 100 ]; then
        add_score 2 "Network latency acceptable ($PING_TIME ms)"
    else
        add_warning "High network latency ($PING_TIME ms)"
    fi
else
    add_critical "Network connectivity issues"
fi

if redis-cli -a "$REDIS_PASSWORD" ping >/dev/null 2>&1; then
    add_score 2 "Redis performance verified"
else
    add_critical "Redis performance issues"
fi

if [ -f ~/vietforex.bot.project/logs/baselines/baseline_*.txt ]; then
    add_score 3 "Performance baseline established"
else
    add_warning "Performance baseline not established"
fi

# Documentation & Maintenance (10 points)
echo ""
echo "📚 DOCUMENTATION & MAINTENANCE (10 points):"
if [ -f ~/vietforex.bot.project/README.md ]; then
    add_score 2 "Project documentation available"
else
    add_warning "Project documentation missing"
fi

if [ $(find ~/vietforex.bot.project/scripts -name "*.sh" | wc -l) -ge 8 ]; then
    add_score 3 "Comprehensive maintenance scripts available"
else
    add_warning "Limited maintenance scripts"
fi

if [ -x ~/vietforex.bot.project/scripts/system.validation.comprehensive.sh ]; then
    add_score 2 "System validation tools available"
else
    add_warning "System validation tools missing"
fi

if [ -x ~/vietforex.bot.project/scripts/performance.testing.comprehensive.sh ]; then
    add_score 2 "Performance testing tools available"
else
    add_warning "Performance testing tools missing"
fi

if [ -x ~/vietforex.bot.project/scripts/alert.system.sh ]; then
    add_score 1 "Alert system configured"
else
    add_warning "Alert system not configured"
fi

# Calculate final readiness percentage
READINESS_PERCENTAGE=$((READINESS_SCORE * 100 / MAX_SCORE))

echo ""
echo "🎯 PRODUCTION READINESS RESULTS"
echo "==============================="
echo "Final Score: $READINESS_SCORE/$MAX_SCORE points"
echo "Readiness Level: $READINESS_PERCENTAGE%"

# Readiness Assessment
if [ $READINESS_PERCENTAGE -ge 90 ]; then
    echo ""
    echo "🎉 PRODUCTION READINESS: EXCELLENT (90%+)"
    echo "✅ System is production-ready"
    echo "✅ All critical components operational"
    echo "✅ Ready for VietForex Bot deployment"
elif [ $READINESS_PERCENTAGE -ge 75 ]; then
    echo ""
    echo "✅ PRODUCTION READINESS: GOOD (75-89%)"
    echo "🔧 Minor improvements recommended"
    echo "➡️ Can proceed to production with monitoring"
elif [ $READINESS_PERCENTAGE -ge 60 ]; then
    echo ""
    echo "⚠️ PRODUCTION READINESS: FAIR (60-74%)"
    echo "🔧 Several improvements needed"
    echo "⚠️ Address warnings before production"
else
    echo ""
    echo "❌ PRODUCTION READINESS: POOR (<60%)"
    echo "🚨 Significant issues must be resolved"
    echo "❌ NOT ready for production deployment"
fi

# Show issues
if [ ${#CRITICAL_ISSUES[@]} -gt 0 ]; then
    echo ""
    echo "🚨 CRITICAL ISSUES TO RESOLVE:"
    for issue in "${CRITICAL_ISSUES[@]}"; do
        echo "   • $issue"
    done
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo ""
    echo "⚠️ WARNINGS TO ADDRESS:"
    for warning in "${WARNINGS[@]}"; do
        echo "   • $warning"
    done
fi

# Recommendations
echo ""
echo "📋 RECOMMENDATIONS:"
echo "==================="
if [ $READINESS_PERCENTAGE -lt 90 ]; then
    echo "1. Address all critical issues listed above"
    echo "2. Review and resolve warnings where possible"
    echo "3. Run comprehensive system validation"
    echo "4. Perform performance testing"
    echo "5. Test backup and recovery procedures"
fi

if [ ${#CRITICAL_ISSUES[@]} -eq 0 ]; then
    echo "6. Ready for Day -1: Final system preparation"
    echo "7. Prepare for VietForex Bot application deployment"
else
    echo "6. Re-run this checker after addressing critical issues"
fi

echo ""
echo "📊 SYSTEM SUMMARY:"
echo "=================="
echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "Infrastructure: Hostinger VPS"
echo "Services: $(systemctl is-active docker postgresql redis-server | tr '\n' ',' | sed 's/,$//')"
echo "Uptime: $(uptime -p)"
echo "Load: $(cat /proc/loadavg | awk '{print $1}')"
echo "Memory: $(free | grep Mem | awk '{printf "%.1f%% used", $3/$2 * 100}')"
echo "Disk: $(df / | awk 'NR==2{print $5 " used"}')"
echo "Project: $(find ~/vietforex.bot.project -type f | wc -l) files, $(du -sh ~/vietforex.bot.project | awk '{print $1}') total"

echo ""
echo "🔄 Production readiness check completed: $(date)"
