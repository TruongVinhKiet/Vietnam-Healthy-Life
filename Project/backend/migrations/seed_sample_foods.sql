-- Seed sample Vietnamese foods with nutrition data
-- Run this after schema.sql to populate the database with test data

-- First, ensure we have the required nutrients
DO $$
DECLARE
    v_calorie_id INTEGER;
    v_protein_id INTEGER;
    v_carb_id INTEGER;
    v_fat_id INTEGER;
    v_fiber_id INTEGER;
BEGIN
    -- Get or create Energy nutrient
    SELECT nutrient_id INTO v_calorie_id 
    FROM Nutrient 
    WHERE nutrient_code = 'ENERC_KCAL';
    
    IF v_calorie_id IS NULL THEN
        INSERT INTO Nutrient (name, nutrient_code, unit)
        VALUES ('Energy', 'ENERC_KCAL', 'kcal')
        RETURNING nutrient_id INTO v_calorie_id;
    END IF;

    -- Get or create Protein nutrient
    SELECT nutrient_id INTO v_protein_id 
    FROM Nutrient 
    WHERE nutrient_code = 'PROCNT';
    
    IF v_protein_id IS NULL THEN
        INSERT INTO Nutrient (name, nutrient_code, unit)
        VALUES ('Protein', 'PROCNT', 'g')
        RETURNING nutrient_id INTO v_protein_id;
    END IF;

    -- Get or create Carbohydrate nutrient
    SELECT nutrient_id INTO v_carb_id 
    FROM Nutrient 
    WHERE nutrient_code = 'CHOCDF';
    
    IF v_carb_id IS NULL THEN
        INSERT INTO Nutrient (name, nutrient_code, unit)
        VALUES ('Carbohydrate, by difference', 'CHOCDF', 'g')
        RETURNING nutrient_id INTO v_carb_id;
    END IF;

    -- Get or create Fat nutrient
    SELECT nutrient_id INTO v_fat_id 
    FROM Nutrient 
    WHERE nutrient_code = 'FAT';
    
    IF v_fat_id IS NULL THEN
        INSERT INTO Nutrient (name, nutrient_code, unit)
        VALUES ('Total lipid (fat)', 'FAT', 'g')
        RETURNING nutrient_id INTO v_fat_id;
    END IF;

    -- Get or create Fiber nutrient
    SELECT nutrient_id INTO v_fiber_id 
    FROM Nutrient 
    WHERE nutrient_code = 'FIBTG';
    
    IF v_fiber_id IS NULL THEN
        INSERT INTO Nutrient (name, nutrient_code, unit)
        VALUES ('Fiber, total dietary', 'FIBTG', 'g')
        RETURNING nutrient_id INTO v_fiber_id;
    END IF;

    RAISE NOTICE 'Ensured base nutrients exist';
END $$;

-- Insert sample Vietnamese foods
INSERT INTO Food (name, category, image_url) VALUES
-- Grains & Staples
('Cơm trắng', 'Ngũ cốc', NULL),
('Bánh mì', 'Ngũ cốc', NULL),
('Phở', 'Ngũ cốc', NULL),
('Bún', 'Ngũ cốc', NULL),
('Miến', 'Ngũ cốc', NULL),

-- Vegetables
('Rau muống', 'Rau củ', NULL),
('Cải thảo', 'Rau củ', NULL),
('Cà chua', 'Rau củ', NULL),
('Dưa chuột', 'Rau củ', NULL),
('Rau cải', 'Rau củ', NULL),

-- Fruits
('Chuối', 'Trái cây', NULL),
('Táo', 'Trái cây', NULL),
('Cam', 'Trái cây', NULL),
('Xoài', 'Trái cây', NULL),
('Dưa hấu', 'Trái cây', NULL),

-- Proteins
('Thịt lợn', 'Thịt', NULL),
('Thịt gà', 'Thịt', NULL),
('Thịt bò', 'Thịt', NULL),
('Cá', 'Hải sản', NULL),
('Tôm', 'Hải sản', NULL),
('Trứng gà', 'Trứng', NULL),
('Đậu hũ', 'Đậu', NULL),

-- Dairy
('Sữa tươi', 'Sữa', NULL),
('Sữa chua', 'Sữa', NULL);

-- Add nutrition data for each food
-- Helper function to add nutrients
CREATE OR REPLACE FUNCTION add_food_nutrients(
    p_food_name VARCHAR,
    p_calories NUMERIC,
    p_protein NUMERIC,
    p_carbs NUMERIC,
    p_fat NUMERIC,
    p_fiber NUMERIC DEFAULT 0
) RETURNS VOID AS $$
DECLARE
    v_food_id INTEGER;
    v_nutrient_id INTEGER;
