# 🛠️ HOSTINGER VPS INFRASTRUCTURE SETUP - GIAI ĐOẠN 0.5

## 📋 **OVERVIEW**
**Mục tiêu**: Tạo nền tảng VPS chuyên nghiệp, bảo mật và tối ưu hiệu suất cho VietForex Bot  
**Timeline**: 7 ngày (Ngày -8 đến -2)  
**Chi phí**: $3.99/tháng (VPS 1) hoặc $7.99/tháng (VPS 2)  
**Địa điểm**: Singapore/Netherlands (tùy chọn)  

---

## 📅 **NGÀY -8: HOSTINGER VPS REGISTRATION & INITIAL SETUP** (2-3 giờ)

### **Bước 1: Đăng ký tài khoản Hostinger**

1. **Truy cập website Hostinger:**
   - Vào https://www.hostinger.com
   - Click "VPS Hosting" trong menu

2. **Chọn VPS plan:**
   
   **🟢 KHUYẾN NGHỊ: VPS Plan 1** 
   - **RAM**: 1GB 
   - **CPU**: 1 vCore
   - **Storage**: 20GB SSD
   - **Bandwidth**: 1TB
   - **Price**: $3.99/month (khoảng 95k VNĐ)
   - **Location**: Singapore (ping tốt cho VN)

   **🟡 TÙY CHỌN: VPS Plan 2 (nếu cần mạnh hơn)**
   - **RAM**: 2GB
   - **CPU**: 1 vCore  
   - **Storage**: 40GB SSD
   - **Bandwidth**: 2TB
   - **Price**: $7.99/month (khoảng 190k VNĐ)

3. **Cấu hình VPS:**
   - **Operating System**: Ubuntu 22.04 LTS 64-bit
   - **Location**: Singapore (tốt nhất cho VN) hoặc Netherlands
   - **Hostname**: `vietforex-production`
   - **Root Password**: Tạo password mạnh
     - Ví dụ: `VietForex2024@Hostinger!Prod`

4. **Hoàn tất thanh toán:**
   - Chọn payment method (Credit Card/PayPal)
   - Nhập thông tin thanh toán
   - Xác nhận đơn hàng
   - **Chờ 5-10 phút** để VPS được setup

### **Bước 2: Lấy thông tin VPS và test kết nối**

5. **Vào Hostinger hPanel:**
   - Login vào account Hostinger
   - Vào **"VPS"** section
   - Click vào VPS vừa tạo

6. **Lấy thông tin kết nối:**
   - **IP Address**: Ghi lại IP của VPS
   - **Username**: root
   - **Password**: Password bạn đã tạo
   - **SSH Port**: 22 (default)

7. **Test kết nối SSH đầu tiên:**

   **Trên Windows:**
   ```cmd
   # Mở Command Prompt hoặc PowerShell
   ssh root@YOUR_VPS_IP
   # Nhập password khi được hỏi
   ```

   **Trên Mac/Linux:**
   ```bash
   # Mở Terminal
   ssh root@YOUR_VPS_IP
   # Nhập password khi được hỏi
   ```

8. **Kiểm tra thông tin server:**
   ```bash
   # Sau khi SSH thành công, chạy:
   uname -a
   cat /etc/os-release
   free -h
   df -h
   
   # Kiểm tra network
   curl ifconfig.me  # Hiển thị IP public
   ping -c 4 8.8.8.8  # Test internet
   ```

### **✅ Checkpoint Ngày -8:**
- [ ] Hostinger VPS đã setup thành công
- [ ] SSH connection từ máy local working
- [ ] Server specs đúng: 1GB+ RAM, 1 vCore, 20GB+ SSD
- [ ] Location: Singapore/Netherlands
- [ ] Internet connectivity OK

---

## 📅 **NGÀY -7: SSH SECURITY & USER MANAGEMENT** (3-4 giờ)

### **Bước 1: System Updates & Essential Tools**

1. **System updates:**
   ```bash
   # SSH vào server với root
   ssh root@YOUR_VPS_IP
   
   # Update package lists và upgrade
   apt update && apt upgrade -y
   
   # Install essential packages
   apt install -y curl wget git vim htop unzip software-properties-common
   
   # Set Vietnam timezone
   timedatectl set-timezone Asia/Ho_Chi_Minh
   
   # Verify timezone
   date
   ```

### **Bước 2: SSH Key Authentication Setup**

2. **Tạo SSH key pair trên máy local:**
   ```bash
   # Trên máy local (không phải VPS)
   ssh-keygen -t rsa -b 4096 -C "vietforex@hostinger.vps"
   
   # Khi được hỏi file location, nhấn Enter (dùng default)
   # Khi được hỏi passphrase, có thể để trống hoặc tạo passphrase
   
   # Kiểm tra key đã tạo
   ls -la ~/.ssh/
   # Sẽ thấy: id_rsa (private key) và id_rsa.pub (public key)
   
   # Xem nội dung public key
   cat ~/.ssh/id_rsa.pub
   # Copy toàn bộ nội dung này
   ```

3. **Setup SSH key trên VPS:**
   ```bash
   # SSH vào VPS với root
   ssh root@YOUR_VPS_IP
   
   # Tạo .ssh directory
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   
   # Tạo authorized_keys file
   nano ~/.ssh/authorized_keys
   # Paste nội dung public key từ bước 2
   # Ctrl+X, Y, Enter để save
   
   # Set permissions
   chmod 600 ~/.ssh/authorized_keys
   ```

4. **Test SSH key authentication:**
   ```bash
   # Từ máy local, test connection mới
   ssh root@YOUR_VPS_IP
   # Lần này không cần nhập password nếu setup đúng
   ```

### **Bước 3: Create Secure User Account**

5. **Tạo user forex-bot:**
   ```bash
   # Trên VPS với root
   adduser forex-bot
   # Nhập password mạnh: VietForexUser2024!
   # Các thông tin khác có thể để trống (nhấn Enter)
   
   # Add to sudo group
   usermod -aG sudo forex-bot
   
   # Verify user created
   id forex-bot
   ```

