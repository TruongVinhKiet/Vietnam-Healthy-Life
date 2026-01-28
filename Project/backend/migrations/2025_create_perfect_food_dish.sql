-- Migration: Create Perfect Food and Perfect Dish
-- Perfect Food contains ALL nutrients at optimal levels to reach 100-120% RDA
-- for ALL age groups (0-120) and genders (male/female) when consuming 100g
-- 
-- Calculation strategy:
-- 1. For amino acids: Use maximum requirement (adult 100kg) * 1.2 = target amount
-- 2. For vitamins/minerals: Use maximum RDA * 1.2 = target amount
-- 3. For fiber/fatty acids: Use maximum RDA * 1.2 = target amount
-- 4. All amounts are per 100g of food

BEGIN;

-- Delete existing Perfect Food/Dish if exists
DELETE FROM DishIngredient WHERE food_id IN (SELECT food_id FROM Food WHERE name = 'Perfect Food');
DELETE FROM FoodNutrient WHERE food_id IN (SELECT food_id FROM Food WHERE name = 'Perfect Food');
DELETE FROM Food WHERE name = 'Perfect Food';
DELETE FROM Dish WHERE name = 'Perfect Dish';

-- Step 1: Create Perfect Food
DO $$
DECLARE
    v_food_id INT;
    v_dish_id INT;
    v_nutrient_id INT;
    v_max_amount NUMERIC;
    v_target_amount NUMERIC;
