-- =================================================================================
-- SCRIPT IMPORT TOÀN BỘ DỮ LIỆU CHO HỆ THỐNG DINH DƯỠNG VIỆT NAM
-- =================================================================================
-- Mục đích: Import đầy đủ dữ liệu thực tế cho database
-- Thứ tự: Tuân thủ foreign key constraints
-- Ngày tạo: December 1, 2025
-- =================================================================================

-- =================================================================================
-- BƯỚC 1: IMPORT DỮ LIỆU CƠ BẢN (real_dataset_vietnam.sql)
-- =================================================================================
-- Bao gồm:
-- - Cập nhật cấu trúc bảng (ALTER TABLE thêm cột tiếng Việt)
-- - Update tên tiếng Việt cho Nutrient (55 nutrients)
-- - Insert HealthCondition (~30 bệnh lý)
-- - Insert Drug (30 thuốc)
-- - Insert DrugHealthCondition (liên kết thuốc-bệnh)
-- - Insert DrugNutrientContraindication (cảnh báo tương tác)
-- - Insert Food (140 thực phẩm: 100 USDA + 40 món Việt)
-- - Insert FoodNutrient (dữ liệu dinh dưỡng cho food)

\i 'real_dataset_vietnam.sql'

-- =================================================================================
-- BƯỚC 2: IMPORT DỮ LIỆU MỞ RỘNG (additional_data_extended.sql)
-- =================================================================================
-- Bao gồm:
-- - DrinkNutrient (40 đồ uống: 20 cũ + 20 mới)
-- - PortionSize (120 khẩu phần thực tế)
-- - ConditionFoodRecommendation (120 khuyến nghị)
-- - ConditionNutrientEffect (120 hiệu ứng dinh dưỡng)
-- - Recipe (40 công thức: 20 cũ + 20 mới)
-- - RecipeIngredient (nguyên liệu cho công thức)

\i 'additional_data_extended.sql'

-- =================================================================================
-- BƯỚC 3: KIỂM TRA DỮ LIỆU SAU KHI IMPORT
-- =================================================================================

-- Đếm số lượng records trong từng bảng
SELECT 'NUTRIENT' as table_name, COUNT(*) as total FROM nutrient
UNION ALL
SELECT 'HEALTHCONDITION', COUNT(*) FROM healthcondition
UNION ALL
SELECT 'DRUG', COUNT(*) FROM drug
UNION ALL
SELECT 'DRUGHEALTHCONDITION', COUNT(*) FROM drughealthcondition
UNION ALL
SELECT 'DRUGNUTRIENTCONTRAINDICATION', COUNT(*) FROM drugnutrientcontraindication
UNION ALL
SELECT 'FOOD', COUNT(*) FROM food
UNION ALL
SELECT 'FOODNUTRIENT', COUNT(*) FROM foodnutrient
UNION ALL
SELECT 'DISH', COUNT(*) FROM dish
UNION ALL
SELECT 'DISHINGREDIENT', COUNT(*) FROM dishingredient
UNION ALL
SELECT 'DISHNUTRIENT', COUNT(*) FROM dishnutrient
UNION ALL
SELECT 'DRINK', COUNT(*) FROM drink
UNION ALL
SELECT 'DRINKNUTRIENT', COUNT(*) FROM drinknutrient
UNION ALL
SELECT 'PORTIONSIZE', COUNT(*) FROM portionsize
UNION ALL
SELECT 'CONDITIONFOODRECOMMENDATION', COUNT(*) FROM conditionfoodrecommendation
UNION ALL
SELECT 'CONDITIONNUTRIENTEFFECT', COUNT(*) FROM conditionnutrienteffect
UNION ALL
SELECT 'RECIPE', COUNT(*) FROM recipe
UNION ALL
SELECT 'RECIPEINGREDIENT', COUNT(*) FROM recipeingredient
ORDER BY table_name;

-- =================================================================================
-- BƯỚC 4: KIỂM TRA TÍNH TOÀN VẸN FOREIGN KEY
-- =================================================================================

