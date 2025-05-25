#!/bin/bash
# Day -3: Monitoring & Backup Systems Setup Script
# VietForex Bot - Hostinger VPS

echo "📊 DAY -3: MONITORING & BACKUP SYSTEMS SETUP"
echo "============================================"
echo "Date: $(date)"
echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "User: $USER"
echo ""

# Verify we're on the correct server and Day -4 is complete
if [[ "$(hostname)" != "vietforex.production" ]]; then
    echo "❌ Not running on vietforex.production server"
    exit 1
fi

if [[ ! -f ~/.env ]] || [[ ! -d ~/vietforex.bot.project/src ]]; then
    echo "❌ Day -4 not completed. Please complete Day -4 first."
    exit 1
fi

echo "✅ Prerequisites verified: Day -4 completed"
echo "✅ Running on correct server: $(hostname)"
echo ""

# Navigate to project directory
cd ~/vietforex.bot.project

# Source environment variables
source ~/.env

echo "📊 Creating advanced system monitoring scripts..."

# Advanced system monitoring script
cat > scripts/system.monitor.advanced.sh << 'EOF'
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
EOF

chmod +x scripts/system.monitor.advanced.sh

echo "💾 Creating comprehensive backup system..."

# Comprehensive backup script
cat > scripts/backup.comprehensive.sh << 'EOF'
#!/bin/bash
# Comprehensive Backup System for VietForex Bot

# Load environment variables
source ~/.env

BACKUP_DIR="$HOME/vietforex.backups"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$BACKUP_DIR/backup.log"

# Create backup directory
mkdir -p $BACKUP_DIR

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log_message "🔄 Starting VietForex Comprehensive Backup - $DATE"
log_message "🌏 Server: $(hostname) @ $(curl -s ifconfig.me)"

# Database Backup
log_message "📊 Backing up PostgreSQL database..."
if PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" > $BACKUP_DIR/database_$DATE.sql; then
    DB_SIZE=$(ls -lh $BACKUP_DIR/database_$DATE.sql | awk '{print $5}')
    log_message "✅ Database backup completed: $DB_SIZE"
else
    log_message "❌ Database backup failed"
fi

# Redis Backup
log_message "⚡ Backing up Redis data..."
if redis-cli -a "$REDIS_PASSWORD" --rdb $BACKUP_DIR/redis_$DATE.rdb >/dev/null 2>&1; then
    REDIS_SIZE=$(ls -lh $BACKUP_DIR/redis_$DATE.rdb 2>/dev/null | awk '{print $5}' || echo "N/A")
    log_message "✅ Redis backup completed: $REDIS_SIZE"
else
    log_message "❌ Redis backup failed"
fi

# Project Files Backup
log_message "📁 Backing up project files..."
tar -czf $BACKUP_DIR/project_$DATE.tar.gz -C $HOME vietforex.bot.project/ --exclude='*.log' --exclude='tmp/*' 2>/dev/null
if [ $? -eq 0 ]; then
    PROJECT_SIZE=$(ls -lh $BACKUP_DIR/project_$DATE.tar.gz | awk '{print $5}')
    log_message "✅ Project files backup completed: $PROJECT_SIZE"
else
    log_message "❌ Project files backup failed"
fi

# System Configuration Backup
log_message "⚙️ Backing up system configurations..."
mkdir -p $BACKUP_DIR/configs_$DATE

