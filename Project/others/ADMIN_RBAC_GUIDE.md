# Admin RBAC System - Hệ Thống Phân Quyền Admin

## 🎯 Tổng Quan

Hệ thống **Role-Based Access Control (RBAC)** cho phép phân quyền chi tiết cho các admin với nhiều vai trò khác nhau, đảm bảo an toàn và phân quyền hợp lý.

## 📊 Database Schema

### Tables Đã Có Sẵn (từ schema.sql):
```sql
-- Role: Định nghĩa các vai trò
CREATE TABLE Role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

-- AdminRole: Liên kết admin với các role (many-to-many)
CREATE TABLE AdminRole (
    admin_id INT REFERENCES Admin(admin_id) ON DELETE CASCADE,
    role_id INT REFERENCES Role(role_id) ON DELETE CASCADE,
    PRIMARY KEY (admin_id, role_id)
);
```

## 🎭 Các Role Chuẩn

### 1. **super_admin** 
- **Mô tả**: Toàn quyền trên hệ thống
- **Quyền hạn**: Truy cập TẤT CẢ tính năng, không bị chặn bởi bất kỳ middleware nào
- **Permissions**: `['*']` (all)
- **Use case**: Chủ hệ thống, admin cấp cao nhất

### 2. **user_manager**
- **Mô tả**: Quản lý người dùng
- **Quyền hạn**:
  - `users.view` - Xem danh sách users
  - `users.block` - Chặn users
  - `users.unblock` - Gỡ chặn users
  - `users.delete` - Xóa users
  - `activity.view` - Xem activity logs
- **Use case**: Admin chuyên quản lý users, xử lý vi phạm

### 3. **content_manager**
- **Mô tả**: Quản lý nội dung (foods, nutrients, health conditions)
- **Quyền hạn**:
  - `foods.create/update/delete/view` - Quản lý thực phẩm
  - `nutrients.create/update/delete` - Quản lý chất dinh dưỡng
  - `conditions.manage` - Quản lý bệnh lý
- **Use case**: Admin chuyên cập nhật database thực phẩm, dinh dưỡng

### 4. **analyst**
- **Mô tả**: Xem analytics và báo cáo (Read-Only)
- **Quyền hạn**:
  - `analytics.view` - Xem analytics
  - `activity.view` - Xem activity logs
  - `dashboard.view` - Xem dashboard
  - `users.view` - Xem users (không sửa)
- **Use case**: Analyst, data scientist, báo cáo

### 5. **support**
- **Mô tả**: Hỗ trợ người dùng
- **Quyền hạn**:
  - `users.view` - Xem users
  - `unblock.view` - Xem yêu cầu gỡ chặn
  - `unblock.approve` - Phê duyệt gỡ chặn
  - `activity.view` - Xem lịch sử hoạt động
- **Use case**: Team support xử lý yêu cầu từ users

## 🔧 Files Đã Tạo

### Backend Files:

1. **`backend/services/roleService.js`** (108 lines)
   - Các function helper để quản lý roles
   - `getAdminRoles(adminId)` - Lấy roles của admin
   - `hasRole(adminId, roleName)` - Kiểm tra có role không
   - `hasAnyRole(adminId, roleNames)` - Kiểm tra có 1 trong các role
   - `assignRole(adminId, roleName)` - Gán role
   - `removeRole(adminId, roleName)` - Gỡ role
   - `getAllRoles()` - Lấy tất cả roles
   - `getAdminWithRoles(adminId)` - Lấy admin kèm roles

2. **`backend/utils/roleMiddleware.js`** (77 lines)
   - Middleware để check permissions
   - `requireRole(roles)` - Yêu cầu 1 hoặc nhiều roles
   - `requireSuperAdmin()` - Chỉ super_admin
   - `attachRoles(req, res, next)` - Gắn roles vào req.admin

3. **`backend/controllers/roleController.js`** (170 lines)
   - Controller xử lý API quản lý roles
   - GET `/admin/roles/all` - Lấy tất cả roles
   - GET `/admin/roles/my-roles` - Lấy roles của mình
   - GET `/admin/roles/permissions` - Permission map
   - GET `/admin/roles/admins/:adminId` - Roles của admin khác
   - POST `/admin/roles/admins/:adminId/assign` - Gán role
   - DELETE `/admin/roles/admins/:adminId/remove` - Gỡ role

4. **`backend/routes/admin.js`** (Updated)
   - Áp dụng RBAC cho TẤT CẢ routes
   - Mỗi endpoint có role requirements rõ ràng

5. **`backend/migrations/2025_seed_admin_roles.sql`**
   - SQL script seed 5 roles chuẩn

6. **`backend/seed_roles.js`**
   - Node.js script để seed roles và gán super_admin cho admin đầu tiên

7. **`backend/test_rbac.js`**
   - Test script kiểm tra toàn bộ RBAC system

## 📡 API Endpoints