BEGIN
    -- Get food_id
    SELECT food_id INTO v_food_id FROM Food WHERE name = p_food_name;
    
    IF v_food_id IS NULL THEN
        RAISE NOTICE 'Food % not found', p_food_name;
        RETURN;
    END IF;

    -- Add Energy (Calories)
    IF p_calories > 0 THEN
        SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'ENERC_KCAL';
        -- Delete existing entry if any
        DELETE FROM FoodNutrient WHERE food_id = v_food_id AND nutrient_id = v_nutrient_id;
        -- Insert new entry
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_food_id, v_nutrient_id, p_calories);
    END IF;

    -- Add Protein
    IF p_protein > 0 THEN
        SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'PROCNT';
        DELETE FROM FoodNutrient WHERE food_id = v_food_id AND nutrient_id = v_nutrient_id;
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_food_id, v_nutrient_id, p_protein);
    END IF;

    -- Add Carbohydrates
    IF p_carbs > 0 THEN
        SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'CHOCDF';
        DELETE FROM FoodNutrient WHERE food_id = v_food_id AND nutrient_id = v_nutrient_id;
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_food_id, v_nutrient_id, p_carbs);
    END IF;

    -- Add Fat
    IF p_fat > 0 THEN
        SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'FAT';
        DELETE FROM FoodNutrient WHERE food_id = v_food_id AND nutrient_id = v_nutrient_id;
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_food_id, v_nutrient_id, p_fat);
    END IF;

    -- Add Fiber
    IF p_fiber > 0 THEN
        SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'FIBTG';
        DELETE FROM FoodNutrient WHERE food_id = v_food_id AND nutrient_id = v_nutrient_id;
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
        VALUES (v_food_id, v_nutrient_id, p_fiber);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Add nutrition data (per 100g)
-- Format: add_food_nutrients(name, calories, protein, carbs, fat, fiber)

-- Grains & Staples
SELECT add_food_nutrients('Cơm trắng', 130, 2.7, 28.2, 0.3, 0.4);
SELECT add_food_nutrients('Bánh mì', 265, 9.0, 49.0, 3.2, 2.7);
SELECT add_food_nutrients('Phở', 85, 3.5, 15.0, 0.5, 0.8);
SELECT add_food_nutrients('Bún', 109, 1.8, 25.2, 0.1, 0.6);
SELECT add_food_nutrients('Miến', 352, 0.2, 86.0, 0.1, 1.0);

-- Vegetables
SELECT add_food_nutrients('Rau muống', 19, 2.6, 2.1, 0.2, 2.2);
SELECT add_food_nutrients('Cải thảo', 13, 1.5, 2.2, 0.2, 1.2);
SELECT add_food_nutrients('Cà chua', 18, 0.9, 3.9, 0.2, 1.2);
SELECT add_food_nutrients('Dưa chuột', 15, 0.7, 3.6, 0.1, 0.5);
SELECT add_food_nutrients('Rau cải', 23, 2.9, 3.7, 0.3, 1.5);

-- Fruits
SELECT add_food_nutrients('Chuối', 89, 1.1, 22.8, 0.3, 2.6);
SELECT add_food_nutrients('Táo', 52, 0.3, 13.8, 0.2, 2.4);
SELECT add_food_nutrients('Cam', 47, 0.9, 11.8, 0.1, 2.4);
SELECT add_food_nutrients('Xoài', 60, 0.8, 15.0, 0.4, 1.6);
SELECT add_food_nutrients('Dưa hấu', 30, 0.6, 7.6, 0.2, 0.4);

-- Proteins
SELECT add_food_nutrients('Thịt lợn', 242, 27.3, 0.0, 14.0, 0.0);
SELECT add_food_nutrients('Thịt gà', 165, 31.0, 0.0, 3.6, 0.0);
SELECT add_food_nutrients('Thịt bò', 250, 26.0, 0.0, 15.0, 0.0);
SELECT add_food_nutrients('Cá', 206, 22.0, 0.0, 12.0, 0.0);
SELECT add_food_nutrients('Tôm', 99, 24.0, 0.2, 0.3, 0.0);
SELECT add_food_nutrients('Trứng gà', 155, 13.0, 1.1, 11.0, 0.0);
SELECT add_food_nutrients('Đậu hũ', 76, 8.0, 1.9, 4.8, 0.3);

-- Dairy
SELECT add_food_nutrients('Sữa tươi', 61, 3.2, 4.8, 3.3, 0.0);
SELECT add_food_nutrients('Sữa chua', 59, 3.5, 4.7, 3.3, 0.0);

-- Clean up the helper function
DROP FUNCTION IF EXISTS add_food_nutrients;

-- Verify data
DO $$
DECLARE
    food_count INTEGER;
    nutrient_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO food_count FROM Food;
    SELECT COUNT(*) INTO nutrient_count FROM FoodNutrient;
    
    RAISE NOTICE 'Seed complete!';
    RAISE NOTICE 'Total foods: %', food_count;
    RAISE NOTICE 'Total food-nutrient relationships: %', nutrient_count;
END $$;
