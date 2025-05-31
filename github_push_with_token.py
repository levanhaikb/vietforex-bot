# Auto Push Script với GitHub Token
import os
import subprocess
from datetime import datetime

def push_voi_token():
    """Push lên GitHub sử dụng Personal Access Token"""
    
    print("🚀 AUTO PUSH LÊN GITHUB")
    print("=" * 30)
    
    # Đọc token từ file hoặc nhập thủ công
    token = doc_github_token()
    
    if not token:
        print("❌ Không có GitHub token")
        print("💡 Cần tạo file github_token.txt với token")
        return False
    
    try:
        # Get current remote URL
        result = subprocess.run(['git', 'remote', 'get-url', 'origin'], 
                               capture_output=True, text=True, check=True)
        original_url = result.stdout.strip()
        
        # Create authenticated URL
        if 'github.com' in original_url:
            if original_url.startswith('https://github.com/'):
                # Extract username/repo from URL
                parts = original_url.replace('https://github.com/', '').split('/')
                username = parts[0]
                repo = parts[1]
                
                # Create token URL
                auth_url = f"https://{token}@github.com/{username}/{repo}.git"
                
                # Temporarily change remote URL
                subprocess.run(['git', 'remote', 'set-url', 'origin', auth_url], check=True)
                
                # Push
                result = subprocess.run(['git', 'push', 'origin', 'main'], 
                                       capture_output=True, text=True, check=True)
                
                # Restore original URL (security)
                subprocess.run(['git', 'remote', 'set-url', 'origin', original_url], check=True)
                
                print("✅ Push thành công lên GitHub!")
                print(f"📝 Commit mới nhất đã được đẩy lên")
                return True
                
        else:
            print("❌ URL không phải GitHub")
            return False
            
    except subprocess.CalledProcessError as e:
        print(f"❌ Lỗi push: {e}")
        
        # Restore original URL if error
        try:
            subprocess.run(['git', 'remote', 'set-url', 'origin', original_url], check=True)
        except:
            pass
            
        return False
    except Exception as e:
        print(f"❌ Lỗi khác: {e}")
        return False

def doc_github_token():
    """Đọc GitHub token từ file"""
    token_file = "github_token.txt"
    
    if os.path.exists(token_file):
        try:
            with open(token_file, 'r') as f:
                token = f.read().strip()
            if token and len(token) > 10:
                print("✅ Đã đọc GitHub token")
                return token
        except Exception as e:
            print(f"⚠️ Lỗi đọc token: {e}")
    
    print("⚠️ Không tìm thấy github_token.txt")
    return None

# Chạy push
if __name__ == "__main__":
    push_voi_token()
else:
    push_voi_token()
