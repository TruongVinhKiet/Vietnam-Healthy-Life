# HƯỚNG DẪN KIỂM TRA TÍNH NĂNG FOOD/DISH RECOMMENDATIONS

## ✅ ĐÃ HOÀN THÀNH

### 1. **Xóa dữ liệu trùng tên trong bảng Food**
- ✅ Xóa 19 bản ghi trùng không sử dụng
- ✅ Merge 8 nhóm bản ghi trùng đang được sử dụng
- ✅ Kết quả: 0 duplicate foods

### 2. **Sửa API và Flutter Service**
- ✅ Đổi endpoint từ `/health/user-food-recommendations` → `/api/suggestions/user-food-recommendations`
- ✅ Sửa tên bảng trong backend (PascalCase → lowercase)
- ✅ API trả về đúng danh sách restricted và recommended foods

### 3. **Cải thiện UI/UX trong Add Meal Dialog**

#### 📱 **FOOD (Nguyên Liệu) Tab:**
- ✅ **Restricted foods (Bị hạn chế):**
  - Hiển thị mờ với `opacity: 0.45`
  - Khi tap → Hiện Dialog cảnh báo với icon ⚠️ + nút OK
  - Message: "Không phù hợp với tình trạng sức khỏe của bạn. Bạn không nên ăn món này."
  
- ✅ **Recommended foods (Được khuyến nghị):**
  - Hiển thị badge màu xanh "👍 Nên dùng"
  - Có thể tap bình thường để thêm vào meal

#### 🍽️ **DISH (Món Ăn) Tab:**
- ✅ **Dishes chứa restricted ingredients:**
  - Tự động kiểm tra ingredients khi load
  - Hiển thị mờ với `opacity: 0.45`
  - Khi tap → Hiện Dialog cảnh báo với icon ⚠️ + nút OK
  - Message: "Món ăn chứa thực phẩm không phù hợp. Bạn không nên ăn món này."

- ✅ **Dishes chứa recommended ingredients:**
  - Hiển thị badge màu xanh "👍 Nên dùng"
  - Có thể tap bình thường để thêm vào meal

- ✅ **Priority:** Nếu dish chứa cả restricted và recommended → Ưu tiên hiển thị restricted (faded)

---

## 🧪 HƯỚNG DẪN KIỂM TRA

### Bước 1: Restart Backend
```bash
cd D:\App\new\Project\backend
# Tắt backend hiện tại (Ctrl+C)
node index.js
# Hoặc dùng terminal trong VS Code
```

### Bước 2: Rebuild Flutter App
```bash
cd D:\App\new\Project
flutter clean
flutter run
```

### Bước 3: Test User Setup
- **User:** truonghoankiet1@gmail.com (ID: 1)
- **Health Conditions:** 
  - Gout
  - Bệnh tả không đặc hiệu
- **Restricted Foods (2):**
  - [12] Chất ngọt từ cây thùa
  - [40] Nuoc mam
- **Recommended Foods (3):**
  - [9] Thực phẩm chay giàu B12 và Folate
  - [11] Adobo với cơm
  - [43] Rau cu

### Bước 4: Test Cases

#### ✅ Test Case 1: Food Tab - Restricted Food
1. Mở Add Meal Dialog
2. Chọn tab "Nguyên Liệu"
3. Tìm kiếm "nuoc mam" hoặc "Chất ngọt"
4. **Expected:**
   - Food hiển thị mờ (opacity 0.45)
   - Tap vào food → Dialog xuất hiện với:
     - Title: "⚠️ Cảnh báo sức khỏe"
     - Message: "... không phù hợp với tình trạng sức khỏe của bạn"
     - Button: "OK"

#### ✅ Test Case 2: Food Tab - Recommended Food
1. Mở Add Meal Dialog
2. Chọn tab "Nguyên Liệu"
3. Tìm kiếm "rau cu" hoặc "adobo"
4. **Expected:**
   - Food hiển thị bình thường
   - Badge màu xanh "👍 Nên dùng" ở bên phải tên
   - Tap vào food → Chọn được bình thường

#### ✅ Test Case 3: Dish Tab - Restricted Dish
1. Mở Add Meal Dialog
2. Chuyển sang tab "Món Ăn"
3. Tìm kiếm "Test" hoặc scroll tìm "Món Test - Hạn Chế"
4. **Expected:**
   - Dish hiển thị mờ (opacity 0.45)
   - Tap vào dish → Dialog xuất hiện với:
     - Title: "⚠️ Cảnh báo sức khỏe"
     - Message: "Món ăn chứa thực phẩm không phù hợp..."
     - Button: "OK"

