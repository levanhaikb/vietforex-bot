# Day 11: ML Model Training System for VietForex - FIXED VERSION
import pandas as pd
import numpy as np
import os
import json
import pickle
from datetime import datetime, timedelta
from typing import Dict, List, Tuple, Optional, Any
import warnings
warnings.filterwarnings('ignore')

# ML Libraries
try:
    from sklearn.model_selection import TimeSeriesSplit, cross_val_score
    from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
    from sklearn.linear_model import LogisticRegression
    from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
    from sklearn.preprocessing import StandardScaler
    print("✅ Sklearn libraries loaded")
except ImportError as e:
    print(f"⚠️ Sklearn import warning: {e}")

# Deep Learning (optional)
try:
    import tensorflow as tf
    from tensorflow.keras.models import Sequential
    from tensorflow.keras.layers import LSTM, Dense, Dropout
    from tensorflow.keras.optimizers import Adam
    print("✅ TensorFlow loaded")
    HAS_TENSORFLOW = True
except ImportError:
    print("⚠️ TensorFlow not available - using sklearn models only")
    HAS_TENSORFLOW = False

class VietForexMLTrainer:
    """VietForex ML Model Training System"""
    
    def __init__(self):
        self.pair = "EURUSD"
        self.timeframes = ['M15', 'H1', 'H4']
        self.model_types = ['RandomForest', 'GradientBoosting', 'Logistic']
        
        if HAS_TENSORFLOW:
            self.model_types.append('LSTM')
        
        self.config = {
            'test_size': 0.2,
            'validation_size': 0.1,
            'random_state': 42,
            'target_accuracy': 0.55,
            'max_features': 15
        }
        
        self.training_results = {
            'models_trained': 0,
            'best_models': {},
            'training_history': []
        }
        
        print("🤖 VietForex ML Trainer khởi tạo")
        print(f"💱 Target pair: {self.pair}")
        print(f"⏰ Timeframes: {', '.join(self.timeframes)}")
        print(f"🧠 Model types: {', '.join(self.model_types)}")

    def load_training_data(self, timeframe: str) -> Dict:
        """Load processed data for training"""
        
        print(f"📊 Loading {timeframe} training data...")
        
        try:
            data_file = f"data/processed/EURUSD/EURUSD_{timeframe}_processed.csv"
            
            if not os.path.exists(data_file):
                return {'error': f'Data file not found: {data_file}'}
            
            df = pd.read_csv(data_file)
            print(f"✅ Loaded {len(df):,} records for {timeframe}")
            
            # Prepare features
            feature_columns = [col for col in df.columns 
                             if col not in ['timestamp', 'returns'] and 
                             df[col].dtype in ['float64', 'int64']]
            
            # Remove columns with too many NaN values
            feature_columns = [col for col in feature_columns 
                             if df[col].notna().sum() / len(df) > 0.8]
            
            # Limit features
            if len(feature_columns) > self.config['max_features']:
                feature_vars = df[feature_columns].var().sort_values(ascending=False)
                feature_columns = feature_vars.head(self.config['max_features']).index.tolist()
            
            X = df[feature_columns].fillna(0)
            y = (df['returns'] > 0).astype(int)
            
            # Remove rows where target is NaN
            valid_idx = ~pd.isna(df['returns'])
            X = X[valid_idx]
            y = y[valid_idx]
            
            print(f"📈 Features: {len(feature_columns)}")
            print(f"🎯 Target distribution: Positive: {y.sum()}, Negative: {len(y) - y.sum()}")
            
            return {
                'X': X,
                'y': y,
                'features': feature_columns,
                'samples': len(X),
                'timeframe': timeframe
            }
            
        except Exception as e:
            print(f"❌ Error loading data: {e}")
            return {'error': str(e)}

    def create_time_series_splits(self, X: pd.DataFrame, y: pd.Series) -> Dict:
        """Create time-aware splits"""
        
        n_samples = len(X)
        
        test_size = int(n_samples * self.config['test_size'])
        val_size = int(n_samples * self.config['validation_size'])
        train_size = n_samples - test_size - val_size
        
        splits = {
            'X_train': X.iloc[:train_size],
            'y_train': y.iloc[:train_size],
            'X_val': X.iloc[train_size:train_size + val_size],
            'y_val': y.iloc[train_size:train_size + val_size],
            'X_test': X.iloc[train_size + val_size:],
            'y_test': y.iloc[train_size + val_size:]
        }
        
        print(f"📊 Data splits:")
        print(f"   Train: {len(splits['X_train']):,} samples")
        print(f"   Val:   {len(splits['X_val']):,} samples")
        print(f"   Test:  {len(splits['X_test']):,} samples")
        
        return splits

    def train_sklearn_model(self, model_type: str, splits: Dict) -> Dict:
        """Train sklearn models"""
        
        print(f"🔧 Training {model_type} model...")
        
        models = {
            'RandomForest': RandomForestClassifier(
                n_estimators=100,
                max_depth=10,
                min_samples_split=20,
                random_state=self.config['random_state'],
                n_jobs=-1
            ),
            'GradientBoosting': GradientBoostingClassifier(
                n_estimators=100,
                max_depth=6,
                learning_rate=0.1,
                random_state=self.config['random_state']
            ),
            'Logistic': LogisticRegression(
                random_state=self.config['random_state'],
                max_iter=1000
            )
        }
        
        try:
            model = models[model_type]
            
            # Scale features for Logistic Regression
            if model_type == 'Logistic':
                scaler = StandardScaler()
                X_train_scaled = scaler.fit_transform(splits['X_train'])
                X_val_scaled = scaler.transform(splits['X_val'])
                X_test_scaled = scaler.transform(splits['X_test'])
                
                model.fit(X_train_scaled, splits['y_train'])
                train_pred = model.predict(X_train_scaled)
                val_pred = model.predict(X_val_scaled)
                test_pred = model.predict(X_test_scaled)
                val_prob = model.predict_proba(X_val_scaled)[:, 1]
                test_prob = model.predict_proba(X_test_scaled)[:, 1]
                
            else:
                model.fit(splits['X_train'], splits['y_train'])
                train_pred = model.predict(splits['X_train'])
                val_pred = model.predict(splits['X_val'])
                test_pred = model.predict(splits['X_test'])
                val_prob = model.predict_proba(splits['X_val'])[:, 1]
                test_prob = model.predict_proba(splits['X_test'])[:, 1]
                scaler = None
            
            # Calculate metrics
            train_acc = accuracy_score(splits['y_train'], train_pred)
            val_acc = accuracy_score(splits['y_val'], val_pred)
            test_acc = accuracy_score(splits['y_test'], test_pred)
            
            result = {
                'model_type': model_type,
                'model': model,
                'scaler': scaler,
                'train_accuracy': train_acc,
                'val_accuracy': val_acc,
                'test_accuracy': test_acc,
                'val_predictions': val_pred,
                'test_predictions': test_pred,
                'val_probabilities': val_prob,
                'test_probabilities': test_prob,
                'training_time': datetime.now().isoformat()
            }
            
            print(f"✅ {model_type} trained successfully")
            print(f"   Train Acc: {train_acc:.3f}")
            print(f"   Val Acc:   {val_acc:.3f}")
            print(f"   Test Acc:  {test_acc:.3f}")
            
            return result
            
        except Exception as e:
            print(f"❌ {model_type} training failed: {e}")
            return {'error': str(e), 'model_type': model_type}

    def train_lstm_model(self, splits: Dict) -> Dict:
        """Train LSTM model if TensorFlow available"""
        
        if not HAS_TENSORFLOW:
            return {'error': 'TensorFlow not available'}
        
        print("🧠 Training LSTM model...")
        
        try:
            # Prepare data for LSTM
            scaler = StandardScaler()
            X_train_scaled = scaler.fit_transform(splits['X_train'])
            X_val_scaled = scaler.transform(splits['X_val'])
            X_test_scaled = scaler.transform(splits['X_test'])
            
            # Reshape for LSTM (samples, timesteps, features)
            X_train_lstm = X_train_scaled.reshape(X_train_scaled.shape[0], 1, X_train_scaled.shape[1])
            X_val_lstm = X_val_scaled.reshape(X_val_scaled.shape[0], 1, X_val_scaled.shape[1])
            X_test_lstm = X_test_scaled.reshape(X_test_scaled.shape[0], 1, X_test_scaled.shape[1])
            
            # Build LSTM model
            model = Sequential([
                LSTM(50, input_shape=(1, X_train_scaled.shape[1])),
                Dropout(0.2),
                Dense(25, activation='relu'),
                Dense(1, activation='sigmoid')
            ])
            
            model.compile(
                optimizer=Adam(learning_rate=0.001),
                loss='binary_crossentropy',
                metrics=['accuracy']
            )
            
            # Train
            history = model.fit(
                X_train_lstm, splits['y_train'],
                validation_data=(X_val_lstm, splits['y_val']),
                epochs=10,
                batch_size=32,
                verbose=0
            )
            
            # Predictions
            val_prob = model.predict(X_val_lstm, verbose=0).flatten()
            test_prob = model.predict(X_test_lstm, verbose=0).flatten()
            
            val_pred = (val_prob > 0.5).astype(int)
            test_pred = (test_prob > 0.5).astype(int)
            
            val_acc = accuracy_score(splits['y_val'], val_pred)
            test_acc = accuracy_score(splits['y_test'], test_pred)
            
            result = {
                'model_type': 'LSTM',
                'model': model,
                'scaler': scaler,
                'val_accuracy': val_acc,
                'test_accuracy': test_acc,
                'val_predictions': val_pred,
                'test_predictions': test_pred,
                'val_probabilities': val_prob,
                'test_probabilities': test_prob,
                'training_history': history.history,
                'training_time': datetime.now().isoformat()
            }
            
            print("✅ LSTM trained successfully")
            print(f"   Val Acc:  {val_acc:.3f}")
            print(f"   Test Acc: {test_acc:.3f}")
            
            return result
            
        except Exception as e:
            print(f"❌ LSTM training failed: {e}")
            return {'error': str(e), 'model_type': 'LSTM'}

    def train_timeframe_models(self, timeframe: str) -> Dict:
        """Train all models for a timeframe"""
        
        print(f"\n🎯 TRAINING MODELS FOR {timeframe}")
        print("=" * 50)
        
        # Load data
        data_result = self.load_training_data(timeframe)
        if 'error' in data_result:
            return data_result
        
        # Create splits
        splits = self.create_time_series_splits(data_result['X'], data_result['y'])
        
        # Train models
        models_results = {}
        
        # Train sklearn models
        for model_type in ['RandomForest', 'GradientBoosting', 'Logistic']:
            result = self.train_sklearn_model(model_type, splits)
            if 'error' not in result:
                models_results[model_type] = result
        
        # Train LSTM if available
        if HAS_TENSORFLOW:
            result = self.train_lstm_model(splits)
            if 'error' not in result:
                models_results['LSTM'] = result
        
        # Find best model
        best_model = None
        best_accuracy = 0
        
        for model_name, result in models_results.items():
            val_acc = result.get('val_accuracy', 0)
            if val_acc > best_accuracy:
                best_accuracy = val_acc
                best_model = model_name
        
        # Save models
        model_files = self.save_models(models_results, timeframe)
        
        summary = {
            'timeframe': timeframe,
            'models_trained': len(models_results),
            'best_model': best_model,
            'best_accuracy': best_accuracy,
            'all_results': models_results,
            'model_files': model_files,
            'training_completed': datetime.now().isoformat()
        }
        
        print(f"\n✅ {timeframe} training completed!")
        print(f"   Models trained: {len(models_results)}")
        print(f"   Best model: {best_model} ({best_accuracy:.3f})")
        
        return summary

    def save_models(self, models_results: Dict, timeframe: str) -> List[str]:
        """Save models to files"""
        
        print(f"💾 Saving {timeframe} models...")
        
        models_dir = f"models/{self.pair}/{timeframe}"
        os.makedirs(models_dir, exist_ok=True)
        
        saved_files = []
        
        for model_name, result in models_results.items():
            try:
                model_file = f"{models_dir}/{model_name}_model.pkl"
                
                if HAS_TENSORFLOW and model_name == 'LSTM':
                    # Save TensorFlow model
                    tf_model_dir = f"{models_dir}/{model_name}_tf_model"
                    result['model'].save(tf_model_dir)
                    
                    # Save additional info
                    model_info = {
                        'model_type': model_name,
                        'scaler': result.get('scaler'),
                        'val_accuracy': result.get('val_accuracy'),
                        'test_accuracy': result.get('test_accuracy')
                    }
                    
                    info_file = f"{models_dir}/{model_name}_info.pkl"
                    with open(info_file, 'wb') as f:
                        pickle.dump(model_info, f)
                    
                    saved_files.extend([tf_model_dir, info_file])
                else:
                    # Save sklearn model
                    with open(model_file, 'wb') as f:
                        pickle.dump(result, f)
                    saved_files.append(model_file)
                
                print(f"   ✅ Saved {model_name}")
                
            except Exception as e:
                print(f"   ❌ Failed to save {model_name}: {e}")
        
        return saved_files

    def train_all_models(self) -> Dict:
        """Train models for all timeframes"""
        
        print("\n🚀 STARTING COMPLETE ML MODEL TRAINING")
        print("=" * 60)
        
        overall_start = datetime.now()
        all_results = {}
        
        for timeframe in self.timeframes:
            timeframe_result = self.train_timeframe_models(timeframe)
            all_results[timeframe] = timeframe_result
            
            if 'error' not in timeframe_result:
                self.training_results['models_trained'] += timeframe_result['models_trained']
                self.training_results['best_models'][timeframe] = {
                    'model': timeframe_result['best_model'],
                    'accuracy': timeframe_result['best_accuracy']
                }
        
        total_time = (datetime.now() - overall_start).total_seconds()
        successful_timeframes = len([r for r in all_results.values() if 'error' not in r])
        
        final_summary = {
            'training_completed': True,
            'total_training_time_seconds': total_time,
            'timeframes_trained': successful_timeframes,
            'total_models_trained': self.training_results['models_trained'],
            'best_models_summary': self.training_results['best_models'],
            'timeframe_results': all_results,
            'completion_timestamp': datetime.now().isoformat()
        }
        
        self.save_training_summary(final_summary)
        
        print(f"\n🎉 ML MODEL TRAINING COMPLETED!")
        print(f"✅ Timeframes: {successful_timeframes}/{len(self.timeframes)}")
        print(f"🤖 Total models: {self.training_results['models_trained']}")
        print(f"⏱️ Total time: {total_time:.1f} seconds")
        
        return final_summary

    def save_training_summary(self, summary: Dict):
        """Save training summary"""
        try:
            summary_dir = f"models/{self.pair}"
            os.makedirs(summary_dir, exist_ok=True)
            
            summary_file = f"{summary_dir}/training_summary.json"
            with open(summary_file, 'w') as f:
                json.dump(summary, f, indent=2, default=str)
            
            print(f"📄 Training summary saved: {summary_file}")
            
        except Exception as e:
            print(f"⚠️ Summary save error: {e}")

def create_ml_trainer():
    """Create ML trainer instance"""
    return VietForexMLTrainer()

def run_complete_ml_training():
    """Run complete ML model training"""
    trainer = create_ml_trainer()
    return trainer.train_all_models()

def quick_ml_test():
    """Quick test of ML training system"""
    print("🧪 Quick ML Training Test")
    
    trainer = create_ml_trainer()
    data_result = trainer.load_training_data('M15')
    
    if 'error' not in data_result:
        print(f"✅ Data loading successful: {data_result['samples']} samples")
        return True
    else:
        print(f"❌ Data loading failed: {data_result['error']}")
        return False

print("🤖 VietForex ML Training System loaded!")
print("🎯 Ready to train multiple model types")
print("📋 Usage: trainer = create_ml_trainer()")
print("🚀 Full training: run_complete_ml_training()")
print("🧪 Quick test: quick_ml_test()")
