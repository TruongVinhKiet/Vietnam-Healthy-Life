
SET client_encoding = 'UTF8';



-- Xóa dữ liệu theo thứ tự tránh lỗi khóa ngoại
DELETE FROM drinknutrient WHERE drink_id IN (
    SELECT DISTINCT drink_id FROM drinkingredient WHERE food_id BETWEEN 88 AND 112
);
DELETE FROM drinkingredient WHERE food_id BETWEEN 88 AND 112;
DELETE FROM foodnutrient WHERE food_id BETWEEN 88 AND 112;
-- Xóa các bản ghi liên quan ở bảng dishingredient trước khi xóa food
DELETE FROM dishingredient WHERE food_id BETWEEN 88 AND 112;
DELETE FROM food WHERE food_id BETWEEN 88 AND 112;

-- Reset sequence nếu cần (tùy chọn)
-- SELECT setval('food_food_id_seq', (SELECT MAX(food_id) FROM food));

-- ============================================
-- PHẦN 1: INSERT SAMPLE DATA FOR FOOD TABLE
-- Bắt đầu từ food_id = 88 (tránh conflict với data hiện có)
-- ============================================

INSERT INTO food (food_id, name, category, description) VALUES
(88, 'Nước lọc', 'Beverages', 'Nước tinh lọc không có tạp chất'),
(89, 'Nước khoáng', 'Beverages', 'Nước khoáng thiên nhiên chứa các khoáng chất'),
(90, 'Nước có gas', 'Beverages', 'Nước có gas cacbonic'),
(91, 'Nước dừa tươi', 'Beverages', 'Nước dừa xiêm tươi tự nhiên'),
(92, 'Nước mía', 'Beverages', 'Nước ép từ cây mía tươi'),
(93, 'Lá trà xanh', 'Beverages', 'Lá trà xanh khô dùng để pha'),
(94, 'Lá trà đen', 'Beverages', 'Lá trà đen khô'),
(95, 'Cà phê bột', 'Beverages', 'Hạt cà phê rang xay'),
(96, 'Sữa tươi nguyên kem', 'Dairy', 'Sữa bò tươi nguyên chất'),
(97, 'Sữa đặc có đường', 'Dairy', 'Sữa đặc ngọt'),
(98, 'Cam tươi', 'Fruits', 'Quả cam canh tươi'),
(99, 'Chanh tươi', 'Fruits', 'Quả chanh vàng/xanh tươi'),
(100, 'Dưa hấu', 'Fruits', 'Dưa hấu đỏ tươi'),
(101, 'Xoài chín', 'Fruits', 'Xoài cát Hòa Lộc chín'),
(102, 'Bơ (Quả)', 'Fruits', 'Quả bơ booth chín'),
(103, 'Trân châu đen', 'Ingredients', 'Trân châu bột sắn nấu chín'),
(104, 'Sữa chua không đường', 'Dairy', 'Sữa chua nguyên chất'),
(105, 'Rau má', 'Vegetables', 'Rau má tươi'),
(106, 'Đậu nành', 'Legumes', 'Đậu nành hạt luộc chín'),
(107, 'Hạnh nhân sống', 'Nuts', 'Hạt hạnh nhân nguyên vỏ'),
(108, 'Thịt dừa', 'Fruits', 'Thịt dừa tươi cạo nhuyễn'),
(109, 'Đường trắng', 'Sweeteners', 'Đường mía tinh luyện'),
(110, 'Đá lạnh', 'Ingredients', 'Nước đá đông lạnh'),
(111, 'Mật ong', 'Sweeteners', 'Mật ong nguyên chất'),
(112, 'Bột trà sữa', 'Ingredients', 'Hỗn hợp bột pha trà sữa');

-- ============================================
-- PHẦN 2: INSERT FOODNUTRIENT DATA
-- Thông tin dinh dưỡng cho từng nguyên liệu (per 100g)
-- ============================================

-- Coconut Water (food_id = 91)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(91, 1, 19), (91, 2, 0.7), (91, 3, 0.2), (91, 4, 3.7), (91, 15, 2.4),
(91, 24, 24), (91, 26, 25), (91, 27, 250), (91, 28, 105);

-- Fresh Milk (food_id = 96)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(96, 1, 64), (96, 2, 3.3), (96, 3, 3.6), (96, 4, 4.8), (96, 40, 2.3),
(96, 10, 10), (96, 11, 46), (96, 12, 40), (96, 17, 0.2), (96, 23, 0.4),
(96, 24, 120), (96, 25, 93), (96, 27, 150), (96, 30, 0.4);

