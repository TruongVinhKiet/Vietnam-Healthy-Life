-- Add a comprehensive test food with ALL nutrients in the system
-- This superfood contains all vitamins, minerals, amino acids, fibers, and fats
-- Useful for testing UI displays and RDA calculations

BEGIN;

-- Insert the superfood (delete if exists first)
DELETE FROM Food WHERE name = 'SuperFood Complete™ (Test Food)';

INSERT INTO Food (name, category, image_url, created_by_admin)
VALUES ('SuperFood Complete™ (Test Food)', 'Test Foods', 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=400', 1);

-- Get the food_id
DO $$
DECLARE
    v_food_id INTEGER;
    v_nutrient_id INTEGER;
BEGIN
    SELECT food_id INTO v_food_id FROM Food WHERE name = 'SuperFood Complete™ (Test Food)';
    IF v_food_id IS NULL THEN
        RAISE EXCEPTION 'SuperFood Complete not found';
    END IF;

    -- ====================
    -- MACRONUTRIENTS (Basic 5)
    -- ====================
    
    -- Energy (Calories) - 200 kcal per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'ENERC_KCAL' OR name = 'Energy';
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) 
        VALUES (v_food_id, v_nutrient_id, 200) 
       ;
    END IF;

    -- Protein - 15g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'PROCNT' OR name = 'Protein';
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) 
        VALUES (v_food_id, v_nutrient_id, 15) 
       ;
    END IF;

    -- Carbohydrate - 25g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'CHOCDF' OR name = 'Carbohydrate, by difference';
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) 
        VALUES (v_food_id, v_nutrient_id, 25) 
       ;
    END IF;

    -- Total Fat - 8g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'FAT' OR name = 'Total lipid (fat)';
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) 
        VALUES (v_food_id, v_nutrient_id, 8) 
       ;
    END IF;

    -- Total Dietary Fiber - 5g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'FIBTG' OR name LIKE '%Fiber, total%';
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) 
        VALUES (v_food_id, v_nutrient_id, 5) 
       ;
    END IF;

    -- ====================
    -- VITAMINS (10 core vitamins)
    -- ====================
    
    -- Vitamin A - 900 µg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE 'Vitamin A%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 900);
    END IF;

    -- Vitamin D - 20 µg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE 'Vitamin D%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 20);
    END IF;

    -- Vitamin E - 15 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE 'Vitamin E%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 15);
    END IF;

    -- Vitamin K - 120 µg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE 'Vitamin K%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 120);
    END IF;

    -- Vitamin C - 90 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE 'Vitamin C%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 90);
    END IF;

    -- Vitamin B1 (Thiamine) - 1.2 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Thiamin%' OR name LIKE 'Vitamin B1%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.2);
    END IF;

    -- Vitamin B2 (Riboflavin) - 1.3 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Riboflavin%' OR name LIKE 'Vitamin B2%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.3);
    END IF;

    -- Vitamin B6 - 1.7 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE 'Vitamin B-6%' OR name LIKE 'Vitamin B6%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.7);
    END IF;

    -- Vitamin B9 (Folate) - 400 µg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Folate%' OR name LIKE 'Vitamin B9%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 400);
    END IF;

    -- Vitamin B12 - 2.4 µg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE 'Vitamin B-12%' OR name LIKE 'Vitamin B12%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2.4);
    END IF;

    -- ====================
    -- MINERALS (14 essential minerals)
    -- ====================
    
    -- Calcium - 1000 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Calcium%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1000);
    END IF;

    -- Phosphorus - 700 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Phosphorus%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 700);
    END IF;

    -- Magnesium - 420 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Magnesium%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 420);
    END IF;

    -- Potassium - 3500 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Potassium%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3500);
    END IF;

    -- Sodium - 1500 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Sodium%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1500);
    END IF;

    -- Iron - 18 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Iron%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 18);
    END IF;

    -- Zinc - 11 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Zinc%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 11);
    END IF;

    -- Copper - 0.9 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Copper%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.9);
    END IF;

    -- Manganese - 2.3 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Manganese%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2.3);
    END IF;

    -- Iodine - 150 µg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Iodine%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 150);
    END IF;

    -- Selenium - 55 µg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Selenium%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 55);
    END IF;

    -- Chromium - 35 µg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Chromium%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 35);
    END IF;

    -- Molybdenum - 45 µg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Molybdenum%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 45);
    END IF;

    -- Fluoride - 3 mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Fluoride%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3);
    END IF;

    -- ====================
    -- ESSENTIAL AMINO ACIDS (9 amino acids)
    -- ====================
    -- These may be stored in EssentialAminoAcid table or Nutrient table
    
    -- Histidine - 14 mg/kg = ~980mg for 70kg person / 100g food
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Histidine%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 200);
    END IF;

    -- Isoleucine - 300mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Isoleucine%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 300);
    END IF;

    -- Leucine - 400mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Leucine%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 400);
    END IF;

    -- Lysine - 350mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Lysine%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 350);
    END IF;

    -- Methionine - 250mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Methionine%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 250);
    END IF;

    -- Phenylalanine - 280mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Phenylalanine%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 280);
    END IF;

    -- Threonine - 270mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Threonine%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 270);
    END IF;

    -- Tryptophan - 80mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Tryptophan%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 80);
    END IF;

    -- Valine - 320mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE name LIKE '%Valine%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN
        INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 320);
    END IF;

    RAISE NOTICE 'SuperFood Complete™ added with comprehensive nutrients';
END $$;

COMMIT;

