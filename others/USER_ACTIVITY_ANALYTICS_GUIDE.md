# Hướng Dẫn Sử Dụng User Activity Analytics

## 🎯 Tính Năng Đã Triển Khai

Tính năng **User Activity Analytics** đã được tích hợp hoàn toàn vào Admin Dashboard, cho phép admin xem chi tiết hành vi và hoạt động của từng người dùng.

---

## 📍 Vị Trí Truy Cập

### Luồng Navigation:

```
Đăng nhập Admin
    ↓
Admin Dashboard
    ↓
Click vào icon "Quản lý User" (hoặc "Users")
    ↓
Danh sách Users hiển thị
    ↓
Click vào một user cụ thể để xem chi tiết
    ↓
Dialog "Chi tiết người dùng" mở ra
    ↓
Scroll xuống dưới cùng
    ↓
Click button "Xem Analytics & Hoạt Động"
    ↓
Màn hình Analytics với 4 tabs
```

---

## 🖥️ Giao Diện Màn Hình Analytics

### AppBar (Thanh tiêu đề)
- **Tiêu đề**: "Analytics: [Tên User]"
- **Icon Calendar**: Chọn khoảng thời gian (24h, 7d, 30d, 90d)
- **Icon Refresh**: Tải lại dữ liệu

### 4 Tabs Chính:

#### 1️⃣ **Tab Tổng Quan** (Overview)
**Nội dung**:
- **Điểm Tương Tác** (Engagement Score):
  - Vòng tròn progress bar với % từ 0-100
  - Màu sắc theo mức độ:
    - 🟢 Xanh (≥70%): "Tốt"
    - 🟠 Cam (40-69%): "Trung bình"
    - 🔴 Đỏ (<40%): "Cần cải thiện"
  - Hiển thị tổng số hoạt động

- **Phân Loại Hoạt Động**:
  - Biểu đồ tròn (Pie Chart) phân bố các loại hoạt động
  - Danh sách chi tiết với:
    - Icon màu sắc theo từng loại
    - Tên hoạt động (tiếng Việt)
    - Số lần thực hiện

**Các loại hoạt động được track**:
- 🔵 Đăng nhập (login)
- ⚪ Đăng xuất (logout)
- 🟢 Tạo bữa ăn (meal_created)
- 🟢 Cập nhật bữa ăn (meal_updated)
- 🔴 Xóa bữa ăn (meal_deleted)
- 🟠 Tìm kiếm thực phẩm (food_searched)
- 🟣 Cập nhật hồ sơ (profile_updated)
- 🟦 Thay đổi cài đặt (settings_changed)
- 🔷 Ghi nước uống (water_logged)
- 🟦 Tính lại BMR/TDEE (bmr_tdee_recomputed)
- 🟪 Tính lại chỉ tiêu (daily_targets_recomputed)

#### 2️⃣ **Tab Timeline**
**Nội dung**:
- Biểu đồ đường (Line Chart) thể hiện số lượng hoạt động theo thời gian
- Trục X: 
  - 24h: Hiển thị theo giờ (HH:mm)
  - 7d/30d/90d: Hiển thị theo ngày (dd/MM)
- Trục Y: Số lượng hoạt động
- Có vùng tô màu dưới đường (gradient xanh nhạt)
- Hover để xem chi tiết từng điểm

#### 3️⃣ **Tab Patterns**
**Nội dung gồm 2 phần**:

**A. Hoạt Động Theo Giờ** (Hourly Pattern):
- Biểu đồ cột (Bar Chart) 24 cột (0h → 23h)
- Màu xanh lá
- Chiều cao cột = số lượng hoạt động trong giờ đó
- Giúp xác định giờ nào user active nhất

**B. Hoạt Động Theo Ngày Trong Tuần** (Weekly Pattern):
- Biểu đồ cột 7 cột (Sun → Sat)
- Màu tím
- Chiều cao cột = số lượng hoạt động trong ngày đó
- Giúp xác định user thường active vào ngày nào

#### 4️⃣ **Tab Logs**
**Nội dung**:
- Header hiển thị: "Tổng: X hoạt động"
- Danh sách cuộn được với tất cả các log
- Mỗi log hiển thị:
  - Avatar tròn với icon và màu theo loại hoạt động
  - Tên hoạt động (tiếng Việt)
  - Thời gian: dd/MM/yyyy HH:mm:ss
  - Icon mũi tên bên phải (>)
- Hỗ trợ pagination (50 logs mỗi trang)

---

## 🔧 Công Nghệ Sử Dụng

### Backend:
- **Files**:
  - `backend/controllers/adminActivityController.js` (384 dòng)
  - `backend/routes/admin.js` (thêm 4 routes)
  - Database: Bảng `UserActivityLog`

- **API Endpoints**:
  - `GET /admin/users/:userId/activity` - Lấy logs
  - `GET /admin/users/:userId/activity/analytics` - Lấy analytics
  - `POST /admin/users/:userId/activity` - Log hoạt động
  - `GET /admin/activity/overview` - Tổng quan platform

### Frontend:
- **Files mới**:
  - `lib/services/admin_activity_service.dart` - API service
  - `lib/screens/admin_user_activity_screen.dart` - Main screen (700+ dòng)

- **Files đã sửa**:
  - `lib/screens/admin_users_screen.dart` - Thêm button Analytics
  - `pubspec.yaml` - Thêm package `fl_chart: ^0.69.0`