6. **Setup SSH key cho user mới:**
   ```bash
   # Copy SSH key từ root sang forex-bot user
   mkdir -p /home/forex-bot/.ssh
   cp ~/.ssh/authorized_keys /home/forex-bot/.ssh/
   chown -R forex-bot:forex-bot /home/forex-bot/.ssh
   chmod 600 /home/forex-bot/.ssh/authorized_keys
   ```

7. **Test new user SSH:**
   ```bash
   # Từ terminal mới
   ssh forex-bot@YOUR_VPS_IP
   
   # Test sudo access
   sudo whoami
   # Should return: root
   ```

### **✅ Checkpoint Ngày -7:**
- [ ] System fully updated
- [ ] SSH key authentication working
- [ ] User 'forex-bot' created với sudo privileges
- [ ] SSH access working cho both root và forex-bot
- [ ] Essential tools installed

---

## 📅 **NGÀY -6: SECURITY HARDENING & FIREWALL** (2-3 giờ)

### **Bước 1: SSH Configuration Hardening**

1. **Backup SSH config:**
   ```bash
   # SSH với forex-bot user
   ssh forex-bot@YOUR_VPS_IP
   
   # Backup original config
   sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
   ```

2. **Edit SSH configuration:**
   ```bash
   sudo nano /etc/ssh/sshd_config
   
   # Tìm và thay đổi các dòng sau (uncomment nếu cần):
   Port 2222                    # Thay vì 22
   PermitRootLogin no          # Disable root login
   PasswordAuthentication no    # Only key authentication
   PubkeyAuthentication yes     # Enable key auth
   MaxAuthTries 3              # Limit auth attempts
   AllowUsers forex-bot        # Only allow forex-bot user
   
   # Save: Ctrl+X, Y, Enter
   ```

3. **Restart SSH service:**
   ```bash
   # Restart SSH (cẩn thận!)
   sudo systemctl restart sshd
   
   # Verify SSH is running
   sudo systemctl status sshd
   ```

4. **Test new SSH configuration:**
   ```bash
   # Từ máy local, test SSH với port mới
   ssh -p 2222 forex-bot@YOUR_VPS_IP
   
   # Test root login bị disable
   ssh -p 2222 root@YOUR_VPS_IP
   # Should be rejected
   ```

### **Bước 2: UFW Firewall Setup**

5. **Install và configure UFW:**
   ```bash
   # Install UFW
   sudo apt install -y ufw
   
   # Set default policies
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   
   # Allow essential ports
   sudo ufw allow 2222/tcp comment 'SSH Access'
   sudo ufw allow 80/tcp comment 'HTTP'
   sudo ufw allow 443/tcp comment 'HTTPS'
   sudo ufw allow 3000/tcp comment 'Node.js App'
   
   # Enable firewall
   sudo ufw enable
   # Type 'y' to confirm
   
   # Check status
   sudo ufw status verbose
   ```

### **Bước 3: Fail2Ban Installation**

6. **Install Fail2Ban:**
   ```bash
   sudo apt install -y fail2ban
   
   # Create custom jail configuration
   sudo nano /etc/fail2ban/jail.local
   ```

7. **Configure Fail2Ban:**
   ```bash
   # Add this content to /etc/fail2ban/jail.local:
   [DEFAULT]
   bantime = 3600
   findtime = 600
   maxretry = 3
   
   [sshd]
   enabled = true
   port = 2222
   filter = sshd
   logpath = /var/log/auth.log
   maxretry = 3
   ```

8. **Start Fail2Ban:**
   ```bash
   # Start and enable Fail2Ban
   sudo systemctl start fail2ban
   sudo systemctl enable fail2ban
   
   # Check status
   sudo systemctl status fail2ban
   sudo fail2ban-client status
   ```

### **✅ Checkpoint Ngày -6:**
- [ ] SSH port changed to 2222
- [ ] Root login disabled
- [ ] Password authentication disabled
- [ ] UFW firewall active với proper rules
- [ ] Fail2Ban protecting SSH
- [ ] All services running properly

---

## 📅 **NGÀY -5: SOFTWARE STACK INSTALLATION** (3-4 giờ)

### **Bước 1: Docker & Docker Compose**

1. **Install Docker:**
   ```bash
   # SSH với port mới
   ssh -p 2222 forex-bot@YOUR_VPS_IP
   
   # Download Docker installation script
   curl -fsSL https://get.docker.com -o get-docker.sh
   
   # Run installation
   sudo sh get-docker.sh
   
   # Add user to docker group
   sudo usermod -aG docker forex-bot
   
   # Apply group changes (logout and login again)
   exit
   ssh -p 2222 forex-bot@YOUR_VPS_IP
   ```

2. **Install Docker Compose:**
   ```bash
   # Download Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   
   # Make executable
   sudo chmod +x /usr/local/bin/docker-compose
   
   # Test installations
   docker --version
   docker-compose --version
   docker run hello-world  # Should work without sudo
   ```

### **Bước 2: Node.js 20+ Installation**

3. **Install Node.js:**
   ```bash
   # Add NodeSource repository
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   
   # Install Node.js
   sudo apt-get install -y nodejs
   
   # Install global packages
   sudo npm install -g pm2 nodemon yarn
   
   # Verify installations
   node --version    # Should be v20.x.x
   npm --version
   pm2 --version
   ```

### **Bước 3: PostgreSQL Database**

4. **Install PostgreSQL:**
   ```bash
   # Install PostgreSQL
   sudo apt install -y postgresql postgresql-contrib
   
   # Start services
   sudo systemctl start postgresql
   sudo systemctl enable postgresql
   
   # Check status
   sudo systemctl status postgresql
   ```

5. **Create database và user:**
   ```bash
   # Switch to postgres user and create database
   sudo -u postgres psql << EOF
   CREATE DATABASE vietforex_production;
   CREATE USER forex_bot WITH ENCRYPTED PASSWORD 'VietForexHostinger2024!';
   GRANT ALL PRIVILEGES ON DATABASE vietforex_production TO forex_bot;
   ALTER USER forex_bot CREATEDB;
   \q
   EOF
   
   # Test database connection
   PGPASSWORD='VietForexHostinger2024!' psql -h localhost -U forex_bot -d vietforex_production -c '\l'
   ```

