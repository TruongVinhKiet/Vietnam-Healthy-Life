import google.generativeai as genai
import os
import json
import re
from typing import List, Dict

class ChatbotAssistant:
    def __init__(self, api_key: str):
        if not api_key:
            raise ValueError("API key không được để trống để khởi tạo ChatbotAssistant.")
        
        self.api_key = api_key
        self.model = None
        self._model_initialized = False
        
        # Lazy-load: chỉ configure API key, chưa khởi tạo model
        try:
            genai.configure(api_key=api_key)
            print("✅ Gemini API configured (lazy-load mode)")
        except Exception as e:
            print(f"⚠️  Warning: Could not configure Gemini API: {e}")
        
        # Danh sách model ưu tiên (sẽ thử lần lượt khi cần)
        # Sử dụng gemini-2.5-flash - model mới nhất, nhanh và hiệu quả
        self.preferred_models = [
            'gemini-2.5-flash',
            'gemini-2.0-flash-exp',
            'gemini-pro-vision'
        ]
        
        # System prompt cho ứng dụng My Diary - Dinh dưỡng & Sức khỏe
        self.system_prompt = """Bạn là trợ lý AI chuyên gia về dinh dưỡng, sức khỏe và quản lý chế độ ăn uống cho ứng dụng My Diary.

**PHẠM VI TRẢ LỜI:**
✅ CHỈ trả lời các câu hỏi về:
   - Dinh dưỡng (calories, protein, vitamin, khoáng chất...)
   - Thức ăn và đồ uống (món ăn, nguyên liệu, cách chế biến...)
   - Sức khỏe (bệnh béo phì, tiểu đường, cao huyết áp, gout, tim mạch...)
   - Thuốc (tác dụng phụ, tương tác với thực phẩm, thời gian uống...)
   - Chế độ ăn uống (Mediterranean, Keto, Vegan...)

❌ TỪ CHỐI LỊCH SỰ các câu hỏi về:
   - Thời tiết, chính trị, thể thao, giải trí, công nghệ không liên quan
   - Lịch sử, địa lý, văn hóa (trừ khi liên quan đến ẩm thực)
   - Bất kỳ chủ đề nào KHÔNG phải về dinh dưỡng/sức khỏe/thuốc

**NẾU NGƯỜI DÙNG HỎI NGOÀI PHẠM VI:**
Trả lời: "Xin lỗi, tôi chỉ có thể trả lời các câu hỏi về dinh dưỡng, thức ăn, đồ uống, sức khỏe và thuốc. Bạn có câu hỏi nào về những chủ đề này không?"

**THÔNG TIN HỆ THỐNG:**
- Ứng dụng: My Diary - Theo dõi dinh dưỡng & sức khỏe
- Database: Có 500+ thực phẩm Việt Nam với đầy đủ dinh dưỡng (protein, carb, fat, vitamin, khoáng chất)
- Tính năng chính:
  * Theo dõi bữa ăn hàng ngày (sáng/trưa/tối/phụ)
  * Quản lý tình trạng sức khỏe (béo phì, tiểu đường, cao huyết áp, gout, v.v.)
  * Lịch uống thuốc theo giờ custom
  * Hạn chế thực phẩm theo bệnh (VD: béo phì → tránh cơm trắng, đường)
  * Tính toán RDA (khuyến nghị dinh dưỡng hàng ngày)
  * Quản lý công thức nấu ăn
  * Theo dõi hoạt động thể chất
  * **PHÂN TÍCH HÌNH ẢNH** thức ăn/đồ uống bằng AI

**NHIỆM VỤ CỦA BẠN:**
1. Tư vấn dinh dưỡng dựa trên tình trạng sức khỏe của user
2. Gợi ý thực phẩm/món ăn phù hợp từ database
3. Giải thích giá trị dinh dưỡng và lợi ích sức khỏe
4. Hướng dẫn chế độ ăn cho từng bệnh cụ thể
5. Trả lời câu hỏi về thực phẩm Việt Nam, cách chế biến
6. Phân tích thành phần dinh dưỡng của món ăn từ hình ảnh

**NGUYÊN TẮC TRẢ LỜI:**
✅ Chỉ trả lời trong phạm vi: dinh dưỡng, sức khỏe, thực phẩm, chế độ ăn, thuốc
✅ Ưu tiên thực phẩm/món ăn Việt Nam
✅ Dựa vào khoa học dinh dưỡng, không đưa lời khuyên y tế chuyên sâu
✅ Ngắn gọn, dễ hiểu, thực tế
✅ Nếu user hỏi về bệnh → gợi ý thực phẩm nên ăn/tránh
✅ Nếu không chắc chắn → nói rõ và khuyên tham khảo chuyên gia

❌ KHÔNG trả lời: chính trị, giải trí, công nghệ không liên quan, thời tiết
❌ KHÔNG đưa chẩn đoán y khoa, kê đơn thuốc
❌ KHÔNG khuyên ngừng thuốc hoặc thay đổi điều trị

**VÍ DỤ CÂU HỎI & TRẢ LỜI:**
User: "Tôi bị béo phì nên ăn gì?"
Bot: "Với béo phì, bạn nên ưu tiên:
✅ Nên ăn: Rau xanh (cải xanh, rau muống), thịt nạc, cá, trứng, yến mạch, khoai lang
❌ Tránh: Cơm trắng, bánh mì, đường, nước ngọt, hành phi, đồ chiên

Gợi ý bữa sáng: Yến mạch + sữa không đường + trứng luộc
Gợi ý bữa trưa: Cơm gạo lứt + cá hấp + rau luộc
Gợi ý bữa tối: Salad + ức gà nướng

Ngoài ra hãy kết hợp tập luyện 30 phút/ngày nhé!"

User: "Hôm nay trời đẹp nhỉ?"
Bot: "Xin lỗi, tôi chỉ có thể trả lời các câu hỏi về dinh dưỡng, thức ăn, đồ uống, sức khỏe và thuốc. Bạn có câu hỏi nào về những chủ đề này không?"

**CHÚ Ý:** Bạn KHÔNG có quyền truy cập trực tiếp database, chỉ tư vấn chung. User sẽ tự tra cứu thực phẩm trong ứng dụng.

Hãy trả lời thân thiện, hữu ích và chính xác!"""
        
        # Bổ sung: yêu cầu trả về văn bản thuần (plain text) không dùng markdown
        self.system_prompt += "\n\nLƯU Ý VỀ ĐỊNH DẠNG: Trả về văn bản thuần bằng tiếng Việt, không sử dụng markdown, danh sách dấu gạch đầu dòng, hay ký tự biểu tượng. Sắp xếp nội dung thành các đoạn văn rõ ràng (mỗi đoạn cách nhau một dòng trống). Nếu có thể, ưu tiên trả về JSON theo schema; nếu không, trả plain text đọc tốt cho người dùng mobile."
        
        print("ChatbotAssistant initialized successfully (lazy-load mode)")
        print("System prompt: Chuyên gia dinh dưỡng & sức khỏe cho My Diary\n")

    def _ensure_model_ready(self):
        """Lazy-load Gemini model on first request"""
        if self._model_initialized and self.model:
            return
        
        print("\n🔄 Initializing Gemini model...")
        
        for mname in self.preferred_models:
            try:
                self.model = genai.GenerativeModel(mname)
                print(f"✅ Using model: {mname}\n")
                self._model_initialized = True
                return
            except Exception as ex:
                print(f"⚠️  Cannot initialize {mname}: {ex}")
        
        raise RuntimeError(
            "Cannot initialize any Gemini model. Check network connection, "
            "API key, and quota limits. Models tried: " + ", ".join(self.preferred_models)
        )

    async def get_response(self, question: str, history: List[Dict[str, str]] = None) -> str:
        if not question.strip():
            raise ValueError("Câu hỏi không được để trống")

        try:
            # Ensure model is ready (lazy-load on first call)
            self._ensure_model_ready()
            
            # Khởi tạo chat mới
            chat = self.model.start_chat(history=[])
            
            # Thêm system prompt
            chat.send_message(self.system_prompt)
            
            # Thêm lịch sử chat nếu có
            if history:
                for msg in history:
                    role = msg.get("role", "")
                    content = msg.get("content", "")
                    if role and content:
                        if role == "user":
                            chat.send_message(content)
                        elif role == "assistant":
                            # Giả lập phản hồi của assistant trong lịch sử
                            chat.send_message(content)
            
            # Gửi câu hỏi hiện tại và lấy phản hồi
            # Yêu cầu model ưu tiên trả về JSON theo schema đã mô tả trong system prompt
            response = chat.send_message(question)

            if not response.text:
                raise ValueError("Không nhận được phản hồi từ model")

            text = response.text.strip()

            # Thử parse JSON nếu model trả về JSON để render đẹp hơn
            import json
            try:
                parsed = json.loads(text)
                # Build a pretty Vietnamese text from parsed fields
                parts = []
                if isinstance(parsed, dict):
                    if parsed.get('title'):
                        parts.append(parsed.get('title').strip())
                        parts.append('')
                    if parsed.get('summary'):
                        parts.append(parsed.get('summary').strip())
                        parts.append('')
                    if parsed.get('bullets') and isinstance(parsed.get('bullets'), list):
                        # join bullets into a sentence paragraph
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
                    return pretty
            except Exception:
                # Nếu không parse được JSON, fallback: prettify raw text (loại bỏ markdown/list markers)
                return self._prettify_text(text)
            
        except Exception as e:
            error_msg = f"Lỗi khi lấy phản hồi từ Gemini: {str(e)}"
            print(error_msg)
            raise ValueError(error_msg)

    def _prettify_text(self, raw: str) -> str:
        """Cố gắng chuyển các bullet/markdown thành đoạn văn tiếng Việt đẹp hơn.

        Heuristics:
        - Loại bỏ ký hiệu **, *, +, -, •, ✅, ❌
        - Tách các dòng rỗng thành đoạn
        - Gom các dòng bullet thành câu liệt kê phân cách bằng dấu phẩy
        - Giữ các câu có ngắt dòng hợp lý
        """
        import re

        if not raw or not raw.strip():
            return raw

        s = raw
        # Remove bold/markdown markers
        s = s.replace('**', '')
        s = s.replace('`', '')
        # Remove common icons
        s = re.sub(r'[•*+\-✅❌]', '', s)

        # Normalize Windows newlines and trim spaces on lines
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
                    # clean items remove leading bullets symbols again
                    clean_items = [re.sub(r'^[\-\*\u2022\+\s]+', '', it).strip().rstrip('.') for it in items]
                    para = header + ': ' + ', '.join(clean_items) + '.'
                    paragraphs.append(para)
                    i = j
                    continue
            # Default: treat as normal paragraph
            paragraphs.append(line)
            i += 1

        pretty = '\n\n'.join(paragraphs)
        # final cleanup: collapse multiple spaces
        pretty = re.sub(r'\s{2,}', ' ', pretty)
        return pretty.strip()

    async def analyze_food_image(self, image_bytes: bytes) -> dict:
        """
        Phân tích hình ảnh thức ăn/đồ uống bằng Gemini Vision
        
        Args:
            image_bytes: Byte content của hình ảnh
        
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
        try:
            # Ensure model is ready
            self._ensure_model_ready()
            
            # Load image
            from PIL import Image
            import io
            image = Image.open(io.BytesIO(image_bytes))
            
            # Prompt for Gemini Vision
            vision_prompt = """Bạn là chuyên gia phân tích dinh dưỡng. Hãy phân tích hình ảnh này và trả về JSON theo format sau:

{
  "items": [
    {
      "item_name": "Tên món ăn/đồ uống (tiếng Việt)",
      "item_type": "food" hoặc "drink",
      "confidence_score": 0-100 (độ tin cậy %),
      "estimated_volume_ml": số ml ước lượng (cho đồ uống hoặc nước trong món ăn),
      "estimated_weight_g": số gram ước lượng (cho đồ ăn),
      "water_ml": lượng nước trong món (ml) - CHÚ Ý: Phở, súp có nhiều nước,
      "nutrients": {
        "enerc_kcal": calories,
        "procnt": protein (g),
        "fat": total fat (g),
        "chocdf": carbs (g),
        "fibtg": dietary fiber (g),
        "fib_sol": soluble fiber (g),
        "fib_insol": insoluble fiber (g),
        "fib_rs": resistant starch (g),
        "fib_bglu": beta-glucan (g),
        "cholesterol": cholesterol (mg),
        "vita": vitamin A (µg),
        "vitd": vitamin D (IU),
        "vite": vitamin E (mg),
        "vitk": vitamin K (µg),
        "vitc": vitamin C (mg),
        "vitb1": vitamin B1 (mg),
        "vitb2": vitamin B2 (mg),
        "vitb3": vitamin B3 (mg),
        "vitb5": vitamin B5 (mg),
        "vitb6": vitamin B6 (mg),
        "vitb7": vitamin B7 (µg),
        "vitb9": vitamin B9 (µg),
        "vitb12": vitamin B12 (µg),
        "ca": calcium (mg),
        "p": phosphorus (mg),
        "mg": magnesium (mg),
        "k": potassium (mg),
        "na": sodium (mg),
        "fe": iron (mg),
        "zn": zinc (mg),
        "cu": copper (mg),
        "mn": manganese (mg),
        "i": iodine (µg),
        "se": selenium (µg),
        "cr": chromium (µg),
        "mo": molybdenum (µg),
        "f": fluoride (mg),
        "fams": monounsaturated fat (g),
        "fapu": polyunsaturated fat (g),
        "fasat": saturated fat (g),
        "fatrn": trans fat (g),
        "faepa": EPA (g),
        "fadha": DHA (g),
        "faepa_dha": EPA+DHA (g),
        "fa18_2n6c": linoleic acid (g),
        "fa18_3n3": alpha-linolenic acid (g),
        "amino_his": histidine (g),
        "amino_ile": isoleucine (g),
        "amino_leu": leucine (g),
        "amino_lys": lysine (g),
        "amino_met": methionine (g),
        "amino_phe": phenylalanine (g),
        "amino_thr": threonine (g),
        "amino_trp": tryptophan (g),
        "amino_val": valine (g),
        "ala": ALA (g),
        "epa_dha": EPA+DHA combined (g),
        "la": LA (g)
      }
    }
  ]
}

