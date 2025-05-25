#!/bin/bash
# Advanced System Monitoring for VietForex Bot

echo "📊 VIETFOREX BOT - ADVANCED SYSTEM MONITORING"
echo "=============================================="
echo "🌏 Hostinger VPS - $(hostname)"
echo "📅 $(date)"
echo "🌐 IP: $(curl -s ifconfig.me 2>/dev/null || echo 'Offline')"
echo ""

# System Health Overview
echo "🖥️ SYSTEM HEALTH OVERVIEW:"
echo "  Hostname: $(hostname)"
echo "  Uptime: $(uptime -p)"
echo "  Load Average: $(cat /proc/loadavg | awk '{print $1" "$2" "$3}')"
echo "  Users: $(who | wc -l) logged in"
echo ""

# Detailed Resource Usage
echo "💾 DETAILED RESOURCE USAGE:"
echo "  Memory Usage:"
free -h | awk 'NR==2{printf "    Total: %s, Used: %s (%.1f%%), Available: %s\n", $2, $3, $3*100/$2, $7}'

echo "  Disk Usage:"
df -h / | awk 'NR==2{printf "    Root: %s used of %s (%s) - %s available\n", $3, $2, $5, $4}'

echo "  CPU Information:"
echo "    Cores: $(nproc)"
echo "    Model: $(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d':' -f2 | xargs)"
echo "    Current Load: $(cat /proc/loadavg | awk '{print $1}')"

# Process Information
echo ""
echo "🔄 PROCESS INFORMATION:"
echo "  Total Processes: $(ps aux | wc -l)"
echo "  Running Processes: $(ps aux | awk '$8 ~ /^[RD]/' | wc -l)"

# Top 5 memory consumers
echo "  Top 5 Memory Consumers:"
ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "    %s: %.1f%% RAM - %s\n", $11, $4, $2}'

# Top 5 CPU consumers  
echo "  Top 5 CPU Consumers:"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "    %s: %.1f%% CPU - %s\n", $11, $3, $2}'

# Network Information
echo ""
echo "🌐 NETWORK STATUS:"
echo "  Network Interfaces:"
ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | while read ip; do
    echo "    IP: $ip"
done

