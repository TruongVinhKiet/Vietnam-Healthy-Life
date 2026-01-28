# 🍽️ Food Management Screen - Setup Guide

## ✅ Đã hoàn thành

### 1. **Giao diện quản lý thực phẩm** (`AdminFoodsScreen`)
- ✅ Hiển thị danh sách thực phẩm với phân trang
- ✅ Tìm kiếm thực phẩm theo tên
- ✅ Xem chi tiết dinh dưỡng
- ✅ Thêm thực phẩm mới (FloatingActionButton)
- ✅ Sửa thông tin thực phẩm
- ✅ Xóa thực phẩm
- ✅ Empty state với hướng dẫn

### 2. **Dialog thêm/sửa thực phẩm**
- ✅ Form nhập tên, danh mục, URL hình ảnh
- ✅ Nhập dinh dưỡng cơ bản: Calories, Protein, Carbs, Fat, Fiber
- ✅ Validation dữ liệu đầu vào
- ✅ Hiển thị loading state khi lưu
- ✅ Thông báo thành công/lỗi

### 3. **Backend API**
- ✅ `/admin/foods` - Lấy danh sách thực phẩm (có phân trang & tìm kiếm)
- ✅ `/admin/foods/:id` - Lấy chi tiết thực phẩm
- ✅ `/admin/foods` (POST) - Thêm/sửa thực phẩm
- ✅ `/admin/foods/:id` (DELETE) - Xóa thực phẩm

### 4. **Dữ liệu mẫu**
- ✅ Script SQL seed 24 loại thực phẩm Việt Nam
- ✅ Bao gồm 5 nhóm: Ngũ cốc, Rau củ, Trái cây, Protein, Sữa
- ✅ Đầy đủ thông tin dinh dưỡng (Calories, Protein, Carbs, Fat, Fiber)

---

## 🚀 Hướng dẫn sử dụng

### Bước 1: Seed dữ liệu mẫu vào database

#### **Cách 1: Dùng PowerShell script (Khuyến nghị)**
```powershell
cd D:\new\my_diary\backend\migrations
.\seed_sample_data.ps1
```

#### **Cách 2: Dùng psql trực tiếp**
```powershell
psql -U postgres -d my_diary -f seed_sample_foods.sql
```

#### **Cách 3: Nếu không có psql trong PATH**
1. Mở pgAdmin hoặc SQL client khác
2. Kết nối đến database `my_diary`
3. Mở file `seed_sample_foods.sql`
4. Execute toàn bộ script

### Bước 2: Khởi động backend server
```powershell
cd D:\new\my_diary\backend
npm start
```

Server sẽ chạy tại `http://localhost:60491`

### Bước 3: Chạy Flutter app
```powershell
cd D:\new\my_diary
flutter run -d windows
```

hoặc nếu đã ở trong thư mục my_diary:
```powershell
flutter run
```

### Bước 4: Đăng nhập Admin
1. Mở app Flutter
2. Đăng nhập bằng tài khoản admin
3. Vào **Admin Dashboard**
4. Nhấn vào **"Quản lý thực phẩm"**

---

## 📋 Các tính năng trong màn hình Quản lý thực phẩm

### 1. **Xem danh sách thực phẩm**
- Hiển thị tên, danh mục, hình ảnh
- Phân trang (20 items/trang)
- Điều hướng trang trước/sau

### 2. **Tìm kiếm thực phẩm**
- Gõ tên thực phẩm vào search bar
- Nhấn Enter để tìm kiếm
- Nhấn X để xóa tìm kiếm

### 3. **Xem chi tiết dinh dưỡng**
- Nhấn nút **ℹ️ (info)** trên mỗi thực phẩm
- Hiển thị dialog với:
  - Thông tin cơ bản (tên, danh mục, hình ảnh)
  - Macronutrients (Calories, Protein, Carbs, Fat)
  - Vitamins
  - Minerals

### 4. **Thêm thực phẩm mới**
- Nhấn nút **➕ "Thêm thực phẩm"** ở góc dưới bên phải
- Điền thông tin:
  - **Tên thực phẩm** (bắt buộc)
  - Danh mục (optional): VD: Trái cây, Rau củ, Thịt...
  - URL hình ảnh (optional)
  - **Dinh dưỡng trên 100g:**
    - Calories (kcal)
    - Protein (g)
    - Carbs (g)
    - Fat (g)
    - Fiber (g)
