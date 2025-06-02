// VietForex Discord Bot - Phiên bản đơn giản cho VPS
const { Client, GatewayIntentBits, EmbedBuilder, SlashCommandBuilder, Routes } = require('discord.js');
const { REST } = require('@discordjs/rest');
const express = require('express');
const axios = require('axios');
const fs = require('fs');

// =============================================
// CẤU HÌNH BOT
// =============================================

const config = {
    discord: {
        token: process.env.DISCORD_TOKEN || 'YOUR_DISCORD_BOT_TOKEN',
        clientId: process.env.DISCORD_CLIENT_ID || 'YOUR_CLIENT_ID',
        guildId: process.env.DISCORD_GUILD_ID || 'YOUR_GUILD_ID'
    },
    api: {
        vpsApiUrl: 'http://localhost:3000',
        webhookPort: 3002
    },
    channels: {
        signalsChannelName: 'vietforex-signals'
    },
    logging: {
        logFile: './logs/discord-bot.log'
    }
};

// =============================================
// KHỞI TẠO BOT VÀ SERVER
// =============================================

console.log('🚀 VietForex Discord Bot - Phiên bản đơn giản cho VPS');
console.log('🌐 Máy chủ: VPS Production');

// Tạo thư mục logs nếu chưa có
if (!fs.existsSync('./logs')) {
    fs.mkdirSync('./logs', { recursive: true });
}

// Tạo Discord client
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

// Tạo Express server cho webhook
const app = express();
app.use(express.json());

// =============================================
// BOT EVENT HANDLERS
// =============================================

client.once('ready', async () => {
    console.log('🎮 VietForex Discord Bot đã ONLINE!');
    console.log(`📊 Đang phục vụ ${client.guilds.cache.size} server`);
    console.log(`🤖 Bot: ${client.user.tag}`);
    
    // Đăng ký commands
    await dangKyLenh();
    
    // Thiết lập channels
    await thieLapKenh();
    
    // Đăng ký webhook với API
    await dangKyWebhook();
    
    console.log('✅ Bot đã sẵn sàng!');
    ghiLog('INFO', 'VietForex Discord Bot khởi động thành công');
});

// Xử lý slash commands
client.on('interactionCreate', async interaction => {
    if (!interaction.isChatInputCommand()) return;

    const tenLenh = interaction.commandName;
    console.log(`📝 Lệnh: /${tenLenh} được gọi bởi ${interaction.user.username}`);

    try {
        switch (tenLenh) {
            case 'ping':
                await xuLyLenhPing(interaction);
                break;
            case 'tinhieu':
                await xuLyLenhTinHieu(interaction);
                break;
            case 'thongtin':
                await xuLyLenhThongTin(interaction);
                break;
            case 'test':
                await xuLyLenhTest(interaction);
                break;
            default:
                await interaction.reply('❌ Lệnh không được hỗ trợ!');
        }
    } catch (error) {
        console.error(`❌ Lỗi lệnh /${tenLenh}:`, error);
        ghiLog('ERROR', `Lỗi lệnh: ${error.message}`);
        
        if (!interaction.replied && !interaction.deferred) {
            await interaction.reply('❌ Có lỗi xảy ra khi xử lý lệnh!');
        }
    }
});

// =============================================
// COMMAND REGISTRATION
// =============================================

async function dangKyLenh() {
    const danhSachLenh = [
        new SlashCommandBuilder()
            .setName('ping')
            .setDescription('Kiểm tra trạng thái bot'),
            
        new SlashCommandBuilder()
            .setName('tinhieu')
            .setDescription('Xem tín hiệu trading mới nhất'),
            
        new SlashCommandBuilder()
            .setName('thongtin')
            .setDescription('Thông tin về VietForex Bot'),
            
        new SlashCommandBuilder()
            .setName('test')
            .setDescription('Test tạo tín hiệu demo')
    ].map(cmd => cmd.toJSON());

    const rest = new REST({ version: '10' }).setToken(config.discord.token);

    try {
        console.log('🔄 Đang đăng ký các lệnh slash...');
        
        await rest.put(
            Routes.applicationGuildCommands(config.discord.clientId, config.discord.guildId),
            { body: danhSachLenh }
        );
        
        console.log('✅ Đã đăng ký commands thành công!');
        
    } catch (error) {
        console.error('❌ Lỗi đăng ký commands:', error.message);
    }
}

