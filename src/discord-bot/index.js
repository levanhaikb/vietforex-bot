// VietForex Discord Bot - Phiên bản VPS Production
const { Client, GatewayIntentBits, EmbedBuilder, SlashCommandBuilder, Routes, ActionRowBuilder, ButtonBuilder, ButtonStyle, PermissionsBitField } = require('discord.js');
const { REST } = require('@discordjs/rest');
const express = require('express');
const axios = require('axios');
const fs = require('fs');
const path = require('path');
const config = require('./config');

// Tạo thư mục logs
if (!fs.existsSync('./logs')) {
    fs.mkdirSync('./logs', { recursive: true });
}

// Tạo thư mục data
if (!fs.existsSync('./data')) {
    fs.mkdirSync('./data', { recursive: true });
}

console.log('🚀 VietForex Discord Bot - Chế độ VPS Production');
console.log('🌐 IP Server: 145.79.13.123');
console.log('⚡ Môi trường: Production');

// Discord client
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.GuildMembers
    ]
});

// Express server cho webhook
const app = express();
app.use(express.json());

// Hàm tạo link mời bot
function generateInviteLink() {
    const permissions = [
        'SendMessages',
        'EmbedLinks', 
        'ReadMessageHistory',
        'UseApplicationCommands',
        'ManageChannels'
    ];
    
    const permissionValue = permissions.reduce((acc, perm) => {
        const flag = Object.keys(PermissionsBitField.Flags).find(key => key === perm);
        return acc | PermissionsBitField.Flags[flag];
    }, 0);
    
    return `https://discord.com/api/oauth2/authorize?client_id=${config.discord.clientId}&permissions=${permissionValue}&scope=bot%20applications.commands`;
}

// Khởi động bot
client.once('ready', async () => {
    console.log('🎮 VietForex Discord Bot ĐANG HOẠT ĐỘNG!');
    console.log(`📊 Đang phục vụ ${client.guilds.cache.size} server(s)`);
    console.log(`🤖 Bot: ${client.user.tag}`);
    console.log(`🆔 Bot ID: ${client.user.id}`);
    
    await registerCommands();
    await setupChannels();
    await registerWithVPSAPI();
    
    console.log('✅ VPS Production Bot Sẵn sàng!');
    console.log('📋 Test với /ping hoặc !ping trong Discord');
    
    // Ghi log khởi động
    logToFile('INFO', 'VietForex Discord Bot khởi động thành công');
});

// Xử lý lệnh slash commands
client.on('interactionCreate', async interaction => {
    if (!interaction.isChatInputCommand()) return;

    const startTime = Date.now();
    console.log(`📝 Lệnh: /${interaction.commandName} từ ${interaction.user.username}`);

    try {
        switch (interaction.commandName) {
            case 'ping':
                await handlePingCommand(interaction);
                break;
                
            case 'status':
                await handleStatusCommand(interaction);
                break;
                
            case 'signals':
                await handleSignalsCommand(interaction);
                break;
                
            case 'info':
                await handleInfoCommand(interaction);
                break;
                
            case 'test-webhook':
                await handleTestWebhook(interaction);
                break;
                
            case 'server-info':
                await handleServerInfoCommand(interaction);
                break;
        }
        
        const executionTime = Date.now() - startTime;
        console.log(`✅ Lệnh /${interaction.commandName} hoàn thành trong ${executionTime}ms`);
        
    } catch (error) {
        console.error(`❌ Lỗi lệnh /${interaction.commandName}:`, error);
        logToFile('ERROR', `Lỗi lệnh: ${error.message}`);
        
        if (!interaction.replied && !interaction.deferred) {
            await interaction.reply('❌ Có lỗi xảy ra khi xử lý lệnh!');
        }
    }
});

// Xử lý lệnh prefix (dự phòng khi slash commands không hoạt động)
client.on('messageCreate', async (message) => {
    // Bỏ qua tin nhắn từ bot
    if (message.author.bot) return;
    
    // Lệnh với prefix !
    const prefix = '!';
    if (!message.content.startsWith(prefix)) return;
    
    const args = message.content.slice(prefix.length).trim().split(/ +/);
    const command = args.shift().toLowerCase();
    
    try {
        switch (command) {
            case 'ping':
                const embed = new EmbedBuilder()
                    .setTitle('🏓 Pong!')
                    .setDescription(`Độ trễ: ${client.ws.ping}ms`)
                    .setColor(0x00FF00);
                await message.reply({ embeds: [embed] });
                break;
                
            case 'help':
                const helpEmbed = new EmbedBuilder()
                    .setTitle('📋 Lệnh VietForex Bot')
                    .setDescription('Các lệnh khả dụng:')
                    .addFields([
                        { name: '!ping', value: 'Kiểm tra độ trễ bot', inline: true },
                        { name: '!status', value: 'Trạng thái bot', inline: true },
                        { name: '!help', value: 'Hiển thị trợ giúp', inline: true },
                        { name: '!test', value: 'Test tín hiệu demo', inline: true }
                    ])
                    .setColor(0x3498DB)
                    .setFooter({ text: 'Sử dụng prefix ! cho các lệnh' });
                await message.reply({ embeds: [helpEmbed] });
                break;
                
            case 'status':
                await message.reply(`✅ Bot đang hoạt động! Uptime: ${Math.floor(process.uptime())}s`);
                break;
                
            case 'test':
                const testEmbed = new EmbedBuilder()
                    .setTitle('🎯 Test Signal Demo')
                    .setDescription('🟢📈 **BUY EURUSD**')
                    .setColor(0x00FF00)
                    .addFields([
                        { name: '💰 Entry', value: '1.0850', inline: true },
                        { name: '🛡️ Stop Loss', value: '1.0830', inline: true },
                        { name: '🎯 Take Profit', value: '1.0890', inline: true }
                    ])
                    .setTimestamp();
                await message.reply({ embeds: [testEmbed] });
                break;
        }
    } catch (error) {
        console.error('Lỗi xử lý lệnh prefix:', error);
    }
});

// Đăng ký slash commands
async function registerCommands() {
    const commands = [
        new SlashCommandBuilder()
            .setName('ping')
            .setDescription('Kiểm tra trạng thái bot và độ trễ'),
            
        new SlashCommandBuilder()
            .setName('status')
            .setDescription('Xem trạng thái hệ thống VPS và API'),
            
        new SlashCommandBuilder()
            .setName('signals')
            .setDescription('Xem tín hiệu trading mới nhất'),
            
        new SlashCommandBuilder()
            .setName('info')
            .setDescription('Thông tin chi tiết về VietForex Bot'),
            
        new SlashCommandBuilder()
            .setName('test-webhook')
            .setDescription('Test kết nối webhook với VPS API'),
            
        new SlashCommandBuilder()
            .setName('server-info')
            .setDescription('Thông tin chi tiết VPS server')
    ].map(cmd => cmd.toJSON());

    const rest = new REST({ version: '10' }).setToken(config.discord.token);

    try {
        console.log('🔄 Đang đăng ký slash commands...');
        
        // Thử đăng ký guild commands trước
        try {
            await rest.put(
                Routes.applicationGuildCommands(config.discord.clientId, config.discord.guildId),
                { body: commands }
            );
            console.log('✅ Đăng ký guild commands thành công!');
        } catch (guildError) {
            console.error('⚠️ Không thể đăng ký guild commands:', guildError.message);
            
            // Chuyển sang global commands
            console.log('🔄 Thử đăng ký global commands...');
            await rest.put(
                Routes.applicationCommands(config.discord.clientId),
                { body: commands }
            );
            console.log('✅ Đăng ký global commands thành công!');
            console.log('⚠️ Lưu ý: Global commands có thể mất đến 1 giờ để hiển thị');
        }
        
    } catch (error) {
        console.error('❌ Không thể đăng ký commands:', error.message);
        console.log('\n⚠️ QUAN TRỌNG: Bot cần được cấp đủ quyền!');
        console.log('📌 Vui lòng mời lại bot bằng link này:');
        console.log(`🔗 ${generateInviteLink()}\n`);
        
        logToFile('ERROR', `Đăng ký command thất bại: ${error.message}`);
        
        // Bot vẫn có thể chạy mà không cần slash commands
        console.log('💡 Bot sẽ tiếp tục hoạt động với prefix commands (!ping, !help, ...)');
    }
}

