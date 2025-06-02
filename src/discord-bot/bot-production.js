const { Client, GatewayIntentBits, EmbedBuilder } = require('discord.js');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

// Channel ID đã tìm thấy từ debug
const SIGNALS_CHANNEL_ID = '1378660503529852939';
let SIGNALS_CHANNEL = null;

client.on('ready', () => {
    console.log(`✅ ${client.user.tag} đã online!`);
    
    // Tìm channel signals
    SIGNALS_CHANNEL = client.channels.cache.get(SIGNALS_CHANNEL_ID);
    
    if (SIGNALS_CHANNEL) {
        console.log(`✅ Kết nối thành công với channel: ${SIGNALS_CHANNEL.name} (${SIGNALS_CHANNEL.id})`);
        console.log('🌉 Signal Bridge sẵn sàng nhận signals từ Generator');
    } else {
        console.error(`❌ Không tìm thấy channel: ${SIGNALS_CHANNEL_ID}`);
    }
    
    client.user.setActivity('🎯 VietForex Signals Live', { type: 'WATCHING' });
});

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;
    
    const content = message.content.toLowerCase();
    
    if (content === '!ping') {
        const embed = new EmbedBuilder()
            .setTitle('🏓 VietForex Bot Production')
            .setDescription('Bot Trading Forex tự động đang hoạt động')
            .setColor(0x00FF00)
            .addFields(
                { name: '⏰ Thời gian', value: new Date().toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }), inline: true },
                { name: '📊 Status', value: '🟢 PRODUCTION', inline: true },
                { name: '🎯 Channel', value: SIGNALS_CHANNEL ? `✅ ${SIGNALS_CHANNEL.name}` : '❌ Lỗi channel', inline: true },
                { name: '📡 Signal Generator', value: '✅ Hoạt động mỗi 3 phút', inline: true },
                { name: '🇻🇳 Language', value: 'Tiếng Việt', inline: true },
                { name: '🔄 Version', value: 'v2.0 Production', inline: true }
            )
            .setFooter({ text: 'VietForex AI Trading System 🇻🇳' })
            .setTimestamp();
        
        await message.reply({ embeds: [embed] });
        console.log(`✅ Đã trả lời !ping cho ${message.author.username}`);
    }
    
    if (content === '!trogiup') {
        const embed = new EmbedBuilder()
            .setTitle('🤖 VietForex Trading Bot - Hướng Dẫn')
            .setDescription('Bot giao dịch Forex tự động với AI tiếng Việt')
            .setColor(0x800080)
            .addFields(
                { name: '!ping', value: '🏓 Kiểm tra trạng thái bot', inline: true },
                { name: '!trogiup', value: '❓ Hiển thị hướng dẫn này', inline: true },
                { name: '!test', value: '🧪 Gửi tín hiệu test', inline: true }
            )
            .addFields({
                name: '🎯 Tính năng chính',
                value: `• 🤖 **Tín hiệu AI tự động** mỗi 3 phút
                       • 📊 **Phân tích kỹ thuật** chuyên sâu
                       • 🛡️ **Quản lý rủi ro** thông minh
                       • 🇻🇳 **Giao diện tiếng Việt** hoàn toàn
                       • ⚡ **Real-time** cập nhật liên tục`,
                inline: false
            })
            .addFields({
                name: '📈 Thông tin tín hiệu',
                value: `• **Cặp tiền**: EURUSD, GBPUSD, USDJPY
                       • **Độ tin cậy**: 75-95%
                       • **Risk/Reward**: 1:2 tối ưu
                       • **Khung thời gian**: M15/H1`,
                inline: false
            })
            .setFooter({ text: 'Made with ❤️ in Vietnam' })
            .setTimestamp();
        
        await message.reply({ embeds: [embed] });
        console.log(`✅ Đã hiển thị trợ giúp cho ${message.author.username}`);
    }
    
    if (content === '!test') {
        await guiTinHieuTest(message.channel);
        console.log(`🧪 Đã gửi test signal cho ${message.author.username}`);
    }
});

