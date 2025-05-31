# End of Day Sync - With GitHub Push
import os
import json
import subprocess
from datetime import datetime

def ket_thuc_ngay_voi_github():
    """Kết thúc ngày với GitHub push tự động"""
    print(f"🌙 KẾT THÚC NGÀY {datetime.now().strftime('%d/%m/%Y %H:%M')}")
    print("=" * 50)
    
    # 1. Tạo báo cáo
    tao_bao_cao()
    
    # 2. Tạo project status  
    tao_project_status()
    
    # 3. Git commit
    git_commit()
    
    # 4. Push lên GitHub
    push_github()
    
    print("✅ HOÀN THÀNH BACKUP!")
    
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
    
    # Test API
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
# Sáng
exec(open('src/colab/daily_setup.py').read())

# Tối (với GitHub push)
exec(open('src/colab/end_of_day_sync.py').read())
```

## 💡 Cho chat mới:
```
VietForex Bot:
📁 {current_dir}
🌐 http://145.79.13.123:3000
📊 {api_status}
```

---
*Auto-generated: {current_time.strftime('%d/%m/%Y %H:%M')}*
"""
    
    try:
        with open('project_status.md', 'w', encoding='utf-8') as f:
            f.write(status_content)
        print("✅ project_status.md")
    except Exception as e:
        print(f"⚠️ Lỗi tạo status: {e}")

def git_commit():
    """Git commit local"""
    print("💾 Git commit...")
    
    try:
        subprocess.run(['git', 'add', '.'], check=True)
        commit_msg = f"🤖 Auto backup - {datetime.now().strftime('%d/%m/%Y %H:%M')}"
        subprocess.run(['git', 'commit', '-m', commit_msg], check=True)
        print("✅ Đã commit local")
    except subprocess.CalledProcessError as e:
        if 'nothing to commit' in str(e):
            print("ℹ️ Không có gì để commit")
        else:
            print(f"⚠️ Git commit: {e}")

def push_github():
    """Push lên GitHub với token"""
    print("🚀 Push lên GitHub...")
    
    # Thử đọc token
    token = None
    if os.path.exists('github_token.txt'):
        try:
            with open('github_token.txt', 'r') as f:
                token = f.read().strip()
        except:
            pass
    
    if not token:
        print("❌ Không có GitHub token")
        print("💡 Cần tạo file github_token.txt với Personal Access Token")
        print("📋 Hoặc chạy: exec(open('github_push_with_token.py').read())")
        return False
    
    try:
        # Get current remote
        result = subprocess.run(['git', 'remote', 'get-url', 'origin'], 
                               capture_output=True, text=True, check=True)
        original_url = result.stdout.strip()
        
        if 'github.com' in original_url and original_url.startswith('https://github.com/'):
            # Parse URL
            parts = original_url.replace('https://github.com/', '').replace('.git', '').split('/')
            username = parts[0]  
            repo = parts[1]
            
            # Create auth URL
            auth_url = f"https://{token}@github.com/{username}/{repo}.git"
            
            # Set auth URL
            subprocess.run(['git', 'remote', 'set-url', 'origin', auth_url], check=True)
            
            # Push
            subprocess.run(['git', 'push', 'origin', 'main'], check=True)
            
            # Restore original URL
            subprocess.run(['git', 'remote', 'set-url', 'origin', original_url], check=True)
            
            print("✅ Đã push lên GitHub thành công!")
            return True
        else:
            print("❌ Remote URL không hợp lệ")
            return False
            
    except Exception as e:
        print(f"❌ Lỗi push GitHub: {e}")
        print("💡 Cần kiểm tra:")
        print("   1. GitHub token đúng không")
        print("   2. Repository URL đúng không")  
        print("   3. Có quyền push không")
        return False

# Chạy version mới
if __name__ == "__main__":
    ket_thuc_ngay_voi_github()
else:
    ket_thuc_ngay_voi_github()