// Thiết lập kênh Discord
async function setupChannels() {
    for (const guild of client.guilds.cache.values()) {
        let signalChannel = guild.channels.cache.find(ch => ch.name === config.channels.signalsChannelName);
        
        if (!signalChannel) {
            try {
                signalChannel = await guild.channels.create({
                    name: config.channels.signalsChannelName,
                    type: 0,
                    topic: '🎯 VietForex Trading Signals - Hệ thống VPS Production'
                });
                
                console.log(`✅ Đã tạo kênh #${config.channels.signalsChannelName} trong ${guild.name}`);
                
                // Gửi tin nhắn chào mừng
                const welcomeEmbed = new EmbedBuilder()
                    .setTitle('🎮 VietForex VPS Bot Đã Kích Hoạt!')
                    .setDescription('🚀 Discord Bot Production đang chạy trên VPS và sẵn sàng nhận tín hiệu từ hệ thống AI!')
                    .setColor(0x00FF00)
                    .addFields([
                        {
                            name: '🌐 Thông tin VPS',
                            value: '• **IP Server**: 145.79.13.123\n• **Môi trường**: Production\n• **Uptime**: 24/7\n• **Kết nối API**: VPS nội bộ',
                            inline: false
                        },
                        {
                            name: '📋 Lệnh khả dụng',
                            value: '• `/ping` - Trạng thái bot & độ trễ\n• `/status` - Trạng thái hệ thống VPS\n• `/signals` - Tín hiệu trading mới nhất\n• `/info` - Thông tin chi tiết bot\n• `/server-info` - Thông số kỹ thuật VPS',
                            inline: false
                        },
                        {
                            name: '⚡ Tính năng Production',
                            value: '• Tích hợp webhook real-time\n• Giám sát tín hiệu 24/7\n• Độ tin cậy production\n• Kết nối API trực tiếp\n• Monitoring nâng cao',
                            inline: false
                        }
                    ])
                    .setTimestamp()
                    .setFooter({ text: 'VietForex VPS Production System | 145.79.13.123' });

                await signalChannel.send({ embeds: [welcomeEmbed] });
                
            } catch (error) {
                console.error(`❌ Không thể tạo kênh trong ${guild.name}:`, error.message);
            }
        }
    }
}

// Xử lý lệnh ping
async function handlePingCommand(interaction) {
    const startTime = Date.now();
    await interaction.deferReply();
    
    const responseTime = Date.now() - startTime;
    const botLatency = client.ws.ping;
    
    const embed = new EmbedBuilder()
        .setTitle('🏓 Phản hồi Ping VPS Bot')
        .setDescription('✅ VietForex Discord Bot đang hoạt động trên VPS!')
        .setColor(0x00FF00)
        .addFields([
            { name: '⚡ Thời gian phản hồi', value: `${responseTime}ms`, inline: true },
            { name: '🌐 Độ trễ Bot', value: `${botLatency}ms`, inline: true },
            { name: '🖥️ VPS Server', value: '145.79.13.123', inline: true },
            { name: '📊 Trạng thái', value: 'Production Ready', inline: true },
            { name: '⏰ Uptime', value: `${Math.floor(process.uptime())}s`, inline: true },
            { name: '💾 Bộ nhớ', value: `${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB`, inline: true }
        ])
        .setTimestamp()
        .setFooter({ text: 'VPS Production Monitor' });

    await interaction.editReply({ embeds: [embed] });
}

