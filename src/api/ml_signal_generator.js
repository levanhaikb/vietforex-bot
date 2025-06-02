const axios = require('axios');
const cron = require('node-cron');

class MLSignalGenerator {
    constructor() {
        this.mlServiceUrl = 'http://localhost:5000';
        this.webhookUrl = 'http://localhost:3002/webhook/signals';
        this.apiUrl = 'http://localhost:3000';
        this.signalCount = 0;
    }

    // Generate realistic market features
    generateMarketFeatures() {
        // Simulate market conditions
        const trend = Math.random();
        const volatility = Math.random() * 0.5 + 0.5;
        
        // Generate correlated features
        const rsi = 20 + Math.random() * 60;
        const isBullish = rsi < 40 || (rsi < 60 && Math.random() > 0.5);
        
        return {
            rsi: rsi,
            macd_signal: isBullish ? Math.random() * 0.002 : -Math.random() * 0.002,
            bb_upper_distance: (Math.random() - 0.5) * 0.005,
            bb_lower_distance: (Math.random() - 0.5) * 0.005,
            ema_20: 1.0850 + (Math.random() - 0.5) * 0.002,
            ema_50: 1.0845 + (Math.random() - 0.5) * 0.002,
            volume_ratio: 0.8 + Math.random() * 0.6,
            atr: 0.002 + Math.random() * 0.002,
            price_change: isBullish ? Math.random() * 0.001 : -Math.random() * 0.001,
            high_low_ratio: 0.999 + Math.random() * 0.002
        };
    }

    async analyzeMarket() {
        console.log('\n🔄 Running market analysis...');
        
        try {
            // 1. Generate market features
            const features = this.generateMarketFeatures();
            console.log('📊 Market features generated');
            
            // 2. Get ML prediction
            const predResponse = await axios.post(`${this.mlServiceUrl}/predict`, {
                features: features
            });
            
            const prediction = predResponse.data;
            console.log(`🤖 ML Prediction: ${prediction.signal} (${(prediction.confidence * 100).toFixed(1)}%)`);
            
            // 3. Check if we should send signal
            if (prediction.confidence >= 0.75) {
                console.log('✅ High confidence signal detected!');
                
                // Calculate trading levels
                const currentPrice = 1.0850 + (Math.random() - 0.5) * 0.001;
                const atr = features.atr;
                
                const signal = {
                    signal: prediction.signal,
                    pair: 'EURUSD',
                    confidence: prediction.confidence,
                    entry_price: currentPrice,
                    stop_loss: prediction.signal === 'BUY' 
                        ? (currentPrice - atr * 1.5).toFixed(5)
                        : (currentPrice + atr * 1.5).toFixed(5),
                    take_profit: prediction.signal === 'BUY'
                        ? (currentPrice + atr * 3).toFixed(5)
                        : (currentPrice - atr * 3).toFixed(5),
                    risk_reward_ratio: 2.0,
                    risk_pips: Math.round(atr * 1.5 * 10000),
                    reward_pips: Math.round(atr * 3 * 10000),
                    validation_score: Math.round(prediction.confidence * 100),
                    signal_id: `ML_AUTO_${++this.signalCount}_${Date.now()}`,
                    is_valid: true,
                    success: true,
                    source: 'VietForex ML Auto Analyzer',
                    features_used: features
                };
                
                // Send to Discord
                const webhookResponse = await axios.post(this.webhookUrl, signal);
                console.log('📤 Signal sent to Discord!');
                console.log(`   Signal: ${signal.signal} ${signal.pair}`);
                console.log(`   Entry: ${signal.entry_price}`);
                console.log(`   SL: ${signal.stop_loss} | TP: ${signal.take_profit}`);
                
            } else {
                console.log(`📊 Low confidence (${(prediction.confidence * 100).toFixed(1)}%) - No signal sent`);
            }
            
        } catch (error) {
            console.error('❌ Analysis error:', error.message);
        }
    }

    async start() {
        console.log('🚀 Starting ML Signal Generator');
        console.log('📊 Will analyze market every 5 minutes');
        console.log('🎯 Signals sent when confidence > 75%\n');
        
        // Run analysis every 5 minutes
        cron.schedule('*/5 * * * *', () => {
            this.analyzeMarket();
        });
        
        // Run once immediately
        setTimeout(() => this.analyzeMarket(), 3000);
    }

    // Manual test function
    async testHighConfidenceSignal() {
        console.log('\n🧪 Testing with guaranteed high confidence features...');
        
        const bullishFeatures = {
            rsi: 22,
            macd_signal: 0.002,
            bb_upper_distance: -0.003,
            bb_lower_distance: 0.002,
            ema_20: 1.0852,
            ema_50: 1.0848,
            volume_ratio: 1.4,
            atr: 0.0025,
            price_change: 0.0008,
            high_low_ratio: 1.002
        };
        
        try {
            const response = await axios.post(`${this.mlServiceUrl}/predict`, {
                features: bullishFeatures
            });
            
            console.log('✅ Test prediction:', response.data);
            
            if (response.data.confidence > 0.75) {
                console.log('📤 Sending test signal to Discord...');
                // Generate and send signal
                await this.analyzeMarket();
            }
            
        } catch (error) {
            console.error('❌ Test failed:', error.message);
        }
    }
}

// Run if called directly
if (require.main === module) {
    const generator = new MLSignalGenerator();
    
    // Parse command line arguments
    const args = process.argv.slice(2);
    
    if (args.includes('--test')) {
        // Run test mode
        generator.testHighConfidenceSignal();
    } else {
        // Run normal mode
        generator.start();
    }
}

module.exports = MLSignalGenerator;