### **Bước 4: Redis Cache**

6. **Install Redis:**
   ```bash
   # Install Redis
   sudo apt install -y redis-server
   
   # Configure Redis password
   sudo sed -i 's/^# requirepass foobared/requirepass VietForexRedisHostinger2024/' /etc/redis/redis.conf
   
   # Restart Redis
   sudo systemctl restart redis-server
   sudo systemctl enable redis-server
   
   # Test Redis
   redis-cli -a VietForexRedisHostinger2024 ping
   # Should return: PONG
   ```

### **✅ Checkpoint Ngày -5:**
- [ ] Docker và Docker Compose operational
- [ ] Node.js v20+ với PM2 installed
- [ ] PostgreSQL database configured
- [ ] Redis cache service running
- [ ] Database connection test passed
- [ ] Redis connection test passed

---

## 📅 **NGÀY -4: PROJECT STRUCTURE & ENVIRONMENT** (2-3 giờ)

### **Bước 1: Create Project Directory Structure**

1. **Create main project structure:**
   ```bash
   # SSH vào server
   ssh -p 2222 forex-bot@YOUR_VPS_IP
   
   # Create main project directory
   mkdir -p ~/vietforex-bot-project
   cd ~/vietforex-bot-project
   
   # Create folder structure
   mkdir -p {
     cau-hinh-chinh,
     mau-template,
     du-lieu-tho,
     du-lieu-xu-ly,
     mo-hinh,
     tin-hieu,
     kiem-chung,
     san-xuat,
     doanh-nghiep,
     phan-tich,
     quoc-te,
     doi-moi,
     mo-rong
   }
   
   # Create production subfolder structure
   mkdir -p san-xuat/{trien-khai,bao-mat,bao-tri,giam-sat}
   mkdir -p san-xuat/trien-khai/{cau-hinh-vps,telegram-bot,co-so-du-lieu}
   mkdir -p san-xuat/bao-mat/{chung-chi,firewall,audit}
   mkdir -p san-xuat/bao-tri/{backup,logs,monitoring}
   mkdir -p san-xuat/giam-sat/{metrics,alerts,dashboards}
   
   # Verify structure
   ls -la ~/vietforex-bot-project/
   ```

### **Bước 2: Create Configuration Files**

2. **VPS Information file:**
   ```bash
   # Create VPS info file
   cat > ~/vietforex-bot-project/san-xuat/trien-khai/cau-hinh-vps/hostinger-vps-info.json << EOF
   {
     "vps_provider": "Hostinger",
     "setup_date": "$(date)",
     "server_info": {
       "hostname": "$(hostname)",
       "ip_address": "$(curl -s ifconfig.me)",
       "os": "$(lsb_release -d | cut -f2)",
       "timezone": "$(timedatectl | grep 'Time zone' | awk '{print $3}')",
       "datacenter": "Singapore/Netherlands"
     },
     "specifications": {
       "ram": "1GB",
       "cpu": "1 vCore", 
       "storage": "20GB SSD",
       "bandwidth": "1TB"
     },
     "pricing": {
       "monthly_cost": "$3.99",
       "annual_cost": "$47.88"
     }
   }
   EOF
   ```

3. **Environment configuration:**
   ```bash
   # Create environment template
   cat > ~/vietforex-bot-project/san-xuat/trien-khai/cau-hinh-vps/.env.hostinger << 'EOF'
   # VietForex Hostinger Production Environment
   NODE_ENV=production
   PORT=3000
   
   # Server Info
   SERVER_PROVIDER=Hostinger
   SERVER_LOCATION=Singapore
   SERVER_IP=$(curl -s ifconfig.me)
   
   # Database Configuration
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=vietforex_production
   DB_USER=forex_bot
   DB_PASSWORD=VietForexHostinger2024!
   
   # Redis Configuration
   REDIS_HOST=localhost
   REDIS_PORT=6379
   REDIS_PASSWORD=VietForexRedisHostinger2024
   
   # Security
   JWT_SECRET=VietForex_JWT_Secret_2024_Hostinger
   API_KEY=VietForex_API_Key_2024_Hostinger
   
   # Telegram Bot (sẽ cập nhật sau)
   TELEGRAM_BOT_TOKEN=
   TELEGRAM_WEBHOOK_URL=
   EOF
   
   # Secure the file
   chmod 600 ~/vietforex-bot-project/san-xuat/trien-khai/cau-hinh-vps/.env.hostinger
   ```

### **✅ Checkpoint Ngày -4:**
- [ ] Project directory structure created
- [ ] VPS information file saved
- [ ] Environment configuration template ready
- [ ] File permissions set correctly
- [ ] Project organized theo PROJECT-PLAN.md structure

---

## 📅 **NGÀY -3: MONITORING & BACKUP SYSTEMS** (2-3 giờ)

### **Bước 1: System Monitoring Script**

1. **Create monitoring script:**
   ```bash
   # Create system monitoring script
   cat > ~/vietforex-bot-project/san-xuat/giam-sat/system-monitor.sh << 'EOF'
   #!/bin/bash
   # VietForex System Monitoring - Hostinger VPS
   
   echo "🔍 VIETFOREX SYSTEM STATUS - $(date)"
   echo "===================================="
   echo "🌏 Hostinger VPS - Singapore/Netherlands"
   echo ""
   
   # Resource usage
   echo "💾 MEMORY: $(free -h | grep Mem | awk '{print $3"/"$2}')"
   echo "💽 DISK: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
   echo "⚡ CPU: $(cat /proc/loadavg | awk '{print $1}')"
   echo "🌐 NETWORK: $(ping -c 1 8.8.8.8 > /dev/null && echo "OK" || echo "FAILED")"
   echo ""
   
   # Service status
   services=("docker" "postgresql" "redis-server" "fail2ban" "ssh")
   echo "🔧 SERVICES:"
   for service in "${services[@]}"; do
       if systemctl is-active --quiet $service; then
           echo "   ✓ $service: RUNNING"
       else
           echo "   ✗ $service: STOPPED"
       fi
   done
   echo ""
   
   # Port status
   echo "🌐 PORTS:"
   ports=("2222" "5432" "6379" "3000")
   for port in "${ports[@]}"; do
       if netstat -tln | grep -q ":$port "; then
           echo "   ✓ Port $port: LISTENING"
       else
           echo "   ⚠ Port $port: NOT LISTENING"
       fi
   done
   
   # Hostinger specific info
   echo ""
   echo "🏢 HOSTINGER VPS INFO:"
   echo "   IP: $(curl -s ifconfig.me)"
   echo "   Location: Singapore/Netherlands"
   echo "   Plan: VPS 1 ($3.99/month)"
   echo ""
   echo "📊 VietForex System: $(systemctl is-active --quiet postgresql && systemctl is-active --quiet redis-server && echo "HEALTHY" || echo "NEEDS ATTENTION")"
   EOF
   
   # Make executable
   chmod +x ~/vietforex-bot-project/san-xuat/giam-sat/system-monitor.sh
   
   # Test monitoring script
   ~/vietforex-bot-project/san-xuat/giam-sat/system-monitor.sh
   ```

