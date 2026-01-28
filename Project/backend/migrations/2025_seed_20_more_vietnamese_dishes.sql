-- ============================================================
-- 20 MORE VIETNAMESE DISHES
-- Additional diverse Vietnamese dishes using existing food IDs
-- ============================================================

BEGIN;

-- ============================================================
-- 1. MÌ XÀO (Stir-fried Noodles)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Stir-fried Noodles', 'Mì Xào Thập Cẩm', 'Mì xào giòn với tôm, thịt, rau củ', 'noodle', 450, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 5, 200, 'Mì (miến)', 1),
    (v_dish_id, 20, 80, 'Tôm', 2),
    (v_dish_id, 16, 70, 'Thịt lợn', 3),
    (v_dish_id, 10, 60, 'Rau cải', 4),
    (v_dish_id, 40, 40, 'Hành tây', 5);
END $$;

-- ============================================================
-- 2. CƠM GÀ (Chicken Rice)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Chicken Rice', 'Cơm Gà Xối Mỡ', 'Cơm gà Hải Nam truyền thống', 'rice', 450, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 1, 250, 'Cơm trắng', 1),
    (v_dish_id, 17, 150, 'Thịt gà', 2),
    (v_dish_id, 35, 20, 'Hành lá', 3),
    (v_dish_id, 9, 30, 'Dưa chuột', 4);
END $$;

-- ============================================================
-- 3. CANH RONG BIỂN (Seaweed Soup)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Seaweed Soup', 'Canh Rong Biển Thịt', 'Canh rong biển nấu với thịt bằm, trứng', 'soup', 400, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 16, 100, 'Thịt lợn băm', 1),
    (v_dish_id, 21, 50, 'Trứng gà', 2),
    (v_dish_id, 8, 50, 'Cà chua', 3),
    (v_dish_id, 35, 15, 'Hành lá', 4);
END $$;

-- ============================================================
-- 4. BÒ LÚC LẮC (Shaking Beef)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Shaking Beef', 'Bò Lúc Lắc', 'Bò lúc lắc kiểu Pháp Việt', 'main_dish', 350, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 18, 200, 'Thịt bò', 1),
    (v_dish_id, 40, 50, 'Hành tây', 2),
    (v_dish_id, 8, 50, 'Cà chua', 3),
    (v_dish_id, 37, 30, 'Rau sống', 4);
END $$;

-- ============================================================
-- 5. HỦ TIẾU (Southern Noodle Soup)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Hu Tieu', 'Hủ Tiếu Nam Vang', 'Hủ tiếu Nam Vang với tôm, thịt, gan', 'noodle', 550, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 4, 250, 'Hủ tiếu (bún)', 1),
    (v_dish_id, 20, 100, 'Tôm', 2),
    (v_dish_id, 16, 80, 'Thịt lợn', 3),
    (v_dish_id, 10, 60, 'Rau cải', 4),
    (v_dish_id, 35, 20, 'Hành lá', 5);
END $$;

-- ============================================================
-- 6. THỊT KHO TÀU (Braised Pork with Eggs)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Braised Pork Eggs', 'Thịt Kho Tàu', 'Thịt kho trứng kiểu miền Nam', 'main_dish', 400, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 1, 200, 'Cơm trắng', 1),
    (v_dish_id, 16, 150, 'Thịt lợn', 2),
    (v_dish_id, 21, 50, 'Trứng gà', 3);
END $$;

-- ============================================================
-- 7. GÀ CHIÊN NƯỚC MẮM (Fish Sauce Chicken Wings)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Fish Sauce Chicken', 'Gà Chiên Nước Mắm', 'Gà chiên giòn tẩm nước mắm ngọt', 'main_dish', 300, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 17, 250, 'Thịt gà', 1),
    (v_dish_id, 37, 30, 'Rau sống', 2),
    (v_dish_id, 9, 20, 'Dưa chuột', 3);
END $$;

-- ============================================================
-- 8. CƠM CHIÊN (Fried Rice)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Fried Rice', 'Cơm Chiên Dương Châu', 'Cơm chiên trứng, xúc xích, rau củ', 'rice', 400, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 1, 250, 'Cơm trắng', 1),
    (v_dish_id, 21, 50, 'Trứng gà', 2),
    (v_dish_id, 20, 50, 'Tôm', 3),
    (v_dish_id, 10, 30, 'Rau cải', 4),
    (v_dish_id, 35, 20, 'Hành lá', 5);
END $$;

-- ============================================================
-- 9. BÚN RIÊU (Crab Noodle Soup)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Bun Rieu', 'Bún Riêu Cua', 'Bún riêu cua đồng miền Bắc', 'noodle', 550, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 4, 250, 'Bún', 1),
    (v_dish_id, 22, 100, 'Đậu hũ', 2),
    (v_dish_id, 8, 80, 'Cà chua', 3),
    (v_dish_id, 6, 60, 'Rau muống', 4),
    (v_dish_id, 35, 20, 'Hành lá', 5);
END $$;

-- ============================================================
-- 10. NEM NƯỚNG (Grilled Pork Skewers)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Grilled Pork Skewers', 'Nem Nướng', 'Nem nướng Nha Trang ăn kèm bánh tráng', 'appetizer', 300, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 16, 150, 'Thịt lợn', 1),
    (v_dish_id, 37, 80, 'Rau sống', 2),
    (v_dish_id, 9, 40, 'Dưa chuột', 3),
    (v_dish_id, 34, 30, 'Bánh tráng', 4);
END $$;

