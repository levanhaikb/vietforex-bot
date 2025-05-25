# 🛠️ VIETFOREX BOT SETUP GUIDE

## 🎯 **Prerequisites**

- **VPS**: Hostinger $3.99/month, Ubuntu 22.04 LTS
- **GitHub**: Access to repository
- **Google Colab Pro**: 3 accounts ($30/month)
- **Telegram**: Bot token from @BotFather

## 🖥️ **Hostinger VPS Setup**

### **Step 1: VPS Registration**
```bash
# 1. Visit https://www.hostinger.com
# 2. Choose VPS Plan 1 ($3.99/month)
# 3. Select Singapore/Netherlands location
# 4. Set hostname: vietforex.production (IMPORTANT: dots only!)
# 5. Complete payment process
Step 2: Initial Server Setup
bash# SSH into server
ssh root@YOUR_VPS_IP

# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git vim htop unzip

# Set timezone
sudo timedatectl set-timezone Asia/Ho_Chi_Minh

# Verify hostname format
hostname
# Should show: vietforex.production
Step 3: Create User Account
bash# Create forex.bot user (note: dots, not hyphens)
sudo adduser forex.bot
sudo usermod -aG sudo forex.bot

# Setup SSH keys
sudo mkdir -p /home/forex.bot/.ssh
sudo cp ~/.ssh/authorized_keys /home/forex.bot/.ssh/
sudo chown -R forex.bot:forex.bot /home/forex.bot/.ssh
📊 Hostinger Specific Notes
🏷️ Naming Conventions:

Hostname: vietforex.production (dots only)
User: forex.bot (dots, not hyphens)
Project folders: Use dots instead of hyphens
Scripts: system.monitor.sh format

⚠️ Important:

Hostinger UI only accepts dot-separated hostnames
No hyphens allowed in hostname field
All naming should follow dot convention

For complete setup instructions, see infrastructure/README.md
