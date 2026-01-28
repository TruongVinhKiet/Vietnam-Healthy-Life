-- ============================================================
-- SEED DATA FOR ADVANCED FEATURES
-- Populates missing data for extended functionality
-- Date: 2025-11-19
-- ============================================================

BEGIN;

-- ============================================================
-- 1. SEED CONDITIONNUTRIENTEFFECT
-- Effects of health conditions on nutrient requirements
-- ============================================================

-- Tiểu đường type 2 (condition_id = 1)
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent, notes) VALUES
(1, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'FIBTG' LIMIT 1), 'increase', 40, 'Tăng chất xơ giúp kiểm soát đường huyết'),
(1, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'MG' LIMIT 1), 'increase', 15, 'Magnesium hỗ trợ chuyển hóa glucose'),
(1, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'FASAT' LIMIT 1), 'decrease', -20, 'Giảm chất béo bão hòa');

-- Cao huyết áp (condition_id = 2)
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent, notes) VALUES
(2, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'K' LIMIT 1), 'increase', 30, 'Potassium giúp giảm huyết áp'),
(2, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'MG' LIMIT 1), 'increase', 20, 'Magnesium giúp giãn mạch máu'),
(2, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'CA' LIMIT 1), 'increase', 15, 'Calcium hỗ trợ kiểm soát huyết áp'),
(2, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'NA' LIMIT 1), 'decrease', -50, 'Giảm natri rất quan trọng');

-- Mỡ máu cao (condition_id = 3)
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent, notes) VALUES
(3, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'FIBTG' LIMIT 1), 'increase', 35, 'Chất xơ giúp giảm cholesterol'),
(3, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'FAPU' LIMIT 1), 'increase', 25, 'Omega-3 giảm triglyceride'),
(3, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'FASAT' LIMIT 1), 'decrease', -30, 'Giảm chất béo bão hòa'),
(3, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'CHOLESTEROL' LIMIT 1), 'decrease', -40, 'Hạn chế cholesterol');

-- Béo phì (condition_id = 4)
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent, notes) VALUES
(4, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'FIBTG' LIMIT 1), 'increase', 30, 'Chất xơ tạo cảm giác no'),
(4, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'PROCNT' LIMIT 1), 'increase', 20, 'Protein giúp giữ cơ khi giảm cân'),
(4, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'FAT' LIMIT 1), 'decrease', -15, 'Giảm tổng lượng chất béo');

-- Gout (condition_id = 5)
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent, notes) VALUES
(5, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'VITC' LIMIT 1), 'increase', 50, 'Vitamin C giúp giảm acid uric'),
(5, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'K' LIMIT 1), 'increase', 20, 'Potassium giúp thải acid uric');

-- Gan nhiễm mỡ (condition_id = 6)
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent, notes) VALUES
(6, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'VITC' LIMIT 1), 'increase', 30, 'Chống oxy hóa bảo vệ gan'),
(6, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'VITE' LIMIT 1), 'increase', 40, 'Vitamin E giảm viêm gan'),
(6, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'FASAT' LIMIT 1), 'decrease', -35, 'Giảm chất béo bão hòa');

-- Thiếu máu (condition_id = 8)
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent, notes) VALUES
(8, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'FE' LIMIT 1), 'increase', 100, 'Tăng gấp đôi sắt'),
(8, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'VITC' LIMIT 1), 'increase', 50, 'Vitamin C giúp hấp thu sắt'),
(8, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'VITB12' LIMIT 1), 'increase', 80, 'B12 cần cho hồng cầu'),
(8, (SELECT nutrient_id FROM Nutrient WHERE nutrient_code = 'FOL' LIMIT 1), 'increase', 60, 'Folate cần cho tạo máu');

DO $$ BEGIN RAISE NOTICE 'Seeded ConditionNutrientEffect data'; END $$;

-- ============================================================
-- 2. SEED CONDITIONFOODRECOMMENDATION
-- Foods to recommend or avoid for each condition
-- ============================================================

-- Tiểu đường type 2 - Tránh
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 1, food_id, 'avoid', 'Nhiều đường, tránh để kiểm soát đường huyết'
FROM Food 
WHERE LOWER(name) LIKE '%sugar%' OR LOWER(name) LIKE '%candy%' OR LOWER(name) LIKE '%soda%'
LIMIT 5;

-- Tiểu đường type 2 - Khuyến khích
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 1, food_id, 'recommend', 'Giàu chất xơ, tốt cho kiểm soát đường huyết'
FROM Food 
WHERE LOWER(name) LIKE '%oat%' OR LOWER(name) LIKE '%bean%' OR LOWER(name) LIKE '%broccoli%'
LIMIT 5;

