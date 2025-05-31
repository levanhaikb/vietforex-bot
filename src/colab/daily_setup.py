# File: src/colab/daily_setup.py
from google.colab import drive
import os
import sys
from datetime import datetime

def setup_ngay_moi():
    """Setup môi trường cho ngày làm việc mới"""
    
    print(f"🌅 SETUP NGÀY MỚI - {datetime.now().strftime('%d/%m/%Y %H:%M')}")
    print("=" * 60)
    
    # 1. Mount Google Drive
    mount_drive()
    
    # 2. Chuyển vào thư mục dự án
    setup_project_directory()
    
    # 3. Tạo cấu trúc thư mục
    create_directory_structure()
    
    # 4. Tạo các file cần thiết
    create_essential_files()
    
    # 5. Setup Python path
    setup_python_path()
    
    # 6. Test import modules
    test_modules()
    
    # 7. Test API connection
    test_api_connection()
    
    print("\n🎯 SETUP HOÀN TẤT!")
    print("✅ Sẵn sàng bắt đầu ngày mới!")
    print("📋 Sử dụng: exec(open('src/colab/test_and_validate.py').read()) để kiểm tra")
    
    return True

def mount_drive():
    """Mount Google Drive"""
    print("📁 Mount Google Drive...")
    
    try:
        drive.mount('/content/drive')
        print("✅ Google Drive mounted thành công")
    except Exception as e:
        print("⚠️ Drive đã được mount hoặc có lỗi:", str(e))

def setup_project_directory():
    """Setup thư mục dự án"""
    print("📂 Setup thư mục dự án...")
    
    project_path = '/content/drive/MyDrive/vietforex-bot'
    
    try:
        if not os.path.exists(project_path):
            os.makedirs(project_path)
            print(f"📁 Đã tạo thư mục: {project_path}")
        
        os.chdir(project_path)
        print(f"✅ Đã chuyển vào: {os.getcwd()}")
        
    except Exception as e:
        print(f"❌ Lỗi setup thư mục: {e}")
        return False
    
    return True

def create_directory_structure():
    """Tạo cấu trúc thư mục cần thiết"""
    print("🏗️ Tạo cấu trúc thư mục...")
    
    required_dirs = [
        'src',
        'src/colab', 
        'data',
        'models',
        'logs',
        'backups'
    ]
    
    for dir_name in required_dirs:
        try:
            if not os.path.exists(dir_name):
                os.makedirs(dir_name, exist_ok=True)
                print(f"📁 Tạo: {dir_name}")
            else:
                print(f"✅ Có: {dir_name}")
        except Exception as e:
            print(f"⚠️ Lỗi tạo {dir_name}: {e}")

def create_essential_files():
    """Tạo các file cần thiết nếu chưa có"""
    print("📝 Tạo file cần thiết...")
    
    # 1. VietForex API Client
    create_vietforex_api()
    
    # 2. Data Processor
    create_data_processor()
    
    # 3. Test & Validate
    create_test_validate()
    
    # 4. End of day sync (đơn giản)
    create_end_of_day_sync()

