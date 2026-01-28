# Role-Based Access Control (RBAC)

## Tổng quan

Hệ thống quản trị viên (Admin) của ứng dụng đã được cài đặt **Role-Based Access Control (RBAC)** để phân quyền truy cập các trang quản lý.

## Các Role trong hệ thống

### 1. **super_admin** 👑
- **Quyền hạn**: Toàn quyền truy cập mọi trang quản lý
- **Đặc biệt**: Bypass mọi kiểm tra quyền
- **Chỉ dành cho**: Admin cấp cao nhất
- **Truy cập được**:
  - ✅ Tất cả các trang quản lý
  - ✅ Quản lý phân quyền (Role Management)
  - ✅ Gán/gỡ role cho admin khác

### 2. **user_manager**
- **Quyền hạn**: Quản lý người dùng
- **Truy cập được**:
  - ✅ Quản lý người dùng (Users)
  - ✅ Tùy biến ứng dụng (Settings)

### 3. **content_manager**
- **Quyền hạn**: Quản lý nội dung (thực phẩm, món ăn, đồ uống, thuốc, bệnh lý)
- **Truy cập được**:
  - ✅ Quản lý thực phẩm (Foods)
  - ✅ Quản lý món ăn (Dishes)
  - ✅ Quản lý đồ uống (Drinks)
  - ✅ Quản lý chất dinh dưỡng (Nutrients)
  - ✅ Quản lý bệnh lý (Health Conditions)
  - ✅ Quản lý thuốc (Drugs)
  - ✅ Tùy biến ứng dụng (Settings)

### 4. **analyst**
- **Quyền hạn**: Phân tích dữ liệu và báo cáo
- **Truy cập được**:
  - ✅ Quản lý người dùng (Users) - xem và phân tích
  - ✅ Quản lý thực phẩm (Foods)
  - ✅ Quản lý món ăn (Dishes)
  - ✅ Quản lý đồ uống (Drinks)
  - ✅ Quản lý chất dinh dưỡng (Nutrients)
  - ✅ Quản lý bệnh lý (Health Conditions)
  - ✅ Quản lý thuốc (Drugs)
  - ✅ Tùy biến ứng dụng (Settings)

### 5. **support**
- **Quyền hạn**: Hỗ trợ người dùng
- **Truy cập được**:
  - ✅ Quản lý người dùng (Users) - để hỗ trợ
  - ✅ Hỗ trợ người dùng (Chat Support Panel)

## Bảng phân quyền chi tiết

| Trang quản lý | super_admin | user_manager | content_manager | analyst | support |
|--------------|:-----------:|:------------:|:---------------:|:-------:|:-------:|
| 👑 **Quản lý phân quyền** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Quản lý người dùng** | ✅ | ✅ | ❌ | ✅ | ✅ |
| **Quản lý thực phẩm** | ✅ | ❌ | ✅ | ✅ | ❌ |
| **Quản lý món ăn** | ✅ | ❌ | ✅ | ✅ | ❌ |
| **Quản lý đồ uống** | ✅ | ❌ | ✅ | ✅ | ❌ |
| **Quản lý chất dinh dưỡng** | ✅ | ❌ | ✅ | ✅ | ❌ |
| **Quản lý bệnh lý** | ✅ | ❌ | ✅ | ✅ | ❌ |
| **Quản lý thuốc** | ✅ | ❌ | ✅ | ✅ | ❌ |
| **Tùy biến ứng dụng** | ✅ | ✅ | ✅ | ✅ | ❌ |

## Cách hoạt động

### 1. Check quyền truy cập
Khi admin cố gắng truy cập một trang quản lý:
```dart
RoleProtectedScreen(
  requiredRoles: ['content_manager', 'analyst'],
  child: AdminFoodsScreen(),
)
```

### 2. Logic kiểm tra
1. Hệ thống gọi API `GET /admin/roles/my-roles` để lấy roles của admin
2. Kiểm tra xem admin có role `super_admin` không
   - ✅ Nếu có → **Bypass** tất cả, cho phép truy cập
   - ❌ Nếu không → Kiểm tra tiếp
3. Kiểm tra xem admin có **ít nhất 1** role trong `requiredRoles`
   - ✅ Nếu có → Cho phép truy cập
   - ❌ Nếu không → Hiển thị màn hình lỗi

### 3. Màn hình lỗi
Nếu không có quyền, hiển thị:
```
⚠️ Không có quyền truy cập

Bạn không có quyền truy cập trang này.

Yêu cầu một trong các role sau:
• content_manager
• analyst

Role hiện tại của bạn:
• support
```

## Quick Actions (Dashboard)

Các quick actions trên dashboard cũng đã được bảo vệ:

| Quick Action | Roles được phép |
|-------------|----------------|
| **Thêm thực phẩm** | content_manager, analyst |
| **Xem người dùng** | user_manager, analyst, support |
| **Cài đặt** | analyst, user_manager, content_manager |
| **Làm mới dữ liệu** | Tất cả admin |