echo "  Network Connectivity:"
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    PING_TIME=$(ping -c 1 8.8.8.8 | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
    echo "    Internet: ✅ Connected (${PING_TIME}ms to Google DNS)"
else
    echo "    Internet: ❌ Connection issues"
fi

# Service Status Monitoring
echo ""
echo "🔧 VIETFOREX SERVICE STATUS:"
services=("docker" "postgresql" "redis-server" "nginx" "fail2ban" "ufw")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        uptime_info=$(systemctl status $service | grep "Active:" | awk '{print $3,$4,$5,$6}' | tr -d '()')
        echo "  ✅ $service: RUNNING ($uptime_info)"
    else
        echo "  ❌ $service: STOPPED"
    fi
done

# Database Health Check
echo ""
echo "🗄️ DATABASE HEALTH CHECK:"
if systemctl is-active --quiet postgresql; then
    # PostgreSQL stats
    DB_SIZE=$(sudo -u postgres psql -d $DB_NAME -c "SELECT pg_size_pretty(pg_database_size('$DB_NAME'));" -t 2>/dev/null | xargs || echo "N/A")
    CONNECTIONS=$(sudo -u postgres psql -d $DB_NAME -c "SELECT count(*) FROM pg_stat_activity;" -t 2>/dev/null | xargs || echo "N/A")
    echo "  ✅ PostgreSQL: HEALTHY"
    echo "    Database Size: $DB_SIZE"
    echo "    Active Connections: $CONNECTIONS"
    
    # Test connection with environment credentials
    if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
        echo "    VietForex Connection: ✅ OK"
    else
        echo "    VietForex Connection: ❌ FAILED"
    fi
else
    echo "  ❌ PostgreSQL: NOT RUNNING"
fi

# Redis Health Check
echo ""
echo "⚡ REDIS HEALTH CHECK:"
if systemctl is-active --quiet redis-server; then
    echo "  ✅ Redis: HEALTHY"
    
    # Redis stats
    REDIS_MEMORY=$(redis-cli -a "$REDIS_PASSWORD" info memory 2>/dev/null | grep used_memory_human | cut -d: -f2 | tr -d '\r' || echo "N/A")
    REDIS_KEYS=$(redis-cli -a "$REDIS_PASSWORD" dbsize 2>/dev/null || echo "0")
    echo "    Memory Usage: $REDIS_MEMORY"
    echo "    Total Keys: $REDIS_KEYS"
    
    # Test connection
    if redis-cli -a "$REDIS_PASSWORD" ping >/dev/null 2>&1; then
        echo "    VietForex Connection: ✅ OK"
    else
        echo "    VietForex Connection: ❌ FAILED"
    fi
else
    echo "  ❌ Redis: NOT RUNNING"
fi

# Docker Status (if available)
echo ""
echo "🐳 DOCKER STATUS:"
if systemctl is-active --quiet docker; then
    echo "  ✅ Docker: RUNNING"
    CONTAINERS=$(docker ps -q | wc -l)
    IMAGES=$(docker images -q | wc -l)
    echo "    Running Containers: $CONTAINERS"
    echo "    Available Images: $IMAGES"
    
    if [ $CONTAINERS -gt 0 ]; then
        echo "    Container Details:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | tail -n +2 | while read line; do
            echo "      $line"
        done
    fi
else
    echo "  ❌ Docker: NOT RUNNING"
fi

# Security Status
echo ""
echo "🔒 SECURITY STATUS:"
if systemctl is-active --quiet fail2ban; then
    BANNED_IPS=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Banned IP list" | wc -w || echo "0")
    echo "  ✅ Fail2Ban: ACTIVE (Banned IPs: $((BANNED_IPS-4)))"
else
    echo "  ❌ Fail2Ban: INACTIVE"
fi

if ufw status | grep -q "Status: active"; then
    RULES_COUNT=$(ufw status numbered | grep -c '\]')
    echo "  ✅ UFW Firewall: ACTIVE ($RULES_COUNT rules)"
else
    echo "  ❌ UFW Firewall: INACTIVE"
fi

# Port Status
echo ""
echo "🌐 PORT STATUS:"
important_ports=("22" "2222" "80" "443" "3000" "5432" "6379")
for port in "${important_ports[@]}"; do
    if netstat -tln | grep -q ":$port "; then
        echo "  ✅ Port $port: LISTENING"
    else
        echo "  ⚠️ Port $port: NOT LISTENING"
    fi
done

# Log Analysis
echo ""
echo "📝 RECENT LOG ANALYSIS:"
echo "  System Errors (last hour):"
ERROR_COUNT=$(journalctl --since "1 hour ago" --priority=err | wc -l)
echo "    Total Errors: $ERROR_COUNT"

if [ $ERROR_COUNT -gt 0 ] && [ $ERROR_COUNT -lt 10 ]; then
    echo "    Recent Errors:"
    journalctl --since "1 hour ago" --priority=err --no-pager -n 3 | tail -3
fi

# Performance Alerts
echo ""
echo "🚨 PERFORMANCE ALERTS:"
ALERTS=0

# Memory alert
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
if [ $MEMORY_USAGE -gt 80 ]; then
    echo "  ⚠️ HIGH MEMORY USAGE: ${MEMORY_USAGE}%"
    ((ALERTS++))
fi

# Disk alert
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 85 ]; then
    echo "  ⚠️ HIGH DISK USAGE: ${DISK_USAGE}%"
    ((ALERTS++))
fi

# Load alert
LOAD=$(cat /proc/loadavg | awk '{print $1}' | cut -d. -f1)
if [ $LOAD -gt 2 ]; then
    echo "  ⚠️ HIGH SYSTEM LOAD: $LOAD"
    ((ALERTS++))
fi

if [ $ALERTS -eq 0 ]; then
    echo "  ✅ All performance metrics within normal range"
fi

# VietForex Specific Monitoring
echo ""
echo "🤖 VIETFOREX SPECIFIC STATUS:"
PROJECT_SIZE=$(du -sh ~/vietforex.bot.project/ | awk '{print $1}')
echo "  Project Directory Size: $PROJECT_SIZE"
echo "  Environment: $NODE_ENV"
echo "  Configuration Files: $(find ~/vietforex.bot.project/configs -name "*.env.*" | wc -l)"
echo "  Scripts Available: $(find ~/vietforex.bot.project/scripts -name "*.sh" | wc -l)"

# Summary
echo ""
echo "📊 MONITORING SUMMARY:"
echo "=============================="
if [ $ALERTS -eq 0 ] && systemctl is-active --quiet postgresql && systemctl is-active --quiet redis-server; then
    echo "🎉 SYSTEM STATUS: EXCELLENT"
    echo "✅ All critical services operational"
    echo "✅ Performance within normal parameters"
    echo "✅ VietForex Bot infrastructure healthy"
else
    echo "⚠️ SYSTEM STATUS: NEEDS ATTENTION"
    echo "🔧 Review alerts and failed services above"
fi

echo ""
echo "💰 Infrastructure Cost: $7.99/month (Hostinger VPS)"
echo "📞 Support: https://www.hostinger.com/help"
echo "🔄 Next monitoring check: $(date -d '+1 hour')"