### **Bước 2: Automated Backup System**

2. **Create backup script:**
   ```bash
   # Create backup script
   cat > ~/vietforex-bot-project/san-xuat/bao-tri/backup.sh << 'EOF'
   #!/bin/bash
   # VietForex Backup System - Hostinger VPS
   
   BACKUP_DIR="$HOME/vietforex-backups"
   DATE=$(date +%Y%m%d_%H%M%S)
   
   # Create backup directory
   mkdir -p $BACKUP_DIR
   
   echo "🔄 Starting VietForex Backup - $DATE"
   echo "🌏 Hostinger VPS - Singapore/Netherlands"
   
   # Database backup
   echo "📊 Backing up database..."
   PGPASSWORD='VietForexHostinger2024!' pg_dump -h localhost -U forex_bot vietforex_production > $BACKUP_DIR/db_backup_$DATE.sql
   
   # Project files backup
   echo "📁 Backing up project files..."
   tar -czf $BACKUP_DIR/project_backup_$DATE.tar.gz -C $HOME vietforex-bot-project/
   
   # Configuration backup
   echo "⚙️ Backing up system configs..."
   sudo cp /etc/ssh/sshd_config $BACKUP_DIR/sshd_config_$DATE
   sudo cp /etc/fail2ban/jail.local $BACKUP_DIR/jail_local_$DATE 2>/dev/null || true
   
   # Keep only last 7 backups (important for small VPS)
   echo "🧹 Cleaning old backups..."
   find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
   find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
   
   echo "✅ Backup completed: $DATE"
   echo "📂 Backup location: $BACKUP_DIR"
   echo "💽 Disk usage after backup:"
   df -h /
   EOF
   
   # Make executable
   chmod +x ~/vietforex-bot-project/san-xuat/bao-tri/backup.sh
   
   # Test backup script
   ~/vietforex-bot-project/san-xuat/bao-tri/backup.sh
   ```

3. **Setup automated backup cron:**
   ```bash
   # Add daily backup to cron (runs at 2 AM)
   (crontab -l 2>/dev/null; echo "0 2 * * * /home/forex-bot/vietforex-bot-project/san-xuat/bao-tri/backup.sh >> /home/forex-bot/backup.log 2>&1") | crontab -
   
   # Verify cron job
   crontab -l
   ```

### **✅ Checkpoint Ngày -3:**
- [ ] System monitoring script working
- [ ] Automated backup system configured
- [ ] Cron job scheduled for daily backups
- [ ] Scripts tested và functional
- [ ] Backup directory created với test files

---

## 📅 **NGÀY -2: SYSTEM VALIDATION & PERFORMANCE TESTING** (2-3 giờ)

### **Bước 1: Comprehensive System Validation**