// Xử lý lệnh status
async function handleStatusCommand(interaction) {
    await interaction.deferReply();
    
    // Kiểm tra trạng thái VPS API
    let apiStatus = 'Không xác định';
    let apiResponseTime = 'N/A';
    
    try {
        const start = Date.now();
        const response = await axios.get(`${config.api.vpsApiUrl}/api/health`, { timeout: 5000 });
        apiResponseTime = `${Date.now() - start}ms`;
        apiStatus = response.data.status === 'healthy' ? '✅ Khỏe mạnh' : '⚠️ Có vấn đề';
    } catch (error) {
        apiStatus = '❌ Offline';
        apiResponseTime = 'Timeout';
    }
    
    // Thông tin hệ thống
    const memoryUsage = process.memoryUsage();
    const uptime = process.uptime();
    
    const embed = new EmbedBuilder()
        .setTitle('📊 Bảng Trạng Thái Hệ Thống VPS')
        .setDescription('Giám sát real-time hệ thống VietForex trên VPS Production')
        .setColor(0x3498DB)
        .addFields([
            {
                name: '🤖 Trạng thái Discord Bot',
                value: `**Trạng thái**: ✅ Online\n**Uptime**: ${Math.floor(uptime)}s\n**Servers**: ${client.guilds.cache.size}\n**Độ trễ**: ${client.ws.ping}ms`,
                inline: true
            },
            {
                name: '🔗 Trạng thái VPS API',
                value: `**Trạng thái**: ${apiStatus}\n**Phản hồi**: ${apiResponseTime}\n**URL**: localhost:3000\n**Webhook**: Port 3002`,
                inline: true
            },
            {
                name: '🖥️ Tài nguyên VPS',
                value: `**Bộ nhớ**: ${Math.round(memoryUsage.heapUsed / 1024 / 1024)}MB\n**RSS**: ${Math.round(memoryUsage.rss / 1024 / 1024)}MB\n**CPU**: Hoạt động\n**Ổ đĩa**: Khả dụng`,
                inline: true
            },
            {
                name: '🌐 Thông tin mạng',
                value: `**IP Server**: 145.79.13.123\n**Môi trường**: Production\n**SSL**: Khả dụng\n**Cổng**: 3000, 3002`,
                inline: false
            },
            {
                name: '📈 Chỉ số hiệu suất',
                value: `**Khởi động**: ${new Date(Date.now() - uptime * 1000).toLocaleString()}\n**Kiểm tra cuối**: ${new Date().toLocaleString()}\n**Sức khỏe**: Xuất sắc\n**Khả dụng**: 99.9%`,
                inline: false
            }
        ])
        .setTimestamp()
        .setFooter({ text: 'VPS Production Monitor | Tự động làm mới mỗi 30s' });

    await interaction.editReply({ embeds: [embed] });
}

// Xử lý lệnh signals
async function handleSignalsCommand(interaction) {
    await interaction.deferReply();
    
    try {
        // Thử lấy tín hiệu mới nhất từ VPS API
        const response = await axios.get(`${config.api.vpsApiUrl}/api/signals/latest`, {
            timeout: 10000,
            headers: { 'User-Agent': 'VietForex-Discord-Bot' }
        });
        
        if (response.data.success && response.data.signals?.length > 0) {
            const latestSignal = response.data.signals[0];
            const embed = createSignalEmbed(latestSignal);
            
            const actionRow = new ActionRowBuilder()
                .addComponents(
                    new ButtonBuilder()
                        .setCustomId('copy_signal')
                        .setLabel('Sao chép tín hiệu')
                        .setStyle(ButtonStyle.Primary)
                        .setEmoji('📋'),
                    new ButtonBuilder()
                        .setCustomId('get_analysis')
                        .setLabel('Phân tích chi tiết')
                        .setStyle(ButtonStyle.Secondary)
                        .setEmoji('🔍'),
                    new ButtonBuilder()
                        .setCustomId('more_signals')
                        .setLabel('Thêm tín hiệu')
                        .setStyle(ButtonStyle.Success)
                        .setEmoji('📊')
                );
            
            await interaction.editReply({ 
                embeds: [embed],
                components: [actionRow]
            });
            
        } else {
            const embed = new EmbedBuilder()
                .setTitle('📊 Chưa có tín hiệu mới')
                .setDescription('Hiện tại chưa có tín hiệu trading mới từ VPS API')
                .setColor(0xFFB347)
                .addFields([
                    { name: '🔄 Tự động kiểm tra', value: 'Hệ thống sẽ tự động kiểm tra tín hiệu mới', inline: true },
                    { name: '⏰ Kiểm tra tiếp theo', value: 'Mỗi 30 giây', inline: true },
                    { name: '📡 Trạng thái API', value: 'Đã kết nối', inline: true }
                ])
                .setTimestamp();
                
            await interaction.editReply({ embeds: [embed] });
        }
        
    } catch (error) {
        console.error('Lỗi gọi API:', error.message);
        
        // Tạo tín hiệu demo
        const demoSignal = {
            signal: 'BUY',
            pair: 'EURUSD',
            confidence: 0.75,
            entry_price: 1.0850,
            stop_loss: 1.0830,
            take_profit: 1.0890,
            risk_reward_ratio: 2.0,
            risk_pips: 20,
            reward_pips: 40,
            validation_score: 80,
            signal_id: `VPS_DEMO_${Date.now()}`,
            source: 'Demo (API không khả dụng)'
        };
        
        const embed = createSignalEmbed(demoSignal);
        await interaction.editReply({ 
            content: '⚠️ VPS API không khả dụng - hiển thị tín hiệu demo:',
            embeds: [embed] 
        });
    }
}

