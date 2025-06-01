// VietForex Discord Bot - Colab Version
const { Client, GatewayIntentBits, EmbedBuilder, SlashCommandBuilder, Routes } = require('discord.js');
const { REST } = require('@discordjs/rest');
const axios = require('axios');
const config = require('./config');

console.log('🚀 Khởi động VietForex Discord Bot (Colab Version)...');

// Tạo Discord client
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

// Bot ready
client.once('ready', async () => {
    console.log('🎮 VietForex Discord Bot online!');
    console.log(`📊 Servers: ${client.guilds.cache.size}`);
    console.log(`🤖 Bot: ${client.user.tag}`);
    
    await registerCommands();
    await setupChannels();
    
    console.log('✅ Bot đã sẵn sàng! Test bằng /ping trong Discord');
});

// Slash commands
client.on('interactionCreate', async interaction => {
    if (!interaction.isChatInputCommand()) return;

    try {
        switch (interaction.commandName) {
            case 'ping':
                await interaction.reply('🏓 Pong! Bot đang hoạt động trên Google Colab! ✨');
                break;
                
            case 'signals':
                await handleSignalsCommand(interaction);
                break;
                
            case 'info':
                await handleInfoCommand(interaction);
                break;
                
            case 'test':
                await handleTestCommand(interaction);
                break;
        }
    } catch (error) {
        console.error('❌ Lỗi command:', error);
    }
});

// Đăng ký commands
async function registerCommands() {
    const commands = [
        new SlashCommandBuilder().setName('ping').setDescription('Test bot hoạt động'),
        new SlashCommandBuilder().setName('signals').setDescription('Xem tín hiệu trading demo'),
        new SlashCommandBuilder().setName('info').setDescription('Thông tin về bot'),
        new SlashCommandBuilder().setName('test').setDescription('Test tín hiệu với embed đẹp')
    ].map(cmd => cmd.toJSON());

    const rest = new REST({ version: '10' }).setToken(config.discord.token);

    try {
        console.log('🔄 Đăng ký slash commands...');
        await rest.put(
            Routes.applicationGuildCommands(config.discord.clientId, config.discord.guildId),
            { body: commands }
        );
        console.log('✅ Slash commands đã đăng ký thành công!');
    } catch (error) {
        console.error('❌ Lỗi đăng ký commands:', error);
    }
}

// Setup channels
async function setupChannels() {
    for (const guild of client.guilds.cache.values()) {
        let channel = guild.channels.cache.find(ch => ch.name === config.channels.signalsChannelName);
        
        if (!channel) {
            try {
                channel = await guild.channels.create({
                    name: config.channels.signalsChannelName,
                    type: 0,
                    topic: '🎯 VietForex Trading Signals - AI Generated (Colab)'
                });
                
                console.log(`✅ Đã tạo channel #${config.channels.signalsChannelName}`);
                
                // Welcome message
                const welcomeEmbed = new EmbedBuilder()
                    .setTitle('🎮 VietForex Bot Activated! (Colab)')
                    .setDescription('🚀 Bot đang chạy trên Google Colab và sẵn sàng gửi tín hiệu AI!')
                    .setColor(0x00FF00)
                    .addFields([
                        { name: '🎯 Features', value: '• Real-time AI signals\n• Demo trading signals\n• Risk management\n• Performance tracking', inline: true },
                        { name: '📋 Commands', value: '• `/ping` - Test bot\n• `/signals` - View signals\n• `/info` - Bot info\n• `/test` - Test embed', inline: true },
                        { name: '⚡ Status', value: '• Platform: Google Colab\n• Mode: Development\n• API: Ready\n• Signals: Demo Mode', inline: false }
                    ])
                    .setTimestamp()
                    .setFooter({ text: 'VietForex AI System' });

                await channel.send({ embeds: [welcomeEmbed] });
                
            } catch (error) {
                console.error(`❌ Lỗi tạo channel:`, error.message);
            }
        }
    }
}

// Handle /signals command
async function handleSignalsCommand(interaction) {
    await interaction.deferReply();
    
    // Random demo signals
    const pairs = ['EURUSD', 'GBPUSD', 'USDJPY'];
    const signals = ['BUY', 'SELL'];
    
    const pair = pairs[Math.floor(Math.random() * pairs.length)];
    const signal = signals[Math.floor(Math.random() * signals.length)];
    
    const demoSignal = {
        signal: signal,
        pair: pair,
        confidence: 0.65 + Math.random() * 0.30,
        entry_price: pair === 'EURUSD' ? 1.0850 : pair === 'GBPUSD' ? 1.2650 : 150.25,
        stop_loss: signal === 'BUY' ? 1.0830 : 1.0870,
        take_profit: signal === 'BUY' ? 1.0890 : 1.0810,
        risk_reward_ratio: 2.0,
        risk_pips: 20,
        reward_pips: 40,
        validation_score: 70 + Math.floor(Math.random() * 30),
        signal_id: `DEMO_${Date.now()}`
    };
    
    const embed = createSignalEmbed(demoSignal);
    await interaction.editReply({ embeds: [embed] });
}

