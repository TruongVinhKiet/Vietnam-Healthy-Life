-- ============================================================
-- SEED DATA: SUPER FOOD & SUPER DRINK
-- ============================================================
-- Tạo 1 super food và 1 super drink với 1000 đơn vị của TẤT CẢ nutrient
-- Khi add meal/drink với super food/drink này, tất cả nutrient sẽ tăng 100%
-- ============================================================

BEGIN;

-- ============================================================
-- 1. Lấy admin_id đầu tiên để tạo food/drink
-- ============================================================
DO $$
DECLARE
    v_admin_id INT;
    v_super_food_id INT;
    v_super_drink_id INT;
    v_nutrient RECORD;
BEGIN
    -- Lấy admin_id đầu tiên
    SELECT admin_id INTO v_admin_id FROM Admin LIMIT 1;
    
    IF v_admin_id IS NULL THEN
        RAISE EXCEPTION 'No admin found. Please create an admin first.';
    END IF;

    -- ============================================================
    -- 2. Tạo SUPER FOOD
    -- ============================================================
    INSERT INTO Food (
        name, category, image_url, created_by_admin, 
        serving_size_g, is_active, is_public
    ) VALUES (
        'SuperFood Complete™ - Complete Nutrition (100% All Nutrients)',
        'Test/Reference',
        'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=400',
        v_admin_id,
        100.00,
        TRUE,
        TRUE
    )
    ON CONFLICT (name) DO UPDATE SET
        category = EXCLUDED.category,
        image_url = EXCLUDED.image_url,
        serving_size_g = EXCLUDED.serving_size_g,
        is_active = EXCLUDED.is_active,
        is_public = EXCLUDED.is_public
    RETURNING food_id INTO v_super_food_id;

    -- Nếu không có conflict, lấy ID từ insert
    IF v_super_food_id IS NULL THEN
        SELECT food_id INTO v_super_food_id 
        FROM Food 
        WHERE name = 'SuperFood Complete™ - Complete Nutrition (100% All Nutrients)';
    END IF;

    -- ============================================================
    -- 3. Tạo SUPER DRINK
    -- ============================================================
    INSERT INTO Drink (
        name, slug, description, image_url, created_by_admin,
        serving_size_ml, is_active, is_public
    ) VALUES (
        'SuperDrink Complete™ - Complete Nutrition (100% All Nutrients)',
        'superdrink-complete-100-percent-all-nutrients',
        'Super drink chứa 100% tất cả các chất dinh dưỡng cần thiết. Dùng để test và đảm bảo tất cả nutrient được cập nhật đúng.',
        'https://images.unsplash.com/photo-1551538827-9c037cb4f32a?w=400',
        v_admin_id,
        100.00,
        TRUE,
        TRUE
    )
    ON CONFLICT (slug) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        image_url = EXCLUDED.image_url,
        serving_size_ml = EXCLUDED.serving_size_ml,
        is_active = EXCLUDED.is_active,
        is_public = EXCLUDED.is_public
    RETURNING drink_id INTO v_super_drink_id;

    -- Nếu không có conflict, lấy ID từ insert
    IF v_super_drink_id IS NULL THEN
        SELECT drink_id INTO v_super_drink_id 
        FROM Drink 
        WHERE slug = 'superdrink-complete-100-percent-all-nutrients';
    END IF;

    -- ============================================================
    -- 4. Thêm TẤT CẢ nutrient vào SUPER FOOD với giá trị 1000
    -- ============================================================
    -- Xóa các nutrient cũ của super food (nếu có)
    DELETE FROM FoodNutrient WHERE food_id = v_super_food_id;

    -- Thêm tất cả nutrient với giá trị 1000
    FOR v_nutrient IN 
        SELECT nutrient_id, nutrient_code, unit 
        FROM Nutrient 
        ORDER BY nutrient_id
    LOOP
        -- Tính giá trị 1000 theo đơn vị của nutrient
        -- Với 100g food, mỗi nutrient có 1000 đơn vị
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_super_food_id, v_nutrient.nutrient_id, 1000.00)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET
            amount_per_100g = 1000.00;
    END LOOP;

    -- ============================================================
    -- 5. Thêm TẤT CẢ nutrient vào SUPER DRINK với giá trị 1000
    -- ============================================================
    -- Xóa các nutrient cũ của super drink (nếu có)
    DELETE FROM DrinkNutrient WHERE drink_id = v_super_drink_id;

    -- Thêm tất cả nutrient với giá trị 1000
    FOR v_nutrient IN 
        SELECT nutrient_id, nutrient_code, unit 
        FROM Nutrient 
        ORDER BY nutrient_id
    LOOP
        -- Với 100ml drink, mỗi nutrient có 1000 đơn vị
        INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
        VALUES (v_super_drink_id, v_nutrient.nutrient_id, 1000.00)
        ON CONFLICT (drink_id, nutrient_id) DO UPDATE SET
            amount_per_100ml = 1000.00;
    END LOOP;

    RAISE NOTICE 'Super Food ID: %, Super Drink ID: %', v_super_food_id, v_super_drink_id;
    RAISE NOTICE 'Added all nutrients to Super Food and Super Drink with value 1000';

END $$;

COMMIT;

-- ============================================================
-- GHI CHÚ:
-- ============================================================
-- 1. Super Food: Khi add 100g super food vào meal, tất cả nutrient sẽ có giá trị 1000
-- 2. Super Drink: Khi add 100ml super drink, tất cả nutrient sẽ có giá trị 1000
-- 3. Để test: Add 100g super food hoặc 100ml super drink sẽ làm tất cả nutrient tăng 100%
-- 4. File này sử dụng ON CONFLICT để tránh lỗi khi chạy nhiều lần
-- ============================================================

