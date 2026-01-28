-- ============================================================
-- SEED DATA: DRUGS, FOODS, DISHES, DRINKS
-- ============================================================
-- Dữ liệu mẫu phù hợp với tính năng tương tác thuốc-dinh dưỡng
-- ============================================================

BEGIN;

-- ============================================================
-- 1. SEED DRUGS (THUỐC) - Phù hợp với các bệnh trong HealthCondition
-- ============================================================

-- Thuốc cho Tiểu đường type 2
INSERT INTO Drug (drug_id, name_vi, name_en, generic_name, drug_class, description, image_url, source_link, dosage_form, is_active) VALUES
(1, 'Metformin', 'Metformin', 'Metformin Hydrochloride', 'Biguanide', 'Thuốc điều trị tiểu đường type 2, giảm sản xuất glucose ở gan', 'https://example.com/metformin.jpg', 'https://www.drugs.com/metformin.html', 'Viên nén', TRUE),
(2, 'Gliclazide', 'Gliclazide', 'Gliclazide', 'Sulfonylurea', 'Kích thích tụy sản xuất insulin', 'https://example.com/gliclazide.jpg', 'https://www.drugs.com/gliclazide.html', 'Viên nén', TRUE)
ON CONFLICT DO NOTHING;

-- Thuốc cho Cao huyết áp
INSERT INTO Drug (drug_id, name_vi, name_en, generic_name, drug_class, description, image_url, source_link, dosage_form, is_active) VALUES
(3, 'Amlodipine', 'Amlodipine', 'Amlodipine Besylate', 'Calcium Channel Blocker', 'Giãn mạch máu, hạ huyết áp', 'https://example.com/amlodipine.jpg', 'https://www.drugs.com/amlodipine.html', 'Viên nén', TRUE),
(4, 'Losartan', 'Losartan', 'Losartan Potassium', 'ARB', 'Ức chế thụ thể angiotensin', 'https://example.com/losartan.jpg', 'https://www.drugs.com/losartan.html', 'Viên nén', TRUE)
ON CONFLICT DO NOTHING;

-- Thuốc cho Mỡ máu cao
INSERT INTO Drug (drug_id, name_vi, name_en, generic_name, drug_class, description, image_url, source_link, dosage_form, is_active) VALUES
(5, 'Atorvastatin', 'Atorvastatin', 'Atorvastatin Calcium', 'Statin', 'Giảm cholesterol, LDL', 'https://example.com/atorvastatin.jpg', 'https://www.drugs.com/atorvastatin.html', 'Viên nén', TRUE),
(6, 'Rosuvastatin', 'Rosuvastatin', 'Rosuvastatin Calcium', 'Statin', 'Giảm cholesterol mạnh', 'https://example.com/rosuvastatin.jpg', 'https://www.drugs.com/rosuvastatin.html', 'Viên nén', TRUE)
ON CONFLICT DO NOTHING;

-- Thuốc cho Gout
INSERT INTO Drug (drug_id, name_vi, name_en, generic_name, drug_class, description, image_url, source_link, dosage_form, is_active) VALUES
(7, 'Allopurinol', 'Allopurinol', 'Allopurinol', 'Xanthine Oxidase Inhibitor', 'Giảm sản xuất acid uric', 'https://example.com/allopurinol.jpg', 'https://www.drugs.com/allopurinol.html', 'Viên nén', TRUE),
(8, 'Colchicine', 'Colchicine', 'Colchicine', 'Anti-inflammatory', 'Giảm đau viêm khớp do gout', 'https://example.com/colchicine.jpg', 'https://www.drugs.com/colchicine.html', 'Viên nén', TRUE)
ON CONFLICT DO NOTHING;

