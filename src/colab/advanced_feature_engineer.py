# Advanced Feature Engineering Module - Day 8-9
import pandas as pd
import numpy as np
from typing import Dict, List, Optional, Union
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

class AdvancedFeatureEngineer:
    """Advanced Feature Engineering"""
    
    def __init__(self):
        print("🔧 Advanced Feature Engineer khởi tạo")

    def engineer_comprehensive_features(self, df: pd.DataFrame, pair: str, 
                                      timeframe: str, feature_set: str = 'comprehensive') -> pd.DataFrame:
        """Main feature engineering function"""
        
        print(f"🔧 Engineering features cho {pair} {timeframe}...")
        
        enriched_df = df.copy()
        
        # Basic features
        if 'close' in enriched_df.columns:
            enriched_df['returns'] = enriched_df['close'].pct_change()
            enriched_df['log_returns'] = np.log(enriched_df['close'] / enriched_df['close'].shift(1))
            
        if 'high' in enriched_df.columns and 'low' in enriched_df.columns:
            enriched_df['price_range'] = enriched_df['high'] - enriched_df['low']
            
        # Moving averages
        periods = [5, 10, 20]
        for period in periods:
            if len(enriched_df) >= period and 'close' in enriched_df.columns:
                enriched_df[f'sma_{period}'] = enriched_df['close'].rolling(period).mean()
                enriched_df[f'ema_{period}'] = enriched_df['close'].ewm(span=period).mean()
        
        # RSI
        if len(enriched_df) >= 14 and 'close' in enriched_df.columns:
            delta = enriched_df['close'].diff()
            gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
            loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
            rs = gain / loss
            enriched_df['rsi'] = 100 - (100 / (1 + rs))
        
        # Clean infinite values
        enriched_df = enriched_df.replace([np.inf, -np.inf], np.nan)
        
        print(f"✅ Feature engineering completed: {len(enriched_df.columns)} features")
        return enriched_df

def create_feature_engineer() -> AdvancedFeatureEngineer:
    """Create feature engineer"""
    return AdvancedFeatureEngineer()

print("🔧 Advanced Feature Engineer loaded!")
