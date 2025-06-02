const express = require('express');
const cors = require('cors');
const axios = require('axios');
const morgan = require('morgan');
const fs = require('fs').promises;
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('combined'));

// Basic routes
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        server: 'VietForex API',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        uptime: process.uptime(),
        memory: process.memoryUsage()
    });
});

// Analysis endpoint
app.post('/api/analysis/trigger', async (req, res) => {
    try {
        console.log('📊 Manual analysis triggered');
        
        // For now, return mock response
        res.json({
            success: true,
            message: 'Analysis triggered',
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        console.error('Analysis error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Market data endpoint
app.get('/api/market/latest', async (req, res) => {
    try {
        // Return mock data for testing
        const mockData = {
            pair: 'EURUSD',
            timeframe: '15m',
            data: {
                open: 1.0850,
                high: 1.0865,
                low: 1.0845,
                close: 1.0860,
                volume: 12500,
                timestamp: new Date().toISOString()
            }
        };
        
        res.json(mockData);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        message: 'The requested endpoint does not exist',
        path: req.path,
        method: req.method
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 VietForex API Server running on port ${PORT}`);
    console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
    console.log(`📚 Available endpoints:`);
    console.log(`   - GET  /api/health`);
    console.log(`   - POST /api/analysis/trigger`);
    console.log(`   - GET  /api/market/latest`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\nSIGINT received, shutting down gracefully');
    process.exit(0);
});