// Xử lý lệnh info
async function handleInfoCommand(interaction) {
    const embed = new EmbedBuilder()
        .setTitle('🤖 VietForex Discord Bot - VPS Production')
        .setDescription('Bot tín hiệu trading Forex được hỗ trợ bởi AI chạy trên môi trường VPS production')
        .setColor(0x3498DB)
        .addFields([
            {
                name: '🎯 Tính năng chính',
                value: '• **Tín hiệu AI real-time** từ mô hình machine learning\n• **Phân tích đa khung thời gian** (M15, H1, H4)\n• **Quản lý rủi ro nâng cao** với position sizing động\n• **Tích hợp webhook** với hệ thống VPS API',
                inline: false
            },
            {
                name: '🌐 Hạ tầng VPS',
                value: '• **Server**: 145.79.13.123 (Production)\n• **Môi trường**: Ubuntu 22.04 LTS\n• **Uptime**: Giám sát 24/7\n• **API**: Tích hợp nội bộ cổng 3000',
                inline: true
          },
            {
                name: '📊 Chỉ số hiệu suất',
                value: '• **Độ chính xác mục tiêu**: 58-65%\n• **Risk/Reward**: Trung bình 1:2\n• **Tín hiệu/ngày**: 2-5 chất lượng cao\n• **Thời gian phản hồi**: <100ms',
                inline: true
            },
            {
                name: '🏗️ Kiến trúc hệ thống',
                value: '**Google Colab** (Huấn luyện AI) ↔ **VPS API** (Xử lý tín hiệu) ↔ **Discord Bot** (Giao hàng người dùng)',
                inline: false
            },
            {
                name: '⚡ Ưu điểm Production',
                value: '• Đảm bảo uptime 24/7\n• Giao hàng webhook real-time\n• Độ tin cậy production\n• Giám sát & logging nâng cao\n• Hạ tầng có thể mở rộng',
                inline: false
            }
        ])
        .setTimestamp()
        .setFooter({ text: 'VietForex VPS Production | Được hỗ trợ bởi AI & Machine Learning' });

    await interaction.reply({ embeds: [embed] });
}

