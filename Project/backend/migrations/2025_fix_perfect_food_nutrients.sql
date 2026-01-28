-- Migration: Fix Perfect Food to use existing nutrient codes that have NutrientMapping

BEGIN;

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
    -- FIBER - Use FIB_* codes that have NutrientMapping
    -- ============================================================
    
    -- FIB_RS (Resistant Starch): 12g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_RS' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 12.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 12.0;
        RAISE NOTICE 'Added FIB_RS = 12g';
    END IF;
    
    -- FIB_BGLU (Beta-Glucan): 3.6g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_BGLU' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3.6)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 3.6;
        RAISE NOTICE 'Added FIB_BGLU = 3.6g';
    END IF;
    
    -- FIB_INSOL (Insoluble Fiber): 18g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_INSOL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 18.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 18.0;
        RAISE NOTICE 'Added FIB_INSOL = 18g';
    END IF;
    
    -- FIB_SOL (Soluble Fiber): 8.4g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_SOL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 8.4)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 8.4;
        RAISE NOTICE 'Added FIB_SOL = 8.4g';
    END IF;
    
    -- FIBTG (Total Fiber): 30g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIBTG' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 30.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 30.0;
        RAISE NOTICE 'Added FIBTG = 30g';
    END IF;
    
    -- ============================================================
    -- FATTY ACIDS - Use FA* codes that have NutrientMapping
    -- ============================================================
    
    -- FA18_3N3 (ALA/Omega-3): 1.92g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FA18_3N3' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.92)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 1.92;
        RAISE NOTICE 'Added FA18_3N3 (ALA) = 1.92g';
    END IF;
    
    -- FAEPA (EPA): 0.3g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAEPA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.3)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 0.3;
        RAISE NOTICE 'Added FAEPA = 0.3g';
    END IF;
    
    -- FADHA (DHA): 0.3g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FADHA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.3)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 0.3;
        RAISE NOTICE 'Added FADHA = 0.3g';
    END IF;
    
    -- FA18_2N6C (LA/Omega-6): 20.4g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FA18_2N6C' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 20.4)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 20.4;
        RAISE NOTICE 'Added FA18_2N6C (LA) = 20.4g';
    END IF;
    
    -- FASAT (Saturated Fat): 24g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FASAT' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 24.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 24.0;
        RAISE NOTICE 'Added FASAT = 24g';
    END IF;
    
    -- FAMS (MUFA): 24g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAMS' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 24.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 24.0;
        RAISE NOTICE 'Added FAMS (MUFA) = 24g';
    END IF;
    
    -- FAPU (PUFA): 20.4g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAPU' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 20.4)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 20.4;
        RAISE NOTICE 'Added FAPU (PUFA) = 20.4g';
    END IF;
    
    -- FATRN (Trans Fat): 0g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FATRN' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 0.0;
        RAISE NOTICE 'Added FATRN = 0g';
    END IF;
    
    -- FAT (Total Fat): 78g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAT' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 78.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 78.0;
        RAISE NOTICE 'Added FAT = 78g';
    END IF;
    
    -- CHOLE (Cholesterol): 360mg
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CHOLE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 360.0)
        ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = 360.0;
        RAISE NOTICE 'Added CHOLE = 360mg';
    END IF;
    
    RAISE NOTICE 'Perfect Food updated with correct nutrient codes';
END $$;

COMMIT;

-- Verify Perfect Food nutrients
SELECT n.nutrient_code, fn.amount_per_100g 
FROM FoodNutrient fn 
JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
JOIN Food f ON f.food_id = fn.food_id
WHERE f.name = 'Perfect Food'
ORDER BY n.nutrient_code;

