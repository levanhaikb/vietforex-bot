# File: src/colab/test_and_validate.py
import os
import sys
import pandas as pd
import numpy as np
from datetime import datetime
import json

def kiem_tra_moi_truong():
    """Kiểm tra môi trường làm việc"""
    print("🔍 KIỂM TRA MÔI TRƯỜNG LÀM VIỆC")
    print("=" * 50)
    
    # Kiểm tra thư mục hiện tại
    current_dir = os.getcwd()
    print(f"📁 Thư mục hiện tại: {current_dir}")
    
    # Kiểm tra cấu trúc thư mục
    expected_dirs = ['src', 'src/colab', 'data', 'models']
    for dir_name in expected_dirs:
        if os.path.exists(dir_name):
            print(f"✅ {dir_name} - Có")
        else:
            print(f"❌ {dir_name} - Không có")
            try:
                os.makedirs(dir_name, exist_ok=True)
                print(f"📁 Đã tạo thư mục: {dir_name}")
            except Exception as e:
                print(f"⚠️ Không thể tạo {dir_name}: {e}")
    
    # Kiểm tra các file quan trọng
    expected_files = [
        'src/colab/vietforex_api.py',
        'src/colab/data_processor.py',
        'src/colab/daily_setup.py'
    ]
    
    for file_path in expected_files:
        if os.path.exists(file_path):
            print(f"✅ {file_path} - Có")
        else:
            print(f"❌ {file_path} - Không có")
    
    return True

def kiem_tra_api_connection():
    """Kiểm tra kết nối API"""
    print("\n🌐 KIỂM TRA KẾT NỐI API")
    print("=" * 30)
    
    try:
        from src.colab.vietforex_api import VietForexAPI
        
        api = VietForexAPI("http://145.79.13.123:3000")
        
        # Kiểm tra health
        health = api.health_check()
        
        if health.get('status') == 'healthy':
            print("✅ API Server hoạt động bình thường")
            
            # Test tạo tín hiệu
            print("\n📊 Test tạo tín hiệu...")
            signal = api.generate_signal("EURUSD")
            
            if signal.get('success'):
                print("✅ Tạo tín hiệu thành công")
                return True
            else:
                print("⚠️ Tạo tín hiệu có vấn đề")
                return False
        else:
            print("❌ API Server không hoạt động")
            return False
            
    except Exception as e:
        print(f"❌ Lỗi kiểm tra API: {e}")
        return False

def chay_nhanh():
    """Chạy kiểm tra nhanh"""
    print("⚡ KIỂM TRA NHANH HỆ THỐNG")
    print("=" * 35)
    
    # Kiểm tra API
    api_ok = kiem_tra_api_connection()
    
    if api_ok:
        print("\n✅ HỆ THỐNG HOẠT ĐỘNG TỐT!")
        print("🚀 Có thể bắt đầu trading!")
        
        # Hiển thị một số thông tin hữu ích
        print("\n📋 CÁC LỆNH HỮU ÍCH:")
        print("1. Tạo tín hiệu: api.generate_signal('EURUSD')")
        print("2. Xem lịch sử: api.get_signals_history()")
        print("3. Phân tích hiệu suất: api.get_performance_analytics()")
        
    else:
        print("\n❌ HỆ THỐNG CÓ VẤN ĐỀ!")
        print("🔧 Cần kiểm tra lại cấu hình")
    
    return api_ok

# Chạy kiểm tra nhanh khi file được load
if __name__ == "__main__":
    chay_nhanh()
else:
    chay_nhanh()
