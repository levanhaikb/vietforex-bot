# Data Processor for VietForex
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