// Function gửi tín hiệu test
async function guiTinHieuTest(channel) {
    const tinHieuTest = {
        ma_tin_hieu: 'TEST_' + Date.now(),
        cap_tien_te: ['EURUSD', 'GBPUSD', 'USDJPY'][Math.floor(Math.random() * 3)],
        huong: Math.random() > 0.5 ? 'MUA' : 'BAN',
        gia_vao: 1.0850,
        cat_lo: 1.0830,
        lay_lai: 1.0890,
        do_tin_cay: 75 + Math.floor(Math.random() * 20)
    };
    
    await guiTinHieu(tinHieuTest, channel);
}

// Function gửi tín hiệu chính
async function guiTinHieu(duLieuTinHieu, targetChannel = null) {
    try {
        const channel = targetChannel || SIGNALS_CHANNEL;
        
        if (!channel) {
            console.error('❌ Không có channel để gửi signal');
            return false;
        }
        
        const bieuTuongHuong = duLieuTinHieu.huong === 'MUA' ? '🟢' : '🔴';
        const mauSac = duLieuTinHieu.huong === 'MUA' ? 0x00FF00 : 0xFF0000;
        const saoTinCay = '⭐'.repeat(Math.min(5, Math.floor(duLieuTinHieu.do_tin_cay / 20)));
        
        // Tính risk/reward
        const riskPips = Math.abs(duLieuTinHieu.gia_vao - duLieuTinHieu.cat_lo) * 10000;
        const rewardPips = Math.abs(duLieuTinHieu.lay_lai - duLieuTinHieu.gia_vao) * 10000;
        const rrRatio = (rewardPips / riskPips).toFixed(1);
        
        const embed = new EmbedBuilder()
            .setTitle(`${bieuTuongHuong} TÍN HIỆU ${duLieuTinHieu.huong} ${duLieuTinHieu.cap_tien_te}`)
            .setColor(mauSac)
            .addFields(
                { name: '💰 Giá vào', value: `**${duLieuTinHieu.gia_vao}**`, inline: true },
                { name: '🛑 Cắt lỗ', value: `**${duLieuTinHieu.cat_lo}**`, inline: true },
                { name: '🎯 Lấy lãi', value: `**${duLieuTinHieu.lay_lai}**`, inline: true },
                { name: '📊 Độ tin cậy', value: `**${duLieuTinHieu.do_tin_cay}%** ${saoTinCay}`, inline: true },
                { name: '📏 Risk/Reward', value: `**1:${rrRatio}**`, inline: true },
                { name: '⏰ Thời gian', value: new Date().toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }), inline: true }
            )
            .addFields({
                name: '📈 Phân tích kỹ thuật',
                value: `🔸 **Xu hướng**: ${duLieuTinHieu.huong === 'MUA' ? 'Tăng mạnh 📈' : 'Giảm mạnh 📉'}
                       🔸 **Khung thời gian**: M15/H1 confluence
                       🔸 **AI Model**: VietForex ML v2.0
                       🔸 **Risk Management**: Tự động tối ưu
                       🔸 **Entry Strategy**: Breakout confirmation`,
                inline: false
            })
            .addFields({
                name: '🛡️ Quản lý rủi ro',
                value: `• **Stop Loss**: ${Math.round(riskPips)} pips
                       • **Take Profit**: ${Math.round(rewardPips)} pips  
                       • **Position Size**: Tính theo 2% account
                       • **Max Risk**: Thấp đến trung bình`,
                inline: false
            })
            .setFooter({ text: `⚡ VietForex AI Trading • Signal ID: ${duLieuTinHieu.ma_tin_hieu.slice(-8)} • Made in Vietnam 🇻🇳` })
            .setTimestamp();
        
        await channel.send({ embeds: [embed] });
        console.log(`✅ [${new Date().toLocaleString('vi-VN')}] Đã gửi signal: ${duLieuTinHieu.huong} ${duLieuTinHieu.cap_tien_te} (${duLieuTinHieu.do_tin_cay}%) → ${channel.name}`);
        return true;
        
    } catch (error) {
        console.error('❌ Lỗi gửi signal:', error);
        return false;
    }
}

// Export function để Signal Generator sử dụng
global.guiTinHieuVietForex = guiTinHieu;

// Login bot
client.login(process.env.DISCORD_BOT_TOKEN)
    .then(() => {
        console.log('🚀 VietForex Production Bot đã kết nối thành công!');
    })
    .catch(error => {
        console.error('❌ Lỗi kết nối Discord:', error);
    });

module.exports = { client, guiTinHieu };
