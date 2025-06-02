const { Client, GatewayIntentBits, EmbedBuilder } = require('discord.js');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

let foundChannels = [];

client.on('ready', () => {
    console.log(`✅ ${client.user.tag} đã online!`);
    
    // Liệt kê TẤT CẢ channels mà bot có thể thấy
    console.log('🔍 ĐANG QUÉT TẤT CẢ CHANNELS...');
    
    client.guilds.cache.forEach(guild => {
        console.log(`📊 Guild: ${guild.name} (${guild.id})`);
        
        guild.channels.cache.forEach(channel => {
            if (channel.type === 0) { // Text channel
                foundChannels.push({
                    name: channel.name,
                    id: channel.id,
                    guild: guild.name
                });
                console.log(`   📺 Channel: ${channel.name} (${channel.id})`);
            }
        });
    });
    
    console.log(`✅ Tìm thấy ${foundChannels.length} text channels`);
    client.user.setActivity('🔍 Scanning Channels', { type: 'WATCHING' });
});

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;
    
    const content = message.content.toLowerCase();
    
    if (content === '!ping') {
        const embed = new EmbedBuilder()
            .setTitle('🏓 Pong! - Channel Debug')
            .setColor(0x00FF00)
            .addFields(
                { name: '📊 Bot Status', value: '🟢 ONLINE', inline: true },
                { name: '📺 Current Channel', value: `${message.channel.name} (${message.channel.id})`, inline: true },
                { name: '🏠 Guild', value: message.guild.name, inline: true }
            )
            .setTimestamp();
        
        await message.reply({ embeds: [embed] });
        console.log(`✅ Responded to !ping in ${message.channel.name} (${message.channel.id})`);
    }
    
    if (content === '!channels') {
        let channelList = '📺 **Danh sách channels bot có thể thấy:**\n\n';
        
        foundChannels.forEach((ch, index) => {
            channelList += `${index + 1}. **${ch.name}** (${ch.id})\n`;
        });
        
        if (channelList.length > 2000) {
            channelList = channelList.substring(0, 1900) + '\n... (truncated)';
        }
        
        await message.reply(channelList);
    }
    
    if (content === '!test') {
        // Test gửi signal trực tiếp vào channel hiện tại
        const testSignal = {
            ma_tin_hieu: 'TEST_' + Date.now(),
            cap_tien_te: 'EURUSD',
            huong: Math.random() > 0.5 ? 'MUA' : 'BAN',
            gia_vao: 1.0850,
            cat_lo: 1.0830,
            lay_lai: 1.0890,
            do_tin_cay: 85
        };
        
        await sendSignalToChannel(message.channel, testSignal);
    }
});

async function sendSignalToChannel(channel, signalData) {
    try {
        const bieuTuongHuong = signalData.huong === 'MUA' ? '🟢' : '🔴';
        const mauSac = signalData.huong === 'MUA' ? 0x00FF00 : 0xFF0000;
        
        const embed = new EmbedBuilder()
            .setTitle(`${bieuTuongHuong} TÍN HIỆU ${signalData.huong} ${signalData.cap_tien_te}`)
            .setColor(mauSac)
            .addFields(
                { name: '💰 Giá vào', value: `${signalData.gia_vao}`, inline: true },
                { name: '🛑 Cắt lỗ', value: `${signalData.cat_lo}`, inline: true },
                { name: '🎯 Lấy lãi', value: `${signalData.lay_lai}`, inline: true },
                { name: '📊 Độ tin cậy', value: `${signalData.do_tin_cay}%`, inline: true },
                { name: '📺 Channel', value: `${channel.name}`, inline: true },
                { name: '⏰ Thời gian', value: new Date().toLocaleString('vi-VN'), inline: true }
            )
            .setFooter({ text: '⚡ VietForex Test Signal 🇻🇳' })
            .setTimestamp();
        
        await channel.send({ embeds: [embed] });
        console.log(`✅ Đã gửi test signal đến ${channel.name} (${channel.id})`);
        return true;
        
    } catch (error) {
        console.error(`❌ Lỗi gửi signal đến ${channel.name}:`, error);
        return false;
    }
}

// Export function để Signal Generator sử dụng
global.sendSignalToCurrentChannel = sendSignalToChannel;
global.getAllChannels = () => foundChannels;

client.login(process.env.DISCORD_BOT_TOKEN)
    .then(() => {
        console.log('🚀 Debug Bot đã kết nối thành công!');
    })
    .catch(error => {
        console.error('❌ Lỗi kết nối Discord:', error);
    });

module.exports = { client, sendSignalToChannel };