- **Packages sử dụng**:
  - `fl_chart: ^0.69.0` - Vẽ biểu đồ (Pie, Line, Bar)
  - `intl: ^0.19.0` - Format ngày giờ
  - `http: ^0.13.6` - HTTP requests

---

## 📊 Cách Tính Engagement Score

**Công thức**: Score = ActivityScore (60%) + MealScore (40%)

### ActivityScore (60%):
Dựa trên số hoạt động thực tế so với kỳ vọng:
- **24h**: Kỳ vọng 10 hoạt động = 100%
- **7d**: Kỳ vọng 30 hoạt động = 100%
- **30d**: Kỳ vọng 100 hoạt động = 100%
- **90d**: Kỳ vọng 200 hoạt động = 100%

Công thức: `(totalActivities / expectedActivities) × 60`

### MealScore (40%):
Dựa trên tính nhất quán log bữa ăn:
- Kỳ vọng: 3 bữa/ngày
- Công thức: `(mealsLogged / (days × 3)) × 40`

**Tổng**: `min(100, ActivityScore + MealScore)`

---

## 🎨 Màu Sắc & Icon

### Màu theo loại hoạt động:
| Hoạt động | Màu | Icon |
|-----------|-----|------|
| login | Xanh dương | Icons.login |
| logout | Xám | Icons.logout |
| meal_created | Xanh lá | Icons.restaurant |
| meal_updated | Xanh lá nhạt | Icons.edit |
| meal_deleted | Đỏ | Icons.delete |
| food_searched | Cam | Icons.search |
| profile_updated | Tím | Icons.person |
| settings_changed | Xanh ngọc | Icons.settings |
| water_logged | Xanh cyan | Icons.water_drop |
| bmr_tdee_recomputed | Indigo | Icons.calculate |
| daily_targets_recomputed | Tím đậm | Icons.track_changes |

---

## 🧪 Testing

### Kiểm tra Backend:
```bash
cd backend
node test_activity_api.js
```

Kết quả mong đợi:
```
✅ Login successful
✅ Logged: login, meal_created, food_searched...
✅ Found X activities
✅ Analytics Summary: Score, Breakdown, Timeline...
✅ Platform Overview: Active users, Top users...
🎉 All tests completed successfully!
```

### Kiểm tra Frontend:
1. Chạy app: `flutter run -d chrome`
2. Đăng nhập admin (admin@example.com / admin123)
3. Vào Admin Dashboard → Quản lý User
4. Click vào user bất kỳ
5. Scroll xuống → Click "Xem Analytics & Hoạt Động"
6. Kiểm tra 4 tabs:
   - ✅ Tổng quan: Engagement score + Pie chart
   - ✅ Timeline: Line chart theo thời gian
   - ✅ Patterns: 2 bar charts (hourly + weekly)
   - ✅ Logs: Danh sách chi tiết

---

## 📝 Dữ Liệu Test

Hiện tại User 9 có **20 hoạt động test**:
- 6× meal_created
- 3× food_searched
- 3× login
- 3× logout
- 3× profile_updated
- 1× bmr_tdee_recomputed
- 1× daily_targets_recomputed

**Engagement Score**: ~43% (Trung bình)

---

## 🚀 Tính Năng Mở Rộng (Tương Lai)

### 1. Automatic Activity Logging
Hiện tại logging được thực hiện thủ công qua API. Cần tích hợp tự động:
- Login/Logout: Trong `auth_service.dart`
- Meal CRUD: Trong meal screens
- Profile updates: Trong profile screens
- Food search: Trong search screen

### 2. Export Data
- Xuất CSV/Excel danh sách logs
- Xuất PDF báo cáo analytics

### 3. Real-time Updates
- Sử dụng WebSocket/SSE để cập nhật real-time
- Notification khi có hoạt động bất thường

### 4. Advanced Filters
- Filter theo action type trong Logs tab
- Date range picker chi tiết
- Search logs by keyword

### 5. Comparison View
- So sánh nhiều users
- Benchmark với trung bình platform
- Trends theo tuần/tháng

---

## 🐛 Troubleshooting

### Lỗi: "No authentication token"
**Nguyên nhân**: Chưa đăng nhập admin
**Giải pháp**: Đăng nhập lại với tài khoản admin

### Lỗi: "Failed to load analytics"
**Nguyên nhân**: Backend chưa chạy hoặc port sai
**Giải pháp**: 
```bash
cd backend
npm start
```
Đảm bảo server chạy trên port 60491

### Lỗi: "relation UserActivityLog does not exist"
**Nguyên nhân**: Chưa tạo bảng trong database
**Giải pháp**:
```bash
cd backend
node create_activity_table.js
```

### Biểu đồ không hiển thị
**Nguyên nhân**: Chưa có dữ liệu
**Giải pháp**: Tạo test data:
```bash
cd backend
node test_activity_simple.js
```

---

## ✅ Checklist Triển Khai Hoàn Tất

- ✅ Backend API (4 endpoints)
- ✅ Database table + indexes
- ✅ Frontend service layer
- ✅ Main analytics screen (4 tabs)
- ✅ Charts integration (Pie, Line, Bar)
- ✅ Navigation from User Details
- ✅ Period selector (24h/7d/30d/90d)
- ✅ Engagement score calculation
- ✅ Activity logs display
- ✅ Error handling
- ✅ Loading states
- ✅ Test scripts

**Tính năng đã sẵn sàng sử dụng! 🎉**
