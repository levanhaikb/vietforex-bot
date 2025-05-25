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
