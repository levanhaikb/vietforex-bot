# File: src/colab/end_of_day_sync.py - Phiên bản đơn giản
import os
import subprocess
from datetime import datetime
import json

def ket_thuc_ngay_don_gian():
    """Kết thúc ngày phiên bản đơn giản - chỉ backup local"""
    
    print(f"🌙 KẾT THÚC NGÀY {datetime.now().strftime('%d/%m/%Y %H:%M')}")
    print("=" * 50)
    
    # 1. Tạo báo cáo
    tao_bao_cao_ngay()
    
    # 2. Tạo file trạng thái
    tao_project_status()
    
    # 3. Git commit local (không push)
    git_commit_local()
    
    print("✅ HOÀN THÀNH BACKUP LOCAL!")
    print("💡 Để push GitHub: cần setup authentication")
    
    return True

def tao_bao_cao_ngay():
    """Tạo báo cáo ngày"""
    print("📊 Tạo báo cáo...")
    
    report = {
        "date": datetime.now().strftime('%Y-%m-%d'),
        "time": datetime.now().strftime('%H:%M:%S'),
        "status": "completed",
        "activities": [
            "✅ Kiểm tra VietForex API",
            "📊 Test tín hiệu trading", 
            "💾 Backup code local"
        ]
    }
    
    # Tạo thư mục logs
    if not os.path.exists('logs'):
        os.makedirs('logs')
    
    report_file = f"logs/daily_report_{report['date']}.json"
    
    try:
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        print(f"✅ Báo cáo: {report_file}")
    except Exception as e:
        print(f"⚠️ Lỗi tạo báo cáo: {e}")

def tao_project_status():
    """Tạo file trạng thái dự án"""
    print("📋 Tạo file trạng thái...")
    
    current_time = datetime.now()
    current_dir = os.getcwd()
    
    # Test API
    api_status = "❌ Chưa test"
    try:
        from src.colab.vietforex_api import VietForexAPI
        api = VietForexAPI("http://145.79.13.123:3000")
        health = api.health_check()
        if health.get('status') == 'healthy':
            api_status = "✅ Hoạt động tốt"
    except:
        api_status = "⚠️ Cần kiểm tra"
    
    status_md = f"""# VietForex Bot - Trạng thái Dự án

## 📅 Cập nhật: {current_time.strftime('%d/%m/%Y %H:%M')}

## 🏠 Thông tin cơ bản:
- **Thư mục**: `{current_dir}`
- **API Server**: `http://145.79.13.123:3000`
- **Trạng thái API**: {api_status}

## 🔄 Lệnh hàng ngày:
```python
# Bắt đầu ngày
exec(open('src/colab/daily_setup.py').read())

# Kiểm tra
exec(open('src/colab/test_and_validate.py').read())

# Kết thúc ngày  
exec(open('src/colab/end_of_day_sync.py').read())
```

## 🎯 Tính năng hoạt động:
- ✅ API connection
- ✅ Signal generation
- ✅ Health monitoring
- ✅ Local backup

## 💡 Cho chat mới:
```
Xin chào! VietForex Bot project:
📁 {current_dir}  
🌐 API: http://145.79.13.123:3000
📊 Status: {api_status}
```
"""
    
    try:
        with open('project_status.md', 'w', encoding='utf-8') as f:
            f.write(status_md)
        print("✅ project_status.md")
        
        # JSON version
        status_json = {
            "update_time": current_time.isoformat(),
            "project_path": current_dir,
            "api_server": "http://145.79.13.123:3000",
            "api_status": api_status,
            "commands": {
                "morning": "exec(open('src/colab/daily_setup.py').read())",
                "check": "exec(open('src/colab/test_and_validate.py').read())", 
                "evening": "exec(open('src/colab/end_of_day_sync.py').read())"
            }
        }
        
        with open('project_status.json', 'w', encoding='utf-8') as f:
            json.dump(status_json, f, ensure_ascii=False, indent=2)
        print("✅ project_status.json")
        
    except Exception as e:
        print(f"⚠️ Lỗi tạo status: {e}")

def git_commit_local():
    """Git commit chỉ local, không push"""
    print("💾 Git commit local...")
    
    try:
        # Add files
        subprocess.run(['git', 'add', '.'], check=True)
        
        # Commit
        commit_msg = f"💾 Local backup - {datetime.now().strftime('%d/%m/%Y %H:%M')}"
        subprocess.run(['git', 'commit', '-m', commit_msg], check=True)
        print("✅ Đã commit local")
        
        # Hiển thị status
        result = subprocess.run(['git', 'log', '--oneline', '-3'], 
                               capture_output=True, text=True, check=True)
        print("📝 3 commit gần nhất:")
        print(result.stdout)
        
    except subprocess.CalledProcessError as e:
        if 'nothing to commit' in str(e):
            print("ℹ️ Không có gì để commit")
        else:
            print(f"⚠️ Git commit: {e}")
    except Exception as e:
        print(f"⚠️ Git error: {e}")

# Chạy version đơn giản
if __name__ == "__main__":
    ket_thuc_ngay_don_gian()

# Function để chạy trực tiếp
ket_thuc_ngay_don_gian()
