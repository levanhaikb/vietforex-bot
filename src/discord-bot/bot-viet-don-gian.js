const { Client, GatewayIntentBits, EmbedBuilder } = require('discord.js');
const signalBridge = require('../shared/signal-bridge');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

const SIGNALS_CHANNEL_ID = '1378299763429441566';

client.on('ready', () => {
    console.log(`✅ ${client.user.tag} đã online!`);
    console.log(`🎯 Đang theo dõi channel: ${SIGNALS_CHANNEL_ID}`);
    
    // Đăng ký với Signal Bridge
    signalBridge.registerDiscordBot(client, SIGNALS_CHANNEL_ID);
    
    client.user.setActivity('🎯 VietForex Signals', { type: 'WATCHING' });
});

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;
    
    const content = message.content.toLowerCase();
    console.log(`📨 Nhận tin nhắn: ${content} từ ${message.author.username}`);
    
    if (content === '!ping') {
        const embed = new EmbedBuilder()
            .setTitle('🏓 Pong!')
            .setDescription('VietForex Bot đang hoạt động tốt!')
            .setColor(0x00FF00)
            .addFields(
                { name: '⏰ Thời gian', value: new Date().toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }), inline: true },
                { name: '📊 Status', value: '🟢 ONLINE', inline: true },
                { name: '🎯 Version', value: 'VietForex v2.0', inline: true },
                { name: '🌉 Signal Bridge', value: `${signalBridge.getSignalCount()} signals`, inline: true }
            )
            .setFooter({ text: 'Made in Vietnam 🇻🇳' })
            .setTimestamp();
        
        await message.reply({ embeds: [embed] });
        console.log(`✅ Đã trả lời !ping cho ${message.author.username}`);
    }
    
    if (content === '!trogiup') {
        const embed = new EmbedBuilder()
            .setTitle('🤖 Hướng Dẫn VietForex Bot')
            .setDescription('Bot Trading Forex tự động bằng tiếng Việt')
            .setColor(0x800080)
            .addFields(
                { name: '!ping', value: '🏓 Kiểm tra bot hoạt động', inline: true },
                { name: '!trogiup', value: '❓ Hiển thị hướng dẫn', inline: true },
                { name: '!test', value: '🧪 Test tín hiệu mẫu', inline: true },
                { name: '!thongke', value: '📊 Xem thống kê signals', inline: true }
            )
            .addFields({
                name: '🎯 Tính năng VietForex',
                value: `• 🤖 Tín hiệu AI tự động mỗi 3 phút
                       • 📈 Phân tích multi-timeframe M15/H1
                       • 🛡️ Quản lý rủi ro chuyên nghiệp R:R 1:2
                       • 📊 Theo dõi hiệu suất real-time
                       • 🇻🇳 Giao diện 100% tiếng Việt`,
                inline: false
            })
            .setFooter({ text: 'VietForex Trading Bot - Made in Vietnam 🇻🇳' })
            .setTimestamp();
        
        await message.reply({ embeds: [embed] });
        console.log(`✅ Đã hiển thị trợ giúp cho ${message.author.username}`);
    }
    
    if (content === '!test') {
        const tinHieuTest = {
            ma_tin_hieu: 'TEST_' + Date.now(),
            cap_tien_te: 'EURUSD',
            huong: Math.random() > 0.5 ? 'MUA' : 'BAN',
            gia_vao: 1.0850,
            cat_lo: 1.0830,
            lay_lai: 1.0890,
            do_tin_cay: 85
        };
        
        signalBridge.sendSignal(tinHieuTest);
        console.log(`🧪 Đã gửi test signal cho ${message.author.username}`);
    }
    
    if (content === '!thongke') {
        const recentSignals = signalBridge.getRecentSignals(5);
        const totalSignals = signalBridge.getSignalCount();
        
        const embed = new EmbedBuilder()
            .setTitle('📊 Thống Kê VietForex')
            .setColor(0x0099FF)
            .addFields(
                { name: '🎯 Tổng signals', value: totalSignals.toString(), inline: true },
                { name: '📈 Gần đây', value: recentSignals.length.toString(), inline: true },
                { name: '⚡ Trạng thái', value: '🟢 HOẠT ĐỘNG', inline: true }
            )
            .setFooter({ text: 'VietForex Statistics' })
            .setTimestamp();
        
        if (recentSignals.length > 0) {
            const signalList = recentSignals.map((signal, index) => 
                `${index + 1}. ${signal.huong} ${signal.cap_tien_te} (${signal.do_tin_cay}%)`
            ).join('\n');
            
            embed.addFields({
                name: '📋 5 Signals gần nhất',
                value: signalList,
                inline: false
            });
        }
        
        await message.reply({ embeds: [embed] });
        console.log(`📊 Đã hiển thị thống kê cho ${message.author.username}`);
    }
});

// Login bot
client.login(process.env.DISCORD_BOT_TOKEN)
    .then(() => {
        console.log('🚀 VietForex Discord Bot đã kết nối thành công!');
    })
    .catch(error => {
        console.error('❌ Lỗi kết nối Discord:', error);
    });

module.exports = { client };
