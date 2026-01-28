-- Migration: Grant super_admin role to truonghoankiet@gmail.com

DO $$
DECLARE
    v_admin_id INT;
    v_super_admin_role_id INT;
BEGIN
    -- Get or create admin for truonghoankiet@gmail.com
    SELECT admin_id INTO v_admin_id FROM admin WHERE username = 'truonghoankiet@gmail.com';
    
    IF v_admin_id IS NULL THEN
        -- Create admin if doesn't exist (with a placeholder password hash)
        INSERT INTO admin (username, password_hash) 
        VALUES ('truonghoankiet@gmail.com', '$2a$10$dummyhashforadminaccount12345678901234567890')
        RETURNING admin_id INTO v_admin_id;
        RAISE NOTICE 'Created new admin with ID: %', v_admin_id;
    ELSE
        RAISE NOTICE 'Admin already exists with ID: %', v_admin_id;
    END IF;
    
    -- Get super_admin role_id
    SELECT role_id INTO v_super_admin_role_id FROM role WHERE role_name = 'super_admin';
    
    IF v_super_admin_role_id IS NULL THEN
        -- Create super_admin role if doesn't exist
        INSERT INTO role (role_name, description)
        VALUES ('super_admin', 'Super Administrator with all permissions')
        RETURNING role_id INTO v_super_admin_role_id;
        RAISE NOTICE 'Created super_admin role with ID: %', v_super_admin_role_id;
    END IF;
    
    -- Grant super_admin role to this admin
    INSERT INTO adminrole (admin_id, role_id)
    VALUES (v_admin_id, v_super_admin_role_id)
    ON CONFLICT (admin_id, role_id) DO NOTHING;
    
    RAISE NOTICE 'Granted super_admin role to admin %', v_admin_id;
END $$;