-- Thuốc kháng sinh (có tương tác với Canxi)
INSERT INTO Drug (drug_id, name_vi, name_en, generic_name, drug_class, description, image_url, source_link, dosage_form, is_active) VALUES
(9, 'Tetracycline', 'Tetracycline', 'Tetracycline Hydrochloride', 'Antibiotic', 'Kháng sinh phổ rộng, kỵ canxi', 'https://example.com/tetracycline.jpg', 'https://www.drugs.com/tetracycline.html', 'Viên nang', TRUE),
(10, 'Doxycycline', 'Doxycycline', 'Doxycycline Hyclate', 'Antibiotic', 'Kháng sinh, kỵ canxi và sắt', 'https://example.com/doxycycline.jpg', 'https://www.drugs.com/doxycycline.html', 'Viên nang', TRUE),
(11, 'Ciprofloxacin', 'Ciprofloxacin', 'Ciprofloxacin', 'Fluoroquinolone', 'Kháng sinh, kỵ canxi, magie, sắt', 'https://example.com/ciprofloxacin.jpg', 'https://www.drugs.com/ciprofloxacin.html', 'Viên nén', TRUE)
ON CONFLICT DO NOTHING;

-- Thuốc cho Thiếu máu
INSERT INTO Drug (drug_id, name_vi, name_en, generic_name, drug_class, description, image_url, source_link, dosage_form, is_active) VALUES
(12, 'Sắt Sulfate', 'Ferrous Sulfate', 'Ferrous Sulfate', 'Iron Supplement', 'Bổ sung sắt cho thiếu máu', 'https://example.com/iron.jpg', 'https://www.drugs.com/ferrous_sulfate.html', 'Viên nén', TRUE),
(13, 'Vitamin B12', 'Cyanocobalamin', 'Cyanocobalamin', 'Vitamin Supplement', 'Bổ sung B12 cho thiếu máu', 'https://example.com/b12.jpg', 'https://www.drugs.com/cyanocobalamin.html', 'Viên nén', TRUE)
ON CONFLICT DO NOTHING;

-- Thuốc cho Viêm dạ dày
INSERT INTO Drug (drug_id, name_vi, name_en, generic_name, drug_class, description, image_url, source_link, dosage_form, is_active) VALUES
(14, 'Omeprazole', 'Omeprazole', 'Omeprazole', 'PPI', 'Ức chế bơm proton, giảm acid dạ dày', 'https://example.com/omeprazole.jpg', 'https://www.drugs.com/omeprazole.html', 'Viên nang', TRUE),
(15, 'Pantoprazole', 'Pantoprazole', 'Pantoprazole Sodium', 'PPI', 'Giảm tiết acid dạ dày', 'https://example.com/pantoprazole.jpg', 'https://www.drugs.com/pantoprazole.html', 'Viên nén', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. LIÊN KẾT DRUG VỚI HEALTH CONDITION
-- ============================================================

-- Tiểu đường type 2 (condition_id = 1)
INSERT INTO DrugHealthCondition (drug_id, condition_id, is_primary, treatment_notes) VALUES
(1, 1, TRUE, 'Thuốc đầu tay cho tiểu đường type 2'),
(2, 1, FALSE, 'Dùng khi Metformin không đủ hiệu quả')
ON CONFLICT DO NOTHING;

-- Cao huyết áp (condition_id = 2)
INSERT INTO DrugHealthCondition (drug_id, condition_id, is_primary, treatment_notes) VALUES
(3, 2, TRUE, 'Thuốc hạ huyết áp phổ biến'),
(4, 2, TRUE, 'Bảo vệ thận, tim mạch')
ON CONFLICT DO NOTHING;

-- Mỡ máu cao (condition_id = 3)
INSERT INTO DrugHealthCondition (drug_id, condition_id, is_primary, treatment_notes) VALUES
(5, 3, TRUE, 'Giảm cholesterol hiệu quả'),
(6, 3, TRUE, 'Giảm cholesterol mạnh hơn Atorvastatin')
ON CONFLICT DO NOTHING;

-- Gout (condition_id = 5)
INSERT INTO DrugHealthCondition (drug_id, condition_id, is_primary, treatment_notes) VALUES
(7, 5, TRUE, 'Giảm acid uric dài hạn'),
(8, 5, FALSE, 'Giảm đau cấp tính')
ON CONFLICT DO NOTHING;

-- Thiếu máu (condition_id = 8)
INSERT INTO DrugHealthCondition (drug_id, condition_id, is_primary, treatment_notes) VALUES
(12, 8, TRUE, 'Bổ sung sắt'),
(13, 8, TRUE, 'Bổ sung B12')
ON CONFLICT DO NOTHING;

-- Viêm dạ dày (condition_id = 7)
INSERT INTO DrugHealthCondition (drug_id, condition_id, is_primary, treatment_notes) VALUES
(14, 7, TRUE, 'Giảm acid dạ dày'),
(15, 7, TRUE, 'Giảm acid dạ dày')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. TÁC DỤNG PHỤ: DRUG NUTRIENT CONTRAINDICATION
-- ============================================================

-- Tetracycline kỵ Canxi (2 giờ trước và sau)
-- Sử dụng nutrient_id = 24 (Calcium (Ca))
INSERT INTO DrugNutrientContraindication (drug_id, nutrient_id, avoid_hours_before, avoid_hours_after, warning_message_vi, warning_message_en, severity)
VALUES (
    9, 
    24, -- Calcium (Ca)
    2,
    2,
    'Bạn vừa uống thuốc kháng sinh Tetracycline. Không nên uống sữa hoặc thực phẩm giàu canxi trong vòng 2 giờ tới vì canxi làm mất tác dụng thuốc.',
    'You just took Tetracycline antibiotic. Do not consume milk or calcium-rich foods within 2 hours as calcium reduces drug effectiveness.',
    'severe'
)
ON CONFLICT (drug_id, nutrient_id) DO NOTHING;

-- Doxycycline kỵ Canxi và Sắt
-- Sử dụng nutrient_id = 24 (Calcium), 29 (Iron)
INSERT INTO DrugNutrientContraindication (drug_id, nutrient_id, avoid_hours_before, avoid_hours_after, warning_message_vi, warning_message_en, severity)
VALUES (
    10, 
    24, -- Calcium (Ca)
    2,
    2,
    'Bạn vừa uống thuốc kháng sinh Doxycycline. Tránh canxi và sắt trong vòng 2 giờ để thuốc hấp thụ tốt.',
    'You just took Doxycycline antibiotic. Avoid calcium and iron within 2 hours for optimal drug absorption.',
    'severe'
)
ON CONFLICT (drug_id, nutrient_id) DO NOTHING;

INSERT INTO DrugNutrientContraindication (drug_id, nutrient_id, avoid_hours_before, avoid_hours_after, warning_message_vi, warning_message_en, severity)
VALUES (
    10, 
    29, -- Iron (Fe)
    2,
    2,
    'Bạn vừa uống thuốc kháng sinh Doxycycline. Tránh sắt trong vòng 2 giờ để thuốc hấp thụ tốt.',
    'You just took Doxycycline antibiotic. Avoid iron within 2 hours for optimal drug absorption.',
    'severe'
)
ON CONFLICT (drug_id, nutrient_id) DO NOTHING;

-- Ciprofloxacin kỵ Canxi, Magie, Sắt
-- Sử dụng nutrient_id = 24 (Calcium), 26 (Magnesium), 29 (Iron)
INSERT INTO DrugNutrientContraindication (drug_id, nutrient_id, avoid_hours_before, avoid_hours_after, warning_message_vi, warning_message_en, severity)
VALUES (
    11, 
    24, -- Calcium (Ca)
    2,
    2,
    'Bạn vừa uống thuốc kháng sinh Ciprofloxacin. Tránh canxi trong vòng 2 giờ.',
    'You just took Ciprofloxacin antibiotic. Avoid calcium within 2 hours.',
    'severe'
)
ON CONFLICT (drug_id, nutrient_id) DO NOTHING;

INSERT INTO DrugNutrientContraindication (drug_id, nutrient_id, avoid_hours_before, avoid_hours_after, warning_message_vi, warning_message_en, severity)
VALUES (
    11, 
    26, -- Magnesium (Mg)
    2,
    2,
    'Bạn vừa uống thuốc kháng sinh Ciprofloxacin. Tránh magie trong vòng 2 giờ.',
    'You just took Ciprofloxacin antibiotic. Avoid magnesium within 2 hours.',
    'moderate'
)
ON CONFLICT (drug_id, nutrient_id) DO NOTHING;

-- Sắt Sulfate kỵ Canxi (canxi cản trở hấp thụ sắt)
-- Sử dụng nutrient_id = 24 (Calcium)
INSERT INTO DrugNutrientContraindication (drug_id, nutrient_id, avoid_hours_before, avoid_hours_after, warning_message_vi, warning_message_en, severity)
VALUES (
    12, 
    24, -- Calcium (Ca)
    1,
    2,
    'Bạn vừa uống thuốc sắt. Tránh canxi trong vòng 2 giờ để sắt hấp thụ tốt hơn.',
    'You just took iron supplement. Avoid calcium within 2 hours for better iron absorption.',
    'moderate'
)
ON CONFLICT (drug_id, nutrient_id) DO NOTHING;

-- ============================================================
-- 4. SEED FOODS GIÀU CANXI (để test cảnh báo)
-- Sử dụng dữ liệu có sẵn: Food ID 67 (Sữa tươi), 68 (Sữa chua), 66 (Đậu hũ)
-- Nutrient ID 24 là "Calcium (Ca)"
-- ============================================================

DO $$
DECLARE
    v_calcium_nutrient_id INT := 24; -- Calcium (Ca) từ dữ liệu mẫu
    v_milk_food_id INT := 67; -- Sữa tươi từ dữ liệu mẫu
    v_yogurt_food_id INT := 68; -- Sữa chua từ dữ liệu mẫu
    v_tofu_food_id INT := 66; -- Đậu hũ từ dữ liệu mẫu
    v_cheese_food_id INT;
    v_sardine_food_id INT;
    v_almond_food_id INT;
    v_bok_choy_food_id INT;
    v_admin_id INT;
BEGIN
    -- Lấy admin_id đầu tiên (hoặc NULL nếu không có)
    SELECT admin_id INTO v_admin_id FROM Admin LIMIT 1;

    -- Thêm canxi vào Sữa tươi (food_id = 67) nếu chưa có
    IF NOT EXISTS (
        SELECT 1 FROM FoodNutrient 
        WHERE food_id = v_milk_food_id AND nutrient_id = v_calcium_nutrient_id
    ) THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_milk_food_id, v_calcium_nutrient_id, 120.0)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Thêm canxi vào Sữa chua (food_id = 68) nếu chưa có
    IF NOT EXISTS (
        SELECT 1 FROM FoodNutrient 
        WHERE food_id = v_yogurt_food_id AND nutrient_id = v_calcium_nutrient_id
    ) THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_yogurt_food_id, v_calcium_nutrient_id, 150.0)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Thêm canxi vào Đậu hũ (food_id = 66) nếu chưa có
    IF NOT EXISTS (
        SELECT 1 FROM FoodNutrient 
        WHERE food_id = v_tofu_food_id AND nutrient_id = v_calcium_nutrient_id
    ) THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_tofu_food_id, v_calcium_nutrient_id, 350.0)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Phô mai - Kiểm tra xem đã tồn tại chưa
    SELECT food_id INTO v_cheese_food_id
    FROM Food 
    WHERE name = 'Phô mai' OR name ILIKE '%cheese%'
    LIMIT 1;

    IF v_cheese_food_id IS NULL THEN
        INSERT INTO Food (name, category, image_url, created_by_admin)
        VALUES ('Phô mai', 'Sữa', 'https://example.com/cheese.jpg', v_admin_id)
        RETURNING food_id INTO v_cheese_food_id;
    END IF;

    IF v_cheese_food_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_cheese_food_id, v_calcium_nutrient_id, 700.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE
        SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;

    -- Cá mòi (giàu canxi) - Kiểm tra xem đã tồn tại chưa
    SELECT food_id INTO v_sardine_food_id
    FROM Food 
    WHERE name = 'Cá mòi' OR name ILIKE '%sardine%'
    LIMIT 1;

    IF v_sardine_food_id IS NULL THEN
        INSERT INTO Food (name, category, image_url, created_by_admin)
        VALUES ('Cá mòi', 'Hải sản', 'https://example.com/sardine.jpg', v_admin_id)
        RETURNING food_id INTO v_sardine_food_id;
    END IF;

    IF v_sardine_food_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_sardine_food_id, v_calcium_nutrient_id, 382.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE
        SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;

    -- Hạnh nhân - Kiểm tra xem đã tồn tại chưa
    SELECT food_id INTO v_almond_food_id
    FROM Food 
    WHERE name = 'Hạnh nhân' OR name ILIKE '%almond%'
    LIMIT 1;

    IF v_almond_food_id IS NULL THEN
        INSERT INTO Food (name, category, image_url, created_by_admin)
        VALUES ('Hạnh nhân', 'Hạt', 'https://example.com/almond.jpg', v_admin_id)
        RETURNING food_id INTO v_almond_food_id;
    END IF;

    IF v_almond_food_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_almond_food_id, v_calcium_nutrient_id, 264.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE
        SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;

    -- Cải xoong (Bok choy) - Kiểm tra xem đã tồn tại chưa
    SELECT food_id INTO v_bok_choy_food_id
    FROM Food 
    WHERE name = 'Cải xoong' OR name ILIKE '%bok choy%' OR name ILIKE '%cải%'
    LIMIT 1;

    IF v_bok_choy_food_id IS NULL THEN
        INSERT INTO Food (name, category, image_url, created_by_admin)
        VALUES ('Cải xoong', 'Rau củ', 'https://example.com/bok_choy.jpg', v_admin_id)
        RETURNING food_id INTO v_bok_choy_food_id;
    END IF;

    IF v_bok_choy_food_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_bok_choy_food_id, v_calcium_nutrient_id, 105.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE
        SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
END $$;

-- ============================================================
-- 5. SEED DRINKS GIÀU CANXI
-- Sử dụng nutrient_id = 24 (Calcium)
-- ============================================================

DO $$
DECLARE
    v_calcium_nutrient_id INT := 24; -- Calcium (Ca)
    v_milk_drink_id INT;
    v_soy_milk_drink_id INT;
    v_almond_milk_drink_id INT;
    v_orange_juice_drink_id INT;
    v_coconut_milk_drink_id INT;
    v_admin_id INT;
BEGIN
    -- Lấy admin_id đầu tiên
    SELECT admin_id INTO v_admin_id FROM Admin LIMIT 1;

    -- Sữa tươi (drink) - Kiểm tra xem đã tồn tại chưa
    SELECT drink_id INTO v_milk_drink_id
    FROM Drink 
    WHERE name = 'Milk' OR vietnamese_name = 'Sữa tươi'
    LIMIT 1;

    -- Nếu chưa tồn tại, tạo mới
    IF v_milk_drink_id IS NULL THEN
        INSERT INTO Drink (name, vietnamese_name, slug, category, base_liquid, default_volume_ml, hydration_ratio, image_url, is_template, is_public, created_by_admin)
        VALUES ('Milk', 'Sữa tươi', 'milk', 'Dairy', 'milk', 250, 0.8, 'https://example.com/milk.jpg', TRUE, TRUE, v_admin_id)
        RETURNING drink_id INTO v_milk_drink_id;
    END IF;

    IF v_milk_drink_id IS NOT NULL THEN
        INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
        VALUES (v_milk_drink_id, v_calcium_nutrient_id, 120.0)
        ON CONFLICT (drink_id, nutrient_id) DO UPDATE
        SET amount_per_100ml = EXCLUDED.amount_per_100ml;
    END IF;

    -- Sữa đậu nành - Kiểm tra xem đã tồn tại chưa
    SELECT drink_id INTO v_soy_milk_drink_id
    FROM Drink 
    WHERE name = 'Soy Milk' OR vietnamese_name = 'Sữa đậu nành'
    LIMIT 1;

    -- Nếu chưa tồn tại, tạo mới
    IF v_soy_milk_drink_id IS NULL THEN
        INSERT INTO Drink (name, vietnamese_name, slug, category, base_liquid, default_volume_ml, hydration_ratio, image_url, is_template, is_public, created_by_admin)
        VALUES ('Soy Milk', 'Sữa đậu nành', 'soy-milk', 'Plant-based', 'soy', 250, 0.85, 'https://example.com/soy_milk.jpg', TRUE, TRUE, v_admin_id)
        RETURNING drink_id INTO v_soy_milk_drink_id;
    END IF;

    IF v_soy_milk_drink_id IS NOT NULL THEN
        INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
        VALUES (v_soy_milk_drink_id, v_calcium_nutrient_id, 25.0)
        ON CONFLICT (drink_id, nutrient_id) DO UPDATE
        SET amount_per_100ml = EXCLUDED.amount_per_100ml;
    END IF;

    -- Sữa hạnh nhân - Kiểm tra xem đã tồn tại chưa
    SELECT drink_id INTO v_almond_milk_drink_id
    FROM Drink 
    WHERE name = 'Almond Milk' OR vietnamese_name = 'Sữa hạnh nhân'
    LIMIT 1;

    IF v_almond_milk_drink_id IS NULL THEN
        INSERT INTO Drink (name, vietnamese_name, slug, category, base_liquid, default_volume_ml, hydration_ratio, image_url, is_template, is_public, created_by_admin)
        VALUES ('Almond Milk', 'Sữa hạnh nhân', 'almond-milk', 'Plant-based', 'almond', 250, 0.9, 'https://example.com/almond_milk.jpg', TRUE, TRUE, v_admin_id)
        RETURNING drink_id INTO v_almond_milk_drink_id;
    END IF;

    IF v_almond_milk_drink_id IS NOT NULL THEN
        INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
        VALUES (v_almond_milk_drink_id, v_calcium_nutrient_id, 188.0)
        ON CONFLICT (drink_id, nutrient_id) DO UPDATE
        SET amount_per_100ml = EXCLUDED.amount_per_100ml;
    END IF;

    -- Nước cam bổ sung canxi - Kiểm tra xem đã tồn tại chưa
    SELECT drink_id INTO v_orange_juice_drink_id
    FROM Drink 
    WHERE name = 'Calcium-Fortified Orange Juice' OR vietnamese_name = 'Nước cam bổ sung canxi'
    LIMIT 1;

    IF v_orange_juice_drink_id IS NULL THEN
        INSERT INTO Drink (name, vietnamese_name, slug, category, base_liquid, default_volume_ml, hydration_ratio, image_url, is_template, is_public, created_by_admin)
        VALUES ('Calcium-Fortified Orange Juice', 'Nước cam bổ sung canxi', 'calcium-orange-juice', 'Fruit Juice', 'orange', 250, 0.95, 'https://example.com/orange_juice.jpg', TRUE, TRUE, v_admin_id)
        RETURNING drink_id INTO v_orange_juice_drink_id;
    END IF;

    IF v_orange_juice_drink_id IS NOT NULL THEN
        INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
        VALUES (v_orange_juice_drink_id, v_calcium_nutrient_id, 150.0)
        ON CONFLICT (drink_id, nutrient_id) DO UPDATE
        SET amount_per_100ml = EXCLUDED.amount_per_100ml;
    END IF;

    -- Sữa dừa - Kiểm tra xem đã tồn tại chưa
    SELECT drink_id INTO v_coconut_milk_drink_id
    FROM Drink 
    WHERE name = 'Coconut Milk' OR vietnamese_name = 'Sữa dừa'
    LIMIT 1;

    IF v_coconut_milk_drink_id IS NULL THEN
        INSERT INTO Drink (name, vietnamese_name, slug, category, base_liquid, default_volume_ml, hydration_ratio, image_url, is_template, is_public, created_by_admin)
        VALUES ('Coconut Milk', 'Sữa dừa', 'coconut-milk', 'Plant-based', 'coconut', 250, 0.85, 'https://example.com/coconut_milk.jpg', TRUE, TRUE, v_admin_id)
        RETURNING drink_id INTO v_coconut_milk_drink_id;
    END IF;

    IF v_coconut_milk_drink_id IS NOT NULL THEN
        INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
        VALUES (v_coconut_milk_drink_id, v_calcium_nutrient_id, 16.0)
        ON CONFLICT (drink_id, nutrient_id) DO UPDATE
        SET amount_per_100ml = EXCLUDED.amount_per_100ml;
    END IF;
END $$;

-- ============================================================
-- 6. SEED DISHES (MÓN ĂN) CÓ CANXI
-- Sử dụng nutrient_id = 24 (Calcium)
-- ============================================================

DO $$
DECLARE
    v_calcium_nutrient_id INT := 24; -- Calcium (Ca)
    v_cheese_pasta_dish_id INT;
    v_milk_soup_dish_id INT;
    v_crab_soup_dish_id INT;
    v_cream_shrimp_soup_dish_id INT;
    v_tuna_salad_dish_id INT;
    v_flan_dish_id INT;
    v_admin_id INT;
BEGIN
    -- Lấy admin_id đầu tiên (bắt buộc cho constraint)
    SELECT admin_id INTO v_admin_id FROM Admin LIMIT 1;

    -- Nếu không có admin, bỏ qua (không thể tạo dish)
    IF v_admin_id IS NULL THEN
        RAISE NOTICE 'No admin found. Skipping dish creation.';
        RETURN;
    END IF;

    -- Mì Ý sốt phô mai - Kiểm tra xem đã tồn tại chưa
    SELECT dish_id INTO v_cheese_pasta_dish_id
    FROM Dish 
    WHERE name = 'Cheese Pasta' OR vietnamese_name = 'Mì Ý sốt phô mai'
    LIMIT 1;

    -- Nếu chưa tồn tại, tạo mới
    IF v_cheese_pasta_dish_id IS NULL THEN
        INSERT INTO Dish (
            name, vietnamese_name, description, category, 
            serving_size_g, image_url, is_template, is_public, created_by_admin
        )
        VALUES (
            'Cheese Pasta', 'Mì Ý sốt phô mai', 'Mì Ý với sốt phô mai béo ngậy', 'Italian',
            100.00, 'https://example.com/cheese_pasta.jpg', TRUE, TRUE, v_admin_id
        )
        RETURNING dish_id INTO v_cheese_pasta_dish_id;
    END IF;

    IF v_cheese_pasta_dish_id IS NOT NULL THEN
        INSERT INTO DishNutrient (dish_id, nutrient_id, amount_per_100g)
        VALUES (v_cheese_pasta_dish_id, v_calcium_nutrient_id, 200.0)
        ON CONFLICT (dish_id, nutrient_id) DO UPDATE
        SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;

    -- Súp kem sữa - Kiểm tra xem đã tồn tại chưa
    SELECT dish_id INTO v_milk_soup_dish_id
    FROM Dish 
    WHERE name = 'Cream Soup' OR vietnamese_name = 'Súp kem'
    LIMIT 1;

    -- Nếu chưa tồn tại, tạo mới
    IF v_milk_soup_dish_id IS NULL THEN
        INSERT INTO Dish (
            name, vietnamese_name, description, category,
            serving_size_g, image_url, is_template, is_public, created_by_admin
        )
        VALUES (
            'Cream Soup', 'Súp kem', 'Súp kem sữa', 'Soup',
            100.00, 'https://example.com/cream_soup.jpg', TRUE, TRUE, v_admin_id
        )
        RETURNING dish_id INTO v_milk_soup_dish_id;
    END IF;

    IF v_milk_soup_dish_id IS NOT NULL THEN
        INSERT INTO DishNutrient (dish_id, nutrient_id, amount_per_100g)
        VALUES (v_milk_soup_dish_id, v_calcium_nutrient_id, 80.0)
        ON CONFLICT (dish_id, nutrient_id) DO UPDATE
        SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;

    -- Canh cua (Crab Soup) - Giàu canxi từ cua
    SELECT dish_id INTO v_crab_soup_dish_id
    FROM Dish 
    WHERE name = 'Crab Soup' OR vietnamese_name = 'Canh cua'
    LIMIT 1;

    IF v_crab_soup_dish_id IS NULL THEN
        INSERT INTO Dish (
            name, vietnamese_name, description, category,
            serving_size_g, image_url, is_template, is_public, created_by_admin
        )
        VALUES (
            'Crab Soup', 'Canh cua', 'Canh cua nấu với rau, giàu canxi từ cua', 'Soup',
            200.00, 'https://example.com/crab_soup.jpg', TRUE, TRUE, v_admin_id
        )
        RETURNING dish_id INTO v_crab_soup_dish_id;
    END IF;

    IF v_crab_soup_dish_id IS NOT NULL THEN
        INSERT INTO DishNutrient (dish_id, nutrient_id, amount_per_100g)
        VALUES (v_crab_soup_dish_id, v_calcium_nutrient_id, 91.0)
        ON CONFLICT (dish_id, nutrient_id) DO UPDATE
        SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;

    -- Súp kem tôm (Cream Shrimp Soup)
    SELECT dish_id INTO v_cream_shrimp_soup_dish_id
    FROM Dish 
    WHERE name = 'Cream Shrimp Soup' OR vietnamese_name = 'Súp kem tôm'
    LIMIT 1;

    IF v_cream_shrimp_soup_dish_id IS NULL THEN
        INSERT INTO Dish (
            name, vietnamese_name, description, category,
            serving_size_g, image_url, is_template, is_public, created_by_admin
        )
        VALUES (
            'Cream Shrimp Soup', 'Súp kem tôm', 'Súp kem với tôm, giàu canxi', 'Soup',
            200.00, 'https://example.com/cream_shrimp_soup.jpg', TRUE, TRUE, v_admin_id
        )
        RETURNING dish_id INTO v_cream_shrimp_soup_dish_id;
    END IF;

    IF v_cream_shrimp_soup_dish_id IS NOT NULL THEN
        INSERT INTO DishNutrient (dish_id, nutrient_id, amount_per_100g)
        VALUES (v_cream_shrimp_soup_dish_id, v_calcium_nutrient_id, 120.0)
        ON CONFLICT (dish_id, nutrient_id) DO UPDATE
        SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;

    -- Salad cá ngừ (Tuna Salad) - Cá ngừ đóng hộp có canxi
    SELECT dish_id INTO v_tuna_salad_dish_id
    FROM Dish 
    WHERE name = 'Tuna Salad' OR vietnamese_name = 'Salad cá ngừ'
    LIMIT 1;

    IF v_tuna_salad_dish_id IS NULL THEN
        INSERT INTO Dish (
            name, vietnamese_name, description, category,
            serving_size_g, image_url, is_template, is_public, created_by_admin
        )
        VALUES (
            'Tuna Salad', 'Salad cá ngừ', 'Salad cá ngừ với rau xanh, giàu canxi', 'Salad',
            150.00, 'https://example.com/tuna_salad.jpg', TRUE, TRUE, v_admin_id
        )
        RETURNING dish_id INTO v_tuna_salad_dish_id;
    END IF;

    IF v_tuna_salad_dish_id IS NOT NULL THEN
        INSERT INTO DishNutrient (dish_id, nutrient_id, amount_per_100g)
        VALUES (v_tuna_salad_dish_id, v_calcium_nutrient_id, 12.0)
        ON CONFLICT (dish_id, nutrient_id) DO UPDATE
        SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;

    -- Bánh flan (Crème Caramel) - Giàu canxi từ sữa và trứng
    SELECT dish_id INTO v_flan_dish_id
    FROM Dish 
    WHERE name = 'Crème Caramel' OR vietnamese_name = 'Bánh flan'
    LIMIT 1;

    IF v_flan_dish_id IS NULL THEN
        INSERT INTO Dish (
            name, vietnamese_name, description, category,
            serving_size_g, image_url, is_template, is_public, created_by_admin
        )
        VALUES (
            'Crème Caramel', 'Bánh flan', 'Bánh flan làm từ sữa và trứng, giàu canxi', 'Dessert',
            100.00, 'https://example.com/flan.jpg', TRUE, TRUE, v_admin_id
        )
        RETURNING dish_id INTO v_flan_dish_id;
    END IF;

    IF v_flan_dish_id IS NOT NULL THEN
        INSERT INTO DishNutrient (dish_id, nutrient_id, amount_per_100g)
        VALUES (v_flan_dish_id, v_calcium_nutrient_id, 130.0)
        ON CONFLICT (dish_id, nutrient_id) DO UPDATE
        SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
END $$;

COMMIT;

