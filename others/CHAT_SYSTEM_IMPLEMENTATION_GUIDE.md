# HƯỚNG DẪN TRIỂN KHAI HỆ THỐNG CHATBOT VÀ LIÊN HỆ ADMIN

## ✅ Đã Hoàn Thành

### 1. Database Migration
- **File**: `backend/migrations/2025_chat_system.sql`
- **Bảng đã tạo**:
  - `ChatbotConversation`: Lưu cuộc trò chuyện với chatbot
  - `ChatbotMessage`: Tin nhắn chatbot (hỗ trợ text + hình ảnh + nutrition data)
  - `AdminConversation`: Cuộc trò chuyện với admin
  - `AdminMessage`: Tin nhắn với admin
  - `NutritionAnalysis`: Cache kết quả phân tích dinh dưỡng từ AI

**Chạy migration**:
```sql
psql -U postgres -d my_diary_db -f backend/migrations/2025_chat_system.sql
```

### 2. Backend APIs
- **Controllers**:
  - `backend/controllers/chatController.js`: Chatbot endpoints
  - `backend/controllers/adminChatController.js`: Admin chat endpoints
- **Routes**: `backend/routes/chatRoutes.js`
- **Đã thêm vào**: `backend/index.js`

**Endpoints hoạt động**:
```
# Chatbot
GET  /chat/chatbot/conversation
GET  /chat/chatbot/conversation/:id/messages
POST /chat/chatbot/conversation/:id/message
POST /chat/chatbot/conversation/:id/analyze-image
POST /chat/chatbot/message/:messageId/approve

# Admin Chat
GET  /chat/admin-chat/conversation
GET  /chat/admin-chat/conversation/:id/messages
POST /chat/admin-chat/conversation/:id/message
GET  /chat/admin-chat/unread-count
```

### 3. AI Nutrition Analysis
- **File**: `ChatbotAPI/main.py`
- **Endpoint mới**: `POST /analyze-nutrition`
- **Dependencies cập nhật**: `ChatbotAPI/requirements.txt`

**Cài đặt**:
```powershell
cd D:\new\ChatbotAPI
pip install -r requirements.txt
```

**Chạy AI server**:
```powershell
cd D:\new\ChatbotAPI
python main.py
```

### 4. Flutter Service Layer
- **File**: `lib/services/chat_service.dart`
- **Methods**:
  - `getChatbotConversation()`, `sendChatbotMessage()`
  - `analyzeFoodImage()`, `approveNutrition()`
  - `getAdminConversation()`, `sendAdminMessage()`
  - `getUnreadCount()`

## 🚧 Cần Hoàn Thành

### 5. Flutter UI Components (Cần tạo thêm)

#### A. Floating Chat Button
**File cần tạo**: `lib/widgets/floating_chat_button.dart`
```dart
// Nút tròn floating với Hero animation
// - Hiển thị ở góc phải thanh điều hướng trên
// - Badge hiển thị số tin nhắn chưa đọc từ admin
// - onTap -> Hero transition sang màn chat
```

#### B. Chat Screen với Hero Animation
**File cần tạo**: `lib/screens/chat_screen.dart`
```dart
// Màn hình full-screen với 2 tab:
// Tab 1: Chatbot AI
//   - TextField gửi tin nhắn
//   - Nút camera (chụp/chọn ảnh)
//   - Hiển thị nutrition analysis result
//   - Buttons: V (approve) và X (reject)
// Tab 2: Liên hệ Admin
//   - TextField gửi tin nhắn
//   - Nút gửi hình ảnh
//   - Hiển thị status (admin đã đọc chưa)
```

#### C. Nutrition Analysis Result Widget
**File cần tạo**: `lib/widgets/nutrition_result_table.dart`
```dart
// Bảng hiển thị kết quả phân tích:
// - Tên món ăn (AI nhận diện)
// - Table: Nutrient Name | Amount | Unit
// - 2 nút lớn: 
//   ✓ Đồng ý (màu xanh) -> Lưu vào DB
//   ✗ Từ chối (màu đỏ) -> Bỏ qua
```

#### D. Camera Nutrition Scanner
**File cần tạo**: `lib/screens/camera_nutrition_scanner.dart`
```dart
// Thay thế QR scanner hiện tại
// - Camera preview / Image picker
// - Animation "generating..." khi phân tích
// - Show NutritionResultTable khi xong
```

