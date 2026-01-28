import os
import json
import re
import base64
from typing import List, Dict
import httpx
import google.generativeai as genai
from cache_manager import get_cache_instance

class ChatbotAssistant:
    def __init__(self, gemini_api_key: str = None, openrouter_api_key: str = None):
        """
        Initialize ChatbotAssistant với thứ tự ưu tiên: Gemini → OpenRouter
        
        Args:
            gemini_api_key: Gemini Direct API key (Primary)
            openrouter_api_key: OpenRouter API key (Fallback)
        """
        if not gemini_api_key and not openrouter_api_key:
            raise ValueError("Cần ít nhất một trong hai: GEMINI_API_KEY hoặc OPENROUTER_API_KEY")
        
        self.gemini_api_key = gemini_api_key  # Gemini Direct API (Primary)
        self.openrouter_api_key = openrouter_api_key  # OpenRouter API (Fallback)
        self.base_url = "https://openrouter.ai/api/v1"
        self.openrouter_model = "google/gemini-2.0-flash-exp:free"
        # Try gemini-1.5-flash-latest first, fallback to gemini-pro if not available
        self.gemini_model_name = "gemini-1.5-flash-latest"  # Gemini model
        
        # Gemini Direct API setup (lazy-load)
        self.gemini_model = None
        if gemini_api_key:
            try:
                genai.configure(api_key=gemini_api_key)
                print("✅ Gemini Direct API configured as PRIMARY")
            except Exception as e:
                print(f"⚠️  Gemini Direct API config failed: {e}")
        
        # Tối ưu system prompt - giảm từ ~100 dòng xuống ~30 dòng để tiết kiệm token
        self.system_prompt = """Bạn là trợ lý AI chuyên gia dinh dưỡng & sức khỏe cho ứng dụng My Diary.

PHẠM VI: Chỉ trả lời về dinh dưỡng, thức ăn, đồ uống, sức khỏe, thuốc, chế độ ăn. Từ chối lịch sự các câu hỏi ngoài phạm vi.

NGUYÊN TẮC:
- Ưu tiên thực phẩm Việt Nam
- Ngắn gọn, dễ hiểu, dựa trên khoa học
- Không đưa chẩn đoán y khoa hay kê đơn
- Nếu không chắc → khuyên tham khảo chuyên gia

ĐỊNH DẠNG: Trả về văn bản thuần tiếng Việt, không markdown, không ký tự biểu tượng. Ưu tiên JSON nếu có thể, nếu không thì plain text."""
        
        print(f"✅ ChatbotAssistant initialized with fallback chain")
        if self.gemini_api_key:
            print(f"✅ Primary: Gemini Direct ({self.gemini_model_name})")
        if self.openrouter_api_key:
            print(f"✅ Fallback: OpenRouter ({self.openrouter_model})")
        print("System prompt: Tối ưu token (~30 dòng thay vì ~100 dòng)\n")

    async def get_response(self, question: str, history: List[Dict[str, str]] = None) -> str:
        """
        Get response với fallback chain: OpenRouter → OpenAI → Gemini
        Chỉ dùng cho chat, không dùng cho phân tích hình ảnh
        """
        if not question.strip():
            raise ValueError("Câu hỏi không được để trống")

        # Build messages array (tối ưu: chỉ lấy 5-10 messages gần nhất để giảm token)
        messages = [{"role": "system", "content": self.system_prompt}]

        # Limit history to last 10 messages to save tokens
        if history:
            limited_history = history[-10:] if len(history) > 10 else history
            for msg in limited_history:
                role = msg.get("role", "")
                content = msg.get("content", "")
                if role and content and role in ["user", "assistant"]:
                    messages.append({"role": role, "content": content})

        messages.append({"role": "user", "content": question})

        # Fallback chain: Gemini → OpenRouter
        last_error = None
        
        # Try 1: Gemini Direct (Primary)
        gemini_error = None
        if self.gemini_api_key:
            # First, try to list available models
            available_models = []
            try:
                print("🔍 Listing available Gemini models...")
                for model in genai.list_models():
                    if 'generateContent' in model.supported_generation_methods:
                        model_name = model.name.replace('models/', '')
                        available_models.append(model_name)
                        print(f"   ✅ Found: {model_name}")
                
                if available_models:
                    print(f"📋 Using first available model: {available_models[0]}")
                    gemini_models = available_models
                else:
                    # Fallback to common model names if list_models fails
                    gemini_models = [
                        "gemini-pro",
                        "gemini-1.5-pro",
                        "gemini-1.5-flash",
                        "models/gemini-pro",
                        "models/gemini-1.5-pro"
                    ]
            except Exception as list_error:
                print(f"⚠️  Could not list models: {list_error}")
                # Fallback to common model names
                gemini_models = [
                    "gemini-pro",
                    "gemini-1.5-pro", 
                    "gemini-1.5-flash",
                    "models/gemini-pro",
                    "models/gemini-1.5-pro"
                ]
            
            for model_name in gemini_models:
                try:
                    print(f"🔄 Trying Gemini Direct (Primary) with {model_name}...")
                    # Create new model instance for each try
                    test_model = genai.GenerativeModel(model_name)
                    
                    # Build prompt with system message and history
                    full_prompt = self.system_prompt + "\n\n"
                    
                    # Add history
                    for msg in messages[1:-1]:  # Skip system and last user message
                        role = msg["role"]
                        content = msg["content"]
                        if role == "user":
                            full_prompt += f"User: {content}\n"
                        elif role == "assistant":
                            full_prompt += f"Assistant: {content}\n"
                    
                    # Add current question
                    full_prompt += f"User: {question}\nAssistant:"
                    
                    # Try generate_content directly (simpler approach)
                    response = test_model.generate_content(full_prompt)
                    text = response.text.strip() if response.text else None
                    
                    if text:
                        print(f"✅ Success with Gemini Direct ({model_name})")
                        # Save working model for next time
                        self.gemini_model = test_model
                        self.gemini_model_name = model_name
                        return self._process_response(text)
                    else:
                        raise ValueError("Empty response from Gemini")
                        
                except Exception as e:
                    gemini_error = str(e)
                    error_msg = str(e)
                    # Check if it's an API not enabled error
                    if "API key not valid" in error_msg or "not enabled" in error_msg.lower():
                        print(f"❌ Gemini API error: {error_msg}")
                        print("💡 HINT: Make sure Gemini API is enabled in Google Cloud Console")
                        print("   Visit: https://makersuite.google.com/app/apikey")
                    elif "404" in error_msg or "not found" in error_msg.lower():
                        print(f"❌ Model {model_name} not found: {error_msg[:100]}")
                    else:
                        print(f"❌ Gemini Direct failed with {model_name}: {error_msg[:200]}")
                    # Try next model
                    continue
            
            # All Gemini models failed
            if gemini_error:
                last_error = f"Gemini Direct: {gemini_error}"
                print(f"❌ All Gemini models failed. Last error: {last_error}")
        
        # Try 2: OpenRouter (Fallback)
        if self.openrouter_api_key:
            try:
                print("🔄 Falling back to OpenRouter...")
                async with httpx.AsyncClient(timeout=60.0) as client:
                    response = await client.post(
                        f"{self.base_url}/chat/completions",
                        headers={
                            "Authorization": f"Bearer {self.openrouter_api_key}",
                            "Content-Type": "application/json",
                            "HTTP-Referer": "https://mydiary.app",
                            "X-Title": "My Diary Nutrition App"
                        },
                        json={"model": self.openrouter_model, "messages": messages}
                    )
                
                    if response.status_code == 200:
                        result = response.json()
                        if "choices" in result and len(result["choices"]) > 0:
                            text = result["choices"][0]["message"]["content"].strip()
                            if text:
                                print("✅ Success with OpenRouter")
                                return self._process_response(text)
                    else:
                        # Rate limit or error
                        if response.status_code == 429:
                            raise ValueError(f"OpenRouter rate limited: {response.text}")
                        else:
                            raise ValueError(f"OpenRouter error {response.status_code}: {response.text}")
                        
            except Exception as e:
                last_error = str(e)
                print(f"❌ OpenRouter failed: {last_error}")
        
        # All providers failed
        raise ValueError(f"Tất cả providers đều thất bại. Lỗi cuối: {last_error}")
    
    def _process_response(self, text: str) -> str:
        """Process và prettify response text"""
        try:
            parsed = json.loads(text)
            # Build pretty text from JSON
            parts = []
            if isinstance(parsed, dict):
                if parsed.get('title'):
                    parts.append(parsed.get('title').strip())
                    parts.append('')
                if parsed.get('summary'):
                    parts.append(parsed.get('summary').strip())
                    parts.append('')
                if parsed.get('bullets') and isinstance(parsed.get('bullets'), list):
                    bullets = [b.strip().rstrip('.') for b in parsed.get('bullets') if b]
                    if bullets:
                        parts.append('Bạn nên: ' + ', '.join(bullets) + '.')
                        parts.append('')
                if parsed.get('meals') and isinstance(parsed.get('meals'), list):
                    parts.append('\n'.join([m.strip() for m in parsed.get('meals') if m]))
                    parts.append('')
                if parsed.get('notes'):
                    parts.append('Ghi chú: ' + parsed.get('notes').strip())
            
            pretty = '\n'.join([p for p in parts if p is not None and p != ''])
            return pretty if pretty else self._prettify_text(text)
        except:
            return self._prettify_text(text)

    def _prettify_text(self, raw: str) -> str:
        """Cố gắng chuyển các bullet/markdown thành đoạn văn tiếng Việt đẹp hơn."""
        if not raw or not raw.strip():
            return raw

        s = raw
        # Remove bold/markdown markers
        s = s.replace('**', '')
        s = s.replace('`', '')
        # Remove common icons
        s = re.sub(r'[•*+\-✅❌]', '', s)

        # Normalize newlines and trim spaces
        lines = [ln.strip() for ln in re.split(r'[\r\n]+', s) if ln.strip()]
        if not lines:
            return s.strip()

        paragraphs = []
        i = 0
        while i < len(lines):
            line = lines[i]
            # If line ends with ':' treat following lines as list -> join with commas
            if line.endswith(':') or re.search(r'^(Nên|Ưu|Hạn chế|Gợi ý|Gợi ý bữa|Bạn nên|Nên hạn chế)', line, re.I):
                header = line.rstrip(':').strip()
                items = []
                j = i + 1
                while j < len(lines) and not lines[j].endswith(':'):
                    items.append(lines[j].strip())
                    j += 1
                if items:
                    clean_items = [re.sub(r'^[\-\*\u2022\+\s]+', '', it).strip().rstrip('.') for it in items]
                    para = header + ': ' + ', '.join(clean_items) + '.'
                    paragraphs.append(para)
                    i = j
                    continue
            # Default: treat as normal paragraph
            paragraphs.append(line)
            i += 1

        pretty = '\n\n'.join(paragraphs)
        # Final cleanup: collapse multiple spaces
        pretty = re.sub(r'\s{2,}', ' ', pretty)
        return pretty.strip()

    async def analyze_food_image(self, image_bytes: bytes, filename: str = "default") -> dict:
        """
        Phân tích hình ảnh thức ăn/đồ uống - CHỈ DÙNG MOCK DATA (không gọi API để tiết kiệm token)
        
        Args:
            image_bytes: Byte content của hình ảnh (không sử dụng, chỉ để tương thích)
            filename: Tên file để match với mock data
        
        Returns:
            {
                "items": [
                    {
                        "item_name": "Phở Bò",
                        "item_type": "food",
                        "confidence_score": 92.5,
                        "estimated_volume_ml": 500,
                        "estimated_weight_g": 600,
                        "water_ml": 400,
                        "nutrients": {
                            "enerc_kcal": 350,
                            "procnt": 25,
                            ... (76 nutrients)
                        }
                    }
                ]
            }
        """
        print("📸 Image analysis: Using MOCK DATA only (no API calls to save tokens)")
        
        # Import mock data function
        from mock_nutrition_data import get_mock_nutrition_by_filename
        
        # Get mock data based on filename
        mock_result = get_mock_nutrition_by_filename(filename)
        
        # Convert to analyze-image format
        nutrients_obj = {}
        for nutrient in mock_result.get("nutrients", []):
            code = nutrient["nutrient_code"]
            # Remove MIN_ prefix from minerals
            if code.startswith("MIN_"):
                code = code.replace("MIN_", "")
            # Convert to lowercase
            code = code.lower()
            nutrients_obj[code] = nutrient["amount"]
        
        # Ensure all 76 nutrients exist (fill missing with 0)
        nutrient_keys = [
            "enerc_kcal", "procnt", "fat", "chocdf",
            "fibtg", "fib_sol", "fib_insol", "fib_rs", "fib_bglu",
            "cholesterol",
            "vita", "vitd", "vite", "vitk", "vitc",
            "vitb1", "vitb2", "vitb3", "vitb5", "vitb6", "vitb7", "vitb9", "vitb12",
            "ca", "p", "mg", "k", "na", "fe", "zn", "cu", "mn", "i", "se", "cr", "mo", "f",
            "fams", "fapu", "fasat", "fatrn", "faepa", "fadha", "faepa_dha", "fa18_2n6c", "fa18_3n3",
            "amino_his", "amino_ile", "amino_leu", "amino_lys", "amino_met",
            "amino_phe", "amino_thr", "amino_trp", "amino_val",
            "ala", "epa_dha", "la"
        ]
        
        for key in nutrient_keys:
            if key not in nutrients_obj:
                nutrients_obj[key] = 0
        
        # Random confidence between 90-95%
        import random
        random_confidence = random.uniform(0.90, 0.95)
        
        # Simulate processing delay (1-2 seconds)
        import asyncio
        await asyncio.sleep(random.uniform(1, 2))
        
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
        
        print(f"✅ Mock analysis complete: {mock_result.get('food_name', 'Unknown')}")
        return result