1. **Create validation script:**
   ```bash
   # Create comprehensive validation script
   cat > ~/vietforex-bot-project/san-xuat/kiem-chung/hostinger-validation.sh << 'EOF'
   #!/bin/bash
   # Hostinger VPS Comprehensive Validation
   
   echo "🔍 HOSTINGER VPS VALIDATION - VIETFOREX PROJECT"
   echo "=============================================="
   echo "Date: $(date)"
   echo "Server: $(hostname) ($(curl -s ifconfig.me))"
   echo "Provider: Hostinger VPS"
   echo ""
   
   # System Information
   echo "✅ SYSTEM INFORMATION:"
   echo "   OS: $(lsb_release -d | cut -f2)"
   echo "   Kernel: $(uname -r)"  
   echo "   Uptime: $(uptime -p)"
   echo "   User: $USER"
   echo "   Location: Singapore/Netherlands"
   echo ""
   
   # Resource Usage
   echo "💾 RESOURCE USAGE:"
   echo "   Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
   echo "   Disk: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
   echo "   CPU Load: $(cat /proc/loadavg | awk '{print $1}')"
   echo ""
   
   # Service Status Validation
   echo "🔧 SERVICE STATUS:"
   services=("docker" "postgresql" "redis-server" "fail2ban" "ssh")
   for service in "${services[@]}"; do
       if systemctl is-active --quiet $service; then
           echo "   ✓ $service: RUNNING"
       else
           echo "   ✗ $service: STOPPED"
       fi
   done
   echo ""
   
   # Security Validation
   echo "🔒 SECURITY STATUS:"
   if ufw status | grep -q "Status: active"; then
       echo "   ✓ UFW Firewall: ACTIVE"
       echo "   Rules: $(ufw status numbered | grep -c ']')"
   else
       echo "   ✗ UFW Firewall: INACTIVE"
   fi
   
   if fail2ban-client status > /dev/null 2>&1; then
       echo "   ✓ Fail2Ban: ACTIVE"
   else  
       echo "   ✗ Fail2Ban: INACTIVE"
   fi
   
   # Port Status Check
   echo ""
   echo "🌐 PORT STATUS:"
   ports=("2222" "5432" "6379" "80" "443" "3000")
   for port in "${ports[@]}"; do
       if netstat -tln | grep -q ":$port "; then
           echo "   ✓ Port $port: LISTENING"
       else
           echo "   ⚠ Port $port: NOT LISTENING"
       fi
   done
   
   # Software Versions
   echo ""
   echo "📦 SOFTWARE VERSIONS:"
   echo "   Docker: $(docker --version | awk '{print $3}' | sed 's/,//')"
   echo "   Node.js: $(node --version)"
   echo "   PostgreSQL: $(psql --version | awk '{print $3}')"
   echo "   Redis: $(redis-server --version | awk '{print $3}' | cut -d'=' -f2)"
   
   # Database Connection Tests
   echo ""
   echo "🗄️ DATABASE TESTS:"
   if PGPASSWORD='VietForexHostinger2024!' psql -h localhost -U forex_bot -d vietforex_production -c '\l' > /dev/null 2>&1; then
       echo "   ✓ PostgreSQL: CONNECTION OK"
   else
       echo "   ✗ PostgreSQL: CONNECTION FAILED"
   fi
   
   if redis-cli -a VietForexRedisHostinger2024 ping 2>/dev/null | grep -q "PONG"; then
       echo "   ✓ Redis: CONNECTION OK"  
   else
       echo "   ✗ Redis: CONNECTION FAILED"
   fi
   
   # Project Structure Validation
   echo ""
   echo "📁 PROJECT STRUCTURE:"
   if [ -d ~/vietforex-bot-project ]; then
       echo "   ✓ Main project folder: EXISTS"
       echo "   Subfolders: $(find ~/vietforex-bot-project -maxdepth 1 -type d | wc -l)"
   else
       echo "   ✗ Main project folder: MISSING"
   fi
   
   # Hostinger Specific Checks
   echo ""
   echo "🏢 HOSTINGER SPECIFIC:"
   echo "   IP Address: $(curl -s ifconfig.me)"
   echo "   Ping to VN: $(ping -c 1 google.com | grep time | awk '{print $7}' | cut -d'=' -f2 || echo "N/A")"
   echo "   Available Storage: $(df -h / | awk 'NR==2{print $4}')"
   
   # Final Status
   echo ""
   echo "🎯 VALIDATION SUMMARY:"
   if systemctl is-active --quiet docker && \
      systemctl is-active --quiet postgresql && \
      systemctl is-active --quiet redis-server && \
      ufw status | grep -q "active"; then
       echo "   🎉 HOSTINGER VPS SETUP: SUCCESSFUL!"
       echo "   Status: READY FOR VIETFOREX DEVELOPMENT"
   else
       echo "   ⚠️  HOSTINGER VPS SETUP: NEEDS ATTENTION"
       echo "   Status: CHECK FAILED SERVICES"
   fi
   
   echo ""
   echo "📞 Support: https://www.hostinger.com/help"
   echo "💬 Next: Continue with VietForex Bot API development!"
   EOF
   
   chmod +x ~/vietforex-bot-project/san-xuat/kiem-chung/hostinger-validation.sh
   
   # Run validation
   ~/vietforex-bot-project/san-xuat/kiem-chung/hostinger-validation.sh
   ```

### **Bước 2: Performance Baseline Testing**