// =============================================
// COMMAND HANDLERS
// =============================================

async function xuLyLenhPing(interaction) {
    const thoiGianBatDau = Date.now();
    await interaction.deferReply();
    const thoiGianPhanHoi = Date.now() - thoiGianBatDau;
    
    const embed = new EmbedBuilder()
        .setTitle('🏓 Trạng Thái Bot')
        .setDescription('✅ VietForex Discord Bot hoạt động bình thường!')
        .setColor(0x00FF00)
        .addFields([
            { name: '⚡ Phản Hồi', value: `${thoiGianPhanHoi}ms`, inline: true },
            { name: '🌐 Độ Trễ', value: `${client.ws.ping}ms`, inline: true },
            { name: '⏰ Hoạt Động', value: `${Math.floor(process.uptime())}s`, inline: true },
            { name: '💾 Bộ Nhớ', value: `${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB`, inline: true }
        ])
        .setTimestamp()
        .setFooter({ text: 'VietForex VPS Production' });

    await interaction.editReply({ embeds: [embed] });
}

async function xuLyLenhTinHieu(interaction) {
    await interaction.deferReply();
    
    try {
        // Thử lấy tín hiệu từ API
        const response = await axios.get(`${config.api.vpsApiUrl}/api/signals/latest`, {
            timeout: 10000
        });
        
        if (response.data.success && response.data.signals?.length > 0) {
            const tinHieu = response.data.signals[0];
            const embed = taoEmbedTinHieu(tinHieu);
            await interaction.editReply({ embeds: [embed] });
        } else {
            const embed = new EmbedBuilder()
                .setTitle('📊 Chưa Có Tín Hiệu')
                .setDescription('Hiện tại chưa có tín hiệu trading mới')
                .setColor(0xFFB347)
                .setTimestamp();
                
            await interaction.editReply({ embeds: [embed] });
        }
        
    } catch (error) {
        console.error('Lỗi gọi API:', error.message);
        
        // Tạo tín hiệu demo
        const tinHieuDemo = {
            signal: 'MUA',
            pair: 'EURUSD', 
            confidence: 0.75,
            entry_price: 1.0850,
            stop_loss: 1.0830,
            take_profit: 1.0890,
            risk_reward_ratio: 2.0,
            signal_id: `DEMO_${Date.now()}`,
            source: 'Demo (API không khả dụng)'
        };
        
        const embed = taoEmbedTinHieu(tinHieuDemo);
        await interaction.editReply({ 
            content: '⚠️ API không khả dụng - hiển thị tín hiệu demo:',
            embeds: [embed] 
        });
    }
}

async function xuLyLenhThongTin(interaction) {
    const embed = new EmbedBuilder()
        .setTitle('🤖 VietForex Discord Bot')
        .setDescription('Bot Discord chuyên nghiệp cho tín hiệu trading VietForex')
        .setColor(0x3498DB)
        .addFields([
            {
                name: '🎯 Tính Năng',
                value: '• Tín hiệu AI thời gian thực\n• Phân tích đa khung thời gian\n• Quản lý rủi ro nâng cao\n• Tích hợp VPS API',
                inline: false
            },
            {
                name: '🌐 Hạ Tầng',
                value: '• **Server**: VPS Production\n• **API**: Tích hợp localhost:3000\n• **Thời gian**: 24/7',
                inline: true
            },
            {
                name: '📊 Hiệu Suất',
                value: '• **Độ chính xác**: 58-65%\n• **R/R**: 1:2 trung bình\n• **Tín hiệu/ngày**: 2-5',
                inline: true
            }
        ])
        .setTimestamp()
        .setFooter({ text: 'VietForex VPS Production | AI Trading System' });

    await interaction.reply({ embeds: [embed] });
}

async function xuLyLenhTest(interaction) {
    await interaction.deferReply();
    
    const tinHieuTest = {
        signal: Math.random() > 0.5 ? 'MUA' : 'BÁN',
        pair: 'EURUSD',
        confidence: 0.78,
        entry_price: 1.0850,
        stop_loss: 1.0830,
        take_profit: 1.0890,
        risk_reward_ratio: 2.0,
        signal_id: `TEST_${Date.now()}`,
        source: 'Test VPS'
    };
    
    const embed = taoEmbedTinHieu(tinHieuTest);
    await interaction.editReply({ embeds: [embed] });
    
    console.log(`🧪 Test tín hiệu: ${tinHieuTest.signal} ${tinHieuTest.pair}`);
}

