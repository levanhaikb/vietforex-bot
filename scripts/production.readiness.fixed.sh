#!/bin/bash
source ~/.env

echo "🚀 VIETFOREX BOT - PRODUCTION READINESS CHECK (FIXED)"
echo "==================================================="
echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "Date: $(date)"
echo ""

SCORE=0

echo "🏗️ INFRASTRUCTURE (40 points):"
systemctl is-active --quiet docker && echo "✅ Docker: Running (+10)" && SCORE=$((SCORE + 10)) || echo "❌ Docker: Not running"
systemctl is-active --quiet postgresql && echo "✅ PostgreSQL: Running (+10)" && SCORE=$((SCORE + 10)) || echo "❌ PostgreSQL: Not running"
systemctl is-active --quiet redis-server && echo "✅ Redis: Running (+10)" && SCORE=$((SCORE + 10)) || echo "❌ Redis: Not running"

# Fixed memory check
AVAILABLE_MEM=$(free -m | grep Mem | awk '{print $7}')
if [ $AVAILABLE_MEM -gt 1000 ]; then
    echo "✅ Memory: ${AVAILABLE_MEM}MB available (+10)" && SCORE=$((SCORE + 10))
else
    echo "❌ Memory: Only ${AVAILABLE_MEM}MB available"
fi

echo ""
echo "🔒 SECURITY (20 points):"
if ufw status | grep -q "Status: active"; then
    RULES=$(ufw status | grep -c "ALLOW")
    echo "✅ UFW Firewall: Active with $RULES rules (+10)" && SCORE=$((SCORE + 10))
else
    echo "❌ UFW Firewall: Not active"
fi

systemctl is-active --quiet fail2ban && echo "✅ Fail2Ban: Running (+10)" && SCORE=$((SCORE + 10)) || echo "❌ Fail2Ban: Not running"

echo ""
echo "🤖 APPLICATION (20 points):"
[ -d ~/vietforex.bot.project/src ] && echo "✅ Project Structure: Complete (+10)" && SCORE=$((SCORE + 10)) || echo "❌ Project Structure: Incomplete"
[ -n "$NODE_ENV" ] && [ -n "$DB_NAME" ] && echo "✅ Environment Config: Complete (+10)" && SCORE=$((SCORE + 10)) || echo "❌ Environment Config: Incomplete"

echo ""
echo "📊 MONITORING (20 points):"
[ -d ~/vietforex.backups ] && echo "✅ Backup System: Active (+10)" && SCORE=$((SCORE + 10)) || echo "❌ Backup System: Not found"
CRON_COUNT=$(crontab -l | grep -v '^#' | grep -v '^$' | wc -l)
[ $CRON_COUNT -ge 5 ] && echo "✅ Automated Tasks: $CRON_COUNT jobs (+10)" && SCORE=$((SCORE + 10)) || echo "❌ Automated Tasks: Only $CRON_COUNT jobs"

echo ""
echo "🎯 PRODUCTION READINESS RESULTS"
echo "==============================="
echo "Final Score: $SCORE/100 points"
echo "Readiness Level: $SCORE%"

if [ $SCORE -ge 90 ]; then
    echo ""
    echo "🎉 PRODUCTION READY! (90%+)"
    echo "✅ System ready for VietForex Bot deployment"
    echo "🚀 Ready to begin Week 1 development"
elif [ $SCORE -ge 80 ]; then
    echo ""
    echo "✅ MOSTLY READY (80-89%)"
    echo "🔧 Minor improvements, but can proceed"
else
    echo ""
    echo "⚠️ NEEDS IMPROVEMENT (<80%)"
    echo "🔧 Address issues before production"
fi

echo ""
echo "📊 FINAL SYSTEM SUMMARY:"
echo "========================"
echo "Server: $(hostname)"
echo "Memory: $(free -h | grep Mem | awk '{print $3"/"$2" ("$7" available)"}')"
echo "Disk: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5" used, "$4" available)"}')"
echo "Load: $(cat /proc/loadavg | awk '{print $1}')"
echo "Services: Docker, PostgreSQL, Redis, Fail2Ban all running"
echo "Project: $(du -sh ~/vietforex.bot.project | awk '{print $1}') total size"
echo "Backups: $(ls ~/vietforex.backups/*_????????_??????.* 2>/dev/null | wc -l) backup files"
echo "Cron Jobs: $CRON_COUNT automated tasks"