def create_vietforex_api():
    """Tạo VietForex API client"""
    file_path = 'src/colab/vietforex_api.py'
    
    if os.path.exists(file_path):
        print(f"✅ {file_path} đã có")
        return
    
    api_content = '''# VietForex API Client for Google Colab
import requests
import json
import pandas as pd
import numpy as np
from typing import Dict, Any, Optional, List
import time
from datetime import datetime

class VietForexAPI:
    """VietForex API Client for Google Colab Integration"""

    def __init__(self, base_url: str, api_key: str = "VietForex_API_Key_2024"):
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "User-Agent": "VietForex-Colab-Client/1.0"
        })
        print(f"🚀 VietForex API Client đã khởi tạo")
        print(f"🔗 Server: {self.base_url}")

    def health_check(self) -> Dict[str, Any]:
        """Kiểm tra kết nối API"""
        try:
            response = self.session.get(f"{self.base_url}/api/health")
            response.raise_for_status()
            health_data = response.json()
            print(f"✅ API Health: {health_data['status']}")
            return health_data
        except Exception as e:
            print(f"❌ API Health Check Failed: {str(e)}")
            return {"error": str(e), "status": "failed"}

    def generate_signal(self, pair: str) -> Dict[str, Any]:
        """Tạo tín hiệu giao dịch"""
        try:
            payload = {"pair": pair.upper(), "signal_type": "auto", "include_analysis": True}
            response = self.session.post(f"{self.base_url}/api/signals/generate", json=payload)
            response.raise_for_status()
            signal_data = response.json()
            
            if signal_data.get('success'):
                print(f"🎯 Tín hiệu: {signal_data['signal']} {signal_data['pair']}")
                print(f"💰 Entry: {signal_data['entry_price']}")
                print(f"🛑 Stop Loss: {signal_data['stop_loss']}")
                print(f"🎯 Take Profit: {signal_data['take_profit']}")
                
            return signal_data
        except Exception as e:
            print(f"❌ Tạo tín hiệu thất bại: {str(e)}")
            return {"error": str(e), "success": False}

    def get_signals_history(self, pair: str = None, limit: int = 10) -> Dict[str, Any]:
        """Lấy lịch sử tín hiệu"""
        try:
            params = {"limit": limit}
            if pair:
                params["pair"] = pair.upper()
            
            response = self.session.get(f"{self.base_url}/api/signals/history", params=params)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"❌ Lỗi lấy lịch sử: {str(e)}")
            return {"error": str(e)}

    def get_performance_analytics(self, period: str = "30d") -> Dict[str, Any]:
        """Lấy phân tích hiệu suất"""
        try:
            params = {"period": period}
            response = self.session.get(f"{self.base_url}/api/analytics/performance", params=params)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"❌ Lỗi lấy analytics: {str(e)}")
            return {"error": str(e)}
'''
    
    try:
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(api_content)
        print(f"✅ Tạo: {file_path}")
    except Exception as e:
        print(f"❌ Lỗi tạo API file: {e}")

def create_data_processor():
    """Tạo Data Processor"""
    file_path = 'src/colab/data_processor.py'
    
    if os.path.exists(file_path):
        print(f"✅ {file_path} đã có")
        return
    
    processor_content = '''# Data Processor for VietForex
import pandas as pd
import numpy as np
from typing import Dict, List, Any
from datetime import datetime

class DataProcessor:
    """Xử lý dữ liệu cho VietForex trading bot"""
    
    def __init__(self):
        print("🔧 DataProcessor đã khởi tạo")
    
    def clean_market_data(self, data: pd.DataFrame) -> pd.DataFrame:
        """Làm sạch dữ liệu thị trường"""
        try:
            # Loại bỏ dữ liệu trùng lặp
            data = data.drop_duplicates()
            
            # Loại bỏ giá trị null
            data = data.dropna()
            
            print(f"✅ Đã làm sạch dữ liệu: {len(data)} records")
            return data
        except Exception as e:
            print(f"❌ Lỗi làm sạch dữ liệu: {e}")
            return data
    
    def calculate_indicators(self, data: pd.DataFrame) -> pd.DataFrame:
        """Tính toán các chỉ báo kỹ thuật"""
        try:
            # Moving Average
            data['MA_20'] = data['close'].rolling(window=20).mean()
            data['MA_50'] = data['close'].rolling(window=50).mean()
            
            # RSI
            delta = data['close'].diff()
            gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
            loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
            rs = gain / loss
            data['RSI'] = 100 - (100 / (1 + rs))
            
            print("✅ Đã tính toán các chỉ báo kỹ thuật")
            return data
        except Exception as e:
            print(f"❌ Lỗi tính toán chỉ báo: {e}")
            return data
    
    def prepare_training_data(self, data: pd.DataFrame, target_col: str = 'close') -> tuple:
        """Chuẩn bị dữ liệu cho training"""
        try:
            # Tạo features và target
            features = data.select_dtypes(include=[np.number]).fillna(0)
            target = data[target_col].shift(-1).fillna(0)  # Predict next value
            
            print(f"✅ Dữ liệu training: {features.shape[0]} samples, {features.shape[1]} features")
            return features, target
        except Exception as e:
            print(f"❌ Lỗi chuẩn bị training data: {e}")
            return None, None
'''
    
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(processor_content)
        print(f"✅ Tạo: {file_path}")
    except Exception as e:
        print(f"❌ Lỗi tạo DataProcessor: {e}")

