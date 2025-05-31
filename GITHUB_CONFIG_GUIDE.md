# GitHub Configuration Guide

## ⚠️ CẦN THAY ĐỔI THÔNG TIN NÀY

### 1. Thay đổi Git config:
```bash
git config user.name "TÊN_GITHUB_CỦA_BẠN"
git config user.email "EMAIL_GITHUB_CỦA_BẠN"
```

### 2. Thay đổi remote URL:
```bash
git remote set-url origin https://github.com/USERNAME_CỦA_BẠN/vietforex-bot.git
```

### 3. Lưu GitHub token:
- Tạo file: github_token.txt
- Paste token vào file này
- Hoặc nhớ token để nhập khi push

### 4. Test push:
```python
exec(open('github_push_test.py').read())
```

---
*File được tạo tự động - cần cập nhật thông tin*
