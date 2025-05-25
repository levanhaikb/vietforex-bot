#!/bin/bash
# System Information Script

echo "🖥️ VIETFOREX BOT SYSTEM INFORMATION"
echo "=================================="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "IP: $(curl -s ifconfig.me)"
echo ""

echo "💻 SYSTEM SPECS:"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "Storage: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
echo "CPU Load: $(cat /proc/loadavg | awk '{print $1}')"
echo ""

echo "🔧 SERVICES STATUS:"
services=("docker" "postgresql" "redis-server")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "✅ $service: RUNNING"
    else
        echo "❌ $service: STOPPED"
    fi
done