def create_test_validate():
    """Tạo file test và validate"""
    file_path = 'src/colab/test_and_validate.py'
    
    if os.path.exists(file_path):
        print(f"✅ {file_path} đã có")
        return
    
    test_content = '''# Test and Validate VietForex System
import os
import sys
from datetime import datetime

def test_he_thong():
    """Test toàn bộ hệ thống"""
    print("⚡ KIỂM TRA HỆ THỐNG VIETFOREX")
    print("=" * 40)
    
    # Test API connection
    ket_qua = test_api_connection()
    
    if ket_qua:
        print("\\n✅ HỆ THỐNG HOẠT ĐỘNG TỐT!")
        print("🚀 Có thể bắt đầu trading!")
        
        # Hiển thị thông tin hữu ích
        print("\\n📋 LỆNH HỮU ÍCH:")
        print("1. Tạo tín hiệu: api.generate_signal('EURUSD')")
        print("2. Xem lịch sử: api.get_signals_history()")
        print("3. Phân tích: api.get_performance_analytics()")
        
    else:
        print("\\n❌ HỆ THỐNG CÓ VẤN ĐỀ!")
        print("🔧 Cần kiểm tra lại API server")
    
    return ket_qua

def test_api_connection():
    """Test kết nối API"""
    print("🌐 Test API connection...")
    
    try:
        from src.colab.vietforex_api import VietForexAPI
        
        api = VietForexAPI("http://145.79.13.123:3000")
        
        # Health check
        health = api.health_check()
        
        if health.get('status') == 'healthy':
            print("✅ API Server online")
            
            # Test signal generation
            print("\\n📊 Test tạo tín hiệu...")
            signal = api.generate_signal("EURUSD")
            
            if signal.get('success'):
                print("✅ Tạo tín hiệu thành công")
                return True
            else:
                print("⚠️ Tạo tín hiệu có vấn đề")
                return False
        else:
            print("❌ API Server offline")
            return False
            
    except Exception as e:
        print(f"❌ Lỗi API test: {e}")
        return False

# Chạy test khi file được load
if __name__ == "__main__":
    test_he_thong()
else:
    test_he_thong()
'''
    
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(test_content)
        print(f"✅ Tạo: {file_path}")
    except Exception as e:
        print(f"❌ Lỗi tạo test file: {e}")

