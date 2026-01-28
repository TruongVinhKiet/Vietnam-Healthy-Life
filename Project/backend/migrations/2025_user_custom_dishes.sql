-- ============================================================
-- USER CUSTOM DISHES ENHANCEMENT
-- Purpose: Allow users to create their own custom dishes
-- Date: 2025-11-15
-- ============================================================

-- Add is_public flag check to allow users to have private dishes
-- Already exists in 2025_dish_management.sql but ensure it's properly indexed

-- Create index for user's private dishes
CREATE INDEX IF NOT EXISTS idx_dish_user_private 
ON Dish(created_by_user, is_public) 
WHERE created_by_user IS NOT NULL;

-- Create view for user's accessible dishes (own + public)
CREATE OR REPLACE VIEW user_accessible_dishes AS
SELECT 
    d.*,
    CASE 
        WHEN d.created_by_admin IS NOT NULL THEN 'admin'
        WHEN d.created_by_user IS NOT NULL THEN 'user'
        ELSE 'unknown'
    END as created_by_type,
    u.full_name as creator_name
FROM Dish d
LEFT JOIN "User" u ON u.user_id = d.created_by_user
WHERE d.is_public = true 
   OR d.created_by_user IS NOT NULL;

-- Comment
COMMENT ON VIEW user_accessible_dishes IS 'Shows all dishes accessible to users (public + their own private dishes)';

-- ============================================================
-- END OF USER CUSTOM DISHES ENHANCEMENT
-- ============================================================
