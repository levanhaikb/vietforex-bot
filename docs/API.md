# 🔌 VIETFOREX BOT API DOCUMENTATION

## 📋 **API OVERVIEW**

**Base URL**: `https://your-vps-ip:3000/api`  
**Authentication**: Bearer Token  
**Content-Type**: `application/json`  
**Rate Limit**: 1000 requests/hour per authenticated user

---

## 🔐 **AUTHENTICATION**

### **API Key Authentication**
```bash
# Header required for all requests
Authorization: Bearer VietForex_API_Key_2024_YOUR_SECRET

# Example request
curl -H "Authorization: Bearer VietForex_API_Key_2024_YOUR_SECRET" \
     -H "Content-Type: application/json" \
     https://your-vps-ip:3000/api/models/status
```

### **Rate Limiting**
```javascript
// Rate Limits
Free Tier: 100 requests/hour
Premium Tier: 1000 requests/hour  
Enterprise: 10000 requests/hour

// Rate Limit Headers (Response)
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

---

## 🤖 **MODEL Management ENDPOINTS**

### **1. Upload Trained Model**
```http
POST /api/models/upload
```

**Purpose**: Upload trained ML model từ Google Colab đến VPS

**Request Body:**
```json
{
  "model_name": "EURUSD_LSTM_v2.1",
  "model_version": "2.1.0",
  "pair_symbol": "EURUSD",
  "model_type": "LSTM",
  "accuracy": 0.5847,
  "training_data": {
    "start_date": "2014-01-01",
    "end_date": "2024-10-01",
    "samples": 2547890,
    "features": 45
  },
  "model_config": {
    "input_shape": [60, 45],
    "layers": ["LSTM(50)", "Dropout(0.2)", "Dense(1)"],
    "optimizer": "adam",
    "loss": "binary_crossentropy"
  },
  "model_data": "base64_encoded_model_binary",
  "performance_metrics": {
    "sharpe_ratio": 1.23,
    "max_drawdown": 0.15,
    "win_rate": 0.58,
    "profit_factor": 1.45
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Model uploaded successfully",
  "model_id": 1547,
  "status": "uploaded",
  "validation_status": "pending",
  "estimated_validation_time": "5-10 minutes"
}
```

### **2. Get Model Status**
```http
GET /api/models/status/{model_id}
```

**Response:**
```json
{
  "model_id": 1547,
  "name": "EURUSD_LSTM_v2.1",
  "status": "active", // uploaded, validating, active, inactive, error
  "pair_symbol": "EURUSD",
  "accuracy": 0.5847,
  "deployed_at": "2024-11-15T10:30:00Z",
  "last_signal": "2024-11-15T14:25:30Z",
  "performance": {
    "signals_generated": 1247,
    "successful_signals": 728,
    "current_accuracy": 0.5839,
    "profit_pips": 2847.5
  }
}
```

### **3. Activate Model**
```http
PUT /api/models/activate/{model_id}
```

**Request Body:**
```json
{
  "force_activation": false,
  "deactivate_previous": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Model activated successfully",
  "model_id": 1547,
  "previous_model_deactivated": 1546,
  "activation_time": "2024-11-15T15:00:00Z"
}
```

### **4. List Models**
```http
GET /api/models/list?pair=EURUSD&status=active&limit=10
```

**Response:**
```json
{
  "models": [
    {
      "id": 1547,
      "name": "EURUSD_LSTM_v2.1", 
      "pair": "EURUSD",
      "status": "active",
      "accuracy": 0.5847,
      "created_at": "2024-11-15T10:30:00Z"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 10
}
```

---

## 📊 **DATA PROCESSING ENDPOINTS**

### **1. Get Market Data**
```http
GET /api/data/market/{pair}?timeframe=M15&limit=1000
```

**Response:**
```json
{
  "pair": "EURUSD",
  "timeframe": "M15", 
  "data": [
    {
      "timestamp": "2024-11-15T14:15:00Z",
      "open": 1.0856,
      "high": 1.0863,
      "low": 1.0851,
      "close": 1.0859,
      "volume": 15634
    }
  ],
  "count": 1000,
  "last_updated": "2024-11-15T14:30:00Z"
}
```

### **2. Upload Historical Data**
```http
POST /api/data/upload
```

**Request Body:**
```json
{
  "pair": "EURUSD",
  "timeframe": "M1",
  "data_source": "Exness",
  "data": [
    {
      "timestamp": "2024-11-15T14:15:00Z",
      "open": 1.0856,
      "high": 1.0863, 
      "low": 1.0851,
      "close": 1.0859,
      "volume": 1563
    }
  ]
}
```

### **3. Process Features**
```http
POST /api/data/process-features
```

**Request Body:**
```json
{
  "pair": "EURUSD",
  "timeframe": "M15", 
  "start_date": "2024-11-01",
  "end_date": "2024-11-15",
  "feature_sets": ["technical", "sentiment", "economic"],
  "regime_classification": true
}
```

**Response:**
```json
{
  "success": true,
  "job_id": "feature_job_5847",
  "status": "processing",
  "estimated_completion": "2024-11-15T15:45:00Z",
  "progress_url": "/api/jobs/feature_job_5847"
}
```

---

## 🎯 **SIGNAL GENERATION ENDPOINTS**

### **1. Generate Signal**
```http
POST /api/signals/generate
```

**Request Body:**
```json
{
  "pair": "EURUSD",
  "model_id": 1547,
  "signal_type": "auto", // auto, manual, backtest
  "include_analysis": true
}
```

**Response:**
```json
{
  "signal_id": 98745,
  "pair": "EURUSD", 
  "signal": "BUY",
  "confidence": 0.847,
  "entry_price": 1.0859,
  "stop_loss": 1.0834,
  "take_profit": 1.0909,
  "risk_reward": 2.0,
  "market_regime": "trending_bullish",
  "analysis": {
    "technical_score": 0.78,
    "sentiment_score": 0.61, 
    "momentum_score": 0.89,
    "key_factors": [
      "Strong bullish momentum on M15",
      "Breaking above resistance at 1.0855",
      "RSI showing bullish divergence"
    ]
  },
  "generated_at": "2024-11-15T14:30:00Z",
  "expires_at": "2024-11-15T18:30:00Z"
}
```

### **2. Get Signal History**
```http
GET /api/signals/history?pair=EURUSD&limit=50&status=closed
```

**Response:**
```json
{
  "signals": [
    {
      "id": 98744,
      "pair": "EURUSD",
      "signal": "SELL", 
      "entry_price": 1.0832,
      "exit_price": 1.0847,
      "result": "loss",
      "pnl_pips": -15.0,
      "created_at": "2024-11-15T12:15:00Z",
      "closed_at": "2024-11-15T13:45:00Z"
    }
  ],
  "total": 247,
  "page": 1,
  "performance_summary": {
    "total_signals": 247,
    "winning_signals": 143,
    "win_rate": 0.579,
    "total_pips": 1247.5,
    "sharpe_ratio": 1.23
  }
}
```

### **3. Update Signal Performance**
```http
PUT /api/signals/{signal_id}/performance
```

**Request Body:**
```json
{
  "result": "win", // win, loss, breakeven
  "exit_price": 1.0909,
  "pnl_pips": 50.0,
  "closed_at": "2024-11-15T16:30:00Z",
  "notes": "Hit take profit target"
}
```

### **4. Broadcast Signal**
```http
POST /api/signals/broadcast/{signal_id}
```

**Request Body:**
```json
{
  "channels": ["telegram", "webhook"],
  "user_filters": {
    "subscription_tier": ["premium", "enterprise"],
    "pair_preferences": ["EURUSD"]
  },
  "message_template": "detailed" // simple, detailed, custom
}
```

---

## 🌊 **MARKET REGIME ENDPOINTS**

### **1. Get Current Regime**
```http
GET /api/regime/current/{pair}
```

**Response:**
```json
{
  "pair": "EURUSD",
  "current_regime": {
    "type": "trending_bullish",
    "confidence": 0.832,
    "detected_at": "2024-11-15T08:30:00Z",
    "duration": "6h 15m",
    "characteristics": {
      "trend_strength": 0.78,
      "volatility_level": "medium",
      "volume_profile": "increasing"
    }
  },
  "regime_history": [
    {
      "type": "sideways",
      "start": "2024-11-14T22:00:00Z", 
      "end": "2024-11-15T08:30:00Z",
      "duration": "10h 30m"
    }
  ]
}
```

### **2. Regime Analysis**
```http
GET /api/regime/analysis/{pair}?period=1d
```

**Response:**
```json
{
  "pair": "EURUSD",
  "analysis_period": "24h",
  "regime_distribution": {
    "trending_bullish": 0.35,
    "trending_bearish": 0.22,
    "sideways": 0.28,
    "volatile": 0.15
  },
  "transitions": [
    {
      "from": "sideways",
      "to": "trending_bullish", 
      "timestamp": "2024-11-15T08:30:00Z",
      "trigger": "breakout_above_resistance"
    }
  ],
  "performance_by_regime": {
    "trending_bullish": {
      "signals": 12,
      "win_rate": 0.75,
      "avg_pips": 28.5
    }
  }
}
```

---

## 👥 **USER MANAGEMENT ENDPOINTS**

### **1. Register User**
```http
POST /api/users/register
```

**Request Body:**
```json
{
  "telegram_id": 123456789,
  "username": "trader_pro",
  "first_name": "John",
  "subscription_tier": "free",
  "preferences": {
    "pairs": ["EURUSD", "GBPUSD"],
    "risk_level": "medium",
    "notification_time": "09:00-17:00"
  }
}
```

### **2. Get User Profile**
```http
GET /api/users/{telegram_id}
```

**Response:**
```json
{
  "telegram_id": 123456789,
  "username": "trader_pro",
  "subscription_tier": "premium",
  "joined_at": "2024-10-15T10:30:00Z",
  "last_active": "2024-11-15T14:25:00Z",
  "statistics": {
    "signals_received": 247,
    "trades_taken": 89,
    "win_rate": 0.61,
    "total_pips": 432.5
  },
  "preferences": {
    "pairs": ["EURUSD", "GBPUSD"],
    "risk_level": "medium"
  }
}
```

### **3. Update Subscription**
```http
PUT /api/users/{telegram_id}/subscription
```

**Request Body:**
```json
{
  "tier": "premium",
  "payment_method": "crypto",
  "duration": "monthly"
}
```

---

## 📈 **ANALYTICS ENDPOINTS**

### **1. Performance Analytics**
```http
GET /api/analytics/performance?period=30d&pair=EURUSD
```

**Response:**
```json
{
  "period": "30 days",
  "pair": "EURUSD",
  "overview": {
    "total_signals": 147,
    "winning_signals": 89,
    "win_rate": 0.605,
    "total_pips": 1247.5,
    "sharpe_ratio": 1.34,
    "max_drawdown": 0.12
  },
  "daily_performance": [
    {
      "date": "2024-11-15",
      "signals": 5,
      "wins": 3,
      "pips": 45.5
    }
  ],
  "by_regime": {
    "trending": {"win_rate": 0.72, "avg_pips": 32.1},
    "sideways": {"win_rate": 0.48, "avg_pips": 12.3}
  }
}
```

### **2. System Health**
```http
GET /api/health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-11-15T14:30:00Z",
  "services": {
    "database": "healthy",
    "redis": "healthy", 
    "telegram_bot": "healthy",
    "models": {
      "active_models": 3,
      "healthy_models": 3
    }
  },
  "performance": {
    "avg_response_time": "147ms",
    "requests_per_minute": 234,
    "error_rate": 0.001
  }
}
```

---

## 🔄 **WEBHOOK ENDPOINTS**

### **1. Model Training Complete**
```http
POST /api/webhooks/model-complete
```

**Colab Callback khi model training xong:**
```json
{
  "event": "model_training_complete",
  "model_name": "EURUSD_LSTM_v2.1",
  "status": "success",
  "performance": {
    "accuracy": 0.5847,
    "loss": 0.4231
  },
  "model_url": "https://colab-storage/model.h5"
}
```

### **2. Market Data Update**
```http
POST /api/webhooks/market-update
```

**External data provider callback:**
```json
{
  "event": "market_data_update",
  "pair": "EURUSD",
  "timestamp": "2024-11-15T14:30:00Z",
  "data": {
    "price": 1.0859,
    "change": 0.0023,
    "volume": 15634
  }
}
```

---

## 🔧 **UTILITY ENDPOINTS**

### **1. Validate Data**
```http
POST /api/utils/validate-data
```

**Request Body:**
```json
{
  "data_type": "ohlcv",
  "data": [
    {
      "timestamp": "2024-11-15T14:15:00Z",
      "open": 1.0856,
      "high": 1.0863,
      "low": 1.0851,
      "close": 1.0859,
      "volume": 1563
    }
  ]
}
```

**Response:**
```json
{
  "valid": true,
  "issues": [],
  "summary": {
    "total_records": 1,
    "valid_records": 1,
    "invalid_records": 0
  }
}
```

### **2. Calculate Technical Indicators**
```http
POST /api/utils/indicators
```

**Request Body:**
```json
{
  "pair": "EURUSD",
  "indicators": ["RSI", "MACD", "BB"],
  "timeframe": "M15",
  "period": 100
}
```

**Response:**
```json
{
  "pair": "EURUSD",
  "timeframe": "M15",
  "indicators": {
    "RSI": [45.23, 47.56, 52.18],
    "MACD": {
      "macd": [0.0012, 0.0015, 0.0018],
      "signal": [0.0010, 0.0013, 0.0016]
    },
    "BB": {
      "upper": [1.0875, 1.0878, 1.0880],
      "middle": [1.0856, 1.0859, 1.0862], 
      "lower": [1.0837, 1.0840, 1.0844]
    }
  }
}
```

---

## 🚨 **ERROR HANDLING**

### **Standard Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "MODEL_NOT_FOUND",
    "message": "Model with ID 1547 not found",
    "details": {
      "model_id": 1547,
      "suggested_action": "Check model ID or create new model"
    }
  },
  "timestamp": "2024-11-15T14:30:00Z",
  "request_id": "req_7834092"
}
```

### **Common Error Codes:**
```javascript
// Authentication Errors
401 UNAUTHORIZED: "Invalid or missing API key"
403 FORBIDDEN: "Insufficient permissions"

// Validation Errors  
400 BAD_REQUEST: "Invalid request format"
422 VALIDATION_ERROR: "Data validation failed"

// Resource Errors
404 NOT_FOUND: "Resource not found"
409 CONFLICT: "Resource already exists"

// Rate Limiting
429 RATE_LIMITED: "Rate limit exceeded"

// Server Errors
500 INTERNAL_ERROR: "Internal server error"
503 SERVICE_UNAVAILABLE: "Service temporarily unavailable"

// Business Logic Errors
600 MODEL_ERROR: "Model processing error"
601 SIGNAL_ERROR: "Signal generation error"
602 DATA_ERROR: "Data processing error"
```

---

## 📊 **API USAGE EXAMPLES**

### **Complete Workflow Example:**

#### **1. Upload Model từ Colab:**
```python
# In Google Colab
import requests
import base64

# Load trained model
with open('eurusd_model.h5', 'rb') as f:
    model_data = base64.b64encode(f.read()).decode()

# Upload to VPS
response = requests.post(
    'https://your-vps:3000/api/models/upload',
    headers={
        'Authorization': 'Bearer VietForex_API_Key_2024_YOUR_SECRET',
        'Content-Type': 'application/json'
    },
    json={
        'model_name': 'EURUSD_LSTM_v2.1',
        'pair_symbol': 'EURUSD',
        'accuracy': 0.5847,
        'model_data': model_data
    }
)

print(f"Model uploaded: {response.json()}")
```

#### **2. Generate Signal:**
```python
# Generate new signal
response = requests.post(
    'https://your-vps:3000/api/signals/generate',
    headers={
        'Authorization': 'Bearer VietForex_API_Key_2024_YOUR_SECRET',
        'Content-Type': 'application/json'
    },
    json={
        'pair': 'EURUSD',
        'model_id': 1547,
        'include_analysis': True
    }
)

signal = response.json()
print(f"New signal: {signal['signal']} at {signal['entry_price']}")
```

#### **3. Broadcast to Telegram:**
```python
# Broadcast signal to users
response = requests.post(
    f"https://your-vps:3000/api/signals/broadcast/{signal['signal_id']}",
    headers={
        'Authorization': 'Bearer VietForex_API_Key_2024_YOUR_SECRET',
        'Content-Type': 'application/json'
    },
    json={
        'channels': ['telegram'],
        'user_filters': {
            'subscription_tier': ['premium'],
            'pair_preferences': ['EURUSD']
        }
    }
)

print(f"Signal broadcasted to {response.json()['users_notified']} users")
```

---

## 🔒 **SECURITY BEST PRACTICES**

### **API Key Management:**
```javascript
// Store API keys securely
process.env.VIETFOREX_API_KEY = "VietForex_API_Key_2024_YOUR_SECRET"

// Rotate keys regularly
// Use different keys for dev/staging/production
// Monitor API key usage
```

### **Request Validation:**
```javascript
// Always validate inputs
const validateSignalRequest = (req, res, next) => {
  const { pair, model_id } = req.body;
  
  if (!pair || !['EURUSD', 'GBPUSD', 'USDJPY'].includes(pair)) {
    return res.status(400).json({
      error: 'Invalid trading pair'
    });
  }
  
  if (!model_id || !Number.isInteger(model_id)) {
    return res.status(400).json({
      error: 'Invalid model ID'
    });
  }
  
  next();
};
```

### **Rate Limiting Implementation:**
```javascript
const rateLimit = require('express-rate-limit');

const apiLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 1000, // 1000 requests per hour
  message: {
    error: 'Rate limit exceeded',
    retry_after: 3600
  }
});

app.use('/api/', apiLimiter);
```

---

## 📈 **PERFORMANCE OPTIMIZATION**

### **Caching Strategy:**
```javascript
// Cache frequently accessed data
const redis = require('redis');
const client = redis.createClient();

// Cache model data for 1 hour
app.get('/api/models/:id', async (req, res) => {
  const cacheKey = `model:${req.params.id}`;
  const cached = await client.get(cacheKey);
  
  if (cached) {
    return res.json(JSON.parse(cached));
  }
  
  const model = await db.getModel(req.params.id);
  await client.setex(cacheKey, 3600, JSON.stringify(model));
  
  res.json(model);
});
```

### **Database Optimization:**
```sql
-- Create indexes for frequently queried columns
CREATE INDEX idx_signals_pair_created ON signals(pair_id, created_at);
CREATE INDEX idx_models_active ON models(is_active, pair_id);
CREATE INDEX idx_users_telegram ON users(telegram_id);

-- Optimize queries with EXPLAIN
EXPLAIN ANALYZE 
SELECT * FROM signals 
WHERE pair_id = 1 AND created_at >= NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

---

## 🔍 **TESTING & DEBUGGING**

### **API Testing với curl:**
```bash
# Test authentication
curl -H "Authorization: Bearer VietForex_API_Key_2024_YOUR_SECRET" \
     https://your-vps:3000/api/health

# Test model upload
curl -X POST \
     -H "Authorization: Bearer VietForex_API_Key_2024_YOUR_SECRET" \
     -H "Content-Type: application/json" \
     -d '{"model_name":"Test_Model","pair_symbol":"EURUSD"}' \
     https://your-vps:3000/api/models/upload

# Test signal generation
curl -X POST \
     -H "Authorization: Bearer VietForex_API_Key_2024_YOUR_SECRET" \
     -H "Content-Type: application/json" \
     -d '{"pair":"EURUSD","model_id":1547}' \
     https://your-vps:3000/api/signals/generate
```

### **Response Time Monitoring:**
```javascript
// Add response time middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.path} - ${duration}ms`);
    
    // Log slow requests
    if (duration > 1000) {
      console.warn(`Slow request: ${req.method} ${req.path} - ${duration}ms`);
    }
  });
  
  next();
});
```

---

## 📋 **API INTEGRATION CHECKLIST**

### ✅ **Colab Integration:**
- [ ] Model upload endpoint working
- [ ] Authentication configured
- [ ] Error handling implemented  
- [ ] Progress tracking functional
- [ ] Model validation pipeline active

### ✅ **Telegram Bot Integration:**
- [ ] Signal broadcast endpoint working
- [ ] User management endpoints functional
- [ ] Webhook endpoints configured
- [ ] Message formatting working
- [ ] Analytics tracking active

### ✅ **Database Integration:**
- [ ] All CRUD operations working
- [ ] Indexes optimized
- [ ] Connection pooling configured
- [ ] Backup procedures tested
- [ ] Performance monitoring active

### ✅ **Security Implementation:**
- [ ] Authentication working
- [ ] Rate limiting active
- [ ] Input validation implemented
- [ ] HTTPS configured
- [ ] API keys secured

---

**🎯 This API documentation covers all endpoints needed for the complete PROJECT-PLAN.md implementation!**
