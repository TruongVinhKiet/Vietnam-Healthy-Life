-- ============================================================
-- RBAC SYSTEM WITH DISH MANAGEMENT PERMISSIONS
-- Date: 2025-11-15
-- ============================================================

BEGIN;

-- Create Permission table
CREATE TABLE IF NOT EXISTS permission (
    permission_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    resource VARCHAR(50) NOT NULL, -- users, foods, dishes, analytics, etc.
    action VARCHAR(50) NOT NULL,   -- create, read, update, delete, manage
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create RolePermission junction table
CREATE TABLE IF NOT EXISTS rolepermission (
    role_permission_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) REFERENCES role(role_name) ON DELETE CASCADE,
    permission_id INTEGER REFERENCES permission(permission_id) ON DELETE CASCADE,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(role_name, permission_id)
);

-- Insert core permissions
INSERT INTO permission (name, description, resource, action) VALUES
-- User Management
('users.create', 'Tạo người dùng mới', 'users', 'create'),
('users.read', 'Xem danh sách người dùng', 'users', 'read'),
('users.update', 'Cập nhật thông tin người dùng', 'users', 'update'),
('users.delete', 'Xóa người dùng', 'users', 'delete'),
('users.manage', 'Quản lý toàn bộ người dùng', 'users', 'manage'),

-- Food Management
('foods.create', 'Thêm thực phẩm mới', 'foods', 'create'),
('foods.read', 'Xem danh sách thực phẩm', 'foods', 'read'),
('foods.update', 'Cập nhật thông tin thực phẩm', 'foods', 'update'),
('foods.delete', 'Xóa thực phẩm', 'foods', 'delete'),
('foods.manage', 'Quản lý toàn bộ thực phẩm', 'foods', 'manage'),

-- Dish Management (NEW)
('dishes.create', 'Tạo món ăn mới', 'dishes', 'create'),
('dishes.read', 'Xem danh sách món ăn', 'dishes', 'read'),
('dishes.update', 'Cập nhật thông tin món ăn', 'dishes', 'update'),
('dishes.delete', 'Xóa món ăn', 'dishes', 'delete'),
('dishes.manage', 'Quản lý toàn bộ món ăn', 'dishes', 'manage'),
('dishes.approve', 'Phê duyệt món ăn từ user', 'dishes', 'approve'),

-- Analytics
('analytics.view', 'Xem báo cáo thống kê', 'analytics', 'read'),
('analytics.export', 'Xuất báo cáo', 'analytics', 'export'),

-- Activity Logs
('logs.view', 'Xem nhật ký hoạt động', 'logs', 'read'),
('logs.delete', 'Xóa nhật ký', 'logs', 'delete'),

-- Role Management
('roles.create', 'Tạo vai trò mới', 'roles', 'create'),
('roles.update', 'Cập nhật vai trò', 'roles', 'update'),
('roles.delete', 'Xóa vai trò', 'roles', 'delete'),
('roles.assign', 'Gán vai trò cho admin', 'roles', 'assign')

ON CONFLICT (name) DO NOTHING;

-- Assign permissions to roles
-- Super Admin: All permissions
INSERT INTO rolepermission (role_name, permission_id)
SELECT 'super_admin', permission_id FROM permission
ON CONFLICT DO NOTHING;

-- Content Manager: Foods and Dishes management
INSERT INTO rolepermission (role_name, permission_id)
SELECT 'content_manager', permission_id FROM permission 
WHERE resource IN ('foods', 'dishes')
ON CONFLICT DO NOTHING;

-- Analytics Manager: View analytics and logs
INSERT INTO rolepermission (role_name, permission_id)
SELECT 'analytics_manager', permission_id FROM permission 
WHERE resource IN ('analytics', 'logs') AND action IN ('read', 'export')
ON CONFLICT DO NOTHING;

-- User Manager: User management only
INSERT INTO rolepermission (role_name, permission_id)
SELECT 'user_manager', permission_id FROM permission 
WHERE resource = 'users'
ON CONFLICT DO NOTHING;

-- Create function to check permission
CREATE OR REPLACE FUNCTION has_permission(
    p_admin_id INTEGER,
    p_permission_name VARCHAR(100)
) RETURNS BOOLEAN AS $$
DECLARE
    v_has_permission BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1
        FROM adminrole ar
        JOIN rolepermission rp ON ar.role_name = rp.role_name
        JOIN permission p ON rp.permission_id = p.permission_id
        WHERE ar.admin_id = p_admin_id
        AND p.name = p_permission_name
    ) INTO v_has_permission;
    
    RETURN v_has_permission;
END;
$$ LANGUAGE plpgsql;

-- Create function to get admin permissions
CREATE OR REPLACE FUNCTION get_admin_permissions(p_admin_id INTEGER)
RETURNS TABLE(
    permission_name VARCHAR(100),
    permission_description TEXT,
    resource VARCHAR(50),
    action VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT p.name, p.description, p.resource, p.action
    FROM adminrole ar
    JOIN rolepermission rp ON ar.role_name = rp.role_name
    JOIN permission p ON rp.permission_id = p.permission_id
    WHERE ar.admin_id = p_admin_id
    ORDER BY p.resource, p.action;
END;
$$ LANGUAGE plpgsql;

COMMIT;

-- Verify installation
SELECT 
    r.role_name,
    COUNT(rp.permission_id) as permission_count,
    STRING_AGG(p.name, ', ' ORDER BY p.name) as permissions
FROM role r
LEFT JOIN rolepermission rp ON r.role_name = rp.role_name
LEFT JOIN permission p ON rp.permission_id = p.permission_id
GROUP BY r.role_name
ORDER BY r.role_name;
