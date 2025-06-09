from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
from openai import OpenAI
import httpx # Added
import json
import re

# 載入環境變數
load_dotenv()

app = Flask(__name__)
CORS(app)

# 配置
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key')
LLM_API_KEY = os.environ.get('LLM_API_KEY')
LLM_PROVIDER = os.environ.get('LLM_PROVIDER', 'openai')

# 模型配置
OPENAI_MODEL = os.environ.get('OPENAI_MODEL', 'gpt-4o-mini')
GEMINI_MODEL = os.environ.get('GEMINI_MODEL', 'gemini-pro')

# 根據 provider 選擇對應的模型
if LLM_PROVIDER == 'openai':
    CURRENT_MODEL = OPENAI_MODEL
elif LLM_PROVIDER == 'gemini':
    CURRENT_MODEL = GEMINI_MODEL
else:
    CURRENT_MODEL = 'gpt-4o-mini'  # 預設模型

# 初始化 OpenAI 客戶端
client = None
if LLM_PROVIDER == 'openai' and LLM_API_KEY:
    try:
        proxy_url = os.environ.get('PROXY_URL') or \
                    os.environ.get('HTTPS_PROXY') or \
                    os.environ.get('HTTP_PROXY')

        if proxy_url:
            print(f"💡 使用代理伺服器 (httpx.Client): {proxy_url}")
            # Using httpx.Client directly with 'proxies' argument
            custom_httpx_client = httpx.Client(proxies=proxy_url)
            client = OpenAI(api_key=LLM_API_KEY, http_client=custom_httpx_client)
        else:
            client = OpenAI(api_key=LLM_API_KEY)

        print(f"✅ OpenAI 客戶端初始化成功，使用模型: {CURRENT_MODEL}")
    except Exception as e:
        print(f"❌ OpenAI 客戶端初始化失敗: {e}")
        client = None
else:
    print(f"⚠️ OpenAI 客戶端未初始化 - Provider: {LLM_PROVIDER}, API Key: {'已設置' if LLM_API_KEY else '未設置'}")

def analyze_emotion(text):
    """使用 OpenAI 分析文本情緒"""
    if not client:
        return 'neutral'
    
    try:
        response = client.chat.completions.create(
            model=CURRENT_MODEL,
            messages=[
                {
                    "role": "system", 
                    "content": "你是一個情緒分析專家。請分析給定文本的情緒，只回答以下情緒之一：happy, sad, angry, surprised, confused, excited, neutral, thoughtful。只回答一個單詞，不要任何解釋。"
                },
                {
                    "role": "user", 
                    "content": f"請分析這段文本的情緒：{text}"
                }
            ],
            max_tokens=10,
            temperature=0.3
        )
        
        emotion = response.choices[0].message.content.strip().lower()
        
        # 驗證回應是否在允許的情緒列表中
        valid_emotions = ['happy', 'sad', 'angry', 'surprised', 'confused', 'excited', 'neutral', 'thoughtful']
        if emotion in valid_emotions:
            return emotion
        else:
            return 'neutral'
            
    except Exception as e:
        print(f"情緒分析錯誤: {e}")
        return 'neutral'

def chat_with_llm(message):
    """與 LLM 進行對話"""
    if not client:
        return "抱歉，LLM 服務目前不可用。請檢查 API 設置。"
    
    try:
        response = client.chat.completions.create(
            model=CURRENT_MODEL,
            messages=[
                {
                    "role": "system", 
                    "content": "你是一個友善的 AI 助手，名叫 Emo-Face。你會根據對話內容表達不同的情緒。請用繁體中文回答，保持友善和有趣的語調。"
                },
                {
                    "role": "user", 
                    "content": message
                }
            ],
            max_tokens=500,
            temperature=0.7
        )
        
        return response.choices[0].message.content.strip()
        
    except Exception as e:
        print(f"LLM 對話錯誤: {e}")
        return f"抱歉，我遇到了一些技術問題。錯誤：{str(e)}"

@app.route('/')
def index():
    """主頁面"""
    return render_template('index.html')

@app.route('/health')
def health_check():
    """健康檢查端點"""
    api_status = "configured" if LLM_API_KEY else "not_configured"
    return jsonify({
        'status': 'healthy', 
        'service': 'emo-face',
        'llm_provider': LLM_PROVIDER,
        'api_status': api_status
    })

@app.route('/api/chat', methods=['POST'])
def chat():
    """聊天 API 端點"""
    try:
        data = request.get_json()
        user_message = data.get('message', '')
        
        if not user_message:
            return jsonify({'error': '消息不能為空'}), 400
        
        if not LLM_API_KEY:
            return jsonify({'error': 'LLM API Key 未配置'}), 500
        
        # 使用 LLM 生成回應
        ai_response = chat_with_llm(user_message)
        
        # 分析 AI 回應的情緒
        emotion = analyze_emotion(ai_response)
        
        response = {
            'message': ai_response,
            'emotion': emotion,
            'timestamp': '2025-06-08T12:00:00Z',
            'model': CURRENT_MODEL,
            'provider': LLM_PROVIDER
        }
        
        return jsonify(response)
    
    except Exception as e:
        print(f"聊天 API 錯誤: {e}")
        return jsonify({'error': f'服務器錯誤: {str(e)}'}), 500

@app.route('/api/emotions')
def get_emotions():
    """獲取可用的情緒列表"""
    emotions = [
        'happy', 'sad', 'angry', 'surprised', 
        'confused', 'excited', 'neutral', 'thoughtful'
    ]
    return jsonify({'emotions': emotions})

@app.route('/api/info')
def get_api_info():
    """獲取 API 配置信息"""
    return jsonify({
        'llm_provider': LLM_PROVIDER,
        'model': CURRENT_MODEL,
        'openai_model': OPENAI_MODEL,
        'gemini_model': GEMINI_MODEL,
        'api_configured': bool(LLM_API_KEY),
        'supported_emotions': [
            'happy', 'sad', 'angry', 'surprised', 
            'confused', 'excited', 'neutral', 'thoughtful'
        ]
    })

@app.route('/api/test', methods=['GET'])
def test_api():
    """測試 API 連接是否正常"""
    if not LLM_API_KEY:
        return jsonify({
            'status': 'error',
            'message': 'API Key 未配置',
            'api_configured': False
        }), 400
    
    if not client:
        return jsonify({
            'status': 'error',
            'message': 'OpenAI 客戶端未初始化',
            'api_configured': False
        }), 500
    
    try:
        # 發送一個簡單的測試請求
        test_response = client.chat.completions.create(
            model=CURRENT_MODEL,
            messages=[
                {
                    "role": "user", 
                    "content": "請回答：測試成功"
                }
            ],
            max_tokens=10,
            temperature=0
        )
        
        response_text = test_response.choices[0].message.content.strip()
        
        return jsonify({
            'status': 'success',
            'message': 'API 連接正常',
            'test_response': response_text,
            'model': CURRENT_MODEL,
            'provider': LLM_PROVIDER,
            'api_configured': True
        })
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'API 調用失敗: {str(e)}',
            'api_configured': True,
            'error_details': str(e)
        }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    debug = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)