// =============================================
// CHANNEL SETUP
// =============================================

async function thieLapKenh() {
    for (const guild of client.guilds.cache.values()) {
        let kenhTinHieu = guild.channels.cache.find(ch => ch.name === config.channels.signalsChannelName);
        
        if (!kenhTinHieu) {
            try {
                kenhTinHieu = await guild.channels.create({
                    name: config.channels.signalsChannelName,
                    type: 0,
                    topic: '🎯 Tín Hiệu VietForex - VPS Production'
                });
                
                const embedChaoMung = new EmbedBuilder()
                    .setTitle('🎮 VietForex VPS Bot Kích Hoạt!')
                    .setDescription('🚀 Bot Production đang chạy và sẵn sàng gửi tín hiệu!')
                    .setColor(0x00FF00)
                    .addFields([
                        {
                            name: '📋 Lệnh Có Sẵn',
                            value: '• `/ping` - Kiểm tra bot\n• `/tinhieu` - Tín hiệu mới nhất\n• `/thongtin` - Thông tin bot\n• `/test` - Test tín hiệu',
                            inline: false
                        }
                    ])
                    .setTimestamp()
                    .setFooter({ text: 'VietForex VPS Production' });

                await kenhTinHieu.send({ embeds: [embedChaoMung] });
                console.log(`✅ Đã tạo kênh #${config.channels.signalsChannelName} trong ${guild.name}`);
                
            } catch (error) {
                console.error(`❌ Lỗi tạo kênh trong ${guild.name}:`, error.message);
            }
        }
    }
}

// =============================================
// SIGNAL PROCESSING
// =============================================

function taoEmbedTinHieu(duLieuTinHieu) {
    const { signal, pair, confidence, entry_price, stop_loss, take_profit } = duLieuTinHieu;
    
    // Chuyển đổi signal sang tiếng Việt
    const tinHieuTV = signal === 'BUY' ? 'MUA' : signal === 'SELL' ? 'BÁN' : signal;
    const mauSac = signal === 'BUY' || signal === 'MUA' ? 0x00FF00 : 
                   signal === 'SELL' || signal === 'BÁN' ? 0xFF0000 : 0xFFFF00;
    const emoji = signal === 'BUY' || signal === 'MUA' ? '🟢📈' : 
                  signal === 'SELL' || signal === 'BÁN' ? '🔴📉' : '⚪➡️';
    
    return new EmbedBuilder()
        .setTitle('🎯 Tín Hiệu VietForex')
        .setDescription(`${emoji} **${tinHieuTV} ${pair}**`)
        .setColor(mauSac)
        .addFields([
            {
                name: '📊 Chi Tiết Tín Hiệu',
                value: `**Hướng**: ${tinHieuTV}\n**Độ tin cậy**: ${(confidence * 100).toFixed(1)}%`,
                inline: false
            },
            {
                name: '💰 Mức Giá',
                value: `**Vào lệnh**: ${entry_price}\n**Cắt lỗ**: ${stop_loss}\n**Chốt lời**: ${take_profit}`,
                inline: true
            },
            {
                name: '📈 Quản Lý Rủi Ro',
                value: `**R/R**: 1:${duLieuTinHieu.risk_reward_ratio || 2}\n**Nguồn**: ${duLieuTinHieu.source || 'VPS API'}`,
                inline: true
            }
        ])
        .setTimestamp()
        .setFooter({ text: `ID: ${duLieuTinHieu.signal_id} | VietForex VPS` });
}

// =============================================
// WEBHOOK ENDPOINTS
// =============================================

