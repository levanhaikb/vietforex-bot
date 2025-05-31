# Day 10: EURUSD Historical Data Processing System
import pandas as pd
import numpy as np
import os
import json
from datetime import datetime, timedelta
from typing import Dict, List, Tuple, Optional
import warnings
warnings.filterwarnings('ignore')

class EURUSDHistoricalProcessor:
    """
    EURUSD Historical Data Processing System
    Processes 10 years of data với regime classification
    """
    
    def __init__(self):
        self.pair = "EURUSD"
        self.timeframes = ['M1', 'M5', 'M15', 'H1', 'H4', 'D1', 'W1']
        self.data_sources = ['Exness', 'MetaTrader', 'TradingView']
        
        # Processing statistics
        self.processing_stats = {
            'total_records_processed': 0,
            'timeframes_completed': 0,
            'regime_classifications': {},
            'data_quality_scores': {},
            'processing_time': {},
            'last_processed': None
        }
        
        # Load existing components
        self.api_client = None
        self.regime_detector = None
        self.data_pipeline = None
        self.feature_engineer = None
        
        print("📊 EURUSD Historical Data Processor khởi tạo")
        print(f"💱 Target pair: {self.pair}")
        print(f"⏰ Timeframes: {', '.join(self.timeframes)}")
    
    def initialize_components(self):
        """Initialize all required components"""
        print("🔧 Loading components...")
        
        try:
            # Load Enhanced API Client
            exec(open('src/colab/vietforex_api_enhanced.py').read())
            self.api_client = create_enhanced_api()
            print("✅ Enhanced API Client loaded")
            
            # Load Regime Detector
            exec(open('src/colab/regime_detector.py').read())
            self.regime_detector = create_regime_detector()
            print("✅ Regime Detector loaded")
            
            # Load Universal Pipeline
            exec(open('src/colab/universal_data_pipeline.py').read())
            self.data_pipeline = create_pipeline()
            print("✅ Universal Pipeline loaded")
            
            # Load Feature Engineer
            exec(open('src/colab/advanced_feature_engineer.py').read())
            self.feature_engineer = create_feature_engineer()
            print("✅ Advanced Feature Engineer loaded")
            
            return True
            
        except Exception as e:
            print(f"❌ Component loading error: {e}")
            return False
    
    def simulate_historical_data(self, timeframe: str, years: int = 10) -> pd.DataFrame:
        """
        Simulate realistic EURUSD historical data
        (In production, this would load from actual data sources)
        """
        print(f"📈 Generating {years}-year {timeframe} data simulation...")
        
        # Calculate number of periods based on timeframe
        periods_map = {
            'M1': years * 365 * 24 * 60,      # 1 minute
            'M5': years * 365 * 24 * 12,      # 5 minutes  
            'M15': years * 365 * 24 * 4,      # 15 minutes
            'H1': years * 365 * 24,           # 1 hour
            'H4': years * 365 * 6,            # 4 hours
            'D1': years * 365,                # 1 day
            'W1': years * 52                  # 1 week
        }
        
        num_periods = min(periods_map.get(timeframe, 10000), 50000)  # Cap for memory
        
        # Generate realistic EURUSD price data
        np.random.seed(42)  # For reproducible results
        
        # Start price around 1.1000
        start_price = 1.1000
        
        # Generate realistic returns with volatility clustering
        returns = np.random.normal(0, 0.0008, num_periods)  # 0.08% daily volatility
        
        # Add trend components
        trend_component = np.sin(np.arange(num_periods) * 2 * np.pi / 252) * 0.0002
        returns += trend_component
        
        # Add volatility clustering (GARCH effect)
        volatility = np.ones(num_periods) * 0.0008
        for i in range(1, num_periods):
            volatility[i] = 0.95 * volatility[i-1] + 0.05 * abs(returns[i-1])
            returns[i] = np.random.normal(0, volatility[i])
        
        # Generate prices
        prices = [start_price]
        for ret in returns[1:]:
            prices.append(prices[-1] * (1 + ret))
        
        # Generate OHLC data
        data = []
        for i, close_price in enumerate(prices):
            # Generate realistic OHLC around close price
            spread = close_price * 0.0001  # 1 pip spread
            
            open_price = prices[i-1] if i > 0 else close_price
            high_price = max(open_price, close_price) + np.random.uniform(0, spread * 2)
            low_price = min(open_price, close_price) - np.random.uniform(0, spread * 2)
            volume = np.random.randint(1000, 10000)
            
            # Generate timestamp
            if timeframe == 'M1':
                timestamp = datetime(2015, 1, 1) + timedelta(minutes=i)
            elif timeframe == 'M5':
                timestamp = datetime(2015, 1, 1) + timedelta(minutes=i*5)
            elif timeframe == 'M15':
                timestamp = datetime(2015, 1, 1) + timedelta(minutes=i*15)
            elif timeframe == 'H1':
                timestamp = datetime(2015, 1, 1) + timedelta(hours=i)
            elif timeframe == 'H4':
                timestamp = datetime(2015, 1, 1) + timedelta(hours=i*4)
            elif timeframe == 'D1':
                timestamp = datetime(2015, 1, 1) + timedelta(days=i)
            else:  # W1
                timestamp = datetime(2015, 1, 1) + timedelta(weeks=i)
            
            data.append({
                'timestamp': timestamp,
                'open': round(open_price, 5),
                'high': round(high_price, 5),
                'low': round(low_price, 5),
                'close': round(close_price, 5),
                'volume': volume
            })
        
        df = pd.DataFrame(data)
        print(f"✅ Generated {len(df)} {timeframe} data points")
        return df
    
    def process_timeframe_data(self, timeframe: str) -> Dict:
        """Process complete historical data for one timeframe"""
        
        print(f"\n🔄 Processing {self.pair} {timeframe} Historical Data")
        print("=" * 60)
        
        start_time = datetime.now()
        
        try:
            # Step 1: Load/Generate historical data
            historical_data = self.simulate_historical_data(timeframe, years=10)
            
            # Step 2: Process through Universal Pipeline
            pipeline_result = self.data_pipeline.process_pair_data(
                pair=self.pair,
                timeframe=timeframe,
                data=historical_data,
                data_source='Historical_Simulation',
                include_regime=True,
                validate_leakage=True
            )
            
            if not pipeline_result['success']:
                return {
                    'timeframe': timeframe,
                    'success': False,
                    'error': 'Pipeline processing failed',
                    'details': pipeline_result.get('errors', [])
                }
            
            processed_data = pipeline_result['processed_data']
            
            # Step 3: Advanced Feature Engineering
            enhanced_data = self.feature_engineer.engineer_comprehensive_features(
                df=processed_data,
                pair=self.pair,
                timeframe=timeframe,
                feature_set='comprehensive'
            )
            
            # Step 4: Regime Analysis
            regime_result = self.regime_detector.detect_regime(enhanced_data)
            
            # Step 5: Prepare ML Training Data
            ml_training_data = self.prepare_ml_training_data(enhanced_data)
            
            # Step 6: Data Quality Assessment
            quality_score = self.assess_data_quality(enhanced_data)
            
            # Step 7: Save processed data
            save_result = self.save_processed_data(enhanced_data, timeframe)
            
            processing_time = (datetime.now() - start_time).total_seconds()
            
            # Update statistics
            self.processing_stats['total_records_processed'] += len(enhanced_data)
            self.processing_stats['timeframes_completed'] += 1
            self.processing_stats['regime_classifications'][timeframe] = regime_result
            self.processing_stats['data_quality_scores'][timeframe] = quality_score
            self.processing_stats['processing_time'][timeframe] = processing_time
            self.processing_stats['last_processed'] = datetime.now().isoformat()
            
            result = {
                'timeframe': timeframe,
                'success': True,
                'processing_time_seconds': processing_time,
                'records_processed': len(enhanced_data),
                'features_engineered': len(enhanced_data.columns),
                'regime_analysis': regime_result,
                'data_quality_score': quality_score,
                'ml_training_ready': len(ml_training_data['features']),
                'save_status': save_result,
                'pipeline_details': pipeline_result
            }
            
            print(f"✅ {timeframe} processing completed in {processing_time:.2f}s")
            print(f"📊 Records: {len(enhanced_data)}, Features: {len(enhanced_data.columns)}")
            print(f"🧠 Regime: {regime_result.get('regime', 'unknown')}")
            print(f"🎯 Quality Score: {quality_score:.3f}")
            
            return result
            
        except Exception as e:
            print(f"❌ Error processing {timeframe}: {e}")
            return {
                'timeframe': timeframe,
                'success': False,
                'error': str(e),
                'processing_time_seconds': (datetime.now() - start_time).total_seconds()
            }
    
    def prepare_ml_training_data(self, df: pd.DataFrame) -> Dict:
        """Prepare data for ML training"""
        
        try:
            # Remove non-numeric columns
            numeric_df = df.select_dtypes(include=[np.number])
            
            # Create target variable (next period return)
            target = numeric_df['returns'].shift(-1).fillna(0)
            
            # Remove current return from features to avoid leakage
            features = numeric_df.drop(['returns'], axis=1, errors='ignore')
            
            # Remove rows with NaN values
            valid_indices = features.dropna().index
            features_clean = features.loc[valid_indices]
            target_clean = target.loc[valid_indices]
            
            return {
                'features': features_clean,
                'target': target_clean,
                'feature_names': list(features_clean.columns),
                'samples': len(features_clean)
            }
            
        except Exception as e:
            print(f"⚠️ ML data preparation error: {e}")
            return {'features': pd.DataFrame(), 'target': pd.Series(), 'samples': 0}
    
    def assess_data_quality(self, df: pd.DataFrame) -> float:
        """Assess overall data quality"""
        
        try:
            score = 1.0
            
            # Penalize missing values
            missing_ratio = df.isnull().sum().sum() / (len(df) * len(df.columns))
            score -= missing_ratio * 0.5
            
            # Check for duplicate timestamps
            if 'timestamp' in df.columns:
                duplicate_ratio = df['timestamp'].duplicated().sum() / len(df)
                score -= duplicate_ratio * 0.3
            
            # Check for price consistency
            if all(col in df.columns for col in ['open', 'high', 'low', 'close']):
                invalid_ohlc = ((df['high'] < df[['open', 'close']].max(axis=1)) |
                               (df['low'] > df[['open', 'close']].min(axis=1))).sum()
                invalid_ratio = invalid_ohlc / len(df)
                score -= invalid_ratio * 0.2
            
            return max(0.0, min(1.0, score))
            
        except:
            return 0.5
    
    def save_processed_data(self, df: pd.DataFrame, timeframe: str) -> Dict:
        """Save processed data to files"""
        
        try:
            # Create data directory
            data_dir = f"data/processed/{self.pair}"
            os.makedirs(data_dir, exist_ok=True)
            
            # Save as CSV
            csv_file = f"{data_dir}/{self.pair}_{timeframe}_processed.csv"
            df.to_csv(csv_file, index=False)
            
            # Save metadata
            metadata = {
                'pair': self.pair,
                'timeframe': timeframe,
                'records': len(df),
                'features': len(df.columns),
                'date_range': {
                    'start': df['timestamp'].min().isoformat() if 'timestamp' in df.columns else None,
                    'end': df['timestamp'].max().isoformat() if 'timestamp' in df.columns else None
                },
                'processed_at': datetime.now().isoformat(),
                'file_size_mb': os.path.getsize(csv_file) / (1024*1024)
            }
            
            metadata_file = f"{data_dir}/{self.pair}_{timeframe}_metadata.json"
            with open(metadata_file, 'w') as f:
                json.dump(metadata, f, indent=2)
            
            return {
                'csv_file': csv_file,
                'metadata_file': metadata_file,
                'file_size_mb': metadata['file_size_mb'],
                'success': True
            }
            
        except Exception as e:
            print(f"⚠️ Save error: {e}")
            return {'success': False, 'error': str(e)}
    
    def process_all_timeframes(self) -> Dict:
        """Process historical data for all timeframes"""
        
        print("\n🚀 STARTING COMPLETE EURUSD HISTORICAL PROCESSING")
        print("=" * 70)
        
        overall_start = datetime.now()
        results = {}
        
        # Initialize components
        if not self.initialize_components():
            return {'error': 'Component initialization failed'}
        
        # Process each timeframe
        for timeframe in self.timeframes:
            print(f"\n📊 Processing {timeframe}...")
            results[timeframe] = self.process_timeframe_data(timeframe)
        
        # Calculate overall statistics
        total_time = (datetime.now() - overall_start).total_seconds()
        successful_timeframes = sum(1 for r in results.values() if r.get('success', False))
        
        summary = {
            'overall_success': successful_timeframes == len(self.timeframes),
            'successful_timeframes': successful_timeframes,
            'total_timeframes': len(self.timeframes),
            'total_processing_time_seconds': total_time,
            'total_records_processed': self.processing_stats['total_records_processed'],
            'processing_stats': self.processing_stats,
            'timeframe_results': results,
            'completion_timestamp': datetime.now().isoformat()
        }
        
        # Save summary
        self.save_processing_summary(summary)
        
        print(f"\n🎉 EURUSD HISTORICAL PROCESSING COMPLETED!")
        print(f"✅ Successful: {successful_timeframes}/{len(self.timeframes)} timeframes")
        print(f"⏱️ Total time: {total_time:.2f} seconds")
        print(f"📊 Total records: {self.processing_stats['total_records_processed']:,}")
        
        return summary
    
    def save_processing_summary(self, summary: Dict):
        """Save processing summary"""
        try:
            summary_file = f"data/processed/{self.pair}/processing_summary.json"
            os.makedirs(os.path.dirname(summary_file), exist_ok=True)
            
            with open(summary_file, 'w') as f:
                json.dump(summary, f, indent=2, default=str)
            
            print(f"📄 Summary saved: {summary_file}")
            
        except Exception as e:
            print(f"⚠️ Summary save error: {e}")

def create_eurusd_processor():
    """Create EURUSD historical processor"""
    return EURUSDHistoricalProcessor()

def run_complete_eurusd_processing():
    """Run complete EURUSD historical data processing"""
    processor = create_eurusd_processor()
    return processor.process_all_timeframes()

def quick_eurusd_test():
    """Quick test of EURUSD processing"""
    print("🧪 Quick EURUSD Processing Test")
    processor = create_eurusd_processor()
    
    if processor.initialize_components():
        # Test with M15 data only
        result = processor.process_timeframe_data('M15')
        return result.get('success', False)
    
    return False

print("📊 EURUSD Historical Data Processor loaded!")
print("🎯 Ready to process 10 years of historical data")
print("📋 Usage: processor = create_eurusd_processor()")
print("🚀 Full processing: run_complete_eurusd_processing()")
print("🧪 Quick test: quick_eurusd_test()")