### Role Management (Super Admin Only)

#### 1. GET `/admin/roles/all`
Lấy tất cả roles có trong hệ thống.

**Yêu cầu**: Super Admin

**Response**:
```json
{
  "success": true,
  "roles": [
    {
      "role_id": 1,
      "role_name": "super_admin"
    },
    {
      "role_id": 2,
      "role_name": "user_manager"
    }
  ]
}
```

#### 2. GET `/admin/roles/my-roles`
Lấy roles của admin hiện tại.

**Yêu cầu**: Admin đã login

**Response**:
```json
{
  "success": true,
  "admin_id": 1,
  "roles": ["super_admin", "analyst"]
}
```

#### 3. GET `/admin/roles/permissions`
Lấy permission map của tất cả roles.

**Yêu cầu**: Admin đã login

**Response**:
```json
{
  "success": true,
  "permissions": {
    "super_admin": {
      "description": "Full system access",
      "permissions": ["*"]
    },
    "user_manager": {
      "description": "Manage users",
      "permissions": [
        "users.view",
        "users.block",
        "users.unblock",
        "users.delete",
        "activity.view"
      ]
    }
  }
}
```

#### 4. GET `/admin/roles/admins/:adminId`
Lấy roles của một admin cụ thể.

**Yêu cầu**: Super Admin

**Response**:
```json
{
  "success": true,
  "admin": {
    "admin_id": 2,
    "username": "john@admin.com",
    "created_at": "2025-11-14T...",
    "roles": ["user_manager", "support"]
  }
}
```

#### 5. POST `/admin/roles/admins/:adminId/assign`
Gán role cho admin.

**Yêu cầu**: Super Admin

**Body**:
```json
{
  "role_name": "user_manager"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Role 'user_manager' assigned successfully",
  "admin": {
    "admin_id": 2,
    "username": "john@admin.com",
    "roles": ["user_manager"]
  }
}
```

#### 6. DELETE `/admin/roles/admins/:adminId/remove`
Gỡ role khỏi admin.

**Yêu cầu**: Super Admin

**Body**:
```json
{
  "role_name": "analyst"
}
```

**Security**: Không cho phép gỡ super_admin khỏi chính mình

**Response**:
```json
{
  "success": true,
  "message": "Role 'analyst' removed successfully",
  "admin": {
    "admin_id": 2,
    "username": "john@admin.com",
    "roles": ["user_manager"]
  }
}
```

## 🛡️ Protected Routes với RBAC

### User Management
```javascript
// Xem users: user_manager, analyst, support
GET /admin/users

// Xóa user: user_manager only
DELETE /admin/users/:id

// Block user: user_manager only
POST /admin/users/:id/block

// Unblock user: user_manager, support
POST /admin/users/:id/unblock
```

### Food Management
```javascript
// Xem foods: content_manager, analyst
GET /admin/foods

// Tạo/sửa/xóa food: content_manager only
POST /admin/foods
PUT /admin/foods/:id
DELETE /admin/foods/:id
```

### Analytics
```javascript
// Xem analytics: analyst, user_manager
GET /admin/activity/overview
GET /admin/users/:userId/activity/analytics

// Log activity: user_manager only
POST /admin/users/:userId/activity
```

### Role Management
```javascript
// Tất cả role management: super_admin only
GET /admin/roles/all
POST /admin/roles/admins/:adminId/assign
DELETE /admin/roles/admins/:adminId/remove

// Xem permissions: all admins
GET /admin/roles/my-roles
GET /admin/roles/permissions
```

## 🚀 Cách Sử Dụng

### 1. Seed Roles vào Database

**Cách 1: Dùng SQL Script**
```bash
# Run SQL migration
psql -U postgres -d Health -f backend/migrations/2025_seed_admin_roles.sql
```

**Cách 2: Dùng Node.js Script**
```bash
cd backend
node seed_roles.js
```

Script sẽ:
- Tạo 5 roles chuẩn
- Tự động gán `super_admin` cho admin đầu tiên

### 2. Gán Role cho Admin

**Via API:**
```bash
# Login để lấy token
curl -X POST http://localhost:60491/auth/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'

# Gán role user_manager cho admin ID 2
curl -X POST http://localhost:60491/admin/roles/admins/2/assign \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role_name":"user_manager"}'
```

**Via Database (Direct):**
```sql
-- Gán role user_manager cho admin ID 2
INSERT INTO AdminRole (admin_id, role_id)
SELECT 2, role_id FROM Role WHERE role_name = 'user_manager';
```

### 3. Kiểm Tra Roles

```bash
# Xem roles của mình
curl http://localhost:60491/admin/roles/my-roles \
  -H "Authorization: Bearer YOUR_TOKEN"

# Xem roles của admin khác (cần super_admin)
curl http://localhost:60491/admin/roles/admins/2 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 4. Test RBAC System

```bash
cd backend
node test_rbac.js
```

Output mong đợi:
```
=== Testing Admin RBAC System ===

