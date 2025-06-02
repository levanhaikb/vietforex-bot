const { Client, GatewayIntentBits, EmbedBuilder } = require('discord.js');
const QuanLyDatabase = require('../database/quan-ly-database');
const moment = require('moment-timezone');

moment.tz.setDefault('Asia/Ho_Chi_Minh');

class BotVietForexNangCao {
    constructor() {
        this.client = new Client({
            intents: [
                GatewayIntentBits.Guilds,
                GatewayIntentBits.GuildMessages,
                GatewayIntentBits.MessageContent
            ]
        });
        
        this.db = new QuanLyDatabase();
        this.kenhTinHieu = '1378299763429441566'; // Channel ID từ hệ thống cũ
        
        this.thieLapSuKien();
        console.log('🤖 Bot VietForex Nâng Cao đã được khởi tạo');
    }
    
    thieLapSuKien() {
        this.client.on('ready', () => {
            console.log(`✅ ${this.client.user.tag} đã online!`);
            this.client.user.setActivity('🎯 Tín hiệu VietForex', { type: 'WATCHING' });
        });
        
        this.client.on('messageCreate', async (message) => {
            if (message.author.bot) return;
            
            this.db.themNguoiDung(message.author.id, message.author.username);
            await this.xuLyLenh(message);
        });
    }
    
    async xuLyLenh(message) {
        const noiDung = message.content.toLowerCase();
        
        if (noiDung.startsWith('!trogiup')) {
            await this.hienThiTroGiup(message);
        } else if (noiDung.startsWith('!ping')) {
            await this.kiemTraKetNoi(message);
        }
    }
    
    async hienThiTroGiup(message) {
        const embed = new EmbedBuilder()
            .setTitle('🤖 Hướng Dẫn Sử Dụng Bot VietForex')
            .setColor(0x800080)
            .setDescription('Các lệnh có sẵn cho Bot Trading VietForex')
            .addFields(
                { name: '!ping', value: '🏓 Kiểm tra kết nối bot', inline: true },
                { name: '!trogiup', value: '❓ Hiển thị tin nhắn này', inline: true }
            )
            .setFooter({ text: '💼 VietForex - Bot Trading Chuyên Nghiệp' })
            .setTimestamp();
        
        await message.reply({ embeds: [embed] });
    }
    
    async kiemTraKetNoi(message) {
        const embed = new EmbedBuilder()
            .setTitle('🏓 Ping - Kiểm Tra Kết Nối')
            .setColor(0x00FF00)
            .addFields(
                { name: '🕐 Múi giờ', value: moment().format('DD/MM/YYYY HH:mm:ss'), inline: true },
                { name: '📊 Trạng thái', value: '🟢 HOẠT ĐỘNG', inline: true }
            )
            .setFooter({ text: 'VietForex Bot - Made in Vietnam 🇻🇳' })
            .setTimestamp();
        
        await message.reply({ embeds: [embed] });
    }
    
    async guiTinHieu(duLieuTinHieu) {
        try {
            this.db.luuTinHieu(duLieuTinHieu);
            
            const kenh = this.client.channels.cache.get(this.kenhTinHieu);
            if (!kenh) {
                console.error('❌ Không tìm thấy kênh tín hiệu');
                return false;
            }
            
            const embed = this.taoEmbedTinHieu(duLieuTinHieu);
            await kenh.send({ embeds: [embed] });
            
            console.log(`✅ Đã gửi tín hiệu: ${duLieuTinHieu.huong} ${duLieuTinHieu.cap_tien_te}`);
            return true;
            
        } catch (loi) {
            console.error('❌ Lỗi khi gửi tín hiệu:', loi);
            return false;
        }
    }
    
    taoEmbedTinHieu(duLieuTinHieu) {
        const bieuTuongHuong = duLieuTinHieu.huong === 'MUA' ? '🟢' : '🔴';
        const mauSac = duLieuTinHieu.huong === 'MUA' ? 0x00FF00 : 0xFF0000;
        
        return new EmbedBuilder()
            .setTitle(`${bieuTuongHuong} TÍN HIỆU ${duLieuTinHieu.huong} ${duLieuTinHieu.cap_tien_te}`)
            .setColor(mauSac)
            .addFields(
                { name: '💰 Giá vào', value: duLieuTinHieu.gia_vao.toString(), inline: true },
                { name: '🛑 Cắt lỗ', value: duLieuTinHieu.cat_lo.toString(), inline: true },
                { name: '🎯 Lấy lãi', value: duLieuTinHieu.lay_lai.toString(), inline: true },
                { name: '📊 Độ tin cậy', value: `${duLieuTinHieu.do_tin_cay}%`, inline: true }
            )
            .setFooter({ text: '⚡ VietForex AI Trading System 🇻🇳' })
            .setTimestamp();
    }
    
    async batDau() {
        try {
            await this.client.login(process.env.DISCORD_BOT_TOKEN);
            console.log('✅ Bot Discord đã đăng nhập thành công');
        } catch (loi) {
            console.error('❌ Không thể đăng nhập Bot Discord:', loi);
        }
    }
}

module.exports = BotVietForexNangCao;