-- Orange (food_id = 98)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(98, 1, 47), (98, 2, 0.9), (98, 3, 0.1), (98, 4, 11.8), (98, 5, 2.4),
(98, 15, 53), (98, 22, 30), (98, 24, 40), (98, 27, 181);

-- Avocado (food_id = 102)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(102, 1, 160), (102, 2, 2), (102, 3, 15), (102, 4, 8.5), (102, 5, 6.7),
(102, 38, 10), (102, 40, 2.1), (102, 13, 2.1), (102, 14, 21), (102, 15, 10),
(102, 22, 81), (102, 24, 12), (102, 26, 29), (102, 27, 485);

-- Soybeans (food_id = 106)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(106, 1, 446), (106, 2, 36.5), (106, 3, 19.9), (106, 4, 30.2), (106, 5, 9.3),
(106, 24, 277), (106, 25, 704), (106, 26, 280), (106, 27, 1797),
(106, 29, 15.7), (106, 30, 4.9);

-- Almonds (food_id = 107)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(107, 1, 579), (107, 2, 21.2), (107, 3, 49.9), (107, 4, 21.6), (107, 5, 12.5),
(107, 38, 31.5), (107, 40, 3.8), (107, 13, 25.6), (107, 17, 1.1),
(107, 24, 269), (107, 25, 481), (107, 26, 270), (107, 27, 733),
(107, 29, 3.7), (107, 30, 3.1);

-- White Sugar (food_id = 109)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(109, 1, 387), (109, 4, 100);

-- Coffee Beans (food_id = 95)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(95, 1, 1), (95, 2, 0.1), (95, 18, 0.7), (95, 26, 8), (95, 27, 49);

-- Green Tea Leaves (food_id = 93)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(93, 1, 1), (93, 15, 0.3), (93, 26, 2), (93, 27, 19);

-- Mango (food_id = 101)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(101, 1, 60), (101, 2, 0.8), (101, 3, 0.4), (101, 4, 15), (101, 5, 1.6),
(101, 11, 54), (101, 15, 36), (101, 24, 11), (101, 27, 168);

-- Watermelon (food_id = 100)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(100, 1, 30), (100, 2, 0.6), (100, 3, 0.2), (100, 4, 7.6),
(100, 11, 28), (100, 15, 8.1), (100, 27, 112);

-- Lemon (food_id = 99)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(99, 1, 29), (99, 2, 1.1), (99, 3, 0.3), (99, 4, 9.3), (99, 5, 2.8),
(99, 15, 53), (99, 24, 26), (99, 27, 138);

-- Condensed Milk (food_id = 97)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(97, 1, 321), (97, 2, 7.9), (97, 3, 8.7), (97, 4, 54.4),
(97, 24, 284), (97, 25, 203), (97, 27, 371);

-- Yogurt Plain (food_id = 104)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(104, 1, 61), (104, 2, 3.5), (104, 3, 3.3), (104, 4, 4.7),
(104, 24, 121), (104, 25, 95), (104, 23, 0.4);

-- Tapioca Pearls (food_id = 103)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(103, 1, 358), (103, 2, 0.2), (103, 4, 88.7), (103, 24, 20), (103, 29, 1);

-- Pennywort (food_id = 105)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(105, 1, 19), (105, 2, 1.8), (105, 3, 0.2), (105, 4, 3.3),
(105, 15, 48), (105, 24, 171), (105, 29, 5.6);

-- Coconut Meat (food_id = 108)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(108, 1, 354), (108, 2, 3.3), (108, 3, 33.5), (108, 4, 15.2), (108, 5, 9),
(108, 40, 29.7), (108, 24, 14), (108, 29, 2.4);

-- Honey (food_id = 111)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(111, 1, 304), (111, 2, 0.3), (111, 4, 82.4), (111, 15, 0.5),
(111, 24, 6), (111, 29, 0.4);

-- Sugarcane Juice (food_id = 92)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(92, 1, 269), (92, 2, 0.3), (92, 4, 73), (92, 24, 45), (92, 26, 21),
(92, 27, 41), (92, 29, 1.3);

-- Black Tea Leaves (food_id = 94)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(94, 1, 1), (94, 26, 3), (94, 27, 37);

-- Filtered Water (food_id = 88)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(88, 1, 0), (88, 28, 0);

-- Mineral Water (food_id = 89)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(89, 1, 0), (89, 24, 30), (89, 26, 10), (89, 27, 5), (89, 28, 20);

-- Sparkling Water (food_id = 90)
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES
(90, 1, 0), (90, 24, 8), (90, 28, 1);

-- ============================================
-- PHẦN 3: INSERT DRINKINGREDIENT DATA
-- Liên kết drink với food (công thức đồ uống)
-- ============================================

-- Drink 1: Filtered Water
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(1, 88, 250, 1, 'Nước lọc tinh khiết');

-- Drink 2: Mineral Water
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(2, 89, 250, 1, 'Nước khoáng thiên nhiên');

-- Drink 3: Sparkling Water
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(3, 90, 250, 1, 'Nước có gas cacbonic');

-- Drink 4: Coconut Water
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(4, 91, 250, 1, 'Nước dừa xiêm tươi');

-- Drink 5: Sugarcane Juice
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(5, 92, 250, 1, 'Nước mía ép tươi');

-- Drink 6: Unsweetened Green Tea
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(6, 93, 3, 1, 'Lá trà xanh khô'),
(6, 88, 250, 2, 'Nước lọc pha trà');

-- Drink 7: Black Coffee
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(7, 95, 15, 1, 'Cà phê bột Robusta/Arabica'),
(7, 88, 100, 2, 'Nước nóng pha cà phê');

-- Drink 8: Vietnamese Iced Coffee
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(8, 95, 20, 1, 'Cà phê phin'),
(8, 97, 30, 2, 'Sữa đặc có đường'),
(8, 110, 100, 3, 'Đá viên');

-- Drink 9: Fresh Milk
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(9, 96, 250, 1, 'Sữa bò tươi nguyên chất');

-- Drink 10: Diluted Condensed Milk
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(10, 97, 40, 1, 'Sữa đặc có đường'),
(10, 88, 200, 2, 'Nước lọc'),
(10, 110, 50, 3, 'Đá viên');

-- Drink 11: Fresh Orange Juice
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(11, 98, 150, 1, 'Cam tươi ép (khoảng 2-3 quả)');

-- Drink 12: Lemonade
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(12, 99, 30, 1, 'Chanh tươi vắt'),
(12, 109, 20, 2, 'Đường trắng'),
(12, 88, 200, 3, 'Nước lọc'),
(12, 110, 50, 4, 'Đá viên');

-- Drink 13: Watermelon Juice
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(13, 100, 200, 1, 'Dưa hấu đỏ tươi xay');

-- Drink 14: Mango Smoothie
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(14, 101, 150, 1, 'Xoài chín'),
(14, 96, 100, 2, 'Sữa tươi'),
(14, 109, 15, 3, 'Đường'),
(14, 110, 50, 4, 'Đá viên');

-- Drink 15: Avocado Smoothie
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(15, 102, 100, 1, 'Bơ chín'),
(15, 97, 30, 2, 'Sữa đặc'),
(15, 96, 100, 3, 'Sữa tươi'),
(15, 110, 80, 4, 'Đá viên');

-- Drink 16: Bubble Milk Tea
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(16, 94, 3, 1, 'Lá trà đen'),
(16, 96, 100, 2, 'Sữa tươi hoặc kem sữa'),
(16, 109, 25, 3, 'Đường'),
(16, 103, 50, 4, 'Trân châu đen'),
(16, 110, 80, 5, 'Đá viên');

-- Drink 17: Drinking Yogurt
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(17, 104, 150, 1, 'Sữa chua'),
(17, 109, 10, 2, 'Đường (tùy chọn)'),
(17, 88, 80, 3, 'Nước lọc pha loãng');

-- Drink 19: Pennywort Juice
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(19, 105, 50, 1, 'Rau má tươi xay'),
(19, 109, 20, 2, 'Đường'),
(19, 88, 200, 3, 'Nước lọc');

-- Drink 20: Soy Milk
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(20, 106, 80, 1, 'Đậu nành ngâm xay'),
(20, 109, 15, 2, 'Đường'),
(20, 88, 200, 3, 'Nước lọc');

-- Drink 37: Almond Milk
INSERT INTO drinkingredient (drink_id, food_id, amount_g, display_order, notes) VALUES
(37, 107, 30, 1, 'Hạnh nhân ngâm xay'),
(37, 88, 220, 2, 'Nước lọc'),
(37, 111, 10, 3, 'Mật ong (tùy chọn)');

-- ============================================
-- PHẦN 4: STORED PROCEDURES & TRIGGERS
-- Tự động tính toán dinh dưỡng
-- ============================================

-- Function: Tính toán dinh dưỡng cho 1 drink
CREATE OR REPLACE FUNCTION calculate_drink_nutrients(p_drink_id INT)
RETURNS void AS $$
DECLARE
    v_total_volume_ml NUMERIC;
    v_total_weight_g NUMERIC;
BEGIN
    SELECT COALESCE(default_volume_ml, 250) 
    INTO v_total_volume_ml
    FROM drink 
    WHERE drink_id = p_drink_id;
    
    SELECT COALESCE(SUM(amount_g), 0)
    INTO v_total_weight_g
    FROM drinkingredient
    WHERE drink_id = p_drink_id;
    
    IF v_total_weight_g = 0 THEN
        RAISE NOTICE 'Drink ID % không có nguyên liệu nào, giữ nguyên nutrients hiện có', p_drink_id;
        RETURN;
    END IF;
    
    -- Only delete nutrients that can be recalculated from ingredients
    -- This preserves manually entered nutrients that aren't in FoodNutrient
    DELETE FROM drinknutrient 
    WHERE drink_id = p_drink_id 
    AND nutrient_id IN (
        SELECT DISTINCT fn.nutrient_id
        FROM drinkingredient di
        JOIN foodnutrient fn ON fn.food_id = di.food_id
        WHERE di.drink_id = p_drink_id
    );
    
    INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml)
    SELECT 
        di.drink_id,
        fn.nutrient_id,
        ROUND(
            (SUM(fn.amount_per_100g * di.amount_g / 100.0) / v_total_volume_ml * 100)::numeric,
            6
        ) AS amount_per_100ml
    FROM drinkingredient di
    INNER JOIN foodnutrient fn ON di.food_id = fn.food_id
    WHERE di.drink_id = p_drink_id
    GROUP BY di.drink_id, fn.nutrient_id
    HAVING SUM(fn.amount_per_100g * di.amount_g / 100.0) > 0
    ON CONFLICT (drink_id, nutrient_id)
    DO UPDATE SET amount_per_100ml = EXCLUDED.amount_per_100ml;
    
    RAISE NOTICE 'Đã tính toán dinh dưỡng cho Drink ID %: % nutrients', 
                 p_drink_id, 
                 (SELECT COUNT(*) FROM drinknutrient WHERE drink_id = p_drink_id);
END;
$$ LANGUAGE plpgsql;

-- Function: Tính toán cho TẤT CẢ drinks
CREATE OR REPLACE FUNCTION calculate_all_drink_nutrients()
RETURNS void AS $$
DECLARE
    v_drink_record RECORD;
    v_total_count INT := 0;
BEGIN
    FOR v_drink_record IN 
        SELECT DISTINCT drink_id 
        FROM drinkingredient 
        ORDER BY drink_id
    LOOP
        PERFORM calculate_drink_nutrients(v_drink_record.drink_id);
        v_total_count := v_total_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Hoàn thành! Đã tính toán dinh dưỡng cho % drinks', v_total_count;
END;
$$ LANGUAGE plpgsql;

-- Trigger Function: Tự động tính lại khi có thay đổi
CREATE OR REPLACE FUNCTION trigger_recalculate_drink_nutrients()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM calculate_drink_nutrients(OLD.drink_id);
        RETURN OLD;
    ELSE
        PERFORM calculate_drink_nutrients(NEW.drink_id);
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Gắn trigger
DROP TRIGGER IF EXISTS trg_recalc_drink_nutrients ON drinkingredient;

CREATE TRIGGER trg_recalc_drink_nutrients
AFTER INSERT OR UPDATE OR DELETE ON drinkingredient
FOR EACH ROW
EXECUTE FUNCTION trigger_recalculate_drink_nutrients();

-- ============================================
-- PHẦN 5: TỰ ĐỘNG CHẠY TÍNH TOÁN
-- ============================================

SELECT calculate_all_drink_nutrients();

-- ============================================
-- KẾT THÚC - HƯỚNG DẪN SỬ DỤNG
-- ============================================

-- 1. Xem kết quả tính toán:
-- SELECT d.name, n.name as nutrient, dn.amount_per_100ml, n.unit
-- FROM drinknutrient dn
-- JOIN drink d ON dn.drink_id = d.drink_id
-- JOIN nutrient n ON dn.nutrient_id = n.nutrient_id
-- WHERE dn.drink_id = 8
-- ORDER BY dn.nutrient_id;

-- 2. Tính lại cho 1 drink cụ thể:
-- SELECT calculate_drink_nutrients(8);

-- 3. Tính lại cho TẤT CẢ:
-- SELECT calculate_all_drink_nutrients();

-- 4. Trigger sẽ TỰ ĐỘNG chạy khi thêm/sửa/xóa nguyên liệu trong drinkingredient