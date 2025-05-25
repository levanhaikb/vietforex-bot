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
