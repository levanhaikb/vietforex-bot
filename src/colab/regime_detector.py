# Market Regime Detection System - Day 8-9
import pandas as pd
import numpy as np
from typing import Dict, List, Tuple, Optional
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')

class MarketRegimeDetector:
    """Market Regime Detection System"""
    
    def __init__(self):
        print("🧠 Market Regime Detector khởi tạo")

    def detect_regime(self, data: pd.DataFrame) -> Dict:
        """Simple regime detection"""
        try:
            if len(data) < 20:
                return {'regime': 'insufficient_data', 'confidence': 0.0}
            
            # Simple volatility-based regime detection
            df = data.tail(100).copy()
            df['returns'] = df['close'].pct_change()
            volatility = df['returns'].std()
            
            if volatility > 0.02:
                regime = 'volatile'
                confidence = 0.8
            elif volatility < 0.005:
                regime = 'sideways'
                confidence = 0.7
            else:
                regime = 'trending'
                confidence = 0.6
                
            result = {
                'regime': regime,
                'confidence': confidence,
                'volatility': volatility,
                'analysis_timestamp': datetime.now().isoformat()
            }
            
            print(f"📊 Regime: {regime} (confidence: {confidence:.2f})")
            return result
            
        except Exception as e:
            print(f"❌ Regime detection error: {e}")
            return {'regime': 'error', 'confidence': 0.0, 'error': str(e)}

def create_regime_detector() -> MarketRegimeDetector:
    """Create regime detector"""
    return MarketRegimeDetector()

print("🧠 Market Regime Detector loaded!")