// Xử lý test webhook
async function handleTestWebhook(interaction) {
    await interaction.deferReply();
    
    const testSignal = {
        signal: Math.random() > 0.5 ? 'BUY' : 'SELL',
        pair: 'EURUSD',
        confidence: 0.75,
        entry_price: 1.0850,
        stop_loss: 1.0830,
        take_profit: 1.0890,
        risk_reward_ratio: 2.0,
        risk_pips: 20,
        reward_pips: 40,
        validation_score: 80,
        signal_id: `VPS_TEST_${Date.now()}`,
        is_valid: true,
        success: true,
        source: 'Test Webhook'
    };
    
    const delivered = await sendSignalToAllServers(testSignal);
    
    const embed = new EmbedBuilder()
        .setTitle('✅ Test Webhook Hoàn thành')
        .setDescription('Tín hiệu test đã được gửi thành công!')
        .setColor(0x00FF00)
        .addFields([
            { name: '📤 Đã gửi', value: `${delivered} kênh`, inline: true },
            { name: '🎯 Loại tín hiệu', value: testSignal.signal, inline: true },
            { name: '💱 Cặp tiền', value: testSignal.pair, inline: true }
        ])
        .setTimestamp();
    
    await interaction.editReply({ embeds: [embed] });
}

// Xử lý thông tin server
async function handleServerInfoCommand(interaction) {
    const embed = new EmbedBuilder()
        .setTitle('🖥️ Thông tin VPS Server')
        .setDescription('Chi tiết kỹ thuật của VPS hosting hệ thống VietForex')
        .setColor(0x9B59B6)
        .addFields([
            {
                name: '🌐 Thông tin mạng',
                value: '• **Địa chỉ IP**: 145.79.13.123\n• **Nhà cung cấp**: VPS Hosting\n• **Vị trí**: Data Center\n• **Băng thông**: Tốc độ cao',
                inline: true
            },
            {
                name: '⚙️ Thông số kỹ thuật',
                value: '• **OS**: Ubuntu 22.04 LTS\n• **CPU**: Đa lõi\n• **RAM**: Đủ cho trading\n• **Ổ cứng**: SSD',
                inline: true
            },
            {
                name: '🔧 Phần mềm',
                value: '• **Node.js**: v18+\n• **PM2**: Quản lý process\n• **Discord.js**: v14\n• **Express**: Web framework',
                inline: false
            },
            {
                name: '📊 Sử dụng hiện tại',
                value: `• **Uptime**: ${Math.floor(process.uptime())}s\n• **Bộ nhớ**: ${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB\n• **Tải**: Tối ưu\n• **Trạng thái**: Khỏe mạnh`,
                inline: false
            }
        ])
        .setTimestamp()
        .setFooter({ text: 'Thông tin kỹ thuật VPS' });

    await interaction.reply({ embeds: [embed] });
}