#### ✅ Test Case 4: Dish Tab - Recommended Dish
1. Mở Add Meal Dialog
2. Chuyển sang tab "Món Ăn"
3. Tìm kiếm "Test" hoặc scroll tìm "Món Test - Khuyến Nghị"
4. **Expected:**
   - Dish hiển thị bình thường
   - Badge màu xanh "👍 Nên dùng" ở bên phải tên
   - Tap vào dish → Chọn được bình thường

#### ✅ Test Case 5: Dish Tab - Mixed Dish (Priority Test)
1. Mở Add Meal Dialog
2. Chuyển sang tab "Món Ăn"
3. Tìm "Món Test - Hỗn Hợp" (chứa cả restricted và recommended)
4. **Expected:**
   - Dish hiển thị mờ (restricted takes priority)
   - Không có badge "Nên dùng"
   - Tap vào → Dialog cảnh báo xuất hiện

#### ✅ Test Case 6: Quick Add Section
1. Mở Add Meal Dialog
2. Xem phần "Món ăn thường dùng" ở đầu
3. Nếu có restricted food trong đó
4. **Expected:**
   - Food mờ (opacity 0.45)
   - Tap → Dialog cảnh báo

---

## 📊 TEST DATA ĐÃ TẠO

### Test Dishes:
- **[60] Test Dish - Restricted** (Món Test - Hạn Chế)
  - Ingredient: [12] Chất ngọt từ cây thùa (RESTRICTED)
  - Expected: Faded, show warning dialog
  
- **[61] Test Dish - Recommended** (Món Test - Khuyến Nghị)
  - Ingredient: [9] Thực phẩm chay giàu B12 và Folate (RECOMMENDED)
  - Expected: Normal, show "Nên dùng" badge
  
- **[62] Test Dish - Mixed** (Món Test - Hỗn Hợp)
  - Ingredients: [12] RESTRICTED + [9] RECOMMENDED
  - Expected: Faded (restricted priority), no badge

---

## 📁 FILES ĐÃ SỬA/TẠO

### Files đã sửa:
1. `lib/services/user_food_recommendation_service.dart`
   - Đổi API endpoint
   - Thêm debug logs

2. `lib/widgets/add_meal_dialog.dart`
   - Thay SnackBar → AlertDialog với nút OK
   - Thêm logic mark dish recommended
   - Thêm badge "Nên dùng" cho dish
   - Cải thiện UX cho cảnh báo

3. `backend/routes/suggestions.js`
   - Sửa tên bảng thành lowercase

### Files test đã tạo:
1. `backend/scripts/check_duplicate_foods.js`
2. `backend/scripts/merge_duplicate_foods.js`
3. `backend/scripts/verify_food_recommendations.js`
4. `backend/scripts/test_user_food_recommendations.js`
5. `backend/scripts/test_add_meal_flow.js`
6. `backend/scripts/create_test_dishes.js`

---

## ✅ CHECKLIST CUỐI CÙNG

- [x] Database không còn duplicate foods
- [x] API endpoint hoạt động đúng
- [x] Service load recommendations thành công
- [x] Food restricted: opacity 0.45 + Dialog cảnh báo
- [x] Food recommended: badge "Nên dùng"
- [x] Dish restricted: opacity 0.45 + Dialog cảnh báo
- [x] Dish recommended: badge "Nên dùng"
- [x] Mixed dish: priority cho restricted
- [x] Quick add section: xử lý đúng
- [x] Test data đã tạo
- [x] Debug logs hoạt động

---

## 🔍 DEBUG

Nếu không hoạt động, kiểm tra logs:
```dart
// Trong Flutter console, tìm dòng:
🔴 Loaded food recommendations:
   Restricted: X foods - [id1, id2, ...]
   Recommended: Y foods - [id1, id2, ...]
```

Nếu thấy "Restricted: 0 foods" → Service chưa load được data → Kiểm tra:
1. Backend có chạy không?
2. User có active health conditions không?
3. API endpoint có đúng không?

---

**🎉 HOÀN THÀNH! Vui lòng test theo các test cases trên.**
