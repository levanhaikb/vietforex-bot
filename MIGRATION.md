# 🔄 Migration Guide: IONOS → Hostinger

## Overview
This guide helps migrate from IONOS VPS to Hostinger VPS with proper naming conventions.

## Key Changes

### Hostname Format
- **Old**: `vietforex-production` 
- **New**: `vietforex.production`

### User Accounts  
- **Old**: `forex-bot`
- **New**: `forex.bot`

### Project Structure
- **Old**: `~/vietforex-bot-project/`
- **New**: `~/vietforex.bot.project/`

## Migration Steps

1. **Setup Hostinger VPS** following `infrastructure/README.md`
2. **Backup data** from old IONOS server
3. **Update configurations** to use dot format
4. **Deploy** using new scripts
5. **Verify** all systems working

## Testing
Run validation script to ensure compliance:
```bash
bash scripts/validate-hostinger.sh

### **10. 🎯 GitHub Repository Structure Update**

#### **Final repository structure:**
vietforex-bot/
├── README.md                          # ✅ Updated with Hostinger info
├── SETUP.md                          # ✅ Updated for Hostinger
├── MIGRATION.md                      # 🆕 New migration guide
├── CHANGELOG.md
├── .gitignore                        # ✅ Updated with Hostinger entries
│
├── configs/
│   ├── .env.example                  # ✅ Keep existing
│   ├── .env.hostinger.example        # 🆕 New Hostinger template
│   └── docker-compose.yml            # ✅ Updated with dot naming
│
├── infrastructure/
│   ├── README.md                     # ✅ Completely updated for Hostinger
│   └── hostinger-setup/              # 🆕 New folder for Hostinger scripts
│       ├── system.monitor.sh
│       ├── backup.sh
│       └── validation.scripts/
│
├── scripts/
│   ├── deploy.sh                     # ✅ Updated for Hostinger
│   ├── setup-hostinger.sh            # 🆕 New Hostinger setup
│   ├── monitor-hostinger.sh          # 🆕 New monitoring
│   └── validate-hostinger.sh         # 🆕 New validation
│
├── docs/
│   ├── API.md                        # ✅ Keep existing
│   ├── ARCHITECTURE.md               # ✅ Updated with Hostinger section
│   └── HOSTINGER-GUIDE.md            # 🆕 New comprehensive guide
│
└── src/                              # ✅ Keep existing structure
├── api-server/
├── colab/
├── database/
└── telegram-bot/

## 🚀 **IMPLEMENTATION PLAN**

### **Phase 1: Core Updates (Day 1)**
1. ✅ Update `README.md` with Hostinger info
2. ✅ Replace `infrastructure/README.md` 
3. ✅ Create `.env.hostinger.example`
4. ✅ Update `.gitignore`

### **Phase 2: Scripts & Documentation (Day 2)**
1. ✅ Create Hostinger setup scripts
2. ✅ Update deployment scripts
3. ✅ Create monitoring scripts
4. ✅ Update `SETUP.md`

### **Phase 3: Advanced Features (Day 3)**
1. ✅ Create migration guide
2. ✅ Update architecture documentation
3. ✅ Create validation scripts
4. ✅ Test all components

## 🎯 **COMMIT MESSAGE SUGGESTIONS**
🎯 MAJOR UPDATE: Migrate from IONOS to Hostinger VPS

✅ Infrastructure: Switch to Hostinger VPS ($3.99/month)
✅ Naming: Update all naming conventions to dot-format
✅ Hostname: Change to vietforex.production (Hostinger compliant)
✅ Scripts: Create Hostinger-specific setup/monitoring scripts
✅ Docs: Update all documentation for Hostinger compatibility
✅ Cost: Reduce infrastructure cost by 50%
✅ Performance: Optimize for Singapore datacenter

BREAKING CHANGES:

Hostname format changed from hyphens to dots
User accounts now use dot format (forex.bot)
Project structure uses dot naming convention
All scripts updated for Hostinger compliance

Ready for: GIAI ĐOẠN 0.5 Infrastructure Foundation
