# 🏗️ VIETFOREX BOT SYSTEM ARCHITECTURE

## 🎯 **HIGH-LEVEL OVERVIEW**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GOOGLE COLAB  │    │   IONOS VPS     │    │   TELEGRAM      │
│                 │    │                 │    │                 │
│ 🤖 AI Training  │◄──►│ 🔗 REST API     │◄──►│ 👥 Users        │
│ 📊 Data Process │    │ 🗄️ PostgreSQL   │    │ 🤖 Bot          │
│ 🧠 ML Models    │    │ ⚡ Redis Cache  │    │ 📱 Mobile       │
│ 📈 Backtesting  │    │ 🚀 Node.js      │    │ 💬 Signals      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
      AI ENGINE           CENTRAL HUB           USER INTERFACE
```

## 🔄 **DATA FLOW ARCHITECTURE**

### **Real-Time Signal Generation Flow:**
```
1. 📈 Market Data → Colab Processing
2. 🧠 AI Models → Signal Generation  
3. 🔗 REST API → Signal Validation
4. 🗄️ Database → Signal Storage
5. 🤖 Telegram → User Delivery
6. 📊 Analytics → Performance Tracking
```

### **Model Training & Deployment Flow:**
```
1. 📊 Historical Data Collection (Colab)
2. 🔧 Feature Engineering (Colab)
3. 🤖 Model Training (Colab GPU)
4. ✅ Model Validation (Colab)
5. 📤 Model Upload (API)
6. 🚀 Model Deployment (VPS)
7. 📈 Performance Monitoring (Real-time)
```

---

## 🧩 **COMPONENT ARCHITECTURE**

### **1. 🤖 GOOGLE COLAB LAYER (AI ENGINE)**

#### **Core Responsibilities:**
- **Data Processing**: Historical data cleaning & feature engineering
- **Model Training**: Deep learning models với GPU acceleration
- **Backtesting**: Strategy validation với historical data
- **Research**: Experimental features và model improvements

#### **Key Components:**
```python
colab/
├── data_processing.ipynb      # Data cleaning & feature engineering
├── model_training.ipynb       # ML model training pipeline  
├── backtesting.ipynb         # Strategy backtesting framework
├── api_client.py             # VPS API communication client
├── regime_detection.py       # Market regime classification
└── model_validation.py       # Model performance validation
```

#### **Technical Stack:**
- **Python 3.9+**: Core programming language
- **TensorFlow/PyTorch**: Deep learning frameworks
- **Pandas/NumPy**: Data manipulation
- **Scikit-learn**: Classical ML algorithms
- **TA-Lib**: Technical analysis indicators
- **Requests**: API communication

---

### **2. 🖥️ IONOS VPS LAYER (CENTRAL HUB)**

#### **Core Responsibilities:**
- **API Gateway**: Central communication hub
- **Database Management**: Data persistence & retrieval
- **Signal Processing**: Real-time signal validation & delivery
- **User Management**: Authentication & subscription handling
- **Monitoring**: System health & performance tracking

#### **System Specifications:**
- **Server**: IONOS VPS S (2GB RAM, 1 vCore, 40GB SSD)
- **OS**: Ubuntu 22.04 LTS
- **Location**: Frankfurt, Germany
- **Cost**: €4/month (~100k VNĐ)

#### **Key Components:**
```javascript
api-server/
├── routes/
│   ├── models.js             # Model management endpoints
│   ├── data.js               # Data processing endpoints
│   ├── signals.js            # Signal generation endpoints  
│   ├── users.js              # User management endpoints
│   ├── regime.js             # Market regime endpoints
│   └── analytics.js          # Performance analytics
├── middleware/
│   ├── auth.js               # Authentication middleware
│   ├── validation.js         # Input validation
│   ├── rateLimit.js          # API rate limiting
│   └── logging.js            # Request logging
├── services/
│   ├── modelService.js       # Model deployment service
│   ├── signalService.js      # Signal processing service
│   ├── telegramService.js    # Telegram integration
│   └── analyticsService.js   # Analytics service
└── utils/
    ├── database.js           # Database utilities
    ├── redis.js              # Redis utilities
    └── helpers.js            # Common utilities
```

#### **Technical Stack:**
- **Node.js v20+**: Runtime environment
- **Express.js**: Web framework
- **PostgreSQL**: Primary database
- **Redis**: Caching & session storage
- **PM2**: Process management
- **Docker**: Containerization
- **Nginx**: Reverse proxy (future)

---

### **3. 🗄️ DATABASE ARCHITECTURE**

#### **PostgreSQL Schema:**
```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    username VARCHAR(255),
    subscription_tier VARCHAR(50) DEFAULT 'free',
    created_at TIMESTAMP DEFAULT NOW(),
    last_active TIMESTAMP DEFAULT NOW()
);