-- Cao huyết áp - Tránh
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 2, food_id, 'avoid', 'Nhiều muối, làm tăng huyết áp'
FROM Food 
WHERE LOWER(name) LIKE '%salt%' OR LOWER(name) LIKE '%pickle%' OR LOWER(name) LIKE '%sauce%'
LIMIT 5;

-- Cao huyết áp - Khuyến khích
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 2, food_id, 'recommend', 'Giàu kali, giúp giảm huyết áp'
FROM Food 
WHERE LOWER(name) LIKE '%banana%' OR LOWER(name) LIKE '%spinach%' OR LOWER(name) LIKE '%potato%'
LIMIT 5;

-- Mỡ máu cao - Tránh
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 3, food_id, 'avoid', 'Nhiều chất béo bão hòa và cholesterol'
FROM Food 
WHERE LOWER(name) LIKE '%butter%' OR LOWER(name) LIKE '%cream%' OR LOWER(name) LIKE '%cheese%'
LIMIT 5;

-- Gout - Tránh
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 5, food_id, 'avoid', 'Nhiều purine, tăng acid uric'
FROM Food 
WHERE LOWER(name) LIKE '%beef%' OR LOWER(name) LIKE '%liver%' OR LOWER(name) LIKE '%seafood%'
LIMIT 5;

DO $$ BEGIN RAISE NOTICE 'Seeded ConditionFoodRecommendation data'; END $$;

-- ============================================================
-- 3. SEED FIBERREQUIREMENT
-- RDA for fiber types by age and sex
-- ============================================================

-- Total Fiber requirements
INSERT INTO FiberRequirement (fiber_id, sex, age_min, age_max, rda_value, unit, notes) VALUES
((SELECT fiber_id FROM Fiber WHERE code = 'TOTAL_FIBER' LIMIT 1), 'male', 19, 50, 38.0, 'g', 'Adult men 19-50'),
((SELECT fiber_id FROM Fiber WHERE code = 'TOTAL_FIBER' LIMIT 1), 'male', 51, 999, 30.0, 'g', 'Older men 51+'),
((SELECT fiber_id FROM Fiber WHERE code = 'TOTAL_FIBER' LIMIT 1), 'female', 19, 50, 25.0, 'g', 'Adult women 19-50'),
((SELECT fiber_id FROM Fiber WHERE code = 'TOTAL_FIBER' LIMIT 1), 'female', 51, 999, 21.0, 'g', 'Older women 51+');

-- Soluble Fiber (about 20-30% of total fiber)
INSERT INTO FiberRequirement (fiber_id, sex, age_min, age_max, rda_value, unit, notes) VALUES
((SELECT fiber_id FROM Fiber WHERE code = 'SOLUBLE_FIBER' LIMIT 1), 'male', 19, 50, 10.0, 'g', 'About 25% of total'),
((SELECT fiber_id FROM Fiber WHERE code = 'SOLUBLE_FIBER' LIMIT 1), 'male', 51, 999, 8.0, 'g', 'About 25% of total'),
((SELECT fiber_id FROM Fiber WHERE code = 'SOLUBLE_FIBER' LIMIT 1), 'female', 19, 50, 7.0, 'g', 'About 25% of total'),
((SELECT fiber_id FROM Fiber WHERE code = 'SOLUBLE_FIBER' LIMIT 1), 'female', 51, 999, 6.0, 'g', 'About 25% of total');

DO $$ BEGIN RAISE NOTICE 'Seeded FiberRequirement data'; END $$;

-- ============================================================
-- 4. SEED FOODCATEGORY
-- Food categories for better organization
-- ============================================================

INSERT INTO FoodCategory (name, name_vi, description, created_at) VALUES
('Vegetables', 'Rau củ quả', 'Fresh and cooked vegetables', NOW()),
('Fruits', 'Trái cây', 'Fresh and dried fruits', NOW()),
('Grains', 'Ngũ cốc', 'Rice, bread, pasta, cereals', NOW()),
('Protein', 'Thực phẩm giàu đạm', 'Meat, fish, eggs, legumes', NOW()),
('Dairy', 'Sữa và chế phẩm', 'Milk, cheese, yogurt', NOW()),
('Fats & Oils', 'Chất béo & dầu', 'Cooking oils, butter, nuts', NOW()),
('Beverages', 'Đồ uống', 'Water, juice, tea, coffee', NOW()),
('Snacks', 'Đồ ăn vặt', 'Chips, crackers, candy', NOW()),
('Seafood', 'Hải sản', 'Fish, shellfish, seaweed', NOW()),
('Herbs & Spices', 'Gia vị', 'Herbs, spices, seasonings', NOW());