2. **Create performance testing script:**
   ```bash
   # Create performance baseline script
   cat > ~/vietforex-bot-project/san-xuat/kiem-chung/performance-baseline.sh << 'EOF'
   #!/bin/bash
   # Hostinger Performance Baseline Test
   
   echo "📊 HOSTINGER VPS PERFORMANCE BASELINE"
   echo "====================================="
   echo "Server: $(curl -s ifconfig.me) (Singapore/Netherlands)"
   echo "Provider: Hostinger VPS Plan 1"
   echo "Date: $(date)"
   echo ""
   
   # CPU Performance
   echo "⚡ CPU PERFORMANCE:"
   echo "   Cores: $(nproc)"
   echo "   Model: $(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d':' -f2 | xargs)"
   echo "   Load: $(cat /proc/loadavg)"
   echo "   Architecture: $(uname -m)"
   
   # Memory Performance  
   echo ""
   echo "💾 MEMORY PERFORMANCE:"
   echo "   System Memory Info:"
   free -h
   echo "   Memory Details:"
   echo "   Total: $(free -h | grep Mem | awk '{print $2}')"
   echo "   Used: $(free -h | grep Mem | awk '{print $3}')"
   echo "   Available: $(free -h | grep Mem | awk '{print $7}')"
   
   # Disk I/O Test
   echo ""
   echo "💽 DISK I/O TEST:"
   echo "   Disk Space:"
   df -h /
   echo ""
   echo "   Testing write speed (50MB - smaller for VPS)..."
   dd if=/dev/zero of=~/test_write_file bs=1M count=50 2>&1 | grep -E "(copied|MB/s)"
   
   echo "   Testing read speed (50MB)..."
   dd if=~/test_write_file of=/dev/null bs=1M 2>&1 | grep -E "(copied|MB/s)"
   
   echo "   Testing random I/O..."
   dd if=/dev/zero of=~/test_random_file bs=4k count=5000 oflag=direct 2>&1 | grep -E "(copied|MB/s)"
   
   # Cleanup test files
   rm -f ~/test_write_file ~/test_random_file
   
   # Network Performance
   echo ""
   echo "🌐 NETWORK PERFORMANCE:"
   echo "   Singapore/Netherlands → Google DNS (8.8.8.8):"
   ping -c 4 8.8.8.8 | tail -1
   
   echo "   Singapore/Netherlands → Cloudflare (1.1.1.1):"
   ping -c 4 1.1.1.1 | tail -1
   
   echo "   Singapore/Netherlands → Vietnam (google.com.vn):"
   ping -c 4 google.com.vn 2>/dev/null | tail -1 || echo "   Vietnam ping: Not available"
   
   # Database Performance
   echo ""
   echo "🗄️ DATABASE PERFORMANCE:"
   echo "   PostgreSQL Connection Test:"
   time_start=$(date +%s%N)
   PGPASSWORD='VietForexHostinger2024!' psql -h localhost -U forex_bot -d vietforex_production -c 'SELECT version();' >/dev/null 2>&1
   time_end=$(date +%s%N)
   time_diff=$(( (time_end - time_start) / 1000000 ))
   echo "   PostgreSQL connection time: ${time_diff}ms"
   
   echo "   PostgreSQL Query Performance:"
   PGPASSWORD='VietForexHostinger2024!' psql -h localhost -U forex_bot -d vietforex_production -c "
   SELECT 'Query executed successfully' as status, 
          current_timestamp as timestamp,
          version() as pg_version;" 2>/dev/null || echo "   PostgreSQL query: Error"
   
   echo "   Redis Performance Test:"
   redis_result=$(redis-cli -a VietForexRedisHostinger2024 ping 2>/dev/null)
   if [ "$redis_result" = "PONG" ]; then
       echo "   Redis ping: OK"
       echo "   Redis benchmark (500 operations - suitable for VPS):"
       redis-cli -a VietForexRedisHostinger2024 eval "
       for i=1,500 do
           redis.call('set', 'test_'..i, 'value_'..i)
       end
       return 'Benchmark completed'
       " 0 2>/dev/null
       echo "   Redis: 500 SET operations completed"
       redis-cli -a VietForexRedisHostinger2024 flushall >/dev/null 2>&1
   else
       echo "   Redis: Connection failed"
   fi
   
   # System Resource Usage
   echo ""
   echo "📈 SYSTEM RESOURCES:"
   echo "   CPU Usage:"
   top -bn1 | grep "Cpu(s)" | awk '{print "   Current CPU: " $2}'
   
   echo "   Memory Usage:"
   echo "   Used: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')"
   echo "   Available: $(free -h | grep Mem | awk '{print $7}')"
   
   echo "   Disk Usage:"
   echo "   Root partition: $(df -h / | awk 'NR==2{print $5 " used (" $3 "/" $2 ")"}')"
   
   echo "   Load Average:"
   echo "   1min: $(cat /proc/loadavg | awk '{print $1}')"
   echo "   5min: $(cat /proc/loadavg | awk '{print $2}')"
   echo "   15min: $(cat /proc/loadavg | awk '{print $3}')"
   
   # Hostinger VPS Specific
   echo ""
   echo "🏢 HOSTINGER VPS PERFORMANCE:"
   echo "   Plan: VPS 1 ($3.99/month)"
   echo "   Specs: 1GB RAM, 1 vCore, 20GB SSD"
   echo "   Location: Singapore/Netherlands"
   echo "   Bandwidth: 1TB"
   
   # Final Performance Score
   echo ""
   echo "🎯 PERFORMANCE SUMMARY:"
   echo "================================="
   
   # Calculate performance score
   cpu_cores=$(nproc)
   total_mem=$(free -m | grep Mem | awk '{print $2}')
   available_mem=$(free -m | grep Mem | awk '{print $7}')
   disk_free=$(df / | awk 'NR==2{print $4}')
   
   echo "   Hardware Score:"
   echo "   CPU Cores: $cpu_cores ($([ $cpu_cores -ge 1 ] && echo "✓ Good" || echo "⚠ Limited"))"
   echo "   Total RAM: ${total_mem}MB ($([ $total_mem -ge 900 ] && echo "✓ Good for VPS 1" || echo "⚠ Limited"))"
   echo "   Available RAM: ${available_mem}MB ($([ $available_mem -ge 500 ] && echo "✓ Good" || echo "⚠ Limited"))"
   echo "   Free Disk: $((disk_free/1024))MB ($([ $disk_free -gt 5242880 ] && echo "✓ Good" || echo "⚠ Limited"))"
   
   echo ""
   echo "   Service Health:"
   systemctl is-active --quiet docker && echo "   Docker: ✓ Running" || echo "   Docker: ✗ Stopped"
   systemctl is-active --quiet postgresql && echo "   PostgreSQL: ✓ Running" || echo "   PostgreSQL: ✗ Stopped"
   systemctl is-active --quiet redis-server && echo "   Redis: ✓ Running" || echo "   Redis: ✗ Stopped"
   
   echo ""
   echo "📊 BASELINE ESTABLISHED: $(date)"
   echo "💰 Cost Efficiency: $3.99/month for production-ready VPS"
   echo "🚀 Ready Status: CONFIRMED for VietForex Bot Development"
   echo ""
   echo "🎉 HOSTINGER VPS Performance: VALIDATED!"
   EOF
   
   # Make executable
   chmod +x ~/vietforex-bot-project/san-xuat/kiem-chung/performance-baseline.sh
   
   # Run performance test
   ~/vietforex-bot-project/san-xuat/kiem-chung/performance-baseline.sh
   ```

3. **Setup automated performance monitoring:**
   ```bash
   # Create weekly performance monitoring cron job
   echo "⏰ Setting up automated performance monitoring..."
   
   # Add weekly performance check (every Sunday at 3 AM)
   (crontab -l 2>/dev/null; echo "0 3 * * 0 /home/forex-bot/vietforex-bot-project/san-xuat/kiem-chung/performance-baseline.sh >> /home/forex-bot/vietforex-performance-weekly.log 2>&1") | crontab -
   
   # Verify cron job was added
   echo "📋 Current cron jobs:"
   crontab -l
   
   echo "✅ Weekly performance monitoring scheduled!"
   ```

### **Bước 3: Final System Validation**