-- Trading pairs
CREATE TABLE trading_pairs (
    id SERIAL PRIMARY KEY,
    symbol VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Models table  
CREATE TABLE models (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    pair_id INTEGER REFERENCES trading_pairs(id),
    model_type VARCHAR(100),
    accuracy DECIMAL(5,4),
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    model_data JSONB
);

-- Signals table
CREATE TABLE signals (
    id SERIAL PRIMARY KEY,
    pair_id INTEGER REFERENCES trading_pairs(id),
    model_id INTEGER REFERENCES models(id),
    signal_type VARCHAR(10) CHECK (signal_type IN ('BUY', 'SELL')),
    confidence DECIMAL(5,4),
    entry_price DECIMAL(10,5),
    stop_loss DECIMAL(10,5),
    take_profit DECIMAL(10,5),
    market_regime VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'active'
);

-- Performance tracking
CREATE TABLE signal_performance (
    id SERIAL PRIMARY KEY,
    signal_id INTEGER REFERENCES signals(id),
    result VARCHAR(20), -- 'win', 'loss', 'pending'
    pnl_pips DECIMAL(8,2),
    closed_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Market regimes
CREATE TABLE market_regimes (
    id SERIAL PRIMARY KEY,
    pair_id INTEGER REFERENCES trading_pairs(id),
    regime_type VARCHAR(50), -- 'trending', 'sideways', 'volatile', 'crisis'
    confidence DECIMAL(5,4),
    detected_at TIMESTAMP DEFAULT NOW()
);
```

#### **Redis Cache Structure:**
```javascript
// API rate limiting
"rate_limit:api:{ip_address}" → {count: 100, expiry: 3600}

// Model cache
"model:active:{pair_symbol}" → {model_data, updated_at}

// User sessions  
"session:{telegram_id}" → {user_data, preferences}

// Signal cache
"signals:latest:{pair_symbol}" → {signal_data, timestamp}

// Performance metrics
"performance:daily:{date}" → {accuracy, total_signals, profit}
```

---

### **4. 🤖 TELEGRAM BOT LAYER (USER INTERFACE)**

#### **Core Responsibilities:**
- **User Interaction**: Command handling & response generation
- **Signal Delivery**: Real-time signal broadcasting
- **Subscription Management**: User tier management
- **Analytics Collection**: User behavior tracking

#### **Bot Architecture:**
```javascript
telegram-bot/
├── index.js                  # Main bot entry point
├── commands/
│   ├── start.js              # Welcome & onboarding
│   ├── subscribe.js          # Subscription management
│   ├── signals.js            # Signal history & stats
│   ├── performance.js        # Performance analytics
│   ├── pairs.js              # Available trading pairs
│   ├── regime.js             # Market regime info
│   └── help.js               # Help & documentation
├── handlers/
│   ├── messageHandler.js     # Message processing
│   ├── callbackHandler.js    # Inline keyboard callbacks
│   └── errorHandler.js       # Error handling
├── services/
│   ├── signalSender.js       # Signal broadcasting
│   ├── userManager.js        # User management
│   └── analyticsCollector.js # User analytics
└── templates/
    ├── signalTemplate.js     # Signal message templates
    ├── welcomeTemplate.js    # Welcome messages
    └── analyticsTemplate.js  # Performance reports
```

#### **Technical Stack:**
- **node-telegram-bot-api**: Telegram Bot SDK
- **Express.js**: Webhook handling
- **PostgreSQL**: User & data storage
- **Redis**: Session management
- **Cron Jobs**: Scheduled tasks

---

## 🔐 **SECURITY ARCHITECTURE**

### **VPS Security Hardening:**
```bash
# SSH Security
- Port: 2222 (non-standard)
- Key-based authentication only
- Root login disabled
- Fail2Ban protection active

# Firewall Configuration
- UFW enabled với strict rules
- Only essential ports open:
  * 2222: SSH
  * 80/443: HTTP/HTTPS  
  * 3000: Node.js API
  * 5432: PostgreSQL (localhost only)
  * 6379: Redis (localhost only)

# Application Security
- API rate limiting
- Input validation & sanitization
- SQL injection prevention
- XSS protection
- CORS configuration
```

### **API Security:**
```javascript
// Authentication
Bearer Token: "VietForex_API_Key_2024"

// Rate Limiting
100 requests/hour per IP
1000 requests/hour per authenticated user

// Encryption
HTTPS only in production
API payloads encrypted

// Validation
All inputs validated & sanitized
SQL injection prevention
```

---

## ⚡ **PERFORMANCE ARCHITECTURE**

### **Optimization Strategies:**

#### **Database Performance:**
- **Indexing**: All frequently queried columns
- **Connection Pooling**: Max 20 concurrent connections
- **Query Optimization**: Optimized queries với EXPLAIN
- **Partitioning**: Large tables partitioned by date
- **Caching**: Frequently accessed data cached

#### **API Performance:**
- **Response Caching**: Redis caching cho static data
- **Compression**: Gzip compression enabled
- **Connection Keep-Alive**: HTTP persistent connections
- **Async Processing**: Non-blocking operations
- **Load Balancing**: Ready for horizontal scaling

#### **Real-Time Performance:**
```javascript
// Target Performance Metrics
API Response Time: < 200ms average
Signal Delivery Time: < 5 seconds
Database Query Time: < 50ms average
Cache Hit Ratio: > 80%
System Uptime: > 99.9%
```

---

## 📊 **MONITORING & ANALYTICS ARCHITECTURE**

### **System Monitoring:**
```javascript
// Health Checks
- API endpoint health
- Database connectivity  
- Redis availability
- Telegram bot status
- System resource usage

// Performance Metrics
- API response times
- Database query performance
- Memory usage patterns
- CPU utilization
- Network I/O

// Business Metrics  
- Signal accuracy rates
- User engagement levels
- Subscription conversions
- Revenue tracking
- Churn analysis
```

### **Logging Architecture:**
```javascript
// Log Levels
ERROR: System errors & exceptions
WARN: Performance issues & warnings  
INFO: General application events
DEBUG: Detailed debugging information

// Log Destinations
- Local files: /var/log/vietforex/
- Database: Critical events stored
- External: Future integration với monitoring services
```

---

## 🚀 **DEPLOYMENT ARCHITECTURE**

### **Development Workflow:**
```bash
1. Local Development → GitHub commit
2. GitHub → Automated testing
3. Staging Deploy → Integration testing  
4. Production Deploy → Live monitoring
5. Performance Analysis → Optimization
```

### **Deployment Strategy:**
```javascript
// Blue-Green Deployment
- Zero-downtime deployments
- Instant rollback capability
- A/B testing support
- Gradual traffic shifting

// Container Strategy (Future)
- Docker containers
- Container orchestration
- Auto-scaling capabilities
- Resource optimization
```

---

## 🔮 **SCALABILITY ARCHITECTURE**

### **Horizontal Scaling Preparation:**
```javascript
// Database Scaling
- Read replicas setup ready
- Sharding strategy planned
- Connection pooling optimized

// Application Scaling  
- Stateless application design
- Load balancer ready
- Session store externalized
- Microservices architecture prepared

// Infrastructure Scaling
- Auto-scaling groups planned
- CDN integration ready
- Multi-region deployment planned
```

### **Performance Targets:**
```javascript
// Current Capacity (Single VPS)
Concurrent Users: 1,000
API Requests/min: 10,000  
Signals/day: 100,000
Database Queries/sec: 1,000

// Scaling Targets (Multi-VPS)
Concurrent Users: 100,000
API Requests/min: 1,000,000
Signals/day: 10,000,000
Database Queries/sec: 100,000
```

---

## 📋 **ARCHITECTURE VALIDATION CHECKLIST**

### ✅ **Infrastructure Ready:**
- [ ] IONOS VPS provisioned với required specs
- [ ] Ubuntu 22.04 LTS với security hardening
- [ ] Docker và Docker Compose operational
- [ ] PostgreSQL và Redis configured
- [ ] Node.js v20+ với PM2 installed

### ✅ **Security Implemented:**
- [ ] SSH key authentication configured
- [ ] UFW firewall với proper rules
- [ ] Fail2Ban protection active
- [ ] SSL certificates ready
- [ ] API security measures implemented

### ✅ **Development Environment:**
- [ ] GitHub repository structured
- [ ] Development workflow established  
- [ ] Testing framework ready
- [ ] Deployment scripts prepared
- [ ] Monitoring tools configured

### ✅ **Integration Points:**
- [ ] Colab ↔ VPS API communication tested
- [ ] VPS ↔ Telegram Bot integration working
- [ ] Database ↔ Application layer validated
- [ ] Redis caching operational
- [ ] External APIs integrated

---

**🎯 This architecture supports the complete PROJECT-PLAN.md implementation từ MVP đến enterprise-scale deployment!**
