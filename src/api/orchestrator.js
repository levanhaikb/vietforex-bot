const cron = require('node-cron');
const MarketDataCollector = require('./marketDataCollector');
const axios = require('axios');

class VietForexOrchestrator {
    constructor() {
        this.collector = new MarketDataCollector();
        this.isRunning = false;
    }

    async init() {
        await this.collector.init();
        console.log('🎯 VietForex Orchestrator initialized');
    }

    async runAnalysisCycle() {
        if (this.isRunning) {
            console.log('⚠️ Analysis already running, skipping...');
            return;
        }

        this.isRunning = true;
        console.log('🔄 Starting analysis cycle...');

        try {
            // 1. Collect latest market data
            console.log('📊 Collecting market data...');
            const marketData = await this.collector.collectAllData();

            // 2. Analyze each pair
            for (const pair of Object.keys(marketData)) {
                console.log(`\n🔍 Analyzing ${pair}...`);
                
                try {
                    const response = await axios.post(
                        'http://localhost:3000/api/analysis/trigger',
                        { pair: pair }
                    );
                    
                    if (response.data.analysis.signal_sent) {
                        console.log(`✅ Signal sent for ${pair}!`);
                    } else {
                        console.log(`📊 ${pair}: No signal (low confidence)`);
                    }
                } catch (error) {
                    console.error(`❌ Error analyzing ${pair}:`, error.message);
                }

                // Delay between pairs
                await new Promise(resolve => setTimeout(resolve, 2000));
            }

        } catch (error) {
            console.error('❌ Analysis cycle error:', error);
        }

        this.isRunning = false;
        console.log('✅ Analysis cycle completed\n');
    }

    start() {
        console.log('🚀 Starting VietForex Orchestrator...');
        
        // Run analysis every 5 minutes
        cron.schedule('*/5 * * * *', () => {
            this.runAnalysisCycle();
        });

        // Run once on startup
        setTimeout(() => this.runAnalysisCycle(), 5000);

        console.log('⏰ Scheduled analysis every 5 minutes');
    }
}

module.exports = VietForexOrchestrator;
