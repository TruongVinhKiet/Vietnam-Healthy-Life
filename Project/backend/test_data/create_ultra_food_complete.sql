-- Ultra Food Complete: Contains ALL nutrients at 800% RDA for comprehensive testing
-- This food will trigger 100% consumption for ALL nutrient categories

BEGIN;

-- Delete existing Ultra Food if exists
DELETE FROM DishIngredient WHERE food_id IN (SELECT food_id FROM Food WHERE name = 'Ultra Food Complete');
DELETE FROM FoodNutrient WHERE food_id IN (SELECT food_id FROM Food WHERE name = 'Ultra Food Complete');
DELETE FROM Food WHERE name = 'Ultra Food Complete';
DELETE FROM Dish WHERE name = 'Ultra Dish Complete';

-- Step 1: Insert the ultra food
DO $$
DECLARE
    v_food_id INT;
    v_dish_id INT;
    v_nutrient_id INT;
BEGIN
    -- Create the food
    INSERT INTO Food (name, category, created_by_admin)
    VALUES ('Ultra Food Complete', 'Test Foods', 1)
    RETURNING food_id INTO v_food_id;

    -- MACROS (Energy, Protein, Fat, Carbs)
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'ENERC_KCAL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2000); END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'PROCNT' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 50); END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAT' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 70); END IF;
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CHOCDF' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 250); END IF;

    -- VITAMINS (800% RDA)
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 8100); END IF; -- 800% of ~731 µg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITD' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 800); END IF; -- 800% of ~15 µg = 120 µg -> ~800 IU
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 120); END IF; -- 800% of ~15 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITK' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1080); END IF; -- 800% of ~120 µg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITC' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 720); END IF; -- 800% of ~90 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB1' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 10.0); END IF; -- 800% of ~1.2 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB2' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 11.7); END IF; -- 800% of ~1.3 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB3' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 128); END IF; -- 800% of ~16 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB5' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 41.8); END IF; -- 800% of ~5 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB6' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 10.9); END IF; -- 800% of ~1.3 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB7' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 251); END IF; -- 800% of ~30 µg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB9' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3344); END IF; -- 800% of ~400 µg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB12' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 20.1); END IF; -- 800% of ~2.4 µg

    -- MINERALS (800% RDA)
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 8216); END IF; -- 800% of ~1000 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'P' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 5600); END IF; -- 800% of ~700 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'MG' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2547); END IF; -- 800% of ~310 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'K' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 28000); END IF; -- 800% of ~3500 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'NA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 18400); END IF; -- 800% of ~2300 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 147.9); END IF; -- 800% of ~18 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'ZN' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 99); END IF; -- 800% of ~11 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CU' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 7.39); END IF; -- 800% of ~0.9 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'MN' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 18.9); END IF; -- 800% of ~2.3 mg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'I' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1350); END IF; -- 800% of ~150 µg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'SE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 440); END IF; -- 800% of ~55 µg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'CR' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 287.6); END IF; -- 800% of ~35 µg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'MO' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 405); END IF; -- 800% of ~45 µg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'F' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 24.6); END IF; -- 800% of ~3 mg

    -- AMINO ACIDS (800% - high protein content)
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_HIS' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.12); END IF; -- 800% of ~14mg/kg * 70kg = 980mg -> 0.98g
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_ILE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.52); END IF; -- 800% of ~19mg/kg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_LEU' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3.36); END IF; -- 800% of ~42mg/kg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_LYS' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2.40); END IF; -- 800% of ~30mg/kg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_MET' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.20); END IF; -- 800% of ~15mg/kg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_PHE' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2.00); END IF; -- 800% of ~25mg/kg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_THR' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.20); END IF; -- 800% of ~15mg/kg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_TRP' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.32); END IF; -- 800% of ~4mg/kg
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_VAL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 2.08); END IF; -- 800% of ~26mg/kg

    -- FIBER (800% RDA ~200g total fiber)
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIBTG' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 200); END IF; -- 800% of ~25g
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_SOL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 56); END IF; -- 800% of ~7g
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_INSOL' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 120); END IF; -- 800% of ~15g
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_RS' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 80); END IF; -- 800% of ~10g
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_BGLU' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 24); END IF; -- 800% of ~3g

    -- FATTY ACIDS (800% - converted from energy %)
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FASAT' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 17.8); END IF; -- 800% of ~10% energy
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAMS' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 22.2); END IF; -- 800% of ~12.5% energy
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAPU' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 13.3); END IF; -- 800% of ~7.5% energy
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FA18_3N3' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.6); END IF; -- ALA omega-3
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAEPA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.6); END IF; -- 800% of 250mg = 2000mg = 2g -> converted to per 100g
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FADHA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 1.6); END IF; -- DHA
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FAEPA_DHA' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 3.2); END IF; -- Combined EPA+DHA
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FA18_2N6C' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 8.9); END IF; -- Omega-6 LA
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FATRN' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 0.0); END IF; -- Trans fat (keep low)
    
    SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) LIKE 'DHA%' LIMIT 1;
    IF v_nutrient_id IS NOT NULL THEN INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_id, v_nutrient_id, 10.0); END IF;

    RAISE NOTICE 'Ultra Food Complete created with food_id = %', v_food_id;

    -- Create Ultra Dish
    INSERT INTO Dish (name, vietnamese_name, category, description, serving_size_g, created_by_admin)
    VALUES (
        'Ultra Dish Complete',
        'Món Ăn Ultra Hoàn Chỉnh',
        'test',
        'Món ăn test chứa Ultra Food Complete với đầy đủ tất cả chất dinh dưỡng (1000g serving)',
        1000,
        1
    )
    RETURNING dish_id INTO v_dish_id;

    -- Add Ultra Food to Ultra Dish with 1000g
    INSERT INTO DishIngredient (dish_id, food_id, weight_g)
    VALUES (v_dish_id, v_food_id, 1000);

    RAISE NOTICE 'Ultra Dish Complete created with dish_id = %, contains % g of Ultra Food', v_dish_id, 1000;
END $$;

COMMIT;

-- Verify the food was created
SELECT f.food_id, f.name, COUNT(fn.nutrient_id) as nutrient_count
FROM Food f
LEFT JOIN FoodNutrient fn ON fn.food_id = f.food_id
WHERE f.name = 'Ultra Food Complete'
GROUP BY f.food_id, f.name;