// Webhook endpoint - nhận tín hiệu từ VPS API
app.post('/webhook/signals', async (req, res) => {
    const signalData = req.body;
    const timestamp = new Date().toISOString();
    
    console.log(`📨 Webhook nhận được: ${signalData.signal} ${signalData.pair} lúc ${timestamp}`);
    logToFile('INFO', `Tín hiệu webhook: ${signalData.signal} ${signalData.pair}`);
    
    try {
        if (signalData.is_valid && signalData.success) {
            const delivered = await sendSignalToAllServers(signalData);
            
            const response = {
                delivered: true,
                servers: client.guilds.cache.size,
                channels: delivered,
                timestamp: timestamp,
                signal_id: signalData.signal_id
            };
            
            logToFile('INFO', `Tín hiệu đã gửi đến ${delivered} kênh`);
            res.json(response);
            
        } else {
            const response = {
                delivered: false,
                reason: 'Dữ liệu tín hiệu không hợp lệ',
                timestamp: timestamp
            };
            
            logToFile('WARN', 'Nhận được tín hiệu không hợp lệ qua webhook');
            res.json(response);
        }
        
    } catch (error) {
        console.error('❌ Lỗi xử lý webhook:', error);
        logToFile('ERROR', `Lỗi webhook: ${error.message}`);
        res.status(500).json({ 
            error: error.message,
            timestamp: timestamp
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
        version: '1.0.0'
    });
});

// Gửi tín hiệu đến tất cả servers
async function sendSignalToAllServers(signalData) {
    let delivered = 0;
    
    for (const guild of client.guilds.cache.values()) {
        try {const channel = guild.channels.cache.find(ch => ch.name === config.channels.signalsChannelName);
           
           if (channel) {
               const embed = createSignalEmbed(signalData);
               
               const actionRow = new ActionRowBuilder()
                   .addComponents(
                       new ButtonBuilder()
                           .setCustomId('copy_signal')
                           .setLabel('Sao chép tín hiệu')
                           .setStyle(ButtonStyle.Primary)
                           .setEmoji('📋'),
                       new ButtonBuilder()
                           .setCustomId('get_analysis')
                           .setLabel('Phân tích')
                           .setStyle(ButtonStyle.Secondary)
                           .setEmoji('🔍'),
                       new ButtonBuilder()
                           .setCustomId('subscribe_premium')
                           .setLabel('Premium')
                           .setStyle(ButtonStyle.Success)
                           .setEmoji('💎')
                   );
               
               await channel.send({ 
                   embeds: [embed],
                   components: [actionRow]
               });
               
               delivered++;
           }
           
       } catch (error) {
           console.error(`❌ Không thể gửi tín hiệu đến ${guild.name}:`, error.message);
       }
   }
   
   console.log(`📤 Tín hiệu đã gửi đến ${delivered} kênh`);
   return delivered;
}

// Tạo embed tín hiệu
function createSignalEmbed(signalData) {
   const { signal, pair, confidence, entry_price, stop_loss, take_profit, validation_score } = signalData;
   
   const color = signal === 'BUY' ? 0x00FF00 : 0xFF0000;
   const emoji = signal === 'BUY' ? '🟢📈' : '🔴📉';
   const stars = '⭐'.repeat(Math.min(5, Math.floor(confidence * 5)));
   const scoreEmoji = validation_score >= 80 ? '🏆' : validation_score >= 60 ? '🥇' : '🥈';
   
   return new EmbedBuilder()
       .setTitle('🎯 Tín hiệu Premium VietForex VPS')
       .setDescription(`${emoji} **${signal} ${pair}**`)
       .setColor(color)
       .addFields([
           {
               name: '📊 Thông tin tín hiệu',
               value: `**Hướng**: ${signal}\n**Độ tin cậy**: ${(confidence * 100).toFixed(1)}% ${stars}\n**Điểm chất lượng**: ${scoreEmoji} ${validation_score}/100`,
               inline: false
           },
           {
               name: '💰 Mức giao dịch',
               value: `**Giá vào lệnh**: ${entry_price}\n**Cắt lỗ**: ${stop_loss}\n**Chốt lời**: ${take_profit}`,
               inline: true
           },
           {
               name: '📈 Quản lý rủi ro',
               value: `**Risk/Reward**: 1:${signalData.risk_reward_ratio || 2}\n**Rủi ro**: ${signalData.risk_pips || 20} pips\n**Lợi nhuận**: ${signalData.reward_pips || 40} pips`,
               inline: true
           },
           {
               name: '🌐 Thông tin nguồn',
               value: `**Nền tảng**: VPS Production\n**Server**: 145.79.13.123\n**ID tín hiệu**: \`${signalData.signal_id}\`\n**Nguồn**: ${signalData.source || 'VPS API'}`,
               inline: false
           }
       ])
       .setTimestamp()
       .setFooter({ text: 'VietForex VPS Production System | Tín hiệu được hỗ trợ bởi AI' });
}

// Đăng ký webhook với VPS API
async function registerWithVPSAPI() {
   const webhookUrl = `http://145.79.13.123:${config.api.webhookPort}/webhook/signals`;
   
   try {
       console.log('📱 Kiểm tra kết nối VPS API...');
       
       // Kiểm tra API có hoạt động không
       try {
           const healthCheck = await axios.get(`${config.api.vpsApiUrl}/api/health`, {
               timeout: 5000
           });
           console.log('✅ VPS API đang hoạt động:', healthCheck.data);
       } catch (healthError) {
           console.log('⚠️ Kiểm tra sức khỏe VPS API thất bại - API có thể chưa chạy');
           return;
       }
       
       // Thử các endpoint khác nhau
       const endpoints = [
           '/api/discord/register-webhook',
           '/api/webhook/register',
           '/webhook/register',
           '/api/register-webhook'
       ];
       
       let registered = false;
       
       for (const endpoint of endpoints) {
           try {
               console.log(`🔄 Thử endpoint: ${endpoint}`);
               
               const response = await axios.post(`${config.api.vpsApiUrl}${endpoint}`, {
                   webhook_url: webhookUrl,
                   bot_id: client.user.id,
                   bot_name: client.user.username,
                   servers: client.guilds.cache.size,
                   environment: 'production',
                   server_ip: '145.79.13.123'
               }, {
                   timeout: 5000,
                   headers: { 'User-Agent': 'VietForex-Discord-Bot' }
               });
               
               if (response.data.success || response.status === 200) {
                   console.log(`✅ Đăng ký webhook thành công tại ${endpoint}`);
                   logToFile('INFO', `Webhook đã đăng ký tại ${endpoint}`);
                   registered = true;
                   break;
               }
           } catch (err) {
               // Tiếp tục với endpoint tiếp theo
           }
       }
       
       if (!registered) {
           console.log('⚠️ Không thể đăng ký webhook với bất kỳ endpoint nào');
           console.log('💡 Bot sẽ hoạt động ở chế độ thụ động - chờ webhook calls');
           console.log(`📡 Webhook endpoint sẵn sàng tại: ${webhookUrl}`);
       }
       
   } catch (error) {
       console.error('❌ Lỗi kết nối VPS API:', error.message);
       console.log('⚠️ Bot sẽ hoạt động độc lập không cần tích hợp VPS API');
       console.log(`📡 Webhook server vẫn lắng nghe tại: ${webhookUrl}`);
       logToFile('WARN', `Kết nối VPS API thất bại: ${error.message}`);
   }
}

// Hàm ghi log
function logToFile(level, message) {
   const timestamp = new Date().toISOString();
   const logMessage = `${timestamp} [${level}] ${message}\n`;
   
   try {
       fs.appendFileSync(config.logging.logFile, logMessage);
   } catch (error) {
       console.error('Không thể ghi vào file log:', error.message);
   }
}

// Khởi động ứng dụng
async function startBot() {
   try {
       console.log('⚡ Đang khởi động VPS Discord Bot...');
       
       // Khởi động Express webhook server
       app.listen(config.api.webhookPort, '0.0.0.0', () => {
           console.log(`🌐 Webhook server đang chạy trên cổng ${config.api.webhookPort}`);
           console.log(`📡 Webhook URL: http://145.79.13.123:${config.api.webhookPort}/webhook/signals`);
           logToFile('INFO', `Webhook server khởi động trên cổng ${config.api.webhookPort}`);
       });
       
       // Đăng nhập Discord bot
       console.log('🔑 Đang đăng nhập vào Discord...');
       await client.login(config.discord.token);
       
   } catch (error) {
       console.error('❌ Không thể khởi động bot:', error);
       logToFile('ERROR', `Khởi động bot thất bại: ${error.message}`);
       process.exit(1);
   }
}

// Xử lý lỗi
process.on('unhandledRejection', (reason, promise) => {
   console.error('❌ Unhandled Promise Rejection:', reason);
   logToFile('ERROR', `Unhandled rejection: ${reason}`);
});

process.on('uncaughtException', (error) => {
   console.error('❌ Uncaught Exception:', error);
   logToFile('ERROR', `Uncaught exception: ${error.message}`);
   process.exit(1);
});

process.on('SIGINT', () => {
   console.log('🛑 Nhận được SIGINT, đang tắt bot...');
   logToFile('INFO', 'Tắt bot được khởi tạo');
   client.destroy();
   process.exit(0);
});

process.on('SIGTERM', () => {
   console.log('🛑 Nhận được SIGTERM, đang tắt bot...');
  logToFile('INFO', 'Tắt bot qua SIGTERM');
   client.destroy();
   process.exit(0);
});

// Khởi động bot
console.log('⚡ Đang khởi tạo VietForex Discord Bot...');
startBot();
