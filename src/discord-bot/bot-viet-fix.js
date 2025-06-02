const { Client, GatewayIntentBits, EmbedBuilder } = require('discord.js');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

// Biến lưu trữ channel signals
let SIGNALS_CHANNEL = null;

client.on('ready', () => {
    console.log(`✅ ${client.user.tag} đã online!`);
    
    // Tự động tìm channel signals
    client.guilds.cache.forEach(guild => {
        console.log(`🔍 Tìm kiếm channels trong guild: ${guild.name}`);
        
        const signalsChannel = guild.channels.cache.find(channel => 
            channel.name.includes('signals') || 
            channel.name.includes('vietforex') ||
            channel.id === '1378299763429441566'
        );
        
        if (signalsChannel) {
            SIGNALS_CHANNEL = signalsChannel;
            console.log(`✅ Tìm thấy signals channel: ${signalsChannel.name} (${signalsChannel.id})`);
        }
    });
    
    client.user.setActivity('🎯 VietForex Signals', { type: 'WATCHING' });
    console.log('🌉 Signal Bridge sẵn sàng nhận signals');
});

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;
    
    const content = message.content.toLowerCase();
    console.log(`📨 Nhận tin nhắn: ${content} từ ${message.author.username}`);
    
    if (content === '!ping') {
        const embed = new EmbedBuilder()
            .setTitle('🏓 Pong!')
            .setDescription('VietForex Bot đang hoạt động')
            .setColor(0x00FF00)
            .addFields(
                { name: '⏰ Thời gian', value: new Date().toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }), inline: true },
                { name: '📊 Status', value: '🟢 ONLINE', inline: true },
                { name: '🎯 Channel', value: SIGNALS_CHANNEL ? `✅ ${SIGNALS_CHANNEL.name}` : '❌ Chưa tìm thấy', inline: true }
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
                { name: '!channel', value: '📺 Hiển thị channel info', inline: true }
            )
            .addFields({
                name: '🎯 Tính năng',
                value: `• Tín hiệu trading tự động mỗi 3 phút
                       • Phân tích AI bằng tiếng Việt  
                       • Quản lý rủi ro chuyên nghiệp
                       • Theo dõi hiệu suất real-time`,
                inline: false
            })
            .setFooter({ text: 'VietForex Trading Bot 🇻🇳' })
            .setTimestamp();
        
        await message.reply({ embeds: [embed] });
        console.log(`✅ Đã hiển thị trợ giúp cho ${message.author.username}`);
    }
    
    if (content === '!test') {
        await guiTinHieuTest(message.channel);
    }
    
    if (content === '!channel') {
        let channelInfo = 'Danh sách channels:\n';
        message.guild.channels.cache.forEach(channel => {
            if (channel.type === 0) { // Text channel
                channelInfo += `• ${channel.name} (${channel.id})\n`;
            }
        });
        
        await message.reply(`\`\`\`${channelInfo}\`\`\``);
    }
});

// Function gửi tín hiệu test
async function guiTinHieuTest(channel) {
    const tinHieuTest = {
        ma_tin_hieu: 'TEST_' + Date.now(),
        cap_tien_te: 'EURUSD',
        huong: Math.random() > 0.5 ? 'MUA' : 'BAN',
        gia_vao: 1.0850,
        cat_lo: 1.0830,
        lay_lai: 1.0890,
        do_tin_cay: 85
    };
    
    console.log(`📨 Nhận signal: ${tinHieuTest.huong} ${tinHieuTest.cap_tien_te}`);
    await guiTinHieu(tinHieuTest, channel);
    console.log(`🧪 Đã gửi test signal cho ${channel.guild ? 'channel' : 'DM'}`);
}

// Function gửi tín hiệu chính
async function guiTinHieu(duLieuTinHieu, targetChannel = null) {
    try {
        // Ưu tiên sử dụng targetChannel, sau đó là SIGNALS_CHANNEL
        const channel = targetChannel || SIGNALS_CHANNEL;
        
        if (!channel) {
            console.error('❌ Không tìm thấy channel để gửi signal');
            return false;
        }
        
        const bieuTuongHuong = duLieuTinHieu.huong === 'MUA' ? '🟢' : '🔴';
        const mauSac = duLieuTinHieu.huong === 'MUA' ? 0x00FF00 : 0xFF0000;
        const saoTinCay = '⭐'.repeat(Math.min(5, Math.floor(duLieuTinHieu.do_tin_cay / 20)));
        
        const embed = new EmbedBuilder()
            .setTitle(`${bieuTuongHuong} TÍN HIỆU ${duLieuTinHieu.huong} ${duLieuTinHieu.cap_tien_te}`)
            .setColor(mauSac)
            .addFields(
                { name: '💰 Giá vào', value: `${duLieuTinHieu.gia_vao}`, inline: true },
                { name: '🛑 Cắt lỗ', value: `${duLieuTinHieu.cat_lo}`, inline: true },
                { name: '🎯 Lấy lãi', value: `${duLieuTinHieu.lay_lai}`, inline: true },
                { name: '📊 Độ tin cậy', value: `${duLieuTinHieu.do_tin_cay}% ${saoTinCay}`, inline: true },
                { name: '🆔 Mã TH', value: duLieuTinHieu.ma_tin_hieu.slice(-8), inline: true },
                { name: '⏰ Thời gian', value: new Date().toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }), inline: true }
            )
            .addFields({
                name: '📈 Phân tích',
                value: `🔸 **Xu hướng**: ${duLieuTinHieu.huong === 'MUA' ? 'Tăng mạnh 📈' : 'Giảm mạnh 📉'}
                       🔸 **Khung TG**: M15/H1 
                       🔸 **AI Model**: VietForex v2.0
                       🔸 **Risk/Reward**: 1:2.0`,
                inline: false
            })
            .setFooter({ text: '⚡ VietForex AI Trading System - Made in Vietnam 🇻🇳' })
            .setTimestamp();
        
        await channel.send({ embeds: [embed] });
        console.log(`✅ Đã gửi signal: ${duLieuTinHieu.huong} ${duLieuTinHieu.cap_tien_te} (${duLieuTinHieu.do_tin_cay}%) đến ${channel.name}`);
        return true;
        
    } catch (error) {
        console.error('❌ Lỗi khi gửi signal:', error);
        return false;
    }
}

// Export function để Signal Generator có thể sử dụng
global.guiTinHieuVietForex = guiTinHieu;

// Login bot
client.login(process.env.DISCORD_BOT_TOKEN)
    .then(() => {
        console.log('🚀 VietForex Discord Bot đã kết nối thành công!');
    })
    .catch(error => {
        console.error('❌ Lỗi kết nối Discord:', error);
    });

module.exports = { client, guiTinHieu };