// Webhook nhận tín hiệu từ API
app.post('/webhook/signals', async (req, res) => {
    const duLieuTinHieu = req.body;
    const thoiGian = new Date().toISOString();
    
    console.log(`📨 Webhook nhận tín hiệu: ${duLieuTinHieu.signal} ${duLieuTinHieu.pair}`);
    ghiLog('INFO', `Webhook tín hiệu: ${duLieuTinHieu.signal} ${duLieuTinHieu.pair}`);
    
    try {
        if (duLieuTinHieu.is_valid && duLieuTinHieu.success) {
            const daGui = await guiTinHieuDenTatCaKenh(duLieuTinHieu);
            
            res.json({
                delivered: true,
                servers: client.guilds.cache.size,
                channels: daGui,
                timestamp: thoiGian,
                signal_id: duLieuTinHieu.signal_id
            });
            
            ghiLog('INFO', `Tín hiệu đã gửi đến ${daGui} kênh`);
        } else {
            res.json({
                delivered: false,
                reason: 'Dữ liệu tín hiệu không hợp lệ',
                timestamp: thoiGian
            });
        }
        
    } catch (error) {
        console.error('❌ Lỗi xử lý webhook:', error);
        ghiLog('ERROR', `Lỗi webhook: ${error.message}`);
        res.status(500).json({ 
            error: error.message,
            timestamp: thoiGian
        });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        bot_status: client.user ? 'online' : 'offline',
        servers: client.guilds.cache.size,
        uptime: process.uptime(),
        memory_usage: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
        timestamp: new Date().toISOString(),
        version: '1.0.0-simple'
    });
});

// =============================================
// UTILITY FUNCTIONS
// =============================================

async function guiTinHieuDenTatCaKenh(duLieuTinHieu) {
    let daGui = 0;
    
    for (const guild of client.guilds.cache.values()) {
        try {
            const kenh = guild.channels.cache.find(ch => ch.name === config.channels.signalsChannelName);
            
            if (kenh) {
                const embed = taoEmbedTinHieu(duLieuTinHieu);
                await kenh.send({ embeds: [embed] });
                daGui++;
            }
            
        } catch (error) {
            console.error(`❌ Lỗi gửi tín hiệu đến server ${guild.name}:`, error.message);
        }
    }
    
    console.log(`📤 Tín hiệu đã được gửi đến ${daGui} kênh`);
    return daGui;
}

async function dangKyWebhook() {
    const webhookUrl = `http://localhost:${config.api.webhookPort}/webhook/signals`;
    
    try {
        console.log('📱 Đăng ký webhook Discord với API...');
        
        const response = await axios.post(`${config.api.vpsApiUrl}/api/discord/register-webhook`, {
            webhook_url: webhookUrl,
            bot_id: client.user?.id,
            bot_name: client.user?.username,
            servers: client.guilds.cache.size,
            environment: 'production'
        }, {
            timeout: 10000
        });
        
        if (response.data.success) {
            console.log('✅ Webhook Discord đã đăng ký với API');
            ghiLog('INFO', 'Webhook đã đăng ký với API');
        }
        
    } catch (error) {
        console.error('❌ Không thể đăng ký webhook:', error.message);
        ghiLog('WARN', `Đăng ký webhook thất bại: ${error.message}`);
    }
}

function ghiLog(mucDo, thongDiep) {
    const thoiGian = new Date().toISOString();
    const tinNhan = `${thoiGian} [${mucDo}] ${thongDiep}\n`;
    
    try {
        fs.appendFileSync(config.logging.logFile, tinNhan);
    } catch (error) {
        console.error('Lỗi ghi log:', error.message);
    }
}

// =============================================
// APPLICATION STARTUP
// =============================================

async function khoiDongBot() {
    try {
        console.log('⚡ Khởi động Discord Bot...');
        
        // Khởi động Express webhook server
        app.listen(config.api.webhookPort, '0.0.0.0', () => {
            console.log(`🌐 Webhook server chạy trên port ${config.api.webhookPort}`);
        });
        
        // Khởi động Discord bot
        await client.login(config.discord.token);
        
    } catch (error) {
        console.error('❌ Lỗi khởi động bot:', error);
        ghiLog('ERROR', `Lỗi khởi động: ${error.message}`);
        process.exit(1);
    }
}

// Xử lý tắt bot
process.on('SIGINT', () => {
    console.log('\n🛑 Đang tắt bot...');
    ghiLog('INFO', 'Bot đang tắt');
    client.destroy();
    process.exit(0);
});

process.on('unhandledRejection', (error) => {
    console.error('❌ Unhandled promise rejection:', error);
    ghiLog('ERROR', `Unhandled rejection: ${error.message}`);
});

// Khởi động ứng dụng
khoiDongBot();
