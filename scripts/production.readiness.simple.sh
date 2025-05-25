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