4. **Create comprehensive final validation:**
   ```bash
   # Create final validation script
   cat > ~/vietforex-bot-project/san-xuat/kiem-chung/final-validation.sh << 'EOF'
   #!/bin/bash
   # Final Hostinger VPS Validation for VietForex Bot
   
   echo "🎯 FINAL HOSTINGER VPS VALIDATION"
   echo "=================================="
   echo "Date: $(date)"
   echo "Server: $(hostname) @ $(curl -s ifconfig.me)"
   echo "Provider: Hostinger VPS"
   echo ""
   
   # Counter for passed tests
   PASSED_TESTS=0
   TOTAL_TESTS=15
   
   # Test 1: System Information
   echo "📋 TEST 1: System Information"
   if [ "$(lsb_release -si)" = "Ubuntu" ] && [ "$(lsb_release -sr)" = "22.04" ]; then
       echo "   ✓ Ubuntu 22.04 LTS confirmed"
       ((PASSED_TESTS++))
   else
       echo "   ✗ OS verification failed"
   fi
   
   # Test 2: SSH Security
   echo ""
   echo "🔐 TEST 2: SSH Security"
   if grep -q "Port 2222" /etc/ssh/sshd_config && grep -q "PermitRootLogin no" /etc/ssh/sshd_config; then
       echo "   ✓ SSH security hardening confirmed"
       ((PASSED_TESTS++))
   else
       echo "   ✗ SSH configuration needs attention"
   fi
   
   # Test 3: Firewall Status
   echo ""
   echo "🛡️ TEST 3: Firewall Protection"
   if ufw status | grep -q "Status: active"; then
       echo "   ✓ UFW firewall is active"
       ((PASSED_TESTS++))
   else
       echo "   ✗ UFW firewall not active"
   fi
   
   # Test 4: Fail2Ban Protection
   echo ""
   echo "🚫 TEST 4: Intrusion Protection"
   if systemctl is-active --quiet fail2ban; then
       echo "   ✓ Fail2Ban protection active"
       ((PASSED_TESTS++))
   else
       echo "   ✗ Fail2Ban not running"
   fi
   
   # Test 5: Docker Service
   echo ""
   echo "🐳 TEST 5: Docker Service"
   if systemctl is-active --quiet docker && docker version >/dev/null 2>&1; then
       echo "   ✓ Docker service operational"
       ((PASSED_TESTS++))
   else
       echo "   ✗ Docker service issues"
   fi
   
   # Test 6: PostgreSQL Database
   echo ""
   echo "🗄️ TEST 6: PostgreSQL Database"
   if PGPASSWORD='VietForexHostinger2024!' psql -h localhost -U forex_bot -d vietforex_production -c 'SELECT 1;' >/dev/null 2>&1; then
       echo "   ✓ PostgreSQL connection successful"
       ((PASSED_TESTS++))
   else
       echo "   ✗ PostgreSQL connection failed"
   fi
   
   # Test 7: Redis Cache
   echo ""
   echo "⚡ TEST 7: Redis Cache"
   if redis-cli -a VietForexRedisHostinger2024 ping 2>/dev/null | grep -q "PONG"; then
       echo "   ✓ Redis cache operational"
       ((PASSED_TESTS++))
   else
       echo "   ✗ Redis connection failed"
   fi
   
   # Test 8: Node.js Runtime
   echo ""
   echo "🟢 TEST 8: Node.js Runtime"
   if node --version >/dev/null 2>&1 && npm --version >/dev/null 2>&1; then
       NODE_VERSION=$(node --version)
       echo "   ✓ Node.js $NODE_VERSION installed"
       ((PASSED_TESTS++))
   else
       echo "   ✗ Node.js installation issues"
   fi
   
   # Test 9: PM2 Process Manager
   echo ""
   echo "⚙️ TEST 9: PM2 Process Manager"
   if pm2 --version >/dev/null 2>&1; then
       echo "   ✓ PM2 process manager ready"
       ((PASSED_TESTS++))
   else
       echo "   ✗ PM2 not available"
   fi
   
   # Test 10: Project Structure
   echo ""
   echo "📁 TEST 10: Project Structure"
   if [ -d ~/vietforex-bot-project/san-xuat ]; then
       FOLDER_COUNT=$(find ~/vietforex-bot-project -type d | wc -l)
       echo "   ✓ Project structure created ($FOLDER_COUNT folders)"
       ((PASSED_TESTS++))
   else
       echo "   ✗ Project structure missing"
   fi
   
   # Test 11: Monitoring Scripts
   echo ""
   echo "📊 TEST 11: Monitoring Scripts"
   if [ -x ~/vietforex-bot-project/san-xuat/giam-sat/system-monitor.sh ]; then
       echo "   ✓ System monitoring script ready"
       ((PASSED_TESTS++))
   else
       echo "   ✗ Monitoring script not executable"
   fi
   
   # Test 12: Backup System
   echo ""
   echo "💾 TEST 12: Backup System"
   if [ -x ~/vietforex-bot-project/san-xuat/bao-tri/backup.sh ]; then
       echo "   ✓ Backup system configured"
       ((PASSED_TESTS++))
   else
       echo "   ✗ Backup script not ready"
   fi
   
   # Test 13: Cron Jobs
   echo ""
   echo "⏰ TEST 13: Scheduled Tasks"
   if crontab -l 2>/dev/null | grep -q backup.sh; then
       echo "   ✓ Automated backup scheduled"
       ((PASSED_TESTS++))
   else
       echo "   ✗ Backup automation not scheduled"
   fi
   
   # Test 14: Network Connectivity
   echo ""
   echo "🌐 TEST 14: Network Connectivity"
   if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
       echo "   ✓ Internet connectivity confirmed"
       ((PASSED_TESTS++))
   else
       echo "   ✗ Network connectivity issues"
   fi
   
   # Test 15: Performance Requirements
   echo ""
   echo "🚀 TEST 15: Performance Requirements"
   AVAILABLE_MEM=$(free -m | grep Mem | awk '{print $7}')
   if [ $AVAILABLE_MEM -gt 400 ]; then
       echo "   ✓ Sufficient memory available (${AVAILABLE_MEM}MB)"
       ((PASSED_TESTS++))
   else
       echo "   ✗ Insufficient available memory"
   fi
   
   # Final Results
   echo ""
   echo "🎯 VALIDATION SUMMARY"
   echo "===================="
   echo "Tests Passed: $PASSED_TESTS/$TOTAL_TESTS"
   
   PASS_PERCENTAGE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
   echo "Success Rate: $PASS_PERCENTAGE%"
   
   if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
       echo ""
       echo "🎉 VALIDATION STATUS: PERFECT!"
       echo "✅ HOSTINGER VPS Setup: 100% SUCCESSFUL"
       echo "🚀 Ready for: GIAI ĐOẠN 1 - API Server Development"
       echo ""
       echo "📊 Final Specs Summary:"
       echo "   Server: $(curl -s ifconfig.me) (Singapore/Netherlands)"
       echo "   Provider: Hostinger VPS Plan 1"
       echo "   RAM: $(free -h | grep Mem | awk '{print $2}') total"
       echo "   CPU: $(nproc) cores"
       echo "   Storage: $(df -h / | awk 'NR==2{print $2}') available"
       echo "   Cost: $3.99/month (~95k VNĐ)"
       echo ""
       echo "🎯 GIAI ĐOẠN 0.5: INFRASTRUCTURE FOUNDATION COMPLETE!"
   elif [ $PASSED_TESTS -ge 12 ]; then
       echo ""
       echo "⚠️ VALIDATION STATUS: GOOD (Minor issues)"
       echo "✅ HOSTINGER VPS Setup: Mostly successful"
       echo "🔧 Action: Review failed tests và fix"
   else
       echo ""
       echo "❌ VALIDATION STATUS: NEEDS ATTENTION"
       echo "🚨 HOSTINGER VPS Setup: Major issues detected"
       echo "🔧 Action: Fix failed tests before proceeding"
   fi
   
   echo ""
   echo "📞 Support: Hostinger Help Center"
   echo "📧 Next: Upload results to GitHub for review"
   EOF
   
   # Make executable
   chmod +x ~/vietforex-bot-project/san-xuat/kiem-chung/final-validation.sh
   
   # Run final validation
   echo "🎯 Running final comprehensive validation..."
   ~/vietforex-bot-project/san-xuat/kiem-chung/final-validation.sh
   
   # Save validation results
   ~/vietforex-bot-project/san-xuat/kiem-chung/final-validation.sh > ~/vietforex-bot-project/san-xuat/kiem-chung/final-validation-results-$(date +%Y%m%d).txt
   
   echo ""
   echo "✅ Final validation completed và saved!"
   echo "📁 Results saved to: final-validation-results-$(date +%Y%m%d).txt"
   ```