## API Endpoints liên quan

### Backend Role APIs
```javascript
// Lấy roles của admin hiện tại
GET /admin/roles/my-roles
Headers: Authorization: Bearer <token>
Response: { roles: ['super_admin', 'user_manager'] }

// Lấy tất cả roles (chỉ super_admin)
GET /admin/roles/all
Response: { roles: [{role_id, role_name}, ...] }

// Gán role cho admin (chỉ super_admin)
POST /admin/roles/admins/:adminId/assign
Body: { role_name: 'content_manager' }

// Gỡ role khỏi admin (chỉ super_admin)
DELETE /admin/roles/admins/:adminId/roles/:roleName
```

### Flutter Service
```dart
// Lấy roles của mình
final roles = await AdminRoleService().getMyRoles();

// Lấy tất cả roles
final allRoles = await AdminRoleService().getAllRoles();

// Gán role
await AdminRoleService().assignRole(adminId, 'content_manager');

// Gỡ role
await AdminRoleService().removeRole(adminId, 'content_manager');
```

## Cách gán role cho admin

### 1. Đăng nhập với super_admin
Chỉ có `super_admin` mới có quyền gán role.

### 2. Vào trang "Quản lý phân quyền"
Dashboard → 👑 Quản lý phân quyền

### 3. Chọn admin cần gán role
Danh sách admin hiển thị với roles hiện tại của từng người.

### 4. Gán/Gỡ role
- **Gán**: Chọn role từ dropdown → nhấn "Gán role"
- **Gỡ**: Nhấn nút X bên cạnh role cần gỡ

## Seed roles vào database

Chạy script để tạo roles ban đầu:
```bash
cd backend
node others/seed_roles.js
```

Script này sẽ:
1. Tạo 5 roles: super_admin, user_manager, content_manager, analyst, support
2. Tự động gán `super_admin` cho admin đầu tiên trong database

## Lưu ý quan trọng

### ⚠️ Super Admin
- **Không thể tự gỡ role** `super_admin` của chính mình
- Luôn có ít nhất **1 super_admin** trong hệ thống
- Nếu gỡ hết super_admin → không ai quản lý được roles nữa

### ⚠️ Multiple Roles
- Một admin có thể có **nhiều roles** cùng lúc
- Ví dụ: `['user_manager', 'content_manager', 'support']`
- Chỉ cần **1 trong các required roles** là được phép truy cập

### ⚠️ Dashboard
- Dashboard (trang chính) không bị giới hạn role
- Tất cả admin đều xem được thống kê
- Chỉ các **navigation đến trang con** mới check role

## Testing

### Test 1: Super admin - toàn quyền
1. Đăng nhập với admin có role `super_admin`
2. Thử truy cập tất cả trang quản lý → ✅ Tất cả đều cho phép

### Test 2: Content manager - chỉ nội dung
1. Tạo admin mới, chỉ gán role `content_manager`
2. Thử truy cập:
   - Foods, Dishes, Drinks, Nutrients, Health Conditions, Drugs → ✅ Được phép
   - Users (user_manager) → ❌ Bị chặn
   - Role Management → ❌ Bị chặn

### Test 3: Support - chỉ hỗ trợ
1. Tạo admin mới, chỉ gán role `support`
2. Thử truy cập:
   - Users (để hỗ trợ) → ✅ Được phép
   - Foods, Dishes, etc. → ❌ Bị chặn

## Files liên quan

### Frontend
- `lib/widgets/role_protected_screen.dart` - Widget bảo vệ trang theo role
- `lib/services/admin_role_service.dart` - Service gọi API role
- `lib/screens/admin_dashboard.dart` - Dashboard với role protection
- `lib/screens/admin_role_management_screen.dart` - Trang quản lý role

### Backend
- `backend/utils/roleMiddleware.js` - Middleware check role
- `backend/routes/adminRoleRoutes.js` - Routes quản lý role
- `backend/controllers/adminRoleController.js` - Controller xử lý logic role
- `backend/others/seed_roles.js` - Script seed roles ban đầu

## Câu hỏi thường gặp

**Q: Tôi là admin mới, làm sao có role?**
A: Liên hệ super_admin để được gán role phù hợp.

**Q: Tôi muốn role nào để quản lý thực phẩm?**
A: Cần role `content_manager` hoặc `analyst`.

**Q: Tôi có thể tự gán role cho mình không?**
A: Không, chỉ `super_admin` mới gán được role.

**Q: Làm sao để trở thành super_admin?**
A: Chỉ super_admin hiện tại mới gán được. Admin đầu tiên tự động là super_admin khi chạy `seed_roles.js`.

---

**Phiên bản**: 1.0  
**Ngày cập nhật**: December 4, 2025  
**Tác giả**: GitHub Copilot
