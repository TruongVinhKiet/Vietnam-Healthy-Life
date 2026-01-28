-- =================================================================================
-- ULTRA DRINK COMPLETE - ĐỒ UỐNG SIÊU CẤP VỚI TẤT CẢ NUTRIENTS
-- =================================================================================
-- Tạo đồ uống Ultra Drink chứa tất cả nutrient ở mức 1000 đơn vị
-- Đặc biệt có thông số nước (hydration)
-- Dựa theo Ultra Dish Complete (dish_id = 999)
-- =================================================================================

-- 1. Tạo Ultra Drink (drink_id = 999)
INSERT INTO drink (
    drink_id, 
    name, 
    vietnamese_name, 
    description, 
    category, 
    base_liquid, 
    default_volume_ml, 
    default_temperature, 
    hydration_ratio, 
    caffeine_mg, 
    sugar_free, 
    is_template, 
    is_public, 
    created_by_admin
) VALUES (
    999,
    'Ultra Drink Complete',
    'Nước Uống Siêu Cấp',
    'Đồ uống chứa tất cả các chất dinh dưỡng ở mức 1000 đơn vị mỗi loại. Dùng cho testing và development.',
    'Healthy',
    'Water',
    1000,
    'Room',
    1.0,  -- Hydration ratio = 100%
    0,
    TRUE,
    TRUE,
    TRUE,
    1
) ON CONFLICT (drink_id) DO UPDATE SET
    name = EXCLUDED.name,
    vietnamese_name = EXCLUDED.vietnamese_name,
    description = EXCLUDED.description,
    hydration_ratio = EXCLUDED.hydration_ratio;

-- 2. Thêm thành phần cho Ultra Drink (dựa theo Ultra Food)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes) VALUES 
(999, 999, 1000, 'g', 1, 'Ultra Food - chứa tất cả nutrient')
ON CONFLICT (drink_id, food_id) DO UPDATE SET 
    amount_g = EXCLUDED.amount_g,
    notes = EXCLUDED.notes;

-- 3. Thêm TẤT CẢ nutrients cho Ultra Drink (amount_per_100ml = 1000)
-- Lấy danh sách tất cả nutrient_id từ bảng nutrient
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml)
SELECT 
    999 as drink_id,
    nutrient_id,
    1000.0 as amount_per_100ml
FROM nutrient
WHERE nutrient_id IS NOT NULL
ON CONFLICT (drink_id, nutrient_id) 
DO UPDATE SET amount_per_100ml = EXCLUDED.amount_per_100ml;

-- =================================================================================
-- KẾT QUẢ:
-- Ultra Drink (999) giờ có:
-- - Tất cả nutrients từ bảng nutrient (52+ nutrients)
-- - Mỗi nutrient = 1000 đơn vị per 100ml
-- - Hydration ratio = 1.0 (100% nước)
-- - Volume mặc định = 1000ml (1 lít)
-- 
-- ĐẶC BIỆT:
-- - Nước (Water/Hydration): 1000ml per 100ml × 10 (1000ml) = 10,000ml = 10 lít
-- - Protein: 1000g per 100ml × 10 = 10,000g = 10kg
-- - Calories: 1000 kcal per 100ml × 10 = 10,000 kcal
-- 
-- Dùng để test:
-- - Smart Suggestions system
-- - Nutrient display trong drink cards
-- - Hydration tracking
-- =================================================================================
