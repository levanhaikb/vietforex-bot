# 🛠️ VIETFOREX BOT SETUP GUIDE

## 🎯 **Prerequisites**

- **VPS**: IONOS €4/month, Ubuntu 22.04 LTS
- **GitHub**: Access to repository
- **Google Colab Pro**: 3 accounts ($30/month)
- **Telegram**: Bot token from @BotFather

## 🖥️ **VPS Setup**

### **Step 1: Initial Server Setup**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git vim htop unzip

# Set timezone
sudo timedatectl set-timezone Asia/Ho_Chi_Minh
# Create forex-bot user
sudo adduser forex-bot
sudo usermod -aG sudo forex-bot

# Setup SSH keys
sudo mkdir -p /home/forex-bot/.ssh
sudo cp ~/.ssh/authorized_keys /home/forex-bot/.ssh/
sudo chown -R forex-bot:forex-bot /home/forex-bot/.ssh
sudo chmod 600 /home/forex-bot/.ssh/authorized_keys
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker forex-bot

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Install Node.js 20+
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install global packages
sudo npm install -g pm2 nodemon
# PostgreSQL
sudo apt install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Redis
sudo apt install -y redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
# Configure firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw enable

# Install Fail2Ban
sudo apt install -y fail2ban