// Handle /info command  
async function handleInfoCommand(interaction) {
    const embed = new EmbedBuilder()
        .setTitle('🤖 VietForex Discord Bot (Colab Version)')
        .setDescription('AI-powered Forex trading signals bot chạy trên Google Colab')
        .setColor(0x3498DB)
        .addFields([
            { name: '🎯 Tính Năng', value: '• Tín hiệu AI từ machine learning\n• Phân tích đa khung thời gian\n• Quản lý rủi ro tự động\n• Demo signals với UI đẹp', inline: false },
            { name: '🔧 Technical Info', value: '• **Platform**: Google Colab\n• **Language**: Node.js + Discord.js\n• **API**: VPS integration ready\n• **Mode**: Development/Testing', inline: true },
            { name: '📊 Performance', value: '• **Accuracy**: 58-65%\n• **R:R Ratio**: 1:2 average\n• **Signals/day**: 2-5\n• **Response**: Real-time', inline: true },
            { name: '🚀 Architecture', value: 'Google Colab ↔ VPS API ↔ Discord Bot\nAI Training → Signal Processing → User Delivery', inline: false }
        ])
        .setTimestamp()
        .setFooter({ text: 'VietForex AI System | Powered by Colab' });

    await interaction.reply({ embeds: [embed] });
}

// Handle /test command
async function handleTestCommand(interaction) {
    const testEmbed = new EmbedBuilder()
        .setTitle('🧪 VietForex Test Signal')
        .setDescription('🟢📈 **BUY EURUSD** - Test Signal')
        .setColor(0x00FF00)
        .addFields([
            { name: '💰 Trading Levels', value: '**Entry**: 1.0850\n**Stop Loss**: 1.0830\n**Take Profit**: 1.0890', inline: true },
            { name: '📊 Analysis', value: '**Confidence**: 78% ⭐⭐⭐⭐\n**Quality Score**: 🏆 85/100\n**Risk/Reward**: 1:2', inline: true },
            { name: '🔬 Technical', value: '**Platform**: Google Colab\n**Model**: Demo AI\n**Status**: Test Mode ✅', inline: false }
        ])
        .setTimestamp()
        .setFooter({ text: 'VietForex Test System' });

    await interaction.reply({ embeds: [testEmbed] });
}

// Tạo signal embed
function createSignalEmbed(signalData) {
    const { signal, pair, confidence, entry_price, stop_loss, take_profit, risk_reward_ratio, validation_score } = signalData;
    
    const color = signal === 'BUY' ? 0x00FF00 : 0xFF0000;
    const emoji = signal === 'BUY' ? '🟢📈' : '🔴📉';
    const stars = '⭐'.repeat(Math.min(5, Math.floor(confidence * 5)));
    const scoreEmoji = validation_score >= 80 ? '🏆' : validation_score >= 60 ? '🥇' : '🥈';
    
    return new EmbedBuilder()
        .setTitle(`🎯 VietForex Premium Signal`)
        .setDescription(`${emoji} **${signal} ${pair}**`)
        .setColor(color)
        .addFields([
            { name: '📊 Signal Details', value: `**Direction**: ${signal}\n**Confidence**: ${(confidence * 100).toFixed(1)}% ${stars}\n**Quality**: ${scoreEmoji} ${validation_score}/100`, inline: false },
            { name: '💰 Trading Levels', value: `**Entry**: ${entry_price}\n**Stop Loss**: ${stop_loss}\n**Take Profit**: ${take_profit}`, inline: true },
            { name: '📈 Risk Management', value: `**R:R Ratio**: 1:${risk_reward_ratio}\n**Risk**: ${signalData.risk_pips} pips\n**Reward**: ${signalData.reward_pips} pips`, inline: true },
            { name: '🔬 Technical Info', value: `**Platform**: Google Colab\n**Model**: AI Ensemble Demo\n**Signal ID**: \`${signalData.signal_id}\``, inline: false }
        ])
        .setTimestamp()
        .setFooter({ text: 'VietForex AI System (Colab Demo)' });
}

// Khởi động bot
async function startBot() {
    try {
        console.log('🔑 Đang đăng nhập Discord...');
        await client.login(config.discord.token);
    } catch (error) {
        console.error('❌ Lỗi đăng nhập bot:', error);
        console.log('🔍 Hãy kiểm tra Bot Token trong config.js');
        console.log('📋 Cần: 1) Bot Token từ Discord Developer Portal, 2) Server ID từ Discord');
    }
}

// Error handling
process.on('unhandledRejection', error => {
    console.error('❌ Promise rejection:', error);
});

// Start bot!
console.log('⚡ Bắt đầu khởi động...');
startBot();
