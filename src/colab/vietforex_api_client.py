import requests
import json
import base64
import time
import pandas as pd
from typing import Dict, List, Optional, Union
import logging

class VietForexAPI:
    """
    VietForex API Client for Google Colab Integration
    Connects to VPS API Server at http://145.79.13.123:3000
    """
    
    def __init__(self, base_url: str = "http://145.79.13.123:3000", 
                 api_key: str = "VietForex_API_Key_2024_Hostinger"):
        """
        Initialize VietForex API Client
        
        Args:
            base_url: VPS API server URL
            api_key: Authentication API key
        """
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json',
            'User-Agent': 'VietForex-Colab-Client/1.0'
        })
        
        # Setup logging
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
        # Test connection on initialization
        self._test_connection()
    
    def _test_connection(self) -> bool:
        """Test API connection"""
        try:
            response = self.health_check()
            if response.get('status') == 'healthy':
                self.logger.info(f"✅ Connected to VietForex API at {self.base_url}")
                return True
            else:
                self.logger.error(f"❌ API connection failed: {response}")
                return False
        except Exception as e:
            self.logger.error(f"❌ Connection test failed: {str(e)}")
            return False
    
    def _make_request(self, method: str, endpoint: str, 
                     data: Optional[Dict] = None, 
                     files: Optional[Dict] = None,
                     timeout: int = 30) -> Dict:
        """
        Make HTTP request to API
        
        Args:
            method: HTTP method (GET, POST, PUT, DELETE)
            endpoint: API endpoint
            data: Request data
            files: Files to upload
            timeout: Request timeout
            
        Returns:
            API response as dictionary
        """
        url = f"{self.base_url}{endpoint}"
        
        try:
            if method.upper() == 'GET':
                response = self.session.get(url, params=data, timeout=timeout)
            elif method.upper() == 'POST':
                if files:
                    # Remove Content-Type for file uploads
                    headers = self.session.headers.copy()
                    if 'Content-Type' in headers:
                        del headers['Content-Type']
                    response = self.session.post(url, data=data, files=files, 
                                               headers=headers, timeout=timeout)
                else:
                    response = self.session.post(url, json=data, timeout=timeout)
            elif method.upper() == 'PUT':
                response = self.session.put(url, json=data, timeout=timeout)
            elif method.upper() == 'DELETE':
                response = self.session.delete(url, timeout=timeout)
            else:
                raise ValueError(f"Unsupported HTTP method: {method}")
            
            # Check response status
            response.raise_for_status()
            
            # Parse JSON response
            try:
                return response.json()
            except json.JSONDecodeError:
                return {'raw_response': response.text}
                
        except requests.exceptions.Timeout:
            self.logger.error(f"⏰ Request timeout for {method} {endpoint}")
            return {'error': 'Request timeout', 'success': False}
        except requests.exceptions.ConnectionError:
            self.logger.error(f"🌐 Connection error for {method} {endpoint}")
            return {'error': 'Connection error', 'success': False}
        except requests.exceptions.HTTPError as e:
            self.logger.error(f"❌ HTTP error for {method} {endpoint}: {e}")
            return {'error': f'HTTP error: {e}', 'success': False}
        except Exception as e:
            self.logger.error(f"💥 Unexpected error for {method} {endpoint}: {e}")
            return {'error': f'Unexpected error: {e}', 'success': False}
    
    # ==============================================
    # HEALTH & STATUS ENDPOINTS
    # ==============================================
    
    def health_check(self) -> Dict:
        """Check API server health"""
        return self._make_request('GET', '/api/health')
    
    # ==============================================
    # MODEL MANAGEMENT ENDPOINTS
    # ==============================================
    
    def upload_model(self, model_name: str, model_version: str, 
                    pair_symbol: str, model_type: str,
                    accuracy: float, model_data: Union[str, bytes],
                    **kwargs) -> Dict:
        """
        Upload trained ML model to VPS
        
        Args:
            model_name: Name of the model
            model_version: Version string
            pair_symbol: Trading pair (e.g., 'EURUSD')
            model_type: Type of model (e.g., 'LSTM', 'RandomForest')
            accuracy: Model accuracy (0.0 to 1.0)
            model_data: Model data (base64 string or bytes)
            **kwargs: Additional model metadata
            
        Returns:
            Upload response
        """
        # Convert model data to base64 if needed
        if isinstance(model_data, bytes):
            model_data_b64 = base64.b64encode(model_data).decode('utf-8')
        else:
            model_data_b64 = model_data
        
        payload = {
            'model_name': model_name,
            'model_version': model_version,
            'pair_symbol': pair_symbol,
            'model_type': model_type,
            'accuracy': accuracy,
            'model_data': model_data_b64,
            **kwargs
        }
        
        self.logger.info(f"📤 Uploading model: {model_name} v{model_version}")
        return self._make_request('POST', '/api/models/upload', data=payload)
    
    def list_models(self, pair: Optional[str] = None, 
                   status: Optional[str] = None, 
                   limit: int = 10) -> Dict:
        """
        List available models
        
        Args:
            pair: Filter by trading pair
            status: Filter by status
            limit: Maximum number of results
            
        Returns:
            List of models
        """
        params = {'limit': limit}
        if pair:
            params['pair'] = pair
        if status:
            params['status'] = status
            
        return self._make_request('GET', '/api/models/list', data=params)
    
    def get_model_status(self, model_id: int) -> Dict:
        """Get specific model status"""
        return self._make_request('GET', f'/api/models/status/{model_id}')
    
    def activate_model(self, model_id: int, 
                      force_activation: bool = False,
                      deactivate_previous: bool = True) -> Dict:
        """
        Activate a model for production use
        
        Args:
            model_id: ID of model to activate
            force_activation: Force activation even if validation fails
            deactivate_previous: Deactivate currently active model
            
        Returns:
            Activation response
        """
        payload = {
            'force_activation': force_activation,
            'deactivate_previous': deactivate_previous
        }
        
        self.logger.info(f"🚀 Activating model ID: {model_id}")
        return self._make_request('PUT', f'/api/models/activate/{model_id}', data=payload)
    
    # ==============================================
    # SIGNAL GENERATION ENDPOINTS
    # ==============================================
    
    def generate_signal(self, pair: str, model_id: Optional[int] = None,
                       signal_type: str = 'auto', 
                       include_analysis: bool = True) -> Dict:
        """
        Generate trading signal
        
        Args:
            pair: Trading pair (e.g., 'EURUSD')
            model_id: Specific model to use (optional)
            signal_type: Type of signal ('auto', 'manual', 'backtest')
            include_analysis: Include detailed analysis
            
        Returns:
            Generated signal
        """
        payload = {
            'pair': pair,
            'signal_type': signal_type,
            'include_analysis': include_analysis
        }
        
        if model_id:
            payload['model_id'] = model_id
        
        self.logger.info(f"🎯 Generating signal for {pair}")
        return self._make_request('POST', '/api/signals/generate', data=payload)
    
    def get_signal_history(self, pair: Optional[str] = None,
                          limit: int = 50, 
                          status: Optional[str] = None) -> Dict:
        """
        Get signal history
        
        Args:
            pair: Filter by trading pair
            limit: Maximum number of results
            status: Filter by status
            
        Returns:
            Signal history
        """
        params = {'limit': limit}
        if pair:
            params['pair'] = pair
        if status:
            params['status'] = status
            
        return self._make_request('GET', '/api/signals/history', data=params)
    
    def update_signal_result(self, signal_id: int, result: str,
                           exit_price: float, pnl_pips: float,
                           notes: Optional[str] = None) -> Dict:
        """
        Update signal performance result
        
        Args:
            signal_id: Signal ID
            result: Result ('win', 'loss', 'breakeven')
            exit_price: Exit price
            pnl_pips: Profit/loss in pips
            notes: Additional notes
            
        Returns:
            Update response
        """
        payload = {
            'result': result,
            'exit_price': exit_price,
            'pnl_pips': pnl_pips,
            'closed_at': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
        }
        
        if notes:
            payload['notes'] = notes
        
        return self._make_request('PUT', f'/api/signals/{signal_id}/result', data=payload)
    
    # ==============================================  
    # DATA PROCESSING ENDPOINTS
    # ==============================================
    
    def get_market_data(self, pair: str, timeframe: str = 'M15', 
                       limit: int = 1000) -> Dict:
        """
        Get market data for a trading pair
        
        Args:
            pair: Trading pair
            timeframe: Timeframe (M1, M5, M15, H1, H4, D1)
            limit: Number of data points
            
        Returns:
            Market data
        """
        params = {
            'timeframe': timeframe,
            'limit': limit
        }
        
        return self._make_request('GET', f'/api/data/market/{pair}', data=params)
    
    def upload_historical_data(self, pair: str, timeframe: str,
                             data_source: str, data: List[Dict]) -> Dict:
        """
        Upload historical data to VPS
        
        Args:
            pair: Trading pair
            timeframe: Data timeframe
            data_source: Source of data (e.g., 'Exness', 'MetaTrader')
            data: OHLCV data list
            
        Returns:
            Upload response
        """
        payload = {
            'pair': pair,
            'timeframe': timeframe,
            'data_source': data_source,
            'data': data
        }
        
        self.logger.info(f"📊 Uploading {len(data)} data points for {pair} {timeframe}")
        return self._make_request('POST', '/api/data/upload', data=payload)
    
    # ==============================================
    # ANALYTICS ENDPOINTS  
    # ==============================================
    
    def get_performance_analytics(self, period: str = '30d',
                                pair: Optional[str] = None) -> Dict:
        """
        Get performance analytics
        
        Args:
            period: Analysis period (7d, 30d, 90d, 1y)
            pair: Specific trading pair
            
        Returns:
            Performance analytics
        """
        params = {'period': period}
        if pair:
            params['pair'] = pair
            
        return self._make_request('GET', '/api/analytics/performance', data=params)
    
    # ==============================================
    # UTILITY METHODS
    # ==============================================
    
    def ping(self) -> bool:
        """Simple ping test"""
        try:
            response = self.health_check()
            return response.get('status') == 'healthy'
        except:
            return False
    
    def get_server_info(self) -> Dict:
        """Get detailed server information"""
        response = self.health_check()
        if response.get('success', True):
            return {
                'server_ip': '145.79.13.123',
                'hostname': 'vietforex.production',
                'provider': 'Hostinger',
                'api_status': response.get('status', 'unknown'),
                'timestamp': response.get('timestamp'),
                'uptime': response.get('uptime'),
                'version': response.get('version')
            }
        return {'error': 'Unable to get server info'}

# ==============================================
# CONVENIENCE FUNCTIONS
# ==============================================

def create_api_client(api_key: Optional[str] = None) -> VietForexAPI:
    """
    Create and return VietForex API client
    
    Args:
        api_key: Optional API key (uses default if not provided)
        
    Returns:
        Configured API client
    """
    if api_key:
        return VietForexAPI(api_key=api_key)
    else:
        return VietForexAPI()

def test_api_connection() -> bool:
    """
    Quick test of API connection
    
    Returns:
        True if connection successful
    """
    try:
        client = create_api_client()
        return client.ping()
    except Exception as e:
        print(f"❌ API connection test failed: {e}")
        return False

print("✅ VietForex API Client loaded successfully!")
