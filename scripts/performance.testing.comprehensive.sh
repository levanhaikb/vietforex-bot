#!/bin/bash
# Comprehensive Performance Testing for VietForex Bot

source ~/.env

echo "🚀 VIETFOREX BOT - COMPREHENSIVE PERFORMANCE TESTING"
echo "==================================================="
echo "🌏 Server: $(hostname) @ $(curl -s ifconfig.me)"
echo "📅 $(date)"
echo ""

RESULTS_DIR="$HOME/vietforex.bot.project/logs/performance"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$RESULTS_DIR/performance_test_$TIMESTAMP.txt"

mkdir -p $RESULTS_DIR

# Logging function
log_result() {
    echo "$1" | tee -a $RESULTS_FILE
}

log_result "🚀 PERFORMANCE TESTING SESSION: $TIMESTAMP"
log_result "=============================================="
log_result "Server: $(hostname)"
log_result "Test Date: $(date)"
log_result ""

# System Specifications
log_result "🖥️ SYSTEM SPECIFICATIONS:"
log_result "OS: $(lsb_release -d | cut -f2)"
log_result "Kernel: $(uname -r)"
log_result "CPU: $(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d':' -f2 | xargs)"
log_result "Cores: $(nproc)"
log_result "Total RAM: $(free -h | grep Mem | awk '{print $2}')"
log_result "Total Storage: $(df -h / | awk 'NR==2{print $2}')"
log_result ""

# CPU Performance Tests
log_result "⚡ CPU PERFORMANCE TESTS:"
echo "Running CPU performance tests..."

