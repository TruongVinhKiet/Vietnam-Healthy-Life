import os
from fastapi import FastAPI, HTTPException, Request, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
import uvicorn
from PIL import Image
import io
import json as json_module
import google.generativeai as genai  

load_dotenv() # Tải các biến môi trường từ tệp .env

app = FastAPI()

ALLOWED_ORIGINS = [
    "http://localhost:5500",  # Dev server
    "http://127.0.0.1:5500",  # Dev server alternative
    "http://localhost:8081",  # Production server
    "http://127.0.0.1:8081",  # Production server alternative
    "http://127.0.0.1:127",   # Add this for the client origin
    "*"  # Tạm thời cho phép tất cả origin trong quá trình phát triển
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Lấy API Key từ biến môi trường - Fallback chain: Gemini → OpenRouter
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")

if not GEMINI_API_KEY and not OPENROUTER_API_KEY:
    raise ValueError("Cần ít nhất một trong hai: GEMINI_API_KEY hoặc OPENROUTER_API_KEY trong file .env")

# Import assistant class - luôn dùng assistant_openrouter vì nó hỗ trợ multi-provider
from assistant_openrouter import ChatbotAssistant

try:
    # Pass keys: Gemini primary, OpenRouter fallback
    chatbot_assistant = ChatbotAssistant(
        gemini_api_key=GEMINI_API_KEY,      # Primary
        openrouter_api_key=OPENROUTER_API_KEY  # Fallback
    )
    
    providers = []
    if GEMINI_API_KEY:
        providers.append("Gemini (Primary)")
    if OPENROUTER_API_KEY:
        providers.append("OpenRouter (Fallback)")
    
    print(f"✅ ChatbotAssistant ready with fallback chain: {' → '.join(providers)}\n")
except Exception as e:
    print(f"⚠️  Warning: ChatbotAssistant initialization issue: {e}")
    print("Server will start anyway. API calls may fail if network/quota issues persist.\n")
    chatbot_assistant = None  # Allow server to start

# Model Pydantic để validate dữ liệu đầu vào cho API
class ChatRequest(BaseModel):
    question: str
    history: list[dict[str, str]] = []

    class Config:
        schema_extra = {
            "example": {
                "question": "Cho tôi biết về rùa biển",
                "history": [
                    {"role": "user", "content": "Xin chào"},
                    {"role": "assistant", "content": "Chào bạn! Tôi có thể giúp gì cho bạn?"}
                ]
            }
        }

@app.post("/chat")
async def chat_endpoint(chat_request: ChatRequest):
    try:
        # Validate input
        if not chat_request.question.strip():
            raise HTTPException(
                status_code=400,
                detail="Câu hỏi không được để trống"
            )
            
        answer = await chatbot_assistant.get_response(chat_request.question, chat_request.history)
        return {"answer": answer}
    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        print(f"Lỗi trong chat_endpoint khi gọi assistant.get_response: {e}")
        raise HTTPException(
            status_code=500, 
            detail="Xin lỗi, có lỗi xảy ra khi xử lý yêu cầu của bạn. Vui lòng thử lại sau."
        )

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/cache-stats")
async def cache_stats():
    """
    Lấy thống kê cache để monitor hiệu quả
    
    Returns:
        {
            "total_entries": 150,
            "total_cache_hits": 1250,
            "average_hits_per_entry": 8.33,
            "estimated_api_calls_saved": 1100
        }
    """
    from cache_manager import get_cache_instance
    cache = get_cache_instance()
    stats = cache.get_stats()
    
    # Calculate API calls saved (hits - entries = số lần không cần gọi API)
    api_calls_saved = stats["total_cache_hits"] - stats["total_entries"]
    stats["estimated_api_calls_saved"] = max(0, api_calls_saved)
    
    return stats

@app.post("/cache-cleanup")
async def cache_cleanup(days_to_keep: int = 30):
    """
    Cleanup old cache entries
    
    Args:
        days_to_keep: Số ngày giữ lại (default 30)
    """
    from cache_manager import get_cache_instance
    cache = get_cache_instance()
    deleted = cache.cleanup_old_entries(days_to_keep)
    
    return {
        "status": "success",
        "deleted_entries": deleted,
        "message": f"Cleaned up entries older than {days_to_keep} days"
    }

@app.post("/analyze-image")
async def analyze_image_endpoint(file: UploadFile = File(...)):
    """
    Phân tích hình ảnh thức ăn/đồ uống bằng MOCK DATA
    
    Accepts: multipart/form-data với field "file"
    Returns: JSON với danh sách món ăn/đồ uống và nutrients
    """
    try:
        from mock_nutrition_data import get_mock_nutrition_by_filename
        
        # Get filename
        filename = file.filename if file.filename else "default"
        
        # Đọc file ảnh (chỉ để validate, không phân tích thực)
        image_bytes = await file.read()
        
        if len(image_bytes) == 0:
            raise HTTPException(status_code=400, detail="File ảnh rỗng")
        
        # ALWAYS USE MOCK DATA BASED ON FILENAME
        # Simulate AI processing delay (10-15 seconds)
        import random
        import asyncio
        delay = random.uniform(10, 15)
        await asyncio.sleep(delay)
        
        mock_result = get_mock_nutrition_by_filename(filename)
        
        # Convert nutrients array to object format that backend expects
        # Backend expects lowercase keys with specific formatting:
        # - Minerals: WITHOUT MIN_ prefix (ca, fe, zn)
        # - Amino acids: WITH amino_ prefix (amino_his, amino_ile)  
        # - Fiber: lowercase as-is (fibtg, fib_sol)
        # - Fatty acids: lowercase as-is (fams, fapu)
        # - Vitamins: lowercase as-is (vita, vitd, vitb1)
        nutrients_obj = {}
        for nutrient in mock_result.get("nutrients", []):
            code = nutrient["nutrient_code"]
            # Remove MIN_ prefix from minerals
            if code.startswith("MIN_"):
                code = code.replace("MIN_", "")
            # Convert to lowercase
            code = code.lower()
            nutrients_obj[code] = nutrient["amount"]
        
        # Random confidence between 90-95%
        random_confidence = random.uniform(0.90, 0.95)
        
        # Convert to analyze-image format (items array)
        result = {
            "items": [{
                "item_name": mock_result.get("food_name", "Món ăn"),
                "item_type": "food",
                "confidence_score": random_confidence,
                "estimated_volume_ml": 250,
                "estimated_weight_g": 200,
                "water_ml": nutrients_obj.get("water", 0),
                "nutrients": nutrients_obj
            }]
        }
        
        return result
        
    except Exception as e:
        print(f"[analyze_image_endpoint] Error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Lỗi khi phân tích ảnh: {str(e)}"
        )

@app.post("/analyze-nutrition")
async def analyze_nutrition(request: Request):
    """
    Analyze food nutrition from image using MOCK DATA ONLY
    Accepts both multipart file upload and base64 encoded image
    Returns detailed nutrition breakdown based on filename pattern
    """
    try:
        from mock_nutrition_data import get_mock_nutrition_by_filename
        
        # Check if request is JSON (base64) or multipart
        content_type = request.headers.get('content-type', '')
        filename = "default"  # Default fallback
        
        if 'application/json' in content_type:
            # Handle base64 image from JSON
            body = await request.json()
            # Developer simulation: if caller supplies a simulated_result, return it directly
            if isinstance(body, dict) and body.get('simulate') and body.get('simulated_result'):
                return body.get('simulated_result')
            
            # Get filename if provided
            filename = body.get('filename', 'default')
            base64_image = body.get('image')
            # Get filename if provided
            filename = body.get('filename', 'default')
            base64_image = body.get('image')
            if not base64_image:
                raise HTTPException(status_code=400, detail="No image data provided")
            
            # Decode base64 (just to validate, we don't actually analyze)
            import base64
            image_data = base64.b64decode(base64_image)
            image = Image.open(io.BytesIO(image_data))
        else:
            # Handle multipart file upload
            form = await request.form()
            file = form.get('file')
            if not file:
                raise HTTPException(status_code=400, detail="No file uploaded")
            
            # Get filename from uploaded file
            if hasattr(file, 'filename'):
                filename = file.filename
            
            image_data = await file.read()
            image = Image.open(io.BytesIO(image_data))
        
        # USE MOCK DATA BASED ON FILENAME - NO MORE REAL API CALLS
        # Simulate AI processing delay (10-15 seconds)
        import random
        import asyncio
        delay = random.uniform(10, 15)
        await asyncio.sleep(delay)
        
        result = get_mock_nutrition_by_filename(filename)
        
        return result
        
    except Exception as je:
        print(f"Error analyzing nutrition: {je}")
        return {
            "is_food": False,
            "food_name": None,
            "confidence": 0,
            "nutrients": [],
            "error": str(je)
        }

if __name__ == "__main__":
    print("Khởi động server với uvicorn...")
    uvicorn.run(app, host="0.0.0.0", port=8000) 