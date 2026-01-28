-- ============================================================
-- VIETNAMESE DISHES SEED DATA (Updated with real food_ids)
-- 10 món Việt Nam phổ biến với thành phần dinh dưỡng chi tiết
-- ============================================================

BEGIN;

-- ============================================================
-- 1. PHỞ BÒ (Beef Pho)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Beef Pho', 'Phở Bò', 'Phở bò truyền thống với thịt bò, rau thơm và nước dùng thơm ngon', 'noodle', 600, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    -- Phở (noodles) - 300g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 3, 300, 'Bánh phở tươi', 1);
    
    -- Thịt bò - 150g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 18, 150, 'Thịt bò nạm thái lát', 2);
    
    -- Rau cải - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 10, 50, 'Rau thơm, hành, ngò', 3);
END $$;

-- ============================================================
-- 2. BÚN CHẢ (Grilled Pork with Vermicelli)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Bun Cha', 'Bún Chả', 'Bún chả Hà Nội với chả nướng, nước mắm chua ngọt', 'noodle', 500, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    -- Bún - 200g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 4, 200, 'Bún tươi', 1);
    
    -- Thịt lợn - 150g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 16, 150, 'Thịt lợn nướng', 2);
    
    -- Rau cải - 100g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 10, 100, 'Rau sống các loại', 3);
END $$;

-- ============================================================
-- 3. CƠM TẤM (Broken Rice with Grilled Pork)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Broken Rice', 'Cơm Tấm Sườn', 'Cơm tấm sườn nướng với trứng ốp la, bì, chả', 'rice', 550, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    -- Cơm trắng - 250g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 1, 250, 'Cơm tấm', 1);
    
    -- Thịt lợn - 120g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 16, 120, 'Sườn lợn nướng', 2);
    
    -- Trứng gà - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 21, 50, 'Trứng ốp la', 3);
    
    -- Cà chua - 30g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 8, 30, 'Cà chua tươi', 4);
    
    -- Dưa chuột - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 9, 50, 'Dưa chuột', 5);
END $$;

-- ============================================================
-- 4. BÁNH MÌ (Vietnamese Sandwich)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Banh Mi', 'Bánh Mì Thịt', 'Bánh mì Việt Nam với thịt, pate, rau cải', 'bread', 200, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    -- Bánh mì - 100g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 2, 100, 'Bánh mì Việt Nam', 1);
    
    -- Thịt lợn - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 16, 50, 'Thịt nguội, chả lụa', 2);
    
    -- Cà chua - 20g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 8, 20, 'Cà chua thái lát', 3);
    
    -- Dưa chuột - 20g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 9, 20, 'Dưa leo', 4);
    
    -- Rau cải - 10g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 10, 10, 'Rau mùi, ngò gai', 5);
END $$;

-- ============================================================
-- 5. GỎI CUỐN (Fresh Spring Rolls)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Spring Rolls', 'Gỏi Cuốn', 'Gỏi cuốn tươi với tôm, thịt, rau sống', 'appetizer', 300, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    -- Bún - 100g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 4, 100, 'Bún tươi', 1);
    
    -- Tôm - 80g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 20, 80, 'Tôm luộc', 2);
    
    -- Thịt lợn - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 16, 50, 'Thịt luộc', 3);
    
    -- Rau cải - 70g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 10, 70, 'Rau sống, xà lách', 4);
END $$;

-- ============================================================
-- 6. BÚN BÒ HUẾ (Hue Beef Noodle Soup)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Bun Bo Hue', 'Bún Bò Huế', 'Bún bò Huế cay nồng đặc trưng miền Trung', 'noodle', 650, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    -- Bún - 300g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 4, 300, 'Bún to', 1);
    
    -- Thịt bò - 150g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 18, 150, 'Thịt bò, giò heo', 2);
    
    -- Rau cải - 80g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 10, 80, 'Rau sống, giá đỗ', 3);
    
    -- Cà chua - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 8, 50, 'Cà chua', 4);
END $$;

-- ============================================================
-- 7. CÁ KHO TỘ (Braised Fish in Clay Pot)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Braised Fish', 'Cá Kho Tộ', 'Cá kho tộ đậm đà với nước dừa, ăn kèm cơm trắng', 'main_dish', 400, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    -- Cơm trắng - 200g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 1, 200, 'Cơm trắng', 1);
    
    -- Cá - 150g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 19, 150, 'Cá basa/cá lóc', 2);
    
    -- Rau cải - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 10, 50, 'Rau ngò', 3);
END $$;

-- ============================================================
-- 8. CANH CHUA (Sweet and Sour Soup)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Sour Soup', 'Canh Chua Cá', 'Canh chua cá miền Nam với dứa, cà chua, rau muống', 'soup', 450, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    -- Cá - 120g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 19, 120, 'Cá lóc/cá basa', 1);
    
    -- Cà chua - 80g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 8, 80, 'Cà chua', 2);
    
    -- Rau muống - 100g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 6, 100, 'Rau muống', 3);
    
    -- Dưa chuột - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 9, 50, 'Dứa (thay thế)', 4);
END $$;

-- ============================================================
-- 9. XÔI XÉO (Sticky Rice with Mung Bean)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Sticky Rice', 'Xôi Xéo', 'Xôi xéo với đậu xanh, hành phi, thịt gà xé', 'rice', 350, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    -- Cơm trắng - 200g (thay thế cho xôi)
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 1, 200, 'Gạo nếp (dùng cơm)', 1);
    
    -- Thịt gà - 100g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 17, 100, 'Thịt gà xé', 2);
    
    -- Đậu hũ - 50g (thay thế đậu xanh)
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 22, 50, 'Đậu xanh (dùng đậu hũ)', 3);
END $$;

-- ============================================================
-- 10. CHẢ GIÒ (Fried Spring Rolls)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Fried Rolls', 'Chả Giò', 'Chả giò chiên giòn với nhân thịt, rau củ', 'appetizer', 250, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    -- Thịt lợn - 100g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 16, 100, 'Thịt lợn xay', 1);
    
    -- Tôm - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 20, 50, 'Tôm băm', 2);
    
    -- Rau cải - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 10, 50, 'Rau sống ăn kèm', 3);
    
    -- Miến - 50g
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES (v_dish_id, 5, 50, 'Miến', 4);
END $$;

-- Recalculate nutrients for all dishes
SELECT calculate_dish_nutrients(dish_id) FROM dish WHERE is_template = TRUE;

COMMIT;

-- Verify insertion
SELECT 
    d.dish_id,
    d.vietnamese_name,
    d.category,
    d.serving_size_g,
    COUNT(di.dish_ingredient_id) as ingredient_count
FROM dish d
LEFT JOIN dishingredient di ON d.dish_id = di.dish_id
WHERE d.is_template = TRUE
GROUP BY d.dish_id, d.vietnamese_name, d.category, d.serving_size_g
ORDER BY d.dish_id;
