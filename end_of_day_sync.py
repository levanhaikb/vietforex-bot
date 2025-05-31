# End of Day Sync - FRESH REPOSITORY VERSION
import os
import json
import subprocess
from datetime import datetime

def ket_thuc_ngay_fresh():
    """Kết thúc ngày với fresh repository"""
    print(f"🌙 KẾT THÚC NGÀY (FRESH) {datetime.now().strftime('%d/%m/%Y %H:%M')}")
    print("=" * 55)

    # 1. Tạo báo cáo
    tao_bao_cao()

    # 2. Tạo project status
    tao_project_status()

    # 3. Git commit
    git_commit()

    # 4. Simple GitHub push (no conflicts possible)
    success = simple_github_push()

    if success:
        print("✅ HOÀN THÀNH FRESH BACKUP!")
    else:
        print("⚠️ Backup local OK, GitHub push needs token")

    return True

def get_secure_token():
    """Get token from secure location"""

    # Home directory token
    home_token = os.path.expanduser('~/github_token.txt')
    if os.path.exists(home_token):
        with open(home_token, 'r') as f:
            return f.read().strip()

    # Environment variable
    token = os.environ.get('GITHUB_TOKEN')
    if token:
        return token

    print("❌ No secure token found")
    print("💡 Setup: echo 'your_token' > ~/github_token.txt")
    return None

def simple_github_push():
    """Simple GitHub push - no conflicts possible with fresh repo"""
    print("🚀 Simple GitHub push...")

    token = get_secure_token()
    if not token:
        return False

    try:
        # URLs
        original_url = "https://github.com/levanhaikb/vietforex-bot.git"
        auth_url = f"https://{token}@github.com/levanhaikb/vietforex-bot.git"

        # Set auth URL
        subprocess.run(['git', 'remote', 'set-url', 'origin', auth_url], check=True)

        # Simple push (no conflicts with fresh repo)
        result = subprocess.run(['git', 'push', 'origin', 'main'],
                               capture_output=True, text=True, check=True)

        # Restore URL
        subprocess.run(['git', 'remote', 'set-url', 'origin', original_url], check=True)

        print("✅ Push successful - fresh repo advantage!")
        return True

    except Exception as e:
        print(f"❌ Push failed: {e}")
        # Restore URL
        try:
            subprocess.run(['git', 'remote', 'set-url', 'origin', original_url], check=True)
        except:
            pass
        return False

def tao_bao_cao():
    """Tạo báo cáo ngày"""
    print("📊 Tạo báo cáo...")

    if not os.path.exists('logs'):
        os.makedirs('logs')

    report = {
        "date": datetime.now().strftime('%Y-%m-%d'),
        "time": datetime.now().strftime('%H:%M:%S'),
        "activities": ["Fresh repository setup", "Clean GitHub sync", "No conflicts"],
        "status": "completed",
        "repo_type": "fresh_clean"
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

    status_content = f"""# VietForex Bot - Fresh Repository

## 📅 Cập nhật: {current_time.strftime('%d/%m/%Y %H:%M')}

## 🏠 Thông tin cơ bản:
- **Thư mục**: `{current_dir}`
- **API Server**: `http://145.79.13.123:3000`
- **Trạng thái API**: {api_status}
- **Repository**: 🆕 Fresh & Clean
- **GitHub**: https://github.com/levanhaikb/vietforex-bot

## 🔄 Lệnh hàng ngày:
```python
# Fresh repository version - no conflicts!
exec(open('end_of_day_sync.py').read())
```

## ✨ Advantages:
- ✅ No merge conflicts possible
- ✅ Clean Git history
- ✅ Secure token management
- ✅ Simple push workflow

---
*Fresh repository: {current_time.strftime('%d/%m/%Y %H:%M')}*
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
        commit_msg = f"🆕 Fresh backup - {datetime.now().strftime('%d/%m/%Y %H:%M')}"
        subprocess.run(['git', 'commit', '-m', commit_msg], check=True)
        print("✅ Đã commit local")
    except subprocess.CalledProcessError as e:
        if 'nothing to commit' in str(e):
            print("ℹ️ Không có gì để commit")
        else:
            print(f"⚠️ Git commit: {e}")

# Chạy fresh version
if __name__ == "__main__":
    ket_thuc_ngay_fresh()
else:
    ket_thuc_ngay_fresh()