BEGIN
    -- Create the food
    INSERT INTO Food (name, category, created_by_admin)
    VALUES ('Perfect Food', 'Test Foods', 1)
    RETURNING food_id INTO v_food_id;

    RAISE NOTICE 'Creating Perfect Food with food_id = %', v_food_id;

    -- ============================================================
    -- MACROS (Energy, Protein, Fat, Carbs)
    -- ============================================================
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'ENERC_KCAL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2000);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'PROCNT' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 50);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAT' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 70);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CHOCDF' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 250);
    END IF;

    -- ============================================================
    -- VITAMINS (Target: 120% of maximum RDA for all age groups)
    -- ============================================================
    -- Vitamin A: Max RDA ~900 µg (adult male) * 1.2 = 1080 µg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1080);
    END IF;
    
    -- Vitamin D: Max RDA ~800 IU (elderly) * 1.2 = 960 IU per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITD' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 960);
    END IF;
    
    -- Vitamin E: Max RDA ~15 mg * 1.2 = 18 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 18);
    END IF;
    
    -- Vitamin K: Max RDA ~120 µg * 1.2 = 144 µg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITK' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 144);
    END IF;
    
    -- Vitamin C: Max RDA ~90 mg (adult) * 1.2 = 108 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITC' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 108);
    END IF;
    
    -- Vitamin B1: Max RDA ~1.2 mg * 1.2 = 1.44 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB1' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.44);
    END IF;
    
    -- Vitamin B2: Max RDA ~1.3 mg * 1.2 = 1.56 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB2' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.56);
    END IF;
    
    -- Vitamin B3: Max RDA ~16 mg * 1.2 = 19.2 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB3' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 19.2);
    END IF;
    
    -- Vitamin B5: Max RDA ~5 mg * 1.2 = 6 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB5' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 6);
    END IF;
    
    -- Vitamin B6: Max RDA ~1.3 mg * 1.2 = 1.56 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB6' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.56);
    END IF;
    
    -- Vitamin B7 (Biotin): Max RDA ~30 µg * 1.2 = 36 µg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB7' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 36);
    END IF;
    
    -- Vitamin B9 (Folate): Max RDA ~400 µg * 1.2 = 480 µg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB9' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 480);
    END IF;
    
    -- Vitamin B12: Max RDA ~2.4 µg * 1.2 = 2.88 µg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB12' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2.88);
    END IF;

    -- ============================================================
    -- MINERALS (Target: 120% of maximum RDA for all age groups)
    -- ============================================================
    -- Calcium: Max RDA ~1300 mg (teens) * 1.2 = 1560 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1560);
    END IF;
    
    -- Phosphorus: Max RDA ~1250 mg (teens) * 1.2 = 1500 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'P' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1500);
    END IF;
    
    -- Magnesium: Max RDA ~420 mg (adult male) * 1.2 = 504 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'MG' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 504);
    END IF;
    
    -- Potassium: Max RDA ~4700 mg (adult) * 1.2 = 5640 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'K' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 5640);
    END IF;
    
    -- Sodium: Max RDA ~2300 mg * 1.2 = 2760 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'NA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2760);
    END IF;
    
    -- Iron: Max RDA ~27 mg (pregnant) * 1.2 = 32.4 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 32.4);
    END IF;
    
    -- Zinc: Max RDA ~11 mg (adult male) * 1.2 = 13.2 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'ZN' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 13.2);
    END IF;
    
    -- Copper: Max RDA ~0.9 mg * 1.2 = 1.08 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CU' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.08);
    END IF;
    
    -- Manganese: Max RDA ~2.3 mg (adult male) * 1.2 = 2.76 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'MN' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2.76);
    END IF;
    
    -- Iodine: Max RDA ~150 µg * 1.2 = 180 µg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'I' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 180);
    END IF;
    
    -- Selenium: Max RDA ~55 µg * 1.2 = 66 µg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'SE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 66);
    END IF;
    
    -- Chromium: Max RDA ~35 µg (adult male) * 1.2 = 42 µg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CR' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 42);
    END IF;
    
    -- Molybdenum: Max RDA ~45 µg * 1.2 = 54 µg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'MO' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 54);
    END IF;
    
    -- Fluoride: Max RDA ~3 mg * 1.2 = 3.6 mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'F' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3.6);
    END IF;

    -- ============================================================
    -- AMINO ACIDS (Target: 120% of maximum requirement)
    -- Calculation: Max requirement = Adult (19+) with 100kg weight
    -- LEU: 42 mg/kg * 100kg * 1.2 = 5040 mg = 5.04 g per 100g food
    -- LYS: 30 mg/kg * 100kg * 1.2 = 3600 mg = 3.6 g per 100g food
    -- VAL: 26 mg/kg * 100kg * 1.2 = 3120 mg = 3.12 g per 100g food
    -- ILE: 19 mg/kg * 100kg * 1.2 = 2280 mg = 2.28 g per 100g food
    -- MET: 15 mg/kg * 100kg * 1.2 = 1800 mg = 1.8 g per 100g food
    -- PHE: 25 mg/kg * 100kg * 1.2 = 3000 mg = 3.0 g per 100g food
    -- THR: 15 mg/kg * 100kg * 1.2 = 1800 mg = 1.8 g per 100g food
    -- TRP: 4 mg/kg * 100kg * 1.2 = 480 mg = 0.48 g per 100g food
    -- HIS: 14 mg/kg * 100kg * 1.2 = 1680 mg = 1.68 g per 100g food
    -- ============================================================
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_LEU' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 5.04);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_LYS' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3.6);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_VAL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3.12);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_ILE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2.28);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_MET' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.8);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_PHE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3.0);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_THR' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.8);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_TRP' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.48);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_HIS' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.68);
    END IF;

    -- ============================================================
    -- FIBER (Target: 120% of maximum RDA ~38g for adult male * 1.2 = 45.6g per 100g)
    -- ============================================================
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIBTG' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 45.6);
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_SOL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 13.2); -- ~30% of total
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_INSOL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 27.36); -- ~60% of total
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_RS' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 12.0); -- ~26% of total
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_BGLU' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3.6); -- ~8% of total
    END IF;

    -- ============================================================
    -- FATTY ACIDS (Target: 120% of maximum RDA)
    -- ============================================================
    -- Total Fat: ~65g (adult) * 1.2 = 78g per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FASAT' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 19.5); -- ~25% of total fat
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAMS' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 31.2); -- ~40% of total fat
    END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAPU' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 23.4); -- ~30% of total fat
    END IF;
    
    -- ALA (Omega-3): ~1.6g (adult male) * 1.2 = 1.92g per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FA18_3N3' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.92);
    END IF;
    
    -- EPA: ~250mg * 1.2 = 300mg = 0.3g per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAEPA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.3);
    END IF;
    
    -- DHA: ~250mg * 1.2 = 300mg = 0.3g per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FADHA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.3);
    END IF;
    
    -- EPA + DHA Combined: 0.6g per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAEPA_DHA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.6);
    END IF;
    
    -- LA (Omega-6): ~17g (adult male) * 1.2 = 20.4g per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FA18_2N6C' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 20.4);
    END IF;
    
    -- Trans fat: Keep at 0
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FATRN' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.0);
    END IF;
    
    -- Cholesterol: ~300mg * 1.2 = 360mg per 100g
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CHOLE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN 
        INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 360);
    END IF;

    RAISE NOTICE 'Perfect Food created with food_id = %', v_food_id;

    -- ============================================================
    -- Create Perfect Dish containing Perfect Food
    -- ============================================================
    INSERT INTO Dish (name, vietnamese_name, category, description, serving_size_g, created_by_admin)
    VALUES (
        'Perfect Dish',
        'Món Ăn Hoàn Hảo',
        'test',
        'Món ăn test chứa Perfect Food với đầy đủ tất cả chất dinh dưỡng theo WHO recommendations. Khi add 100g sẽ đạt 100-120% RDA cho tất cả age groups và genders.',
        100,
        1
    )
    RETURNING dish_id INTO v_dish_id;

    -- Add Perfect Food to Perfect Dish with 100g serving
    INSERT INTO DishIngredient (dish_id, food_id, weight_g)
    VALUES (v_dish_id, v_food_id, 100);

    RAISE NOTICE 'Perfect Dish created with dish_id = %, contains % g of Perfect Food', v_dish_id, 100;
END $$;

COMMIT;

-- Verify the food was created
SELECT f.food_id, f.name, COUNT(fn.nutrient_id) as nutrient_count
FROM Food f
LEFT JOIN FoodNutrient fn ON fn.food_id = f.food_id
WHERE f.name = 'Perfect Food'
GROUP BY f.food_id, f.name;

