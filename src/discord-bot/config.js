// src/discord-bot/config.js
module.exports = {
    discord: {
        // THAY ĐỔI: Paste Bot Token từ Discord Developer Portal
        token: 'MTM3ODI5NTc3NzUxNTgwMjYyNA.G1u1Cn.ZR-6BauDbbdwPqjadvXgyDQfMB1E4C7YecUJOQ',
        
        // Application ID (không đổi)
        clientId: '1378295777515802624',
        
        // THAY ĐỔI: Server ID từ Discord server "VietForex Test"
        guildId: '1378299739354343424'
    },
    
    api: {
        vpsUrl: 'http://145.79.13.123:3000',
        pollingInterval: 30000  // 30 giây
    },
    
    subscription: {
        tiers: {
            free: { signals: 2, name: 'Miễn Phí', color: '#95A5A6', emoji: '🆓' },
            premium: { signals: 5, name: 'Premium', color: '#3498DB', emoji: '💎' },
            vip: { signals: 10, name: 'VIP', color: '#F1C40F', emoji: '👑' }
        }
    },
    
    channels: {
        signalsChannelName: 'vietforex-signals'
    }
};