-- Kiểm tra FoodNutrient có nutrient_id không tồn tại
SELECT 'Invalid FoodNutrient.nutrient_id' as issue, COUNT(*) as count
FROM foodnutrient fn
LEFT JOIN nutrient n ON fn.nutrient_id = n.nutrient_id
WHERE n.nutrient_id IS NULL;

-- Kiểm tra DrugNutrientContraindication có nutrient_id không tồn tại
SELECT 'Invalid DrugNutrientContraindication.nutrient_id' as issue, COUNT(*) as count
FROM drugnutrientcontraindication dnc
LEFT JOIN nutrient n ON dnc.nutrient_id = n.nutrient_id
WHERE n.nutrient_id IS NULL;

-- Kiểm tra DrugHealthCondition có condition_id không tồn tại
SELECT 'Invalid DrugHealthCondition.condition_id' as issue, COUNT(*) as count
FROM drughealthcondition dhc
LEFT JOIN healthcondition hc ON dhc.condition_id = hc.condition_id
WHERE hc.condition_id IS NULL;

-- Kiểm tra ConditionFoodRecommendation có food_id không tồn tại
SELECT 'Invalid ConditionFoodRecommendation.food_id' as issue, COUNT(*) as count
FROM conditionfoodrecommendation cfr
LEFT JOIN food f ON cfr.food_id = f.food_id
WHERE f.food_id IS NULL;

-- =================================================================================
-- BƯỚC 5: THỐNG KÊ DỮ LIỆU QUAN TRỌNG
-- =================================================================================

-- Top 10 thực phẩm giàu Vitamin K (quan trọng với Warfarin)
SELECT f.name_vi, fn.amount_per_100g as vitamin_k_mcg
FROM foodnutrient fn
JOIN food f ON fn.food_id = f.food_id
WHERE fn.nutrient_id = 14  -- Vitamin K
ORDER BY fn.amount_per_100g DESC
LIMIT 10;

-- Top 10 thực phẩm giàu Kali (quan trọng với Lisinopril, Spironolactone)
SELECT f.name_vi, fn.amount_per_100g as potassium_mg
FROM foodnutrient fn
JOIN food f ON fn.food_id = f.food_id
WHERE fn.nutrient_id = 27  -- Potassium
ORDER BY fn.amount_per_100g DESC
LIMIT 10;

-- Danh sách thuốc có tương tác với Vitamin K
SELECT d.name_vi as thuoc, dnc.warning_message_vi as canh_bao, dnc.severity
FROM drugnutrientcontraindication dnc
JOIN drug d ON dnc.drug_id = d.drug_id
WHERE dnc.nutrient_id = 14  -- Vitamin K
ORDER BY 
  CASE dnc.severity 
    WHEN 'High' THEN 1 
    WHEN 'high' THEN 1
    WHEN 'Medium' THEN 2 
    WHEN 'medium' THEN 2
    ELSE 3 
  END;

-- Món ăn Việt Nam và dinh dưỡng nổi bật
SELECT 
  f.name_vi,
  MAX(CASE WHEN fn.nutrient_id = 2 THEN fn.amount_per_100g END) as protein_g,
  MAX(CASE WHEN fn.nutrient_id = 3 THEN fn.amount_per_100g END) as fat_g,
  MAX(CASE WHEN fn.nutrient_id = 4 THEN fn.amount_per_100g END) as carbs_g,
  MAX(CASE WHEN fn.nutrient_id = 28 THEN fn.amount_per_100g END) as sodium_mg
FROM food f
JOIN foodnutrient fn ON f.food_id = fn.food_id
WHERE f.food_id BETWEEN 3011 AND 3040
GROUP BY f.food_id, f.name_vi
ORDER BY f.food_id;

-- =================================================================================
-- BƯỚC 6: TẠO INDEX ĐỂ TỐI ƯU PERFORMANCE (TÙY CHỌN)
-- =================================================================================

