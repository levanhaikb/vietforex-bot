const ccxt = require('ccxt');
const cron = require('node-cron');
const fs = require('fs').promises;
const path = require('path');

class MarketDataCollector {
    constructor() {
        // Sử dụng exchange không cần API key để test
        this.exchange = new ccxt.binance({
            'enableRateLimit': true,
        });
        
        this.dataDir = path.join(__dirname, 'data', 'market');
        this.pairs = ['EUR/USD', 'GBP/USD', 'USD/JPY'];
        this.timeframes = ['5m', '15m', '1h', '4h'];
    }

    async init() {
        // Tạo thư mục data nếu chưa có
        await fs.mkdir(this.dataDir, { recursive: true });
        console.log('📊 Market Data Collector initialized');
    }

    async fetchOHLCV(symbol, timeframe, limit = 100) {
        try {
            const ohlcv = await this.exchange.fetchOHLCV(symbol, timeframe, undefined, limit);
            return ohlcv.map(candle => ({
                timestamp: candle[0],
                open: candle[1],
                high: candle[2],
                low: candle[3],
                close: candle[4],
                volume: candle[5]
            }));
        } catch (error) {
            console.error(`Error fetching ${symbol} ${timeframe}:`, error.message);
            return null;
        }
    }

    async collectAllData() {
        const allData = {};
        
        for (const pair of this.pairs) {
            allData[pair] = {};
            
            for (const timeframe of this.timeframes) {
                const data = await this.fetchOHLCV(pair, timeframe);
                if (data) {
                    allData[pair][timeframe] = data;
                    console.log(`✅ Collected ${pair} ${timeframe}: ${data.length} candles`);
                }
                
                // Delay để tránh rate limit
                await new Promise(resolve => setTimeout(resolve, 1000));
            }
        }
        
        // Lưu data
        const filename = `market_data_${Date.now()}.json`;
        const filepath = path.join(this.dataDir, filename);
        await fs.writeFile(filepath, JSON.stringify(allData, null, 2));
        
        console.log(`📁 Data saved to ${filename}`);
        return allData;
    }

    startScheduledCollection() {
        // Thu thập data mỗi 5 phút
        cron.schedule('*/5 * * * *', async () => {
            console.log('⏰ Starting scheduled data collection...');
            await this.collectAllData();
        });
        
        console.log('📅 Scheduled data collection started (every 5 minutes)');
    }
}

module.exports = MarketDataCollector;
