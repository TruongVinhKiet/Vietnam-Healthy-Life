-- Migration: Grant super_admin role to huymt0401@gmail.com

DO $$
DECLARE
    v_admin_id INT;
    v_super_admin_role_id INT;
BEGIN
    -- Get admin_id for huymt0401@gmail.com
    SELECT admin_id INTO v_admin_id FROM admin WHERE username = 'huymt0401@gmail.com';
    
    IF v_admin_id IS NULL THEN
        RAISE EXCEPTION 'Admin with username huymt0401@gmail.com not found';
    ELSE
        RAISE NOTICE 'Found admin with ID: %', v_admin_id;
    END IF;
    
    -- Get super_admin role_id
    SELECT role_id INTO v_super_admin_role_id FROM role WHERE role_name = 'super_admin';
    
    IF v_super_admin_role_id IS NULL THEN
        -- Create super_admin role if doesn't exist
        INSERT INTO role (role_name)
        VALUES ('super_admin')
        RETURNING role_id INTO v_super_admin_role_id;
        RAISE NOTICE 'Created super_admin role with ID: %', v_super_admin_role_id;
    END IF;
    
    -- Grant super_admin role to this admin
    INSERT INTO adminrole (admin_id, role_id)
    VALUES (v_admin_id, v_super_admin_role_id)
    ON CONFLICT (admin_id, role_id) DO NOTHING;
    
    RAISE NOTICE 'Granted super_admin role to admin % (huymt0401@gmail.com)', v_admin_id;
END $$;
