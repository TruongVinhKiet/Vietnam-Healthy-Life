-- ============================================================
-- SEED ADMIN ROLES
-- Tạo các role cơ bản cho hệ thống RBAC admin
-- ============================================================

-- Insert core roles
INSERT INTO Role (role_name) VALUES 
    ('super_admin'),
    ('user_manager'),
    ('content_manager'),
    ('analyst'),
    ('support')
ON CONFLICT (role_name) DO NOTHING;

-- Note: 
-- - super_admin: Full access to all features
-- - user_manager: Can manage users (view, block, unblock, delete)
-- - content_manager: Can manage foods, nutrients, health conditions
-- - analyst: Read-only access to analytics and reports
-- - support: Can view users and handle unblock requests

-- To assign roles to an admin:
-- INSERT INTO AdminRole (admin_id, role_id) 
-- SELECT 1, role_id FROM Role WHERE role_name = 'super_admin';