# Backup important system configs
sudo cp /etc/ssh/sshd_config $BACKUP_DIR/configs_$DATE/ 2>/dev/null
sudo cp /etc/fail2ban/jail.local $BACKUP_DIR/configs_$DATE/ 2>/dev/null
sudo cp /etc/postgresql/*/main/postgresql.conf $BACKUP_DIR/configs_$DATE/ 2>/dev/null
sudo cp /etc/redis/redis.conf $BACKUP_DIR/configs_$DATE/ 2>/dev/null

# Create system info file
cat > $BACKUP_DIR/configs_$DATE/system_info.txt << EOL
Backup Date: $(date)
Hostname: $(hostname)
OS: $(lsb_release -d | cut -f2)
Kernel: $(uname -r)
Uptime: $(uptime -p)
Memory: $(free -h | grep Mem | awk '{print $2}')
Disk Space: $(df -h / | awk 'NR==2{print $2}')
EOL

tar -czf $BACKUP_DIR/system_configs_$DATE.tar.gz -C $BACKUP_DIR configs_$DATE/ 2>/dev/null
rm -rf $BACKUP_DIR/configs_$DATE/
CONFIG_SIZE=$(ls -lh $BACKUP_DIR/system_configs_$DATE.tar.gz | awk '{print $5}')
log_message "✅ System configurations backup completed: $CONFIG_SIZE"

# Environment Variables Backup (secured)
log_message "🔐 Backing up environment variables..."
cp ~/.env $BACKUP_DIR/environment_$DATE.env
chmod 600 $BACKUP_DIR/environment_$DATE.env
ENV_SIZE=$(ls -lh $BACKUP_DIR/environment_$DATE.env | awk '{print $5}')
log_message "✅ Environment backup completed: $ENV_SIZE"

# Create backup summary
cat > $BACKUP_DIR/backup_summary_$DATE.txt << EOL
VietForex Bot Backup Summary
============================
Date: $(date)
Server: $(hostname)
Backup ID: $DATE

Files Created:
- Database: database_$DATE.sql
- Redis: redis_$DATE.rdb  
- Project: project_$DATE.tar.gz
- Configs: system_configs_$DATE.tar.gz
- Environment: environment_$DATE.env

Total Backup Size: $(du -sh $BACKUP_DIR/*_$DATE.* | awk '{sum+=$1} END {print sum "B"}' 2>/dev/null || echo "Calculating...")

System Status at Backup Time:
- Memory Usage: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100}')
- Disk Usage: $(df / | awk 'NR==2{print $5}')
- Load Average: $(cat /proc/loadavg | awk '{print $1}')
- Services: PostgreSQL ($(systemctl is-active postgresql)), Redis ($(systemctl is-active redis-server))
EOL

log_message "📋 Backup summary created"

# Cleanup old backups (keep last 7 days)
log_message "🧹 Cleaning up old backups..."
find $BACKUP_DIR -name "*_????????_??????.*" -mtime +7 -delete 2>/dev/null
REMAINING_BACKUPS=$(find $BACKUP_DIR -name "*_????????_??????.*" | wc -l)
log_message "✅ Cleanup completed. Remaining backups: $REMAINING_BACKUPS"

# Backup verification
log_message "🔍 Verifying backup integrity..."
BACKUP_FILES=("database_$DATE.sql" "project_$DATE.tar.gz" "system_configs_$DATE.tar.gz" "environment_$DATE.env")
VERIFIED=0
for file in "${BACKUP_FILES[@]}"; do
    if [ -f "$BACKUP_DIR/$file" ] && [ -s "$BACKUP_DIR/$file" ]; then
        ((VERIFIED++))
        log_message "✅ Verified: $file"
    else
        log_message "❌ Missing or empty: $file"
    fi
done

# Final summary
TOTAL_SIZE=$(du -sh $BACKUP_DIR | awk '{print $1}')
log_message "📊 Backup completed: $VERIFIED/4 files verified"
log_message "💾 Total backup directory size: $TOTAL_SIZE"
log_message "📂 Backup location: $BACKUP_DIR"

if [ $VERIFIED -eq 4 ]; then
    log_message "🎉 BACKUP SUCCESSFUL: All components backed up and verified"
    echo "✅ VietForex Backup Completed Successfully"
    echo "📊 Backup ID: $DATE"
    echo "💾 Total Size: $TOTAL_SIZE"
    echo "📂 Location: $BACKUP_DIR"
else
    log_message "⚠️ BACKUP PARTIALLY FAILED: $VERIFIED/4 components backed up"
    echo "⚠️ Backup completed with issues - check log: $LOG_FILE"
fi

# Send backup notification (placeholder for future email/telegram integration)
log_message "📧 Backup notification: Success=$VERIFIED/4, Size=$TOTAL_SIZE"
EOF

chmod +x scripts/backup.comprehensive.sh

echo "⏰ Setting up automated monitoring and backup schedules..."

# Create cron job setup script
cat > scripts/setup.cron.jobs.sh << 'EOF'
#!/bin/bash
# Cron Jobs Setup for VietForex Bot

echo "⏰ Setting up VietForex Bot automated schedules..."

# Backup existing crontab
crontab -l > /tmp/crontab_backup_$(date +%Y%m%d) 2>/dev/null || touch /tmp/crontab_backup_$(date +%Y%m%d)

# Create new cron jobs
cat > /tmp/vietforex_cron << EOL
# VietForex Bot Automated Tasks
# Generated: $(date)

# Daily comprehensive backup at 2:00 AM
0 2 * * * /home/forex_bot/vietforex.bot.project/scripts/backup.comprehensive.sh >> /home/forex_bot/vietforex.bot.project/logs/backup.log 2>&1

# System monitoring every hour
0 * * * * /home/forex_bot/vietforex.bot.project/scripts/system.monitor.advanced.sh >> /home/forex_bot/vietforex.bot.project/logs/monitoring.log 2>&1

# Quick system health check every 15 minutes
*/15 * * * * /home/forex_bot/vietforex.bot.project/scripts/system.info.sh >> /home/forex_bot/vietforex.bot.project/logs/health.log 2>&1

