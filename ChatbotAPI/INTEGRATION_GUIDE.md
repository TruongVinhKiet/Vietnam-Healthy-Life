# Hướng Dẫn Tích Hợp & Tối Ưu Token

## 📋 Tổng Quan

Hệ thống đã được tối ưu để:
- ✅ **Chỉ dùng token cho chat** (hỏi đáp)
- ✅ **Phân tích hình ảnh dùng mock data hoàn toàn** (không tốn token)
- ✅ **Fallback chain**: OpenRouter → OpenAI → Gemini (chỉ cho chat)
- ✅ **System prompt tối ưu**: Giảm từ ~100 dòng xuống ~30 dòng (tiết kiệm ~70% token)

## 🔑 Cấu Hình API Keys

Thêm các API keys vào file `.env`:

```env
# Primary (ưu tiên)
GEMINI_API_KEY=your-gemini-api-key

# Fallback (nếu Gemini fail)
OPENROUTER_API_KEY=sk-or-v1-xxxxx
```

**Lưu ý**: Cần ít nhất 1 trong 2 keys để hệ thống hoạt động.

**Lưu ý về npm**: Không cần `npm install @google/generative-ai` vì đây là Python project. Chỉ cần cài package Python:
```bash
pip install google-generativeai
```

## 🔄 Fallback Chain (Chỉ Cho Chat)

Khi gọi API chat, hệ thống sẽ thử theo thứ tự:

1. **Gemini Direct** (Primary)
   - Model: `gemini-1.5-flash`
   - Nếu thành công → trả về kết quả
   - Nếu fail (429, 500, etc.) → chuyển sang bước 2

2. **OpenRouter** (Fallback)
   - Model: `google/gemini-2.0-flash-exp:free`
   - Nếu thành công → trả về kết quả
   - Nếu fail → throw error

## 📸 Phân Tích Hình Ảnh (Mock Data Only)

**QUAN TRỌNG**: Hàm `analyze_food_image()` **KHÔNG gọi API**, chỉ dùng mock data để tiết kiệm token.

### Cách Hoạt Động:

1. Nhận `filename` từ request
2. Match filename với mock data trong `mock_nutrition_data.py`
3. Trả về kết quả ngay lập tức (1-2 giây delay để simulate)

### Mock Data Mapping:

- `pho-bo.jpg` → Phở Bò
- `banhxeo.jpg` → Bánh Xèo
- `nuocchanh.jpg` → Nước Chanh
- `burger-combo.jpg` → Combo Jollibee
- `scaled33.jpg` → Phở Bò (Android scaled files)
- ... (xem `mock_nutrition_data.py` để biết thêm)

## 💰 Tối Ưu Token

### 1. System Prompt Tối Ưu

**Trước** (~100 dòng, ~2000 tokens):
```
Bạn là trợ lý AI chuyên gia về dinh dưỡng...
[100 dòng chi tiết]
```

**Sau** (~30 dòng, ~600 tokens):
```
Bạn là trợ lý AI chuyên gia dinh dưỡng & sức khỏe cho ứng dụng My Diary.
PHẠM VI: Chỉ trả lời về dinh dưỡng, thức ăn, đồ uống, sức khỏe, thuốc...
[30 dòng ngắn gọn]
```

**Tiết kiệm**: ~70% token cho mỗi request!

### 2. History Limiting

- Chỉ lấy **10 messages gần nhất** từ history
- Giảm token cho các cuộc hội thoại dài

### 3. Image Analysis = 0 Token

- Phân tích hình ảnh **KHÔNG dùng token**
- Chỉ dùng mock data dựa trên filename

## 🚀 Sử Dụng

### 1. Chat Endpoint

```bash
POST /chat
Content-Type: application/json

{
  "question": "Tôi bị béo phì nên ăn gì?",
  "history": [
    {"role": "user", "content": "Xin chào"},
    {"role": "assistant", "content": "Chào bạn!"}
  ]
}
```

**Response:**
```json
{
  "answer": "Với béo phì, bạn nên ưu tiên rau xanh, thịt nạc, cá..."
}
```

### 2. Image Analysis Endpoint

```bash
POST /analyze-image
Content-Type: multipart/form-data

file: [image file]
```

**Response:**
```json
{
  "items": [{
    "item_name": "Phở Bò",
    "item_type": "food",
    "confidence_score": 0.92,
    "estimated_weight_g": 600,
    "water_ml": 400,
    "nutrients": {
      "enerc_kcal": 350,
      "procnt": 25,
      ...
    }
  }]
}
```

**Lưu ý**: Kết quả dựa trên `filename`, không phải nội dung ảnh thực tế.

## 📊 Monitoring

### Cache Stats

```bash
GET /cache-stats
```

**Response:**
```json
{
  "total_entries": 150,
  "total_cache_hits": 1250,
  "average_hits_per_entry": 8.33,
  "estimated_api_calls_saved": 1100
}
```

### Health Check

```bash
GET /health
```

## ⚠️ Lưu Ý Quan Trọng

1. **Image Analysis = Mock Data**: Không gọi API, chỉ dùng mock data
2. **Chat = Real API**: Gọi API thật với fallback chain
3. **Token Optimization**: System prompt đã được tối ưu, history bị giới hạn
4. **Fallback Chain**: Chỉ áp dụng cho chat, không áp dụng cho image analysis

## 🔧 Troubleshooting

### Lỗi: "Tất cả providers đều thất bại"

**Nguyên nhân**:
- Gemini API key không hợp lệ hoặc hết quota
- OpenRouter API key không hợp lệ hoặc hết quota
- Network issues
- Chưa cài package `google-generativeai`

**Giải pháp**:
1. Kiểm tra API keys trong `.env`
2. Cài đặt package: `pip install google-generativeai`
3. Kiểm tra quota của từng provider
4. Kiểm tra network connection

### Image Analysis trả về sai món ăn

**Nguyên nhân**: Mock data dựa trên `filename`, không phải nội dung ảnh

**Giải pháp**: Đảm bảo filename match với database trong `mock_nutrition_data.py`

## 📝 File Structure

```
ChatbotAPI/
├── assistant_openrouter.py    # Multi-provider chat với fallback chain
├── assistant.py                # Gemini-only implementation (legacy)
├── main.py                     # FastAPI server
├── mock_nutrition_data.py      # Mock data cho image analysis
├── cache_manager.py           # Cache cho image analysis (không dùng nữa)
└── INTEGRATION_GUIDE.md       # File này
```

## 🎯 Best Practices

1. **Luôn có ít nhất 2 API keys** để đảm bảo fallback (Gemini + OpenRouter)
2. **Monitor token usage** qua logs
3. **Sử dụng cache** cho các câu hỏi lặp lại (nếu implement)
4. **Giới hạn history** để tiết kiệm token
5. **Test fallback chain** bằng cách tắt Gemini key để test OpenRouter
6. **Cài đặt dependencies**: `pip install google-generativeai httpx`

## 📞 Support

Nếu có vấn đề, kiểm tra:
1. Logs trong console
2. API keys trong `.env`
3. Network connectivity
4. Provider quotas

---

**Version**: 2.0  
**Last Updated**: 2024  
**Author**: AI Assistant

