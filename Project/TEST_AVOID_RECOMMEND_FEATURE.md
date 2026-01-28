# HƯỚNG DẪN TEST TÍNH NĂNG AVOID/RECOMMEND FOODS/DISHES

## ✅ ĐÃ SỬA CÁC LỖI:

### 1. **Backend API** (suggestions.js)
- ✅ Thêm check `treatment_end_date >= CURRENT_DATE` để chỉ lấy bệnh còn đang điều trị
- ✅ API trả về đúng array of objects với full details

### 2. **Flutter Service** (user_food_recommendation_service.dart)  
- ✅ Sửa parse từ `item['food_id']` thành `(item is Map ? item['food_id'] : item)`
- ✅ Thêm logic conflict resolution: ưu tiên AVOID khi food vừa avoid vừa recommend
- ✅ Thêm debug logs để track

### 3. **Database**
- ✅ Cập nhật Gout end_date = Dec 12 để thành active
- ✅ User ID 1 hiện có 3 bệnh active: Tiểu đường type 2, Gout, Bệnh tả không đặc hiệu

## 📊 DỮ LIỆU TEST CHO USER ID 1:

### Bệnh đang điều trị (3):
- ✓ [1] Tiểu đường type 2 (end: Dec 12)
- ✓ [5] Gout (end: Dec 12)  
- ✓ [20] Bệnh tả không đặc hiệu (end: Dec 12)

### Foods to AVOID (4):
1. **[1] Mật ong phân tích thành phần** - Tiểu đường type 2
2. **[12] Chất ngọt từ cây thùa** - Gout (conflict với recommend)
3. **[40] Nuoc mam** - Gout
4. **[41] Duong** - Tiểu đường type 2

### Foods to RECOMMEND (5 sau khi loại conflict):
1. **[6] Nước ép acerola** - Tiểu đường type 2
2. **[9] Thực phẩm chay giàu B12 và Folate** - Gout
3. **[11] Adobo với cơm** - Gout
4. **[43] Rau cu** - Tiểu đường type 2 + Gout

**Note:** Food [12] bị loại khỏi recommend vì conflict (ưu tiên avoid)

### Dishes:
- 🚫 **[60] Món Test - Hạn Chế** - chứa Mật ong [1] → BỊ LÀM MỜ
- 🚫 **[62] Món Test - Hỗn Hợp** - chứa Mật ong [1] → BỊ LÀM MỜ  
- ✅ **[61] Món Test - Khuyến Nghị** - chứa Nước ép acerola [6] → BADGE XANH

## 🧪 CÁCH TEST:

### Bước 1: Khởi động Backend
```bash
cd d:\App\new\Project\backend
node server.js
```
Đợi thấy: `Server running on port 60491`

### Bước 2: Rebuild Flutter App
```bash
cd d:\App\new\Project
flutter clean
flutter run
```

### Bước 3: Kiểm tra trong App

#### Tab "Nguyên Liệu":
- [ ] Có 4 foods bị làm mờ (opacity 0.45):
  - Mật ong phân tích thành phần
  - Chất ngọt từ cây thùa
  - Nuoc mam
  - Duong
  
- [ ] Có 5 foods có badge xanh "Nên dùng":
  - Nước ép acerola
  - Thực phẩm chay giàu B12 và Folate
  - Adobo với cơm
  - Rau cu

- [ ] Click vào food bị làm mờ → hiện AlertDialog cảnh báo với icon warning

#### Tab "Món Ăn":
- [ ] Có 2 dishes bị làm mờ:
  - Món Test - Hạn Chế
  - Món Test - Hỗn Hợp

- [ ] Có 1 dish có badge xanh "Nên dùng":
  - Món Test - Khuyến Nghị

- [ ] Click vào dish bị làm mờ → hiện AlertDialog cảnh báo

#### Tab tìm kiếm:
- [ ] Tìm "gao" → thấy kết quả bị làm mờ nếu match
- [ ] Tìm món ăn → thấy kết quả đúng trạng thái

### Bước 4: Check Console Logs (VS Code Debug Console)

Khi mở Add Meal Dialog, bạn sẽ thấy:
```
🔴 UserFoodRecommendationService loaded:
   Foods to avoid: {1, 12, 40, 41}
   Foods to recommend: {6, 9, 11, 43}
⚠️  Conflict detected: 1 foods are both avoid and recommend
   Conflicting food IDs: {12}
   → Prioritizing AVOID for safety
🔴 Loaded food recommendations:
   Restricted: 4 foods - 1, 12, 40, 41
   Recommended: 5 foods - 6, 9, 11, 43
```

## ❌ NẾU KHÔNG HOẠT ĐỘNG:

### Check 1: Backend có chạy không?
```bash
curl http://localhost:60491/health
# hoặc
Invoke-WebRequest http://localhost:60491/health
```

### Check 2: API có trả dữ liệu đúng không?
```bash
cd d:\App\new\Project\backend\scripts
node test_full_api.js
```
Phải thấy:
- Foods to avoid: 4 items - [12, 1, 40, 41]
- Foods to recommend: 6 items - [11, 12, 6, 9, 43, 43]

### Check 3: Flutter có gọi API đúng không?
- Mở Add Meal Dialog
- Check Debug Console có log `🔴 UserFoodRecommendationService loaded` không
- Nếu không có → service không load được, check auth_token

### Check 4: Xem lại auth token
```dart
// Trong app, check Settings hoặc Profile
// Token phải còn hạn
```

## 🐛 TROUBLESHOOTING:

### Lỗi: "password authentication failed"
→ Sửa .env backend với password đúng (123456)

### Lỗi: Foods không bị làm mờ
→ Check _restrictedFoodIds có data không trong console
→ Check _loadRestrictedFoods() có được gọi không

### Lỗi: API trả về empty array
→ Check user có bệnh active không
→ Check treatment_end_date >= hôm nay

### Lỗi: Dishes không có badge
→ Check _markRestrictedDishes() có được gọi không
→ Check DishService.getDishDetails() có trả ingredients không

## 📝 GHI CHÚ:

- Tính năng chỉ hoạt động khi user đã đăng nhập (có auth_token)
- Recommendations cache 5 phút, sau đó auto refresh
- Nếu thay đổi health conditions, cần force refresh app
- Food vừa avoid vừa recommend → ưu tiên AVOID (an toàn hơn)
- Dish chỉ recommended khi TẤT CẢ ingredients đều không bị avoid

## ✅ EXPECTED BEHAVIOR:

Sau khi test xong, bạn sẽ thấy trong Add Meal Dialog:
1. **4 foods faded** (mờ đi)
2. **5 foods có badge xanh** "Nên dùng"
3. Click vào faded item → AlertDialog warning
4. **2 dishes faded**
5. **1 dish có badge xanh**
6. UI smooth, không lag
