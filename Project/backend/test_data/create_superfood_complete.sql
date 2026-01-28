-- SuperFood Complete™ - Comprehensive test food with all nutrients
-- This food has high values for all vitamins, minerals, amino acids, fiber, and fatty acids
-- Use this to test the nutrient tracking system across all categories

-- First, insert the food (using simple Food schema)
INSERT INTO Food (name, category)
VALUES (
  'SuperFood Complete Test Food',
  'Test Data'
)
ON CONFLICT DO NOTHING;

-- Get the food_id
DO $$
DECLARE
  v_food_id INT;
  v_nutrient_id INT;
BEGIN
  SELECT food_id INTO v_food_id FROM Food WHERE name = 'SuperFood Complete Test Food';
  
  -- Delete existing nutrient mappings
  DELETE FROM FoodNutrient WHERE food_id = v_food_id;
  
  -- Add all 13 vitamins (500-1000% RDA values)
  
  -- Vitamin A (VITA) - RDA 900 mcg, add 5400 mcg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITA';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 5400.0);
  END IF;
  
  -- Vitamin B1/Thiamin (VITB1) - RDA 1.2 mg, add 7.2 mg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITB1';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 7.2);
  END IF;
  
  -- Vitamin B2/Riboflavin (VITB2) - RDA 1.3 mg, add 9.1 mg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITB2';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 9.1);
  END IF;
  
  -- Vitamin B3/Niacin (VITB3) - RDA 16 mg, add 112 mg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITB3';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 112.0);
  END IF;
  
  -- Vitamin B5/Pantothenic Acid (VITB5) - RDA 5 mg, add 35 mg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITB5';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 35.0);
  END IF;
  
  -- Vitamin B6/Pyridoxine (VITB6) - RDA 1.7 mg, add 10.2 mg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITB6';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 10.2);
  END IF;
  
  -- Vitamin B7/Biotin (VITB7) - RDA 30 mcg, add 210 mcg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITB7';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 210.0);
  END IF;
  
  -- Vitamin B9/Folate (VITB9) - RDA 400 mcg, add 2400 mcg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITB9';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 2400.0);
  END IF;
  
  -- Vitamin B12/Cobalamin (VITB12) - RDA 2.4 mcg, add 16.8 mcg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITB12';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 16.8);
  END IF;
  
  -- Vitamin C (VITC) - RDA 90 mg, add 630 mg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITC';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 630.0);
  END IF;
  
  -- Vitamin D (VITD) - RDA 20 mcg, add 120 mcg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITD';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 120.0);
  END IF;
  
  -- Vitamin E (VITE) - RDA 15 mg, add 90 mg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITE';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 90.0);
  END IF;
  
  -- Vitamin K (VITK) - RDA 120 mcg, add 840 mcg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VITK';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 840.0);
  END IF;
  
  -- Add all 14 minerals (500-1000% RDA values)
  
  -- Calcium (MIN_CA) - RDA 1000 mg, add 6000 mg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_CA';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 6000.0);
  END IF;
  
  -- Phosphorus (MIN_P) - RDA 700 mg, add 4900 mg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_P';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 4900.0);
  END IF;
  
  -- Magnesium (MIN_MG) - RDA 420 mg, add 2520 mg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_MG';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 2520.0);
  END IF;
  
  -- Potassium (MIN_K) - RDA 3400 mg, add 20400 mg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_K';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 20400.0);
  END IF;
  
  -- Sodium (MIN_NA) - RDA 1500 mg, add 10500 mg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_NA';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 10500.0);
  END IF;
  
  -- Iron (MIN_FE) - RDA 18 mg, add 126 mg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_FE';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 126.0);
  END IF;
  
  -- Zinc (MIN_ZN) - RDA 11 mg, add 66 mg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_ZN';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 66.0);
  END IF;
  
  -- Copper (MIN_CU) - RDA 0.9 mg, add 6.3 mg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_CU';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 6.3);
  END IF;
  
  -- Manganese (MIN_MN) - RDA 2.3 mg, add 13.8 mg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_MN';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 13.8);
  END IF;
  
  -- Iodine (MIN_I) - RDA 150 mcg, add 1050 mcg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_I';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 1050.0);
  END IF;
  
  -- Selenium (MIN_SE) - RDA 55 mcg, add 330 mcg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_SE';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 330.0);
  END IF;
  
  -- Chromium (MIN_CR) - RDA 35 mcg, add 245 mcg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_CR';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 245.0);
  END IF;
  
  -- Molybdenum (MIN_MO) - RDA 45 mcg, add 270 mcg (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_MO';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 270.0);
  END IF;
  
  -- Fluoride (MIN_F) - RDA 4 mg, add 28 mg (700%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MIN_F';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 28.0);
  END IF;
  
  -- Add all 9 essential amino acids (high values)
  
  -- Histidine (HIS) - RDA ~10 mg/kg, add 3000 mg
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'HIS';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 3000.0);
  END IF;
  
  -- Isoleucine (ILE) - RDA ~20 mg/kg, add 4000 mg
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'ILE';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 4000.0);
  END IF;
  
  -- Leucine (LEU) - RDA ~39 mg/kg, add 6000 mg
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'LEU';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 6000.0);
  END IF;
  
  -- Lysine (LYS) - RDA ~30 mg/kg, add 5000 mg
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'LYS';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 5000.0);
  END IF;
  
  -- Methionine (MET) - RDA ~10 mg/kg, add 3000 mg
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'MET';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 3000.0);
  END IF;
  
  -- Phenylalanine (PHE) - RDA ~25 mg/kg, add 4500 mg
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'PHE';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 4500.0);
  END IF;
  
  -- Threonine (THR) - RDA ~15 mg/kg, add 3500 mg
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'THR';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 3500.0);
  END IF;
  
  -- Tryptophan (TRP) - RDA ~4 mg/kg, add 1500 mg
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'TRP';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 1500.0);
  END IF;
  
  -- Valine (VAL) - RDA ~26 mg/kg, add 4500 mg
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'VAL';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 4500.0);
  END IF;
  
  -- Add fiber (high values)
  
  -- Soluble Fiber - RDA ~10-15g, add 90g (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'SOLUBLE';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 90.0);
  END IF;
  
  -- Insoluble Fiber - RDA ~15-20g, add 120g (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'INSOLUBLE';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 120.0);
  END IF;
  
  -- Add fatty acids (high values)
  
  -- Omega-3 - RDA ~1.6g, add 10g (625%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'OMEGA3';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 10.0);
  END IF;
  
  -- Omega-6 - RDA ~12-17g, add 100g (600%)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'OMEGA6';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 100.0);
  END IF;
  
  -- Saturated Fat - Limit ~20g, add 12g (60% of limit for variety)
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'SATURATED';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 12.0);
  END IF;
  
  -- Unsaturated Fat - add 50g
  SELECT nutrient_id INTO v_nutrient_id FROM Nutrient WHERE nutrient_code = 'UNSATURATED';
  IF v_nutrient_id IS NOT NULL THEN
    INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
    VALUES (v_food_id, v_nutrient_id, 50.0);
  END IF;
END $$;