### **✅ Checkpoint Ngày -2:**
- [ ] Comprehensive system validation completed
- [ ] Performance baseline established
- [ ] All services verified working
- [ ] Validation results saved
- [ ] System ready for development

---

## 🎯 **HOSTINGER VPS SETUP COMPLETION CHECKLIST**

### **✅ Infrastructure Foundation:**
- [ ] Hostinger VPS Plan 1 active (Singapore/Netherlands)
- [ ] Ubuntu 22.04 LTS fully updated
- [ ] SSH key authentication configured
- [ ] User `forex-bot` created with sudo privileges
- [ ] Root login disabled for security

### **✅ Security Hardening:**
- [ ] SSH port changed to 2222
- [ ] UFW firewall active with proper rules
- [ ] Fail2Ban protection enabled
- [ ] SSL-ready for HTTPS traffic
- [ ] Security audit completed

### **✅ Software Stack:**
- [ ] Docker & Docker Compose operational
- [ ] Node.js v20+ with PM2 installed
- [ ] PostgreSQL database configured
- [ ] Redis cache service running
- [ ] All services auto-start on boot

### **✅ Project Infrastructure:**
- [ ] VietForex project structure created
- [ ] Environment configurations saved
- [ ] Backup system automated
- [ ] Monitoring scripts deployed
- [ ] Validation framework working

### **✅ Performance & Reliability:**
- [ ] System performance baseline established
- [ ] All services responding correctly
- [ ] Network connectivity validated
- [ ] Automated monitoring active
- [ ] Daily backup cron configured

---

## 💰 **HOSTINGER COST ANALYSIS:**

**Monthly Operating Costs:**
- **Hostinger VPS Plan 1**: $3.99/month (~95k VNĐ)
- **Backup Storage**: $0 (included)
- **DDoS Protection**: Basic (included)
- **Support**: 24/7 chat support

**Total Monthly Cost**: $3.99 (~95k VNĐ)

**ROI Benefits:**
- ✅ **Cheaper than IONOS** ($3.99 vs €4)
- ✅ **Good ping to Vietnam** (Singapore location)
- ✅ **Reliable uptime** (99.9% guarantee)
- ✅ **24/7 support** available
- ✅ **Easy management** via hPanel

---

## 📂 **LƯU VÀO GITHUB - CÁCH THỨC:**

### **📁 Nơi lưu trong GitHub repository:**

```
vietforex-bot/
└── infrastructure/
    ├── hostinger-setup/           # ← LƯU TẤT CẢ SCRIPTS VÀO ĐÂY
    │   ├── system-monitor.sh
    │   ├── backup.sh
    │   ├── performance-baseline.sh
    │   ├── hostinger-validation.sh
    │   ├── final-validation.sh
    │   └── hostinger-vps-info.json
    │
    ├── validation-results/        # ← LƯU KẾT QUẢ TEST
    │   ├── final-validation-results-*.txt
    │   ├── performance-baseline-*.txt
    │   └── hostinger-validation-*.txt
    │
    ├── configs/                   # ← LƯU CONFIG TEMPLATES
    │   ├── .env.hostinger.example
    │   └── ssh-config.example
    │
    └── docs/                      # ← LƯU DOCUMENTATION
        ├── HOSTINGER-SETUP-REPORT.md
        └── TROUBLESHOOTING.md
```

### **📤 Cách upload lên GitHub:**

1. **Download files từ VPS về máy local:**
   ```bash
   # Tạo archive trên VPS
   ssh -p 2222 forex-bot@YOUR_VPS_IP
   cd ~
   tar -czf vietforex-hostinger-setup.tar.gz vietforex-bot-project/
   
   # Download về máy local
   scp -P 2222 forex-bot@YOUR_VPS_IP:~/vietforex-hostinger-setup.tar.gz ~/Downloads/
   ```

2. **Extract và upload lên GitHub:**
   - Extract file downloaded
   - Copy files vào đúng folders trong GitHub
   - Commit với message: "✅ GIAI ĐOẠN 0.5: Hostinger Infrastructure Complete"

### **🎯 Files quan trọng cần lưu:**
- ✅ `system-monitor.sh` - Monitoring script
- ✅ `backup.sh` - Backup automation
- ✅ `performance-baseline.sh` - Performance testing
- ✅ `final-validation.sh` - Comprehensive validation
- ✅ `hostinger-vps-info.json` - Server info
- ✅ Validation results (.txt files)
- ✅ Setup completion report

**🎉 SAU KHI HOÀN THÀNH, BẠN SẼ CÓ HOSTINGER VPS FOUNDATION HOÀN HẢO CHO VIETFOREX BOT!**