- Nhấn **"Thêm"** để lưu

### 5. **Sửa thực phẩm**
- Nhấn nút **✏️ (edit)** trên mỗi thực phẩm
- Chỉnh sửa thông tin
- Nhấn **"Cập nhật"** để lưu

### 6. **Xóa thực phẩm**
- Nhấn nút **🗑️ (delete)** trên mỗi thực phẩm
- Xác nhận xóa trong dialog
- Thực phẩm sẽ bị xóa khỏi database

---

## 🗃️ Danh sách thực phẩm mẫu

### Ngũ cốc (5 loại)
- Cơm trắng (130 kcal/100g)
- Bánh mì (265 kcal/100g)
- Phở (85 kcal/100g)
- Bún (109 kcal/100g)
- Miến (352 kcal/100g)

### Rau củ (5 loại)
- Rau muống (19 kcal/100g)
- Cải thảo (13 kcal/100g)
- Cà chua (18 kcal/100g)
- Dưa chuột (15 kcal/100g)
- Rau cải (23 kcal/100g)

### Trái cây (5 loại)
- Chuối (89 kcal/100g)
- Táo (52 kcal/100g)
- Cam (47 kcal/100g)
- Xoài (60 kcal/100g)
- Dưa hấu (30 kcal/100g)

### Protein (7 loại)
- Thịt lợn (242 kcal/100g)
- Thịt gà (165 kcal/100g)
- Thịt bò (250 kcal/100g)
- Cá (206 kcal/100g)
- Tôm (99 kcal/100g)
- Trứng gà (155 kcal/100g)
- Đậu hũ (76 kcal/100g)

### Sữa (2 loại)
- Sữa tươi (61 kcal/100g)
- Sữa chua (59 kcal/100g)

**Tổng cộng: 24 loại thực phẩm**

---

## 🔧 Troubleshooting

### Vấn đề: Không thấy thực phẩm nào
**Nguyên nhân:** Database chưa có dữ liệu

**Giải pháp:**
1. Chạy seed script: `.\seed_sample_data.ps1`
2. Hoặc thêm thực phẩm thủ công qua giao diện

### Vấn đề: Lỗi "psql not found"
**Giải pháp:**
1. Thêm PostgreSQL bin vào PATH
2. Hoặc dùng pgAdmin để chạy SQL file
3. Hoặc thêm thực phẩm qua giao diện admin

### Vấn đề: API trả về lỗi 401 Unauthorized
**Giải pháp:**
1. Đảm bảo đã đăng nhập admin
2. Token có thể đã hết hạn, đăng nhập lại
3. Kiểm tra backend server đang chạy

### Vấn đề: Không lưu được thực phẩm
**Kiểm tra:**
1. Tên thực phẩm không được để trống
2. Số liệu dinh dưỡng phải là số hợp lệ
3. Xem console log để biết lỗi cụ thể

---

## 📝 Ghi chú kỹ thuật

### Database Schema
- **Food table:** Lưu thông tin cơ bản (name, category, image_url)
- **Nutrient table:** Danh sách chất dinh dưỡng (Energy, Protein, Carbs, Fat, Fiber...)
- **FoodNutrient table:** Liên kết Food <-> Nutrient với giá trị amount_per_100g

### API Endpoints
```
GET    /admin/foods?page=1&limit=20&search=cơm
GET    /admin/foods/:id
POST   /admin/foods (body: {name, category, image_url, nutrients})
PUT    /admin/foods/:id
DELETE /admin/foods/:id
```

### Nutrient Codes
- `ENERC_KCAL` - Energy (Calories)
- `PROCNT` - Protein
- `CHOCDF` - Carbohydrates
- `FAT` - Total Fat
- `FIBTG` - Fiber

---

## ✨ Tính năng tương lai

- [ ] Import thực phẩm từ CSV/Excel
- [ ] Bulk delete/edit
- [ ] Advanced nutrition input (vitamins, minerals)
- [ ] Food images upload
- [ ] Barcode integration
- [ ] Recipe builder using foods
- [ ] Meal templates

---

**📧 Hỗ trợ:** Nếu gặp vấn đề, kiểm tra:
1. Backend logs: `D:\new\my_diary\backend`
2. Flutter logs trong terminal
3. Database connection trong pgAdmin
