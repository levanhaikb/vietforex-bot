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