### 6. Tích hợp vào Main Navigation

**Cập nhật các file**:

1. **`lib/screens/my_diary_screen.dart`** (hoặc root screen):
```dart
// Thêm FloatingChatButton vào Stack
Stack(
  children: [
    // existing content
    Positioned(
      top: 16,
      right: 16,
      child: FloatingChatButton(), // Hero animation start
    ),
  ],
)
```

2. **`lib/main.dart`**:
```dart
// Thêm route
'/chat': (context) => ChatScreen(), // Hero animation end
'/camera-nutrition': (context) => CameraNutritionScanner(),
```

3. **Replace center FAB** trong `lib/screens/my_diary_screen.dart`:
```dart
// Thay thế nút QR code (FAB màu đỏ) thành:
FloatingActionButton(
  heroTag: 'camera_nutrition',
  backgroundColor: Colors.red,
  child: Icon(Icons.camera_alt, color: Colors.white),
  onPressed: () {
    Navigator.pushNamed(context, '/camera-nutrition');
  },
)
```

### 7. Backend Setup Steps

```powershell
# 1. Tạo thư mục uploads
cd D:\new\my_diary\backend
mkdir uploads\chat

# 2. Cài thêm dependencies
npm install form-data

# 3. Restart backend
node index.js
```

### 8. Database Setup

```sql
-- Run migration
\i D:/new/my_diary/backend/migrations/2025_chat_system.sql

-- Verify tables created
\dt *chat*
\dt *admin*conversation*
\dt nutrition*

-- Test query
SELECT * FROM ChatbotConversation LIMIT 1;
```

## 🎨 UI/UX Flow

### Chatbot Flow:
1. User nhấn floating button (góc phải top)
2. Hero animation: button phình to thành full screen
3. Màn chat hiển thị với 2 tabs (Chatbot | Admin)
4. User chọn ảnh hoặc nhắn tin
5. Nếu là ảnh → AI phân tích → hiện bảng nutrition
6. User nhấn ✓ → lưu vào DB, cập nhật progress bars
7. User nhấn ✗ → bỏ qua

### Camera Nutrition trong Add Meal:
1. User nhấn FAB camera (thay QR)
2. Chụp/chọn ảnh món ăn
3. Animation "đang phân tích..."
4. Hiện bảng nutrition
5. User approve → auto điền vào Add Meal form

## 🔧 Testing Checklist

- [ ] Migration chạy thành công
- [ ] Backend endpoints trả về 200
- [ ] ChatbotAPI `/analyze-nutrition` hoạt động
- [ ] Flutter service gọi API thành công
- [ ] Hero animation mượt mà
- [ ] Camera picker hoạt động
- [ ] Nutrition data lưu vào DB đúng
- [ ] Progress bars cập nhật sau approve
- [ ] Admin chat hiển thị unread badge

## 📁 File Structure Summary

```
backend/
├── migrations/
│   └── 2025_chat_system.sql          ✅ Đã tạo
├── controllers/
│   ├── chatController.js              ✅ Đã tạo
│   └── adminChatController.js         ✅ Đã tạo
├── routes/
│   └── chatRoutes.js                  ✅ Đã tạo
└── index.js                           ✅ Đã cập nhật

ChatbotAPI/
├── main.py                            ✅ Đã cập nhật
└── requirements.txt                   ✅ Đã cập nhật

lib/
├── services/
│   └── chat_service.dart              ✅ Đã tạo
├── widgets/
│   ├── floating_chat_button.dart      ⏳ Cần tạo
│   └── nutrition_result_table.dart    ⏳ Cần tạo
└── screens/
    ├── chat_screen.dart               ⏳ Cần tạo
    └── camera_nutrition_scanner.dart  ⏳ Cần tạo
```

## 🚀 Next Steps (Ưu tiên)

1. Chạy migration database
2. Test backend endpoints với Postman
3. Tạo `floating_chat_button.dart` (UI đơn giản nhất)
4. Tạo `chat_screen.dart` (chỉ text chat trước, chưa ảnh)
5. Test Hero animation
6. Thêm camera nutrition scanner
7. Tích hợp full flow

---

**Ghi chú**: Các file Flutter UI cần ~2000-3000 dòng code nữa. Tôi đã setup xong toàn bộ backend + AI + service layer. Bạn có thể tiếp tục từ đây hoặc cho tôi biết muốn tôi tạo file UI nào trước!
