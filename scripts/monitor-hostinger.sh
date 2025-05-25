#!/bin/bash
# Hostinger-specific monitoring script

echo "📊 HOSTINGER VPS MONITORING - VIETFOREX BOT"
echo "==========================================="
echo "🏷️  Hostname: $(hostname)"
echo "🌐 IP: $(curl -s ifconfig.me)"
echo "📍 Provider: Hostinger VPS"
echo ""

# System resources
echo "💾 Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "💽 Disk: $(df -h / | awk 'NR==2{print $5 " used"}')"
echo "⚡ CPU Load: $(cat /proc/loadavg | awk '{print $1}')"

# Service status
services=("docker" "postgresql" "redis-server" "nginx")
echo ""
echo "🔧 SERVICES:"
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        echo "   ✅ $service: RUNNING"
    else
        echo "   ❌ $service: STOPPED"
    fi
done

# VietForex specific checks
echo ""
echo "🤖 VIETFOREX BOT STATUS:"
if pm2 list | grep -q "vietforex"; then
    echo "   ✅ VietForex Bot: RUNNING"
else
    echo "   ❌ VietForex Bot: STOPPED"
fi

echo ""
echo "💰 Cost: $3.99/month"
echo "📞 Support: https://www.hostinger.com/help"
