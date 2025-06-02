const TI = require('technical-indicators');

class TechnicalAnalysis {
    constructor() {
        this.indicators = {};
    }

    calculateIndicators(candles) {
        const closes = candles.map(c => c.close);
        const highs = candles.map(c => c.high);
        const lows = candles.map(c => c.low);
        const volumes = candles.map(c => c.volume);

        // RSI
        const rsi = TI.RSI.calculate({
            values: closes,
            period: 14
        });

        // MACD
        const macd = TI.MACD.calculate({
            values: closes,
            fastPeriod: 12,
            slowPeriod: 26,
            signalPeriod: 9,
            SimpleMAOscillator: false,
            SimpleMASignal: false
        });

        // Bollinger Bands
        const bb = TI.BollingerBands.calculate({
            period: 20,
            values: closes,
            stdDev: 2
        });

        // EMA
        const ema20 = TI.EMA.calculate({ values: closes, period: 20 });
        const ema50 = TI.EMA.calculate({ values: closes, period: 50 });

        // ATR
        const atr = TI.ATR.calculate({
            high: highs,
            low: lows,
            close: closes,
            period: 14
        });

        return {
            rsi: rsi[rsi.length - 1],
            macd: macd[macd.length - 1],
            bb: bb[bb.length - 1],
            ema20: ema20[ema20.length - 1],
            ema50: ema50[ema50.length - 1],
            atr: atr[atr.length - 1],
            trend: this.determineTrend(closes, ema20, ema50)
        };
    }

    determineTrend(closes, ema20, ema50) {
        const currentPrice = closes[closes.length - 1];
        const ema20Current = ema20[ema20.length - 1];
        const ema50Current = ema50[ema50.length - 1];

        if (currentPrice > ema20Current && ema20Current > ema50Current) {
            return 'UPTREND';
        } else if (currentPrice < ema20Current && ema20Current < ema50Current) {
            return 'DOWNTREND';
        } else {
            return 'SIDEWAYS';
        }
    }

    generateSignalFeatures(marketData) {
        const features = {};
        
        // Process each timeframe
        ['15m', '1h', '4h'].forEach(tf => {
            if (marketData[tf]) {
                const indicators = this.calculateIndicators(marketData[tf]);
                
                // Add features with timeframe prefix
                Object.keys(indicators).forEach(key => {
                    features[`${tf}_${key}`] = indicators[key];
                });
            }
        });

        return features;
    }
}

module.exports = TechnicalAnalysis;