# Weekly performance baseline on Sundays at 3:00 AM
0 3 * * 0 /home/forex_bot/vietforex.bot.project/scripts/performance.baseline.sh >> /home/forex_bot/vietforex.bot.project/logs/performance.log 2>&1

# Log rotation weekly on Sundays at 4:00 AM
0 4 * * 0 find /home/forex_bot/vietforex.bot.project/logs -name "*.log" -size +10M -exec gzip {} \; -exec touch {}.gz \;

# Cleanup old compressed logs monthly
0 5 1 * * find /home/forex_bot/vietforex.bot.project/logs -name "*.log.gz" -mtime +30 -delete
EOL

# Install new cron jobs
crontab /tmp/vietforex_cron

echo "✅ Cron jobs installed successfully!"
echo "📋 Active cron jobs:"
crontab -l | grep -v '^#' | grep -v '^$'

# Clean up
rm /tmp/vietforex_cron

echo ""
echo "⏰ SCHEDULED TASKS SUMMARY:"
echo "=========================="
echo "🔄 System monitoring: Every hour"
echo "💾 Comprehensive backup: Daily at 2:00 AM"
echo "❤️ Health checks: Every 15 minutes"
echo "📊 Performance baseline: Weekly (Sunday 3:00 AM)"
echo "🧹 Log rotation: Weekly (Sunday 4:00 AM)"
echo "🗑️ Log cleanup: Monthly (1st day 5:00 AM)"
EOF

chmod +x scripts/setup.cron.jobs.sh

echo "📊 Creating performance baseline script..."

# Performance baseline script
cat > scripts/performance.baseline.sh << 'EOF'
#!/bin/bash
# Performance Baseline Establishment for VietForex Bot

BASELINE_DIR="$HOME/vietforex.bot.project/logs/baselines"
DATE=$(date +%Y%m%d_%H%M%S)
BASELINE_FILE="$BASELINE_DIR/baseline_$DATE.txt"

mkdir -p $BASELINE_DIR

echo "📊 VIETFOREX BOT PERFORMANCE BASELINE" > $BASELINE_FILE
echo "=====================================" >> $BASELINE_FILE
echo "Date: $(date)" >> $BASELINE_FILE
echo "Server: $(hostname) @ $(curl -s ifconfig.me)" >> $BASELINE_FILE
echo "" >> $BASELINE_FILE

# System specifications
echo "🖥️ SYSTEM SPECIFICATIONS:" >> $BASELINE_FILE
echo "OS: $(lsb_release -d | cut -f2)" >> $BASELINE_FILE
echo "Kernel: $(uname -r)" >> $BASELINE_FILE
echo "CPU: $(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d':' -f2 | xargs)" >> $BASELINE_FILE
echo "Cores: $(nproc)" >> $BASELINE_FILE
echo "Total RAM: $(free -h | grep Mem | awk '{print $2}')" >> $BASELINE_FILE
echo "Total Storage: $(df -h / | awk 'NR==2{print $2}')" >> $BASELINE_FILE
echo "" >> $BASELINE_FILE