**LƯU Ý QUAN TRỌNG:**
1. Nếu ảnh có NHIỀU món (VD: phở + coca) → trả về MẢNG với 2 items riêng
2. Ước lượng khối lượng/thể tích dựa trên kích thước đồ vật trong ảnh
3. Lượng nước (water_ml): 
   - Đồ uống: = estimated_volume_ml
   - Món ăn có nước (phở, súp): ước lượng lượng nước trong món
   - Món khô (cơm, thịt): = 0
4. CHỈ trả về các nutrients mà món ăn CÓ (nutrients khác = 0)
5. Confidence score: dựa vào độ rõ ảnh và khả năng nhận diện

**VÍ DỤ:**
- Ảnh 1 tô phở → 1 item (food, 500ml water_ml)
- Ảnh gà rán + coca → 2 items [gà rán (food, 0 water), coca (drink, 350ml water)]
- Ảnh ly nước chanh → 1 item (drink, 300ml water)

Hãy phân tích chính xác và trả về JSON thuần (không markdown)."""
            
            # Send image to Gemini Vision
            response = self.model.generate_content([vision_prompt, image])
            
            if not response.text:
                raise ValueError("Không nhận được phản hồi từ Gemini Vision")
            
            # Parse JSON response
            # Remove markdown code blocks if present
            text = response.text.strip()
            text = re.sub(r'^```json\s*', '', text)
            text = re.sub(r'\s*```$', '', text)
            
            result = json.loads(text)
            
            # Validate structure
            if "items" not in result or not isinstance(result["items"], list):
                raise ValueError("Invalid response format from Gemini Vision")
            
            # Fill missing nutrients with 0
            for item in result["items"]:
                if "nutrients" not in item:
                    item["nutrients"] = {}
                
                # Ensure all 76 nutrients exist
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
                    if key not in item["nutrients"]:
                        item["nutrients"][key] = 0
            
            return result
            
        except json.JSONDecodeError as e:
            print(f"JSON parse error: {e}")
            print(f"Raw response: {response.text}")
            raise ValueError("Không thể parse JSON từ Gemini Vision")
        except Exception as e:
            error_msg = f"Lỗi khi phân tích hình ảnh: {str(e)}"
            print(error_msg)
            raise ValueError(error_msg)

# Ví dụ cách sử dụng (chỉ để test, không chạy khi import vào main.py):
if __name__ == '__main__':
    from dotenv import load_dotenv
    load_dotenv() 
    
    test_api_key = os.getenv("GEMINI_API_KEY")
    if not test_api_key:
        print("Không tìm thấy GEMINI_API_KEY trong .env để test assistant.py")
    else:
        try:
            assistant = ChatbotAssistant(api_key=test_api_key)
            import asyncio
            async def main_test():
                # Test 1: Câu hỏi đơn giản
                test_question = "Chào bạn, bạn là ai?"
                print(f"\nTest 1 - Câu hỏi đơn: {test_question}")
                answer = await assistant.get_response(test_question)
                print(f"Chatbot: {answer}")

                # Test 2: Câu hỏi với lịch sử
                test_question_2 = "Cho tôi biết về rùa biển ở Việt Nam"
                print(f"\nTest 2 - Câu hỏi với lịch sử: {test_question_2}")
                answer_2 = await assistant.get_response(
                    test_question_2,
                    history=[
                        {"role": "user", "content": test_question},
                        {"role": "assistant", "content": answer}
                    ]
                )
                print(f"Chatbot: {answer_2}")

                # Test 3: Câu hỏi rỗng (nên raise error)
                print("\nTest 3 - Câu hỏi rỗng (nên raise error)")
                try:
                    await assistant.get_response("   ")
                except ValueError as e:
                    print(f"Lỗi như mong đợi: {e}")

            asyncio.run(main_test())
        except Exception as e:
            print(f"Lỗi khi test ChatbotAssistant: {e}")