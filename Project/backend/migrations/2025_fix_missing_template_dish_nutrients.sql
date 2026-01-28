BEGIN;

DO $$
DECLARE
  v_n_energy INT;
  v_n_protein INT;
  v_n_fat INT;
  v_n_carb INT;
  v_n_fiber INT;
  v_n_water INT;
  v_n_vitc INT;
  v_n_ca INT;
  v_n_k INT;
  v_n_na INT;
  v_n_mg INT;
  v_n_fe INT;

  v_food_egg INT;
  v_dish_106_weight NUMERIC;
  r RECORD;
BEGIN
  -- Ensure WATER nutrient exists (by code or by name)
  INSERT INTO nutrient(name, unit, nutrient_code)
  SELECT 'Water', 'g', 'WATER'
  WHERE NOT EXISTS (
    SELECT 1 FROM nutrient
    WHERE UPPER(nutrient_code) = 'WATER'
       OR LOWER(name) = 'water'
  );

  SELECT nutrient_id INTO v_n_energy FROM nutrient WHERE UPPER(nutrient_code) = 'ENERC_KCAL' LIMIT 1;
  SELECT nutrient_id INTO v_n_protein FROM nutrient WHERE UPPER(nutrient_code) = 'PROCNT' LIMIT 1;
  SELECT nutrient_id INTO v_n_fat FROM nutrient WHERE UPPER(nutrient_code) = 'FAT' LIMIT 1;
  SELECT nutrient_id INTO v_n_carb FROM nutrient WHERE UPPER(nutrient_code) = 'CHOCDF' LIMIT 1;
  SELECT nutrient_id INTO v_n_fiber FROM nutrient WHERE UPPER(nutrient_code) = 'FIBTG' LIMIT 1;
  SELECT nutrient_id INTO v_n_water FROM nutrient WHERE UPPER(nutrient_code) = 'WATER' LIMIT 1;
  SELECT nutrient_id INTO v_n_vitc FROM nutrient WHERE UPPER(nutrient_code) = 'VITC' LIMIT 1;
  SELECT nutrient_id INTO v_n_ca FROM nutrient WHERE UPPER(nutrient_code) = 'CA' LIMIT 1;
  SELECT nutrient_id INTO v_n_k FROM nutrient WHERE UPPER(nutrient_code) = 'K' LIMIT 1;
  SELECT nutrient_id INTO v_n_na FROM nutrient WHERE UPPER(nutrient_code) = 'NA' LIMIT 1;
  SELECT nutrient_id INTO v_n_mg FROM nutrient WHERE UPPER(nutrient_code) = 'MG' LIMIT 1;
  SELECT nutrient_id INTO v_n_fe FROM nutrient WHERE UPPER(nutrient_code) = 'FE' LIMIT 1;

  -- Backfill FoodNutrient for food_id=110 (Da lanh)
  IF EXISTS (SELECT 1 FROM food WHERE food_id = 110) THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (110, v_n_energy, 0)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (110, v_n_protein, 0)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (110, v_n_fat, 0)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (110, v_n_carb, 0)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (110, v_n_fiber, 0)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (110, v_n_water, 100)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  -- Backfill FoodNutrient for food_id=50 (Rau muong)
  IF EXISTS (SELECT 1 FROM food WHERE food_id = 50) THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_energy, 19)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_protein, 2.6)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_fat, 0.2)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_carb, 3.1)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_fiber, 2.1)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_water, 92.5)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_vitc IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_vitc, 55)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_ca, 77)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_k, 312)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_na, 70)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_mg, 71)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (50, v_n_fe, 1.7)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  -- Backfill FoodNutrient for food_id=43 (Rau cu)
  IF EXISTS (SELECT 1 FROM food WHERE food_id = 43) THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_energy, 35)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_protein, 1.5)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_fat, 0.2)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_carb, 7.0)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_fiber, 2.5)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_water, 90)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_vitc IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_vitc, 20)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_ca, 30)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_k, 200)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_na, 40)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_mg, 20)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (43, v_n_fe, 0.6)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  -- If dish 106 has no ingredients, attach an egg ingredient that has FoodNutrient data
  IF EXISTS (SELECT 1 FROM dish WHERE dish_id = 106) THEN
    SELECT COALESCE(serving_size_g, 100) INTO v_dish_106_weight FROM dish WHERE dish_id = 106;

    SELECT f.food_id INTO v_food_egg
    FROM food f
    WHERE f.food_id IN (3108, 3105, 65, 3157)
       OR f.name ILIKE '%egg%'
    ORDER BY
      EXISTS (SELECT 1 FROM foodnutrient fn WHERE fn.food_id = f.food_id) DESC,
      CASE WHEN f.food_id IN (3108, 3105, 65, 3157) THEN 0 ELSE 1 END,
      f.food_id
    LIMIT 1;

    IF v_food_egg IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dishingredient WHERE dish_id = 106) THEN
      INSERT INTO dishingredient(dish_id, food_id, weight_g, notes, display_order)
      VALUES (106, v_food_egg, v_dish_106_weight, 'Egg', 1)
      ON CONFLICT (dish_id, food_id) DO UPDATE
      SET weight_g = EXCLUDED.weight_g,
          notes = EXCLUDED.notes,
          display_order = EXCLUDED.display_order;
    END IF;

    PERFORM calculate_dish_nutrients(106);
  END IF;

  -- Recalculate DishNutrient for any dish that uses the patched foods
  FOR r IN
    SELECT DISTINCT d.dish_id
    FROM dish d
    JOIN dishingredient di ON di.dish_id = d.dish_id
    WHERE di.food_id IN (43, 50, 110)
    ORDER BY d.dish_id
  LOOP
    PERFORM calculate_dish_nutrients(r.dish_id);
  END LOOP;

  -- Ensure the known affected template dishes are recalculated
  FOR r IN
    SELECT d.dish_id
    FROM dish d
    WHERE d.dish_id IN (1004, 1013, 1017, 1019)
  LOOP
    PERFORM calculate_dish_nutrients(r.dish_id);
  END LOOP;
END $$;

COMMIT;