-- Index cho foreign keys thường dùng
CREATE INDEX IF NOT EXISTS idx_foodnutrient_food_id ON foodnutrient(food_id);
CREATE INDEX IF NOT EXISTS idx_foodnutrient_nutrient_id ON foodnutrient(nutrient_id);
CREATE INDEX IF NOT EXISTS idx_drughealthcondition_drug_id ON drughealthcondition(drug_id);
CREATE INDEX IF NOT EXISTS idx_drughealthcondition_condition_id ON drughealthcondition(condition_id);
CREATE INDEX IF NOT EXISTS idx_drugnutrientcontraindication_drug_id ON drugnutrientcontraindication(drug_id);
CREATE INDEX IF NOT EXISTS idx_drugnutrientcontraindication_nutrient_id ON drugnutrientcontraindication(nutrient_id);
CREATE INDEX IF NOT EXISTS idx_dishingredient_dish_id ON dishingredient(dish_id);
CREATE INDEX IF NOT EXISTS idx_dishingredient_food_id ON dishingredient(food_id);
CREATE INDEX IF NOT EXISTS idx_dishnutrient_dish_id ON dishnutrient(dish_id);
CREATE INDEX IF NOT EXISTS idx_dishnutrient_nutrient_id ON dishnutrient(nutrient_id);
CREATE INDEX IF NOT EXISTS idx_drinknutrient_drink_id ON drinknutrient(drink_id);
CREATE INDEX IF NOT EXISTS idx_drinknutrient_nutrient_id ON drinknutrient(nutrient_id);

-- Index cho tìm kiếm theo tên tiếng Việt
CREATE INDEX IF NOT EXISTS idx_food_name_vi ON food(name_vi);
CREATE INDEX IF NOT EXISTS idx_drug_name_vi ON drug(name_vi);
CREATE INDEX IF NOT EXISTS idx_healthcondition_name_vi ON healthcondition(name_vi);

-- =================================================================================
-- KẾT QUẢ MONG ĐỢI SAU KHI CHẠY SCRIPT
-- =================================================================================
/*
BẢNG                               | SỐ LƯỢNG RECORDS
-----------------------------------|-----------------
NUTRIENT                           | 55-58
HEALTHCONDITION                    | ~30
DRUG                              | ~30
DRUGHEALTHCONDITION               | ~25
DRUGNUTRIENTCONTRAINDICATION      | ~40
FOOD                              | ~140
FOODNUTRIENT                      | ~450+
DISH                              | ~38
DISHINGREDIENT                    | ~80+
DISHNUTRIENT                      | ~120+
DRINK                             | ~40
DRINKNUTRIENT                     | ~160+
PORTIONSIZE                       | ~120
CONDITIONFOODRECOMMENDATION       | ~120
CONDITIONNUTRIENTEFFECT           | ~120
RECIPE                            | ~40
RECIPEINGREDIENT                  | ~25+

TỔNG: Hơn 1,500 records dữ liệu thực tế
*/

-- =================================================================================
-- LƯU Ý KHI SỬ DỤNG
-- =================================================================================
/*
1. TRƯỚC KHI CHẠY:
   - Backup database hiện tại
   - Kiểm tra các bảng đã tồn tại và có cấu trúc đúng
   - Đảm bảo đã có đủ quyền INSERT, UPDATE, DELETE

2. THỨ TỰ THỰC HIỆN:
   - Chạy file này: \i 'import_all_data.sql'
   - Hoặc chạy từng file riêng theo thứ tự:
     1. real_dataset_vietnam.sql
     2. additional_data_extended.sql

3. SAU KHI CHẠY:
   - Kiểm tra kết quả thống kê
   - Verify foreign key integrity
   - Test các query quan trọng

4. XỬ LÝ LỖI:
   - Nếu có lỗi foreign key: Kiểm tra thứ tự import
   - Nếu có lỗi duplicate: Chạy DELETE trước INSERT
   - Nếu có lỗi constraint: Kiểm tra cấu trúc bảng

5. MÔI TRƯỜNG:
   - PostgreSQL 12+
   - Character encoding: UTF-8
   - Locale: vi_VN hoặc en_US.UTF-8
*/
