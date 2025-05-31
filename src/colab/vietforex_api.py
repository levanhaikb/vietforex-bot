# VietForex API Client for Google Colab
import requests
import json
import base64
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
            payload = {"pair": pair.upper(), "signal_type": "auto"}
            response = self.session.post(f"{self.base_url}/api/signals/generate", json=payload)
            response.raise_for_status()
            signal_data = response.json()
            
            if signal_data.get('success'):
                print(f"🎯 Tín hiệu: {signal_data['signal']} {signal_data['pair']}")
                print(f"💰 Entry: {signal_data['entry_price']}")
                
            return signal_data
        except Exception as e:
            print(f"❌ Tạo tín hiệu thất bại: {str(e)}")
            return {"error": str(e), "success": False}