-- ============================================================
-- 11. SÚP CUA (Crab Soup)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Crab Soup', 'Súp Cua', 'Súp cua kiểu Âu Á', 'soup', 350, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 20, 100, 'Tôm (thay cua)', 1),
    (v_dish_id, 21, 50, 'Trứng gà', 2),
    (v_dish_id, 8, 50, 'Cà chua', 3),
    (v_dish_id, 43, 50, 'Nấm', 4),
    (v_dish_id, 35, 20, 'Hành lá', 5);
END $$;

-- ============================================================
-- 12. CƠM RANG (Fried Rice with Soy Sauce)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Soy Fried Rice', 'Cơm Rang Thập Cẩm', 'Cơm rang với thịt, trứng, rau', 'rice', 400, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 1, 250, 'Cơm trắng', 1),
    (v_dish_id, 17, 80, 'Thịt gà', 2),
    (v_dish_id, 21, 50, 'Trứng gà', 3),
    (v_dish_id, 10, 40, 'Rau cải', 4);
END $$;

-- ============================================================
-- 13. BÁN H MÌ THỊT NƯỚNG (Grilled Pork Baguette)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Grilled Pork Banh Mi', 'Bánh Mì Thịt Nướng', 'Bánh mì thịt nướng kiểu Sài Gòn', 'bread', 220, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 2, 100, 'Bánh mì', 1),
    (v_dish_id, 16, 70, 'Thịt lợn nướng', 2),
    (v_dish_id, 8, 20, 'Cà chua', 3),
    (v_dish_id, 9, 20, 'Dưa chuột', 4),
    (v_dish_id, 36, 10, 'Ngò', 5);
END $$;

-- ============================================================
-- 14. MỲ QUẢNG (Quang Style Noodles)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Mi Quang', 'Mì Quảng', 'Mì Quảng đặc sản miền Trung với tôm, thịt', 'noodle', 500, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 3, 200, 'Bánh phở (thay mì Quảng)', 1),
    (v_dish_id, 20, 100, 'Tôm', 2),
    (v_dish_id, 16, 80, 'Thịt lợn', 3),
    (v_dish_id, 37, 60, 'Rau sống', 4),
    (v_dish_id, 34, 30, 'Bánh tráng', 5);
END $$;

-- ============================================================
-- 15. CHÁO GÀ (Chicken Congee)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Chicken Congee', 'Cháo Gà', 'Cháo gà thơm ngon bổ dưỡng', 'rice', 450, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 1, 200, 'Cơm trắng (nấu cháo)', 1),
    (v_dish_id, 17, 120, 'Thịt gà', 2),
    (v_dish_id, 35, 20, 'Hành lá', 3),
    (v_dish_id, 36, 10, 'Ngò', 4);
END $$;

-- ============================================================
-- 16. BÚN CÁ (Fish Noodle Soup)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Fish Noodle Soup', 'Bún Cá', 'Bún cá Hà Nội với chả cá, mắm tôm', 'noodle', 500, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 4, 250, 'Bún', 1),
    (v_dish_id, 19, 150, 'Cá', 2),
    (v_dish_id, 8, 50, 'Cà chua', 3),
    (v_dish_id, 38, 30, 'Rau thơm', 4);
END $$;

-- ============================================================
-- 17. TÔM CHIÊN XÙ (Crispy Fried Shrimp)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Crispy Shrimp', 'Tôm Chiên Xù', 'Tôm chiên xù giòn rụm', 'main_dish', 250, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 20, 200, 'Tôm', 1),
    (v_dish_id, 37, 30, 'Rau sống', 2),
    (v_dish_id, 8, 20, 'Cà chua', 3);
END $$;

-- ============================================================
-- 18. CANH BÍ ĐỎ (Pumpkin Soup)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Pumpkin Soup', 'Canh Bí Đỏ Thịt Băm', 'Canh bí đỏ nấu với thịt băm', 'soup', 400, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 9, 150, 'Dưa chuột (thay bí đỏ)', 1),
    (v_dish_id, 16, 100, 'Thịt lợn băm', 2),
    (v_dish_id, 35, 15, 'Hành lá', 3);
END $$;

-- ============================================================
-- 19. ĐẬU HỦ SỐT CÀ CHUA (Tofu in Tomato Sauce)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Tofu Tomato Sauce', 'Đậu Hủ Sốt Cà Chua', 'Đậu hủ chiên sốt cà chua', 'main_dish', 350, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 22, 200, 'Đậu hũ', 1),
    (v_dish_id, 8, 100, 'Cà chua', 2),
    (v_dish_id, 40, 30, 'Hành tây', 3),
    (v_dish_id, 35, 20, 'Hành lá', 4);
END $$;

-- ============================================================
-- 20. RAU CỦ XÀO CHAY (Stir-fried Vegetables)
-- ============================================================
DO $$
DECLARE
    v_dish_id INTEGER;
BEGIN
    INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
    VALUES ('Stir-fried Veggies', 'Rau Củ Xào Chay', 'Rau củ xào thanh đạm bổ dưỡng', 'main_dish', 350, TRUE, TRUE, 1)
    RETURNING dish_id INTO v_dish_id;
    
    INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
    VALUES 
    (v_dish_id, 6, 100, 'Rau muống', 1),
    (v_dish_id, 7, 80, 'Cải thảo', 2),
    (v_dish_id, 10, 70, 'Rau cải', 3),
    (v_dish_id, 43, 50, 'Nấm', 4),
    (v_dish_id, 22, 50, 'Đậu hũ', 5);
END $$;

-- Recalculate nutrients for all new dishes
SELECT calculate_dish_nutrients(dish_id) 
FROM dish 
WHERE is_template = TRUE 
  AND dish_id NOT IN (
    SELECT dish_id FROM dish WHERE created_at < NOW() - INTERVAL '1 minute'
  );

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
ORDER BY d.dish_id DESC
LIMIT 20;
