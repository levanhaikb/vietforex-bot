const express = require('express');
const BotVietForexNangCao = require('./bot-viet-nang-cao');

class WebhookViet {
    constructor() {
        this.app = express();
        this.port = 3002;
        this.bot = new BotVietForexNangCao();
        
        this.thietLapMiddleware();
        this.thietLapRoutes();
        
        console.log('🔗 Webhook tiếng Việt đã được khởi tạo');
    }
    
    thietLapMiddleware() {
        this.app.use(express.json());
        this.app.use(express.urlencoded({ extended: true }));
        
        // CORS cho dashboard
        this.app.use((req, res, next) => {
            res.header('Access-Control-Allow-Origin', '*');
            res.header('Access-Control-Allow-Headers', 'Content-Type');
            next();
        });
    }
    
    thietLapRoutes() {
        // Webhook nhận tín hiệu từ ML service
        this.app.post('/webhook/signal', async (req, res) => {
            try {
                const tinHieu = req.body;
                
                console.log(`📨 Nhận tín hiệu mới: ${tinHieu.huong} ${tinHieu.cap_tien_te}`);
                
                // Gửi tín hiệu đến Discord
                const daGui = await this.bot.guiTinHieu(tinHieu);
                
                if (daGui) {
                    res.json({
                        thanh_cong: true,
                        thong_bao: 'Đã gửi tín hiệu thành công',
                        ma_tin_hieu: tinHieu.ma_tin_hieu
                    });
                } else {
                    res.status(500).json({
                        thanh_cong: false,
                        thong_bao: 'Lỗi khi gửi tín hiệu đến Discord'
                    });
                }
                
            } catch (loi) {
                console.error('❌ Lỗi webhook:', loi);
                res.status(500).json({
                    thanh_cong: false,
                    loi: loi.message,
                    thong_bao: 'Lỗi xử lý webhook'
                });
            }
        });
        
        // Health check
        this.app.get('/health', (req, res) => {
            res.json({
                thanh_cong: true,
                trang_thai: 'HOẠT ĐỘNG',
                thoi_gian: new Date().toLocaleString('vi-VN', {
                    timeZone: 'Asia/Ho_Chi_Minh'
                }),
                phien_ban: '2.0.0',
                webhook: 'SẴN SÀNG',
                discord_bot: 'ONLINE'
            });
        });
        
        // Test webhook
        this.app.post('/webhook/test', async (req, res) => {
            const tinHieuTest = {
                ma_tin_hieu: 'TEST_' + Date.now(),
                cap_tien_te: 'EURUSD',
                huong: 'MUA',
                gia_vao: 1.0850,
                cat_lo: 1.0830,
                lay_lai: 1.0890,
                do_tin_cay: 85,
                risk_reward_ratio: 2.0
            };
            
            const daGui = await this.bot.guiTinHieu(tinHieuTest);
            
            res.json({
                thanh_cong: daGui,
                thong_bao: daGui ? 'Test tín hiệu đã được gửi' : 'Lỗi gửi test tín hiệu',
                tin_hieu_test: tinHieuTest
            });
        });
    }
    
    async batDau() {
        // Khởi động Discord bot
        await this.bot.batDau();
        
        // Khởi động webhook server
        this.app.listen(this.port, () => {
            console.log(`✅ Webhook server đang chạy trên port ${this.port}`);
            console.log(`🔗 Webhook URL: http://localhost:${this.port}/webhook/signal`);
            console.log(`🏥 Health check: http://localhost:${this.port}/health`);
        });
    }
}

// Khởi tạo và chạy
const webhook = new WebhookViet();
webhook.batDau();

module.exports = WebhookViet;
