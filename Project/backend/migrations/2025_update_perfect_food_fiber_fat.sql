-- Migration: Update Perfect Food with correct Fiber and FattyAcid nutrient codes
-- The trigger reads from FoodNutrient using NutrientMapping that maps to Fiber and FattyAcid codes

BEGIN;

-- Get Perfect Food ID
DO $$
DECLARE
    v_food_id INT;
    v_nutrient_id INT;
BEGIN
    SELECT food_id INTO v_food_id FROM Food WHERE name = 'Perfect Food' LIMIT 1;
    
    IF v_food_id IS NULL THEN
        RAISE EXCEPTION 'Perfect Food not found!';
    END IF;
    
    RAISE NOTICE 'Updating Perfect Food ID: %', v_food_id;
    
    -- ============================================================
    -- FIBER - Using codes that match Fiber table
    -- ============================================================
    -- RESISTANT_STARCH: target ~10g * 1.2 = 12g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'RESISTANT_STARCH' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 12.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 12.0;
        RAISE NOTICE 'Added RESISTANT_STARCH';
    END IF;
    
    -- BETA_GLUCAN: target ~3g * 1.2 = 3.6g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'BETA_GLUCAN' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3.6)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 3.6;
        RAISE NOTICE 'Added BETA_GLUCAN';
    END IF;
    
    -- INSOLUBLE_FIBER: target ~15g * 1.2 = 18g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'INSOLUBLE_FIBER' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 18.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 18.0;
        RAISE NOTICE 'Added INSOLUBLE_FIBER';
    END IF;
    
    -- TOTAL_FIBER: target ~25g * 1.2 = 30g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'TOTAL_FIBER' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 30.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 30.0;
        RAISE NOTICE 'Added TOTAL_FIBER';
    END IF;
    
    -- SOLUBLE_FIBER: target ~7g * 1.2 = 8.4g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'SOLUBLE_FIBER' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 8.4)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 8.4;
        RAISE NOTICE 'Added SOLUBLE_FIBER';
    END IF;
    
    -- ============================================================
    -- FATTY ACIDS - Using codes that match FattyAcid table
    -- ============================================================
    -- ALA: target ~1.6g * 1.2 = 1.92g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'ALA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.92)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 1.92;
        RAISE NOTICE 'Added ALA';
    END IF;
    
    -- EPA: target ~0.25g * 1.2 = 0.3g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'EPA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.3)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 0.3;
        RAISE NOTICE 'Added EPA';
    END IF;
    
    -- DHA: target ~0.25g * 1.2 = 0.3g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'DHA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.3)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 0.3;
        RAISE NOTICE 'Added DHA';
    END IF;
    
    -- EPA_DHA: target ~0.5g * 1.2 = 0.6g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'EPA_DHA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.6)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 0.6;
        RAISE NOTICE 'Added EPA_DHA';
    END IF;
    
    -- LA (Linoleic Acid): target ~17g * 1.2 = 20.4g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'LA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 20.4)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 20.4;
        RAISE NOTICE 'Added LA';
    END IF;
    
    -- CHOLESTEROL: target ~300mg * 1.2 = 360mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CHOLESTEROL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 360)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 360;
        RAISE NOTICE 'Added CHOLESTEROL';
    END IF;
    
    -- TOTAL_FAT: target ~65g * 1.2 = 78g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'TOTAL_FAT' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 78.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 78.0;
        RAISE NOTICE 'Added TOTAL_FAT';
    END IF;
    
    -- PUFA: target ~17g * 1.2 = 20.4g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'PUFA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 20.4)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 20.4;
        RAISE NOTICE 'Added PUFA';
    END IF;
    
    -- TRANS_FAT: target 0 (keep low)
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'TRANS_FAT' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 0.0;
        RAISE NOTICE 'Added TRANS_FAT';
    END IF;
    
    -- MUFA: target ~20g * 1.2 = 24g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'MUFA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 24.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 24.0;
        RAISE NOTICE 'Added MUFA';
    END IF;
    
    -- SFA (Saturated Fat): target ~20g * 1.2 = 24g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'SFA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 24.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 24.0;
        RAISE NOTICE 'Added SFA';
    END IF;
    
    RAISE NOTICE 'Perfect Food updated with Fiber and FattyAcid nutrients';
END $$;

COMMIT;

-- Verify
SELECT n.nutrient_code, fn.amount_per_100g 
FROM FoodNutrient fn 
JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
JOIN Food f ON f.food_id = fn.food_id
WHERE f.name = 'Perfect Food' 
AND (n.nutrient_code IN ('RESISTANT_STARCH','BETA_GLUCAN','INSOLUBLE_FIBER','TOTAL_FIBER','SOLUBLE_FIBER','ALA','EPA','DHA','EPA_DHA','LA','CHOLESTEROL','TOTAL_FAT','PUFA','TRANS_FAT','MUFA','SFA'));