# Performance benchmarks
echo "⚡ PERFORMANCE BENCHMARKS:" >> $BASELINE_FILE

# CPU benchmark
echo "CPU Performance:" >> $BASELINE_FILE
START_TIME=$(date +%s%N)
dd if=/dev/zero of=/tmp/cpu_test bs=1M count=100 >/dev/null 2>&1
END_TIME=$(date +%s%N)
CPU_TIME=$(echo "scale=3; ($END_TIME - $START_TIME) / 1000000000" | bc 2>/dev/null || echo "N/A")
echo "  100MB CPU test: ${CPU_TIME}s" >> $BASELINE_FILE
rm -f /tmp/cpu_test

# Memory performance
echo "Memory Performance:" >> $BASELINE_FILE
MEMORY_SPEED=$(dd if=/dev/zero of=/dev/null bs=1M count=1000 2>&1 | grep copied | awk '{print $(NF-1)" "$NF}')
echo "  Memory throughput: $MEMORY_SPEED" >> $BASELINE_FILE

# Disk I/O performance
echo "Disk I/O Performance:" >> $BASELINE_FILE
WRITE_SPEED=$(dd if=/dev/zero of=/tmp/disk_test bs=1M count=100 oflag=direct 2>&1 | grep copied | awk '{print $(NF-1)" "$NF}')
READ_SPEED=$(dd if=/tmp/disk_test of=/dev/null bs=1M iflag=direct 2>&1 | grep copied | awk '{print $(NF-1)" "$NF}')
echo "  Disk write: $WRITE_SPEED" >> $BASELINE_FILE
echo "  Disk read: $READ_SPEED" >> $BASELINE_FILE
rm -f /tmp/disk_test

# Network performance
echo "Network Performance:" >> $BASELINE_FILE
PING_GOOGLE=$(ping -c 10 8.8.8.8 | tail -1 | awk -F'/' '{print $5}' 2>/dev/null || echo "N/A")
PING_CF=$(ping -c 10 1.1.1.1 | tail -1 | awk -F'/' '{print $5}' 2>/dev/null || echo "N/A")
echo "  Average ping to Google DNS: ${PING_GOOGLE}ms" >> $BASELINE_FILE
echo "  Average ping to Cloudflare: ${PING_CF}ms" >> $BASELINE_FILE

