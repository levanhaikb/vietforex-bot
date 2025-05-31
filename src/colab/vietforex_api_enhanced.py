# VietForex API Enhanced Client - Day 8-9 Completion
import requests
import json
import base64
import pandas as pd
import numpy as np
from typing import Dict, Any, Optional, List, Union
import time
from datetime import datetime, timedelta
import logging

class VietForexAPIEnhanced:
    """Enhanced VietForex API Client"""

    def __init__(self, base_url: str = "http://145.79.13.123:3000", 
                 api_key: str = "VietForex_API_Key_2024"):
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "User-Agent": "VietForex-Enhanced-Client/1.0"
        })
        
        print(f"🚀 VietForex Enhanced API Client khởi tạo")

    def health_check_enhanced(self) -> Dict[str, Any]:
        """Enhanced health check"""
        try:
            response = self.session.get(f"{self.base_url}/api/health", timeout=10)
            health_data = response.json()
            print(f"✅ API Health: {health_data.get('status', 'unknown')}")
            return health_data
        except Exception as e:
            print(f"❌ API Health Check Failed: {str(e)}")
            return {"error": str(e), "status": "failed"}

def create_enhanced_api() -> VietForexAPIEnhanced:
    """Create enhanced API client"""
    return VietForexAPIEnhanced()

print("✅ VietForex Enhanced API Client loaded!")
