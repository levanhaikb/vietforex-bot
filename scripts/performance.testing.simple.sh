#!/bin/bash
# Simple Performance Testing for VietForex Bot

source ~/.env

echo "🚀 VIETFOREX BOT - PERFORMANCE TESTING"
echo "======================================"
echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "Date: $(date)"
echo ""

RESULTS_DIR="$HOME/vietforex.bot.project/logs/performance"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$RESULTS_DIR/performance_test_$TIMESTAMP.txt"

mkdir -p $RESULTS_DIR

echo "📊 PERFORMANCE TEST RESULTS - $TIMESTAMP" > $RESULTS_FILE
echo "==========================================" >> $RESULTS_FILE
echo "Server: $(hostname)" >> $RESULTS_FILE
echo "Date: $(date)" >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# System specs
echo "🖥️ SYSTEM SPECIFICATIONS:" | tee -a $RESULTS_FILE
echo "OS: $(lsb_release -d | cut -f2)" | tee -a $RESULTS_FILE
echo "CPU: $(nproc) cores" | tee -a $RESULTS_FILE
echo "RAM: $(free -h | grep Mem | awk '{print $2}')" | tee -a $RESULTS_FILE
echo "Storage: $(df -h / | awk 'NR==2{print $2}')" | tee -a $RESULTS_FILE
echo "" | tee -a $RESULTS_FILE

# CPU Test
echo "⚡ CPU PERFORMANCE TEST:" | tee -a $RESULTS_FILE
CPU_START=$(date +%s)
dd if=/dev/zero of=/tmp/cpu_test bs=1M count=100 >/dev/null 2>&1
CPU_END=$(date +%s)
CPU_TIME=$((CPU_END - CPU_START))
echo "100MB CPU test: ${CPU_TIME}s" | tee -a $RESULTS_FILE
rm -f /tmp/cpu_test

# Memory Test
echo "" | tee -a $RESULTS_FILE
echo "💾 MEMORY PERFORMANCE TEST:" | tee -a $RESULTS_FILE
MEM_START=$(date +%s)
dd if=/dev/zero of=/dev/null bs=1M count=500 >/dev/null 2>&1
MEM_END=$(date +%s)
MEM_TIME=$((MEM_END - MEM_START))
echo "500MB memory test: ${MEM_TIME}s" | tee -a $RESULTS_FILE

# Disk I/O Test
echo "" | tee -a $RESULTS_FILE
echo "💽 DISK I/O PERFORMANCE TEST:" | tee -a $RESULTS_FILE
DISK_START=$(date +%s)
dd if=/dev/zero of=/tmp/disk_test bs=1M count=50 >/dev/null 2>&1
DISK_END=$(date +%s)
DISK_TIME=$((DISK_END - DISK_START))
echo "50MB disk write test: ${DISK_TIME}s" | tee -a $RESULTS_FILE
rm -f /tmp/disk_test

# Network Test
echo "" | tee -a $RESULTS_FILE
echo "🌐 NETWORK PERFORMANCE TEST:" | tee -a $RESULTS_FILE
PING_RESULT=$(ping -c 5 8.8.8.8 | tail -1 | awk -F'/' '{print $5}' || echo "N/A")
echo "Average ping to Google DNS: ${PING_RESULT}ms" | tee -a $RESULTS_FILE

# Database Test
echo "" | tee -a $RESULTS_FILE
echo "🗄️ DATABASE PERFORMANCE TEST:" | tee -a $RESULTS_FILE
if systemctl is-active --quiet postgresql; then
    DB_START=$(date +%s)
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT generate_series(1,100);" >/dev/null 2>&1
    DB_END=$(date +%s)
    DB_TIME=$((DB_END - DB_START))
    echo "PostgreSQL query (100 records): ${DB_TIME}s" | tee -a $RESULTS_FILE
else
    echo "PostgreSQL: Service not running" | tee -a $RESULTS_FILE
fi

# Redis Test
echo "" | tee -a $RESULTS_FILE
echo "⚡ REDIS PERFORMANCE TEST:" | tee -a $RESULTS_FILE
if systemctl is-active --quiet redis-server; then
    REDIS_START=$(date +%s)
    for i in {1..100}; do
        redis-cli -a "$REDIS_PASSWORD" set "test_$i" "value_$i" >/dev/null 2>&1
    done
    REDIS_END=$(date +%s)
    REDIS_TIME=$((REDIS_END - REDIS_START))
    echo "Redis 100 SET operations: ${REDIS_TIME}s" | tee -a $RESULTS_FILE
    redis-cli -a "$REDIS_PASSWORD" flushall >/dev/null 2>&1
else
    echo "Redis: Service not running" | tee -a $RESULTS_FILE
fi

# Resource usage
echo "" | tee -a $RESULTS_FILE
echo "📊 CURRENT RESOURCE USAGE:" | tee -a $RESULTS_FILE
echo "Memory: $(free | grep Mem | awk '{printf "%.1f%% used", $3/$2 * 100}')" | tee -a $RESULTS_FILE
echo "Disk: $(df / | awk 'NR==2{print $5 " used"}')" | tee -a $RESULTS_FILE
echo "Load: $(cat /proc/loadavg | awk '{print $1}')" | tee -a $RESULTS_FILE

echo "" | tee -a $RESULTS_FILE
echo "✅ Performance testing completed!" | tee -a $RESULTS_FILE
echo "📊 Results saved to: $RESULTS_FILE" | tee -a $RESULTS_FILE
echo ""
echo "📈 Performance Summary:"
echo "CPU: ${CPU_TIME}s for 100MB computation"
echo "Memory: ${MEM_TIME}s for 500MB throughput"
echo "Disk: ${DISK_TIME}s for 50MB write"
echo "Network: ${PING_RESULT}ms average ping"
echo "Database: ${DB_TIME}s for 100 record query"
echo "Redis: ${REDIS_TIME}s for 100 SET operations"