DO $$ BEGIN RAISE NOTICE 'Seeded FoodCategory data'; END $$;

-- ============================================================
-- 5. UPDATE EXISTING FOODS WITH CATEGORIES
-- ============================================================

UPDATE Food SET category = 'Vegetables' WHERE LOWER(name) LIKE '%broccoli%' OR LOWER(name) LIKE '%spinach%' OR LOWER(name) LIKE '%tomato%';
UPDATE Food SET category = 'Fruits' WHERE LOWER(name) LIKE '%banana%' OR LOWER(name) LIKE '%apple%' OR LOWER(name) LIKE '%orange%';
UPDATE Food SET category = 'Grains' WHERE LOWER(name) LIKE '%rice%' OR LOWER(name) LIKE '%bread%' OR LOWER(name) LIKE '%oat%';
UPDATE Food SET category = 'Protein' WHERE LOWER(name) LIKE '%chicken%' OR LOWER(name) LIKE '%beef%' OR LOWER(name) LIKE '%egg%' OR LOWER(name) LIKE '%bean%';
UPDATE Food SET category = 'Dairy' WHERE LOWER(name) LIKE '%milk%' OR LOWER(name) LIKE '%cheese%' OR LOWER(name) LIKE '%yogurt%';
UPDATE Food SET category = 'Seafood' WHERE LOWER(name) LIKE '%fish%' OR LOWER(name) LIKE '%salmon%' OR LOWER(name) LIKE '%tuna%';

DO $$ BEGIN RAISE NOTICE 'Updated existing foods with categories'; END $$;

-- ============================================================
-- 6. SEED PORTIONSIZE FOR COMMON FOODS
-- ============================================================

-- Add portion sizes for existing foods (sample data)
INSERT INTO PortionSize (food_id, portion_name, portion_name_vi, weight_g, is_common, created_at)
SELECT food_id, 'Medium serving', 'Khẩu phần vừa', 150.0, true, NOW()
FROM Food WHERE LOWER(name) LIKE '%rice%' LIMIT 1;

INSERT INTO PortionSize (food_id, portion_name, portion_name_vi, weight_g, is_common, created_at)
SELECT food_id, 'Large serving', 'Khẩu phần lớn', 250.0, false, NOW()
FROM Food WHERE LOWER(name) LIKE '%rice%' LIMIT 1;

INSERT INTO PortionSize (food_id, portion_name, portion_name_vi, weight_g, is_common, created_at)
SELECT food_id, '1 piece', '1 miếng', 100.0, true, NOW()
FROM Food WHERE LOWER(name) LIKE '%chicken%' LIMIT 1;

INSERT INTO PortionSize (food_id, portion_name, portion_name_vi, weight_g, is_common, created_at)
SELECT food_id, '1 cup', '1 chén', 240.0, true, NOW()
FROM Food WHERE LOWER(name) LIKE '%milk%' LIMIT 1;

DO $$ BEGIN RAISE NOTICE 'Seeded PortionSize data'; END $$;

COMMIT;

-- ============================================================
-- VERIFICATION
-- ============================================================

DO $$
DECLARE
    v_condition_effects INT;
    v_food_recommendations INT;
    v_fiber_requirements INT;
    v_food_categories INT;
    v_portion_sizes INT;
BEGIN
    SELECT COUNT(*) INTO v_condition_effects FROM ConditionNutrientEffect;
    SELECT COUNT(*) INTO v_food_recommendations FROM ConditionFoodRecommendation;
    SELECT COUNT(*) INTO v_fiber_requirements FROM FiberRequirement;
    SELECT COUNT(*) INTO v_food_categories FROM FoodCategory;
    SELECT COUNT(*) INTO v_portion_sizes FROM PortionSize;
    
    RAISE NOTICE '';
    RAISE NOTICE '=== SEED DATA RESULTS ===';
    RAISE NOTICE 'ConditionNutrientEffect: %', v_condition_effects;
    RAISE NOTICE 'ConditionFoodRecommendation: %', v_food_recommendations;
    RAISE NOTICE 'FiberRequirement: %', v_fiber_requirements;
    RAISE NOTICE 'FoodCategory: %', v_food_categories;
    RAISE NOTICE 'PortionSize: %', v_portion_sizes;
    RAISE NOTICE '========================';
END $$;
