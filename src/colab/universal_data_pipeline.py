# Universal Data Pipeline - Day 8-9
import pandas as pd
import numpy as np
from typing import Dict, List, Tuple, Optional, Any, Union
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')

class UniversalDataPipeline:
    """Universal Data Processing Pipeline"""
    
    def __init__(self):
        print("🚀 Universal Data Pipeline khởi tạo")

    def process_pair_data(self, pair: str, timeframe: str, data: Union[pd.DataFrame, List[Dict]], 
                         data_source: str = 'Manual', include_regime: bool = True, 
                         validate_leakage: bool = True) -> Dict:
        """Main processing function"""
        
        try:
            print(f"🔄 Processing {pair} {timeframe}...")
            
            # Convert to DataFrame if needed
            if isinstance(data, list):
                df = pd.DataFrame(data)
            else:
                df = data.copy()
            
            # Basic cleaning
            df = df.dropna()
            
            # Add basic features
            if 'close' in df.columns:
                df['returns'] = df['close'].pct_change()
                df['sma_20'] = df['close'].rolling(20).mean()
            
            result = {
                'success': True,
                'processed_data': df,
                'pair': pair,
                'timeframe': timeframe
            }
            
            print(f"✅ Processing completed: {len(df)} records")
            return result
            
        except Exception as e:
            print(f"❌ Processing error: {e}")
            return {'success': False, 'error': str(e)}

def create_pipeline() -> UniversalDataPipeline:
    """Create pipeline"""
    return UniversalDataPipeline()

print("🚀 Universal Data Pipeline loaded!")