1. Logging in as admin...
✅ Login successful

2. Checking my roles...
✅ My roles: [ 'super_admin' ]

3. Getting all available roles...
✅ Available roles:
   - analyst (ID: 4)
   - content_manager (ID: 3)
   - super_admin (ID: 1)
   - support (ID: 5)
   - user_manager (ID: 2)

4. Getting role permissions map...
✅ Role Permissions:
   ...

5. Testing protected routes access...
   ✅ GET /admin/users - Success (5 users)
   ✅ GET /admin/foods - Success (10 foods)
   ✅ GET /admin/activity/overview - Success (20 activities)

🎉 All RBAC tests completed!
```

## 💡 Use Cases Thực Tế

### Scenario 1: Team Admin Lớn

```
CEO (super_admin)
  ↓
├─ Tech Lead (super_admin)
├─ User Support Team
│   ├─ Support Manager (user_manager)
│   └─ Support Agent 1,2,3 (support)
├─ Content Team
│   ├─ Content Manager (content_manager)
│   └─ Content Editor 1,2 (content_manager)
└─ Analytics Team
    └─ Data Analyst 1,2 (analyst)
```

### Scenario 2: Startup Nhỏ

```
Founder (super_admin + user_manager + content_manager)
Intern (analyst)
```

### Scenario 3: Phân Quyền Theo Chức Năng

**Admin A** - Chỉ quản lý users:
```bash
# Gán role
POST /admin/roles/admins/A/assign { "role_name": "user_manager" }

# Admin A có thể:
✅ GET /admin/users
✅ POST /admin/users/:id/block
✅ GET /admin/activity/overview
❌ POST /admin/foods (403 Forbidden)
❌ DELETE /admin/nutrients/:id (403 Forbidden)
```

**Admin B** - Chỉ quản lý content:
```bash
# Gán role
POST /admin/roles/admins/B/assign { "role_name": "content_manager" }

# Admin B có thể:
✅ GET /admin/foods
✅ POST /admin/foods
✅ DELETE /admin/nutrients/:id
❌ DELETE /admin/users/:id (403 Forbidden)
```

## 🔒 Security Features

### 1. Super Admin Bypass
```javascript
// Super admin LUÔN LUÔN được phép
if (isSuperAdmin) {
  return next(); // Bypass tất cả role checks
}
```

### 2. Self-Protection
```javascript
// Không cho phép gỡ super_admin từ chính mình
if (req.admin.admin_id === parseInt(adminId) && role_name === 'super_admin') {
  return res.status(403).json({ error: 'Cannot remove super_admin from yourself' });
}
```

### 3. Multiple Role Support
```javascript
// Admin có thể có nhiều roles
requireRole(['user_manager', 'support'])
// Admin chỉ cần 1 trong 2 roles là được phép
```

### 4. Clear Error Messages
```json
{
  "error": "Insufficient permissions",
  "required_roles": ["user_manager", "support"],
  "message": "This action requires one of the following roles: user_manager, support"
}
```

## 📝 JWT Token Structure

Token bây giờ chứa role info:
```javascript
{
  admin_id: 1,
  username: "admin@example.com",
  role: "admin", // Legacy, luôn là "admin"
  // Roles thực tế load từ database khi cần
}
```

## 🧪 Testing Checklist

- ✅ Seed roles thành công
- ✅ Gán role cho admin
- ✅ Gỡ role khỏi admin
- ✅ Super admin bypass tất cả checks
- ✅ User manager chỉ access được user routes
- ✅ Content manager chỉ access được content routes
- ✅ Analyst chỉ có read-only access
- ✅ Support có thể approve unblock requests
- ✅ Không cho phép gỡ super_admin từ chính mình
- ✅ 403 error khi thiếu quyền
- ✅ Multiple roles hoạt động đúng

## 🔄 Migration Path

### Từ hệ thống cũ (chỉ có adminMiddleware):
1. Run seed script: `node seed_roles.js`
2. Gán super_admin cho tất cả admin hiện tại
3. Dần dần phân quyền chi tiết hơn

### Rollback:
Nếu cần rollback, chỉ cần comment requireRole middleware:
```javascript
// router.get('/users', adminMiddleware, requireRole('user_manager'), handler);
router.get('/users', adminMiddleware, handler); // Fallback
```

## 📚 Tài Liệu Thêm

- **Schema**: `backend/migrations/schema.sql` (Role, AdminRole tables)
- **Service**: `backend/services/roleService.js`
- **Middleware**: `backend/utils/roleMiddleware.js`
- **Controller**: `backend/controllers/roleController.js`
- **Routes**: `backend/routes/admin.js`
- **Seed**: `backend/seed_roles.js`
- **Test**: `backend/test_rbac.js`

---

✨ **Hệ thống RBAC đã sẵn sàng sử dụng!**