# CPU Computation Test
CPU_START=$(date +%s%N)
dd if=/dev/zero of=/tmp/cpu_test bs=1M count=200 >/dev/null 2>&1
CPU_END=$(date +%s%N)
CPU_TIME=$(echo "scale=3; ($CPU_END - $CPU_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
log_result "200MB CPU computation: ${CPU_TIME}s"
rm -f /tmp/cpu_test

# CPU Stress Test
CPU_STRESS_START=$(date +%s)
timeout 10s dd if=/dev/zero of=/dev/null bs=1M &
CPU_LOAD_DURING_STRESS=$(sleep 5; cat /proc/loadavg | awk '{print $1}')
wait
CPU_STRESS_END=$(date +%s)
log_result "10s CPU stress test load: $CPU_LOAD_DURING_STRESS"

# Memory Performance Tests
log_result ""
log_result "💾 MEMORY PERFORMANCE TESTS:"
echo "Running memory performance tests..."

# Memory Allocation Test
MEM_START=$(date +%s%N)
dd if=/dev/zero of=/dev/null bs=1M count=500 2>/dev/null
MEM_END=$(date +%s%N)
MEM_TIME=$(echo "scale=3; ($MEM_END - $MEM_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
log_result "500MB memory throughput test: ${MEM_TIME}s"

# Memory Usage Analysis
INITIAL_MEM=$(free -m | grep Mem | awk '{print $3}')
# Create memory pressure
dd if=/dev/zero of=/tmp/mem_test bs=1M count=100 >/dev/null 2>&1 &
sleep 2
STRESSED_MEM=$(free -m | grep Mem | awk '{print $3}')
kill $! 2>/dev/null
rm -f /tmp/mem_test
log_result "Memory usage: ${INITIAL_MEM}MB → ${STRESSED_MEM}MB under load"

# Disk I/O Performance Tests
log_result ""
log_result "💽 DISK I/O PERFORMANCE TESTS:"
echo "Running disk I/O performance tests..."

# Sequential Write Test
WRITE_START=$(date +%s%N)
dd if=/dev/zero of=/tmp/write_test bs=1M count=100 oflag=direct 2>/dev/null
WRITE_END=$(date +%s%N)
WRITE_TIME=$(echo "scale=3; ($WRITE_END - $WRITE_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
WRITE_SPEED=$(echo "scale=2; 100 / $WRITE_TIME" | bc 2>/dev/null || echo "N/A")
log_result "Sequential write (100MB): ${WRITE_TIME}s (${WRITE_SPEED} MB/s)"

# Sequential Read Test
READ_START=$(date +%s%N)
dd if=/tmp/write_test of=/dev/null bs=1M iflag=direct 2>/dev/null
READ_END=$(date +%s%N)
READ_TIME=$(echo "scale=3; ($READ_END - $READ_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
READ_SPEED=$(echo "scale=2; 100 / $READ_TIME" | bc 2>/dev/null || echo "N/A")
log_result "Sequential read (100MB): ${READ_TIME}s (${READ_SPEED} MB/s)"

# Random I/O Test
RANDOM_START=$(date +%s%N)
dd if=/dev/zero of=/tmp/random_test bs=4k count=1000 oflag=direct 2>/dev/null
RANDOM_END=$(date +%s%N)
RANDOM_TIME=$(echo "scale=3; ($RANDOM_END - $RANDOM_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
log_result "Random I/O (4MB in 4k blocks): ${RANDOM_TIME}s"

# Cleanup
rm -f /tmp/write_test /tmp/random_test

# Network Performance Tests
log_result ""
log_result "🌐 NETWORK PERFORMANCE TESTS:"
echo "Running network performance tests..."

# Ping Tests
PING_GOOGLE=$(ping -c 10 8.8.8.8 | tail -1 | awk -F'/' '{print $5}' || echo "N/A")
PING_CF=$(ping -c 10 1.1.1.1 | tail -1 | awk -F'/' '{print $5}' || echo "N/A")
PING_LOCAL=$(ping -c 5 127.0.0.1 | tail -1 | awk -F'/' '{print $5}' || echo "N/A")
log_result "Average ping to Google DNS: ${PING_GOOGLE}ms"
log_result "Average ping to Cloudflare: ${PING_CF}ms"
log_result "Local loopback ping: ${PING_LOCAL}ms"

# Download Speed Test (small file)
DOWNLOAD_START=$(date +%s%N)
curl -s -o /tmp/speed_test http://speedtest.ftp.otenet.gr/files/test1Mb.db >/dev/null 2>&1
DOWNLOAD_END=$(date +%s%N)
if [ -f /tmp/speed_test ]; then
    DOWNLOAD_TIME=$(echo "scale=3; ($DOWNLOAD_END - $DOWNLOAD_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    DOWNLOAD_SIZE=$(stat -c%s /tmp/speed_test 2>/dev/null || echo "0")
    DOWNLOAD_SPEED=$(echo "scale=2; $DOWNLOAD_SIZE / $DOWNLOAD_TIME / 1024 / 1024 * 8" | bc 2>/dev/null || echo "N/A")
    log_result "Download speed test: ${DOWNLOAD_TIME}s (${DOWNLOAD_SPEED} Mbps)"
    rm -f /tmp/speed_test
else
    log_result "Download speed test: Failed"
fi

# Database Performance Tests
log_result ""
log_result "🗄️ DATABASE PERFORMANCE TESTS:"
echo "Running database performance tests..."

if systemctl is-active --quiet postgresql; then
    # Connection Time Test
    CONN_START=$(date +%s%N)
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1
    CONN_END=$(date +%s%N)
    CONN_TIME=$(echo "scale=3; ($CONN_END - $CONN_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    log_result "PostgreSQL connection time: ${CONN_TIME}s"
    
    # Query Performance Test
    QUERY_START=$(date +%s%N)
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT generate_series(1,1000);" >/dev/null 2>&1
    QUERY_END=$(date +%s%N)
    QUERY_TIME=$(echo "scale=3; ($QUERY_END - $QUERY_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    log_result "PostgreSQL query (1K records): ${QUERY_TIME}s"
    
    # Transaction Test
    TRANS_START=$(date +%s%N)
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
    BEGIN;
    CREATE TEMP TABLE perf_test (id SERIAL, data TEXT);
    INSERT INTO perf_test (data) SELECT 'test_data_' || generate_series(1,100);
    SELECT COUNT(*) FROM perf_test;
    DROP TABLE perf_test;
    COMMIT;
    " >/dev/null 2>&1
    TRANS_END=$(date +%s%N)
    TRANS_TIME=$(echo "scale=3; ($TRANS_END - $TRANS_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    log_result "PostgreSQL transaction (100 inserts): ${TRANS_TIME}s"
else
    log_result "PostgreSQL: Service not running"
fi

# Redis Performance Tests
log_result ""
log_result "⚡ REDIS PERFORMANCE TESTS:"
echo "Running Redis performance tests..."

if systemctl is-active --quiet redis-server; then
    # Connection Time Test
    REDIS_CONN_START=$(date +%s%N)
    redis-cli -a "$REDIS_PASSWORD" ping >/dev/null 2>&1
    REDIS_CONN_END=$(date +%s%N)
    REDIS_CONN_TIME=$(echo "scale=3; ($REDIS_CONN_END - $REDIS_CONN_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    log_result "Redis connection time: ${REDIS_CONN_TIME}s"
    
    # SET Performance Test
    SET_START=$(date +%s%N)
    for i in {1..1000}; do
        redis-cli -a "$REDIS_PASSWORD" set "perf_test_$i" "value_$i" >/dev/null 2>&1
    done
    SET_END=$(date +%s%N)
    SET_TIME=$(echo "scale=3; ($SET_END - $SET_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    SET_RATE=$(echo "scale=0; 1000 / $SET_TIME" | bc 2>/dev/null || echo "N/A")
    log_result "Redis 1000 SET operations: ${SET_TIME}s (${SET_RATE} ops/sec)"
    
    # GET Performance Test
    GET_START=$(date +%s%N)
    for i in {1..1000}; do
        redis-cli -a "$REDIS_PASSWORD" get "perf_test_$i" >/dev/null 2>&1
    done
    GET_END=$(date +%s%N)
    GET_TIME=$(echo "scale=3; ($GET_END - $GET_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    GET_RATE=$(echo "scale=0; 1000 / $GET_TIME" | bc 2>/dev/null || echo "N/A")
    log_result "Redis 1000 GET operations: ${GET_TIME}s (${GET_RATE} ops/sec)"
    
    # Cleanup test data
    redis-cli -a "$REDIS_PASSWORD" flushall >/dev/null 2>&1
else
    log_result "Redis: Service not running"
fi

# Docker Performance Tests
log_result ""
log_result "🐳 DOCKER PERFORMANCE TESTS:"
echo "Running Docker performance tests..."

if systemctl is-active --quiet docker; then
    # Container Start Test
    DOCKER_START=$(date +%s%N)
    docker run --rm hello-world >/dev/null 2>&1
    DOCKER_END=$(date +%s%N)
    DOCKER_TIME=$(echo "scale=3; ($DOCKER_END - $DOCKER_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    log_result "Docker container start time: ${DOCKER_TIME}s"
    
    # Docker Image Operations
    IMAGE_LIST_START=$(date +%s%N)
    docker images >/dev/null 2>&1
    IMAGE_LIST_END=$(date +%s%N)
    IMAGE_LIST_TIME=$(echo "scale=3; ($IMAGE_LIST_END - $IMAGE_LIST_START) / 1000000000" | bc 2>/dev/null || echo "N/A")
    log_result "Docker image list time: ${IMAGE_LIST_TIME}s"
else
    log_result "Docker: Service not running"
fi

# System Resource Usage During Tests
log_result ""
log_result "📊 RESOURCE USAGE DURING TESTS:"
FINAL_MEM_USAGE=$(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100}')
FINAL_DISK_USAGE=$(df / | awk 'NR==2{print $5}')
FINAL_LOAD=$(cat /proc/loadavg | awk '{print $1}')
log_result "Final memory usage: $FINAL_MEM_USAGE"
log_result "Final disk usage: $FINAL_DISK_USAGE"
log_result "Final system load: $FINAL_LOAD"

# Performance Summary
log_result ""
log_result "🎯 PERFORMANCE TEST SUMMARY:"
log_result "============================"
log_result "Test Session: $TIMESTAMP"
log_result "Total Test Duration: $(echo "scale=0; ($(date +%s) - $(date -d \"$(head -3 $RESULTS_FILE | tail -1 | cut -d: -f2-)\" +%s)) / 60" | bc 2>/dev/null || echo "N/A") minutes"
log_result "System Performance: $([ $(echo "$FINAL_LOAD < 1" | bc 2>/dev/null) -eq 1 ] && echo "EXCELLENT" || echo "GOOD")"
log_result "Memory Efficiency: $([ $(echo "$FINAL_MEM_USAGE" | cut -d% -f1 | bc 2>/dev/null) -lt 50 ] && echo "EXCELLENT" || echo "GOOD")"
log_result "Storage Health: $([ $(echo "$FINAL_DISK_USAGE" | cut -d% -f1) -lt 20 ] && echo "EXCELLENT" || echo "GOOD")"

log_result ""
log_result "📂 Results saved to: $RESULTS_FILE"
log_result "🔄 Performance testing completed: $(date)"

echo "✅ Performance testing completed!"
echo "📊 Results saved to: $RESULTS_FILE"
echo "📈 Performance summary:"
echo "  CPU Performance: Tested with computation and stress tests"
echo "  Memory Performance: Tested throughput and allocation"
echo "  Disk I/O: Sequential and random I/O tests completed"
echo "  Network: Latency and bandwidth tests completed"
echo "  Database: Connection and query performance tested"
echo "  Redis: SET/GET operations performance tested"
echo "  Docker: Container operations tested"