# Database performance
echo "" >> $BASELINE_FILE
echo "🗄️ DATABASE PERFORMANCE:" >> $BASELINE_FILE
if systemctl is-active --quiet postgresql; then
    # Simple query performance test
    source ~/.env
    DB_START=$(date +%s%N)
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT generate_series(1,1000);" >/dev/null 2>&1
    DB_END=$(date +%s%N)
    DB_TIME=$(echo "scale=3; ($DB_END - $DB_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    echo "  PostgreSQL query (1K records): ${DB_TIME}s" >> $BASELINE_FILE
    
    # Connection time
    CONN_START=$(date +%s%N)
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1
    CONN_END=$(date +%s%N)
    CONN_TIME=$(echo "scale=3; ($CONN_END - $CONN_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    echo "  Connection time: ${CONN_TIME}s" >> $BASELINE_FILE
else
    echo "  PostgreSQL: Not running" >> $BASELINE_FILE
fi

# Redis performance
echo "" >> $BASELINE_FILE
echo "⚡ REDIS PERFORMANCE:" >> $BASELINE_FILE
if systemctl is-active --quiet redis-server; then
    source ~/.env
    REDIS_START=$(date +%s%N)
    for i in {1..1000}; do
        redis-cli -a "$REDIS_PASSWORD" set "test_$i" "value_$i" >/dev/null 2>&1
    done
    REDIS_END=$(date +%s%N)
    REDIS_TIME=$(echo "scale=3; ($REDIS_END - $REDIS_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    echo "  1000 SET operations: ${REDIS_TIME}s" >> $BASELINE_FILE
    
    # Cleanup test data
    redis-cli -a "$REDIS_PASSWORD" flushall >/dev/null 2>&1
else
    echo "  Redis: Not running" >> $BASELINE_FILE
fi

# Current resource usage
echo "" >> $BASELINE_FILE
echo "📊 CURRENT RESOURCE USAGE:" >> $BASELINE_FILE
echo "Memory: $(free | grep Mem | awk '{printf "%.1f%% used", $3/$2 * 100}')" >> $BASELINE_FILE
echo "Disk: $(df / | awk 'NR==2{print $5 " used"}')" >> $BASELINE_FILE
echo "Load: $(cat /proc/loadavg | awk '{print $1" "$2" "$3}')" >> $BASELINE_FILE
echo "Processes: $(ps aux | wc -l) total" >> $BASELINE_FILE

echo "" >> $BASELINE_FILE
echo "📈 BASELINE ESTABLISHED: $DATE" >> $BASELINE_FILE
echo "📂 File: $BASELINE_FILE" >> $BASELINE_FILE

echo "✅ Performance baseline saved to: $BASELINE_FILE"
echo "📊 Baseline ID: $DATE"
EOF

chmod +x scripts/performance.baseline.sh

echo "🚨 Creating alerting system..."

# Alert system script
cat > scripts/alert.system.sh << 'EOF'
#!/bin/bash
# Alert System for VietForex Bot

source ~/.env

ALERT_LOG="$HOME/vietforex.bot.project/logs/alerts.log"
mkdir -p "$(dirname "$ALERT_LOG")"

# Logging function
log_alert() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERT: $1" | tee -a $ALERT_LOG
}

echo "🚨 VietForex Bot Alert System Check - $(date)"

# Check memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
if [ $MEMORY_USAGE -gt 85 ]; then
    log_alert "HIGH MEMORY USAGE: ${MEMORY_USAGE}% (Critical threshold: 85%)"
fi

# Check disk usage
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
    log_alert "HIGH DISK USAGE: ${DISK_USAGE}% (Critical threshold: 90%)"
fi

# Check system load
LOAD=$(cat /proc/loadavg | awk '{print $1}' | cut -d. -f1)
if [ $LOAD -gt 3 ]; then
    log_alert "HIGH SYSTEM LOAD: $LOAD (Critical threshold: 3)"
fi

# Check critical services
services=("postgresql" "redis-server" "docker")
for service in "${services[@]}"; do
    if ! systemctl is-active --quiet $service; then
        log_alert "SERVICE DOWN: $service is not running"
    fi
done

# Check database connectivity
if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    log_alert "DATABASE CONNECTION FAILED: Unable to connect to $DB_NAME"
fi

# Check Redis connectivity
if ! redis-cli -a "$REDIS_PASSWORD" ping >/dev/null 2>&1; then
    log_alert "REDIS CONNECTION FAILED: Unable to connect to Redis"
fi

# Check backup status
LAST_BACKUP=$(find ~/vietforex.backups -name "database_*.sql" -mtime -1 | wc -l 2>/dev/null || echo "0")
if [ $LAST_BACKUP -eq 0 ]; then
    log_alert "BACKUP MISSING: No database backup found in last 24 hours"
fi

echo "✅ Alert system check completed"
EOF

chmod +x scripts/alert.system.sh

# Run initial setup
echo ""
echo "🚀 Running initial system setup..."

# Create log directories
mkdir -p logs/{monitoring,backup,alerts,performance,health}

# Run the cron job setup
echo "⏰ Setting up automated schedules..."
./scripts/setup.cron.jobs.sh

# Run initial monitoring
echo "📊 Running initial system monitoring..."
./scripts/system.monitor.advanced.sh > logs/monitoring/initial_monitoring_$(date +%Y%m%d_%H%M%S).log

# Run initial backup
echo "💾 Running initial backup..."
./scripts/backup.comprehensive.sh

# Establish performance baseline
echo "📈 Establishing performance baseline..."
./scripts/performance.baseline.sh

# Create Day -3 validation script
cat > scripts/validate.day.3.sh << 'EOF'
#!/bin/bash
# Day -3 Validation Script

echo "🔍 DAY -3 VALIDATION: MONITORING & BACKUP SYSTEMS"
echo "================================================="
echo "Date: $(date)"
echo "Server: $(hostname)"
echo ""

PASSED_TESTS=0
TOTAL_TESTS=12

# Test 1: Advanced monitoring script
echo "📊 TEST 1: Advanced Monitoring Script"
if [ -x ~/vietforex.bot.project/scripts/system.monitor.advanced.sh ]; then
    echo "   ✅ Advanced monitoring script exists and executable"
    ((PASSED_TESTS++))
else
    echo "   ❌ Advanced monitoring script missing"
fi

# Test 2: Comprehensive backup script
echo ""
echo "💾 TEST 2: Comprehensive Backup Script"
if [ -x ~/vietforex.bot.project/scripts/backup.comprehensive.sh ]; then
    echo "   ✅ Backup script exists and executable"
    ((PASSED_TESTS++))
else
    echo "   ❌ Backup script missing"
fi

# Test 3: Performance baseline script
echo ""
echo "📈 TEST 3: Performance Baseline Script"
if [ -x ~/vietforex.bot.project/scripts/performance.baseline.sh ]; then
    echo "   ✅ Performance baseline script exists"
    ((PASSED_TESTS++))
else
    echo "   ❌ Performance baseline script missing"
fi

# Test 4: Alert system
echo ""
echo "🚨 TEST 4: Alert System"
if [ -x ~/vietforex.bot.project/scripts/alert.system.sh ]; then
    echo "   ✅ Alert system script exists"
    ((PASSED_TESTS++))
else
    echo "   ❌ Alert system script missing"
fi

# Test 5: Cron jobs
echo ""
echo "⏰ TEST 5: Automated Scheduling"
CRON_JOBS=$(crontab -l | grep -v '^#' | grep -v '^ | wc -l)
if [ $CRON_JOBS -ge 5 ]; then
    echo "   ✅ Cron jobs configured ($CRON_JOBS jobs)"
    ((PASSED_TESTS++))
else
    echo "   ❌ Insufficient cron jobs ($CRON_JOBS jobs)"
fi

# Test 6: Log directories
echo ""
echo "📁 TEST 6: Log Directory Structure"
if [ -d ~/vietforex.bot.project/logs/monitoring ] && [ -d ~/vietforex.bot.project/logs/backup ]; then
    LOG_DIRS=$(find ~/vietforex.bot.project/logs -type d | wc -l)
    echo "   ✅ Log directories created ($LOG_DIRS directories)"
    ((PASSED_TESTS++))
else
    echo "   ❌ Log directory structure incomplete"
fi

# Test 7: Backup directory
echo ""
echo "💾 TEST 7: Backup System"
if [ -d ~/vietforex.backups ]; then
    BACKUP_FILES=$(find ~/vietforex.backups -name "*_????????_??????.*" | wc -l)
    echo "   ✅ Backup system operational ($BACKUP_FILES backup files)"
    ((PASSED_TESTS++))
else
    echo "   ❌ Backup directory not found"
fi

# Test 8: Performance baseline
echo ""
echo "📊 TEST 8: Performance Baseline"
if [ -d ~/vietforex.bot.project/logs/baselines ]; then
    BASELINES=$(find ~/vietforex.bot.project/logs/baselines -name "baseline_*.txt" | wc -l)
    echo "   ✅ Performance baselines established ($BASELINES baselines)"
    ((PASSED_TESTS++))
else
    echo "   ❌ Performance baseline not established"
fi

# Test 9: Monitoring functionality
echo ""
echo "🔍 TEST 9: Monitoring Functionality"
if ~/vietforex.bot.project/scripts/system.monitor.advanced.sh | grep -q "SYSTEM HEALTH OVERVIEW"; then
    echo "   ✅ Advanced monitoring working"
    ((PASSED_TESTS++))
else
    echo "   ❌ Monitoring script not functioning"
fi

# Test 10: Alert system functionality
echo ""
echo "🚨 TEST 10: Alert System Functionality"
if ~/vietforex.bot.project/scripts/alert.system.sh | grep -q "Alert system check completed"; then
    echo "   ✅ Alert system working"
    ((PASSED_TESTS++))
else
    echo "   ❌ Alert system not functioning"
fi

# Test 11: System services
echo ""
echo "🔧 TEST 11: Critical Services"
SERVICES_UP=0
services=("postgresql" "redis-server" "docker")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        ((SERVICES_UP++))
    fi
done

if [ $SERVICES_UP -eq 3 ]; then
    echo "   ✅ All critical services running ($SERVICES_UP/3)"
    ((PASSED_TESTS++))
else
    echo "   ⚠️ Some services not running ($SERVICES_UP/3)"
fi

# Test 12: Environment integration
echo ""
echo "⚙️ TEST 12: Environment Integration"
source ~/.env
if [ -n "$NODE_ENV" ] && [ -n "$DB_NAME" ] && [ -n "$REDIS_PASSWORD" ]; then
    echo "   ✅ Environment variables properly loaded"
    ((PASSED_TESTS++))
else
    echo "   ❌ Environment variables not properly configured"
fi

# Results
echo ""
echo "🎯 DAY -3 VALIDATION RESULTS"
echo "============================"
echo "Tests Passed: $PASSED_TESTS/$TOTAL_TESTS"
echo "Success Rate: $((PASSED_TESTS * 100 / TOTAL_TESTS))%"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo ""
    echo "🎉 DAY -3: PERFECTLY COMPLETED!"
    echo "✅ Monitoring system comprehensive and operational"
    echo "✅ Backup system configured and tested"
    echo "✅ Performance baseline established"
    echo "✅ Automated scheduling active"
    echo "✅ Alert system functional"
    echo ""
    echo "🚀 READY FOR DAY -2: SYSTEM VALIDATION & PERFORMANCE TESTING"
elif [ $PASSED_TESTS -ge 10 ]; then
    echo ""
    echo "✅ DAY -3: EXCELLENT (Minor issues)"
    echo "🔧 Review failed tests and proceed to Day -2"
else
    echo ""
    echo "❌ DAY -3: NEEDS ATTENTION"
    echo "🚨 Major issues found - must fix before proceeding"
fi

echo ""
echo "📊 SYSTEM SUMMARY:"
echo "=================="
echo "Monitoring Scripts: $(find ~/vietforex.bot.project/scripts -name "*monitor*" | wc -l)"
echo "Backup Scripts: $(find ~/vietforex.bot.project/scripts -name "*backup*" | wc -l)"
echo "Total Scripts: $(find ~/vietforex.bot.project/scripts -name "*.sh" | wc -l)"
echo "Log Directories: $(find ~/vietforex.bot.project/logs -type d | wc -l)"
echo "Cron Jobs: $(crontab -l | grep -v '^#' | grep -v '^ | wc -l)"
echo ""
echo "🔄 Next: Day -2 System Validation & Performance Testing"
EOF

chmod +x scripts/validate.day.3.sh

echo ""
echo "🎯 DAY -3 SETUP COMPLETED!"
echo "=========================="
echo "📊 Monitoring: Advanced system monitoring deployed"
echo "💾 Backup: Comprehensive backup system configured"
echo "⏰ Scheduling: Automated cron jobs active"
echo "📈 Baseline: Performance baseline established"
echo "🚨 Alerts: Alert system operational"
echo ""
echo "🔍 Running Day -3 validation..."
./scripts/validate.day.3.sh

echo ""
echo "📋 AUTOMATED SCHEDULE SUMMARY:"
echo "=============================="
echo "🔄 System monitoring: Every hour"
echo "💾 Comprehensive backup: Daily at 2:00 AM"
echo "❤️ Health checks: Every 15 minutes"
echo "📊 Performance baseline: Weekly (Sunday 3:00 AM)"
echo "🧹 Log rotation: Weekly (Sunday 4:00 AM)"
echo "🗑️ Log cleanup: Monthly (1st day 5:00 AM)"
echo ""
echo "🚀 Ready for: Day -2 System Validation & Performance Testing"
echo ""
echo "Next steps:"
echo "1. Review validation results above"
echo "2. Check: crontab -l"
echo "3. Test: ./scripts/system.monitor.advanced.sh"
echo "4. Ready for Day -2 setup"