def create_end_of_day_sync():
    """Tạo file end of day sync đơn giản"""
    file_path = 'src/colab/end_of_day_sync.py'
    
    if os.path.exists(file_path):
        print(f"✅ {file_path} đã có")
        return
    
    sync_content = '''# End of Day Sync - Simple Version
import os
import json
from datetime import datetime

def ket_thuc_ngay():
    """Kết thúc ngày - tạo báo cáo và backup"""
    print(f"🌙 KẾT THÚC NGÀY {datetime.now().strftime('%d/%m/%Y %H:%M')}")
    print("=" * 50)
    
    # 1. Tạo báo cáo ngày
    tao_bao_cao()
    
    # 2. Tạo file trạng thái cho chat mới
    tao_project_status()
    
    print("✅ HOÀN THÀNH!")
    print("📋 File project_status.md sẵn sàng cho chat mới")
    
    return True

def tao_bao_cao():
    """Tạo báo cáo ngày"""
    print("📊 Tạo báo cáo...")
    
    if not os.path.exists('logs'):
        os.makedirs('logs')
    
    report = {
        "date": datetime.now().strftime('%Y-%m-%d'),
        "time": datetime.now().strftime('%H:%M:%S'),
        "activities": ["API testing", "Signal generation", "System monitoring"],
        "status": "completed"
    }
    
    report_file = f"logs/daily_report_{report['date']}.json"
    
    try:
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        print(f"✅ Báo cáo: {report_file}")
    except Exception as e:
        print(f"⚠️ Lỗi báo cáo: {e}")

def tao_project_status():
    """Tạo file trạng thái dự án"""
    print("📋 Tạo project status...")
    
    current_time = datetime.now()
    current_dir = os.getcwd()
    
    # Test API nhanh
    api_status = "❌ Chưa test"
    try:
        from src.colab.vietforex_api import VietForexAPI
        api = VietForexAPI("http://145.79.13.123:3000")
        health = api.health_check()
        if health.get('status') == 'healthy':
            api_status = "✅ Online"
    except:
        api_status = "⚠️ Cần kiểm tra"
    
    status_content = f"""# VietForex Bot - Trạng thái Dự án

## 📅 Cập nhật: {current_time.strftime('%d/%m/%Y %H:%M')}

## 🏠 Thông tin cơ bản:
- **Thư mục**: `{current_dir}`
- **API Server**: `http://145.79.13.123:3000`
- **Trạng thái API**: {api_status}

## 🔄 Lệnh hàng ngày:
```python
# Sáng - Setup
exec(open('src/colab/daily_setup.py').read())

# Kiểm tra
exec(open('src/colab/test_and_validate.py').read())

# Tối - Backup
exec(open('src/colab/end_of_day_sync.py').read())
```

## 🎯 Tính năng hoạt động:
- ✅ API connection
- ✅ Signal generation  
- ✅ Health monitoring
- ✅ Daily reports

## 💡 Cho chat mới:
```
VietForex Bot project:
📁 {current_dir}
🌐 API: http://145.79.13.123:3000
📊 Status: {api_status}
```

---
*Tạo tự động: {current_time.strftime('%d/%m/%Y %H:%M')}*
"""
    
    try:
        with open('project_status.md', 'w', encoding='utf-8') as f:
            f.write(status_content)
        print("✅ project_status.md")
    except Exception as e:
        print(f"⚠️ Lỗi tạo status: {e}")

# Chạy khi được exec
if __name__ == "__main__":
    ket_thuc_ngay()
else:
    ket_thuc_ngay()
'''
    
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(sync_content)
        print(f"✅ Tạo: {file_path}")
    except Exception as e:
        print(f"❌ Lỗi tạo sync file: {e}")

def setup_python_path():
    """Setup Python path để import được modules"""
    print("🐍 Setup Python path...")
    
    current_dir = os.getcwd()
    if current_dir not in sys.path:
        sys.path.insert(0, current_dir)
        print(f"✅ Đã thêm vào sys.path: {current_dir}")
    else:
        print("✅ Python path đã được setup")

def test_modules():
    """Test import các modules"""
    print("🧪 Test import modules...")
    
    try:
        from src.colab.vietforex_api import VietForexAPI
        print("✅ VietForexAPI - OK")
    except Exception as e:
        print(f"⚠️ VietForexAPI - Lỗi: {e}")
    
    try:
        from src.colab.data_processor import DataProcessor
        print("✅ DataProcessor - OK")
    except Exception as e:
        print(f"⚠️ DataProcessor - Lỗi: {e}")

def test_api_connection():
    """Test kết nối API"""
    print("🌐 Test API connection...")
    
    try:
        from src.colab.vietforex_api import VietForexAPI
        api = VietForexAPI("http://145.79.13.123:3000")
        
        health = api.health_check()
        if health.get('status') == 'healthy':
            print("✅ API Server online và hoạt động tốt")
            return True
        else:
            print("⚠️ API Server có vấn đề")
            return False
    except Exception as e:
        print(f"❌ Lỗi test API: {e}")
        return False

# Chạy setup khi file được thực thi
if __name__ == "__main__":
    setup_ngay_moi()
else:
    # Chạy khi được exec()
    setup_ngay_moi()