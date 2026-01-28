BEGIN;

DO $$
DECLARE
  v_n_energy INT;
  v_n_protein INT;
  v_n_fat INT;
  v_n_carb INT;
  v_n_fiber INT;
  v_n_vitc INT;
  v_n_ca INT;
  v_n_k INT;
  v_n_na INT;
  v_n_mg INT;

  v_food_water INT;
  v_food_ice INT;
  v_food_ice_alt INT;
  v_food_lime INT;
  v_food_sugar INT;
  v_food_honey INT;
  v_food_ginger INT;
  v_food_pennywort INT;
  v_food_aloe INT;
  v_food_coconut_water INT;
  v_food_mint INT;
  v_food_green_tea INT;
  v_food_black_tea INT;
  v_food_passion_fruit INT;
  v_food_black_sesame INT;
  v_food_milk INT;
  v_food_coffee INT;
  v_food_orange INT;
  v_food_watermelon INT;
  v_food_papaya INT;
  v_food_dragon_fruit INT;
  v_food_soursop INT;
  v_food_tamarind INT;
  v_food_kumquat INT;
  v_food_peach INT;
  v_food_young_rice INT;
  v_food_peanut INT;
  v_food_soybean INT;

  v_drink_id INT;
  v_has_nutrients BOOLEAN;
  v_can_compute BOOLEAN;
  v_recipe_fruit INT;
  v_volume_ml NUMERIC;
  r RECORD;
BEGIN
  SELECT nutrient_id INTO v_n_energy FROM nutrient WHERE UPPER(nutrient_code) = 'ENERC_KCAL' LIMIT 1;
  SELECT nutrient_id INTO v_n_protein FROM nutrient WHERE UPPER(nutrient_code) = 'PROCNT' LIMIT 1;
  SELECT nutrient_id INTO v_n_fat FROM nutrient WHERE UPPER(nutrient_code) = 'FAT' LIMIT 1;
  SELECT nutrient_id INTO v_n_carb FROM nutrient WHERE UPPER(nutrient_code) = 'CHOCDF' LIMIT 1;
  SELECT nutrient_id INTO v_n_fiber FROM nutrient WHERE UPPER(nutrient_code) = 'FIBTG' LIMIT 1;
  SELECT nutrient_id INTO v_n_vitc FROM nutrient WHERE UPPER(nutrient_code) = 'VITC' LIMIT 1;
  SELECT nutrient_id INTO v_n_ca FROM nutrient WHERE UPPER(nutrient_code) = 'CA' LIMIT 1;
  SELECT nutrient_id INTO v_n_k FROM nutrient WHERE UPPER(nutrient_code) = 'K' LIMIT 1;
  SELECT nutrient_id INTO v_n_na FROM nutrient WHERE UPPER(nutrient_code) = 'NA' LIMIT 1;
  SELECT nutrient_id INTO v_n_mg FROM nutrient WHERE UPPER(nutrient_code) = 'MG' LIMIT 1;

  -- Ensure base ingredient foods exist
  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'water' OR name_vi = 'Nước lọc') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Water', 'Nước lọc', 'Beverages', 250);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name = 'Đá lạnh') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Đá lạnh', 'Đá lạnh', 'Ingredients', 100);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name = 'Ice' OR name_vi = 'Đá viên') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Ice', 'Đá viên', 'Beverages', 100);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Chanh' OR LOWER(name) = 'lime') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Lime', 'Chanh', 'Fruits', 30);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Đường' OR LOWER(name) = 'sugar') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Sugar', 'Đường', 'Condiments', 10);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Mật ong' OR LOWER(name) = 'honey') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Honey', 'Mật ong', 'Sweeteners', 20);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Gừng' OR LOWER(name) = 'ginger') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Ginger', 'Gừng', 'Spices', 10);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Rau má' OR LOWER(name) = 'pennywort') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Pennywort', 'Rau má', 'Vegetables', 50);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Nha đam' OR LOWER(name) = 'aloe vera') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Aloe Vera', 'Nha đam', 'Vegetables', 50);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Nước dừa tươi' OR LOWER(name) = 'coconut water') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Coconut Water', 'Nước dừa tươi', 'Beverages', 250);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Bạc hà' OR LOWER(name) = 'mint leaves') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Mint Leaves', 'Bạc hà', 'Herbs', 5);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Lá trà xanh' OR LOWER(name) = 'green tea leaves') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Green Tea Leaves', 'Lá trà xanh', 'Beverage Ingredients', 2);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Lá trà đen' OR LOWER(name) = 'black tea leaves') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Black Tea Leaves', 'Lá trà đen', 'Beverage Ingredients', 2);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Chanh dây' OR LOWER(name) = 'passion fruit') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Passion Fruit', 'Chanh dây', 'Fruits', 80);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Mè đen' OR LOWER(name) = 'black sesame') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Black Sesame', 'Mè đen', 'Seeds', 20);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE name_vi = 'Sữa tươi' OR LOWER(name) = 'milk') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Milk', 'Sữa tươi', 'Dairy', 250);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'coffee beans' OR name_vi = 'Cà phê') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Coffee Beans', 'Cà phê', 'Beverage Ingredients', 15);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'orange' OR name_vi = 'Cam') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Orange', 'Cam', 'Fruits', 150);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'watermelon' OR name_vi = 'Dưa hấu') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Watermelon', 'Dưa hấu', 'Fruits', 200);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'papaya' OR name_vi = 'Đu đủ') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Papaya', 'Đu đủ', 'Fruits', 200);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'dragon fruit' OR name_vi = 'Thanh long') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Dragon Fruit', 'Thanh long', 'Fruits', 200);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'soursop' OR name_vi = 'Mãng cầu') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Soursop', 'Mãng cầu', 'Fruits', 150);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'tamarind' OR name_vi = 'Me') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Tamarind', 'Me', 'Fruits', 80);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'kumquat' OR name_vi = 'Tắc') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Kumquat', 'Tắc', 'Fruits', 30);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'peach' OR name_vi = 'Đào') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Peach', 'Đào', 'Fruits', 120);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'young rice' OR name_vi = 'Cốm') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Young Rice', 'Cốm', 'Grains', 100);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'peanut' OR name_vi = 'Đậu phộng') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Peanut', 'Đậu phộng', 'Nuts & Seeds', 30);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM food WHERE LOWER(name) = 'soybean' OR name_vi = 'Đậu nành') THEN
    INSERT INTO food(name, name_vi, category, serving_size_g)
    VALUES ('Soybean', 'Đậu nành', 'Legumes', 100);
  END IF;

  -- Resolve ingredient food ids
  SELECT food_id INTO v_food_water FROM food WHERE name_vi = 'Nước lọc' OR LOWER(name) = 'water' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_ice_alt FROM food WHERE name = 'Đá lạnh' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_ice FROM food WHERE name_vi = 'Đá viên' OR LOWER(name) = 'ice' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_lime FROM food WHERE name_vi = 'Chanh' OR LOWER(name) = 'lime' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_sugar FROM food WHERE name_vi = 'Đường' OR LOWER(name) = 'sugar' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_honey FROM food WHERE name_vi = 'Mật ong' OR LOWER(name) = 'honey' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_ginger FROM food WHERE name_vi = 'Gừng' OR LOWER(name) = 'ginger' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_pennywort FROM food WHERE name_vi = 'Rau má' OR LOWER(name) = 'pennywort' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_aloe FROM food WHERE name_vi = 'Nha đam' OR LOWER(name) = 'aloe vera' OR LOWER(name) = 'aloe vera' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_coconut_water FROM food WHERE name_vi = 'Nước dừa tươi' OR LOWER(name) = 'coconut water' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_mint FROM food WHERE name_vi = 'Bạc hà' OR LOWER(name) = 'mint leaves' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_green_tea FROM food WHERE name_vi = 'Lá trà xanh' OR LOWER(name) = 'green tea leaves' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_black_tea FROM food WHERE name_vi = 'Lá trà đen' OR LOWER(name) = 'black tea leaves' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_passion_fruit FROM food WHERE name_vi = 'Chanh dây' OR LOWER(name) = 'passion fruit' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_black_sesame FROM food WHERE name_vi = 'Mè đen' OR LOWER(name) = 'black sesame' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_milk FROM food WHERE name_vi = 'Sữa tươi' OR LOWER(name) = 'milk' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_coffee FROM food WHERE name_vi = 'Cà phê' OR LOWER(name) = 'coffee beans' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_orange FROM food WHERE name_vi = 'Cam' OR LOWER(name) = 'orange' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_watermelon FROM food WHERE name_vi = 'Dưa hấu' OR LOWER(name) = 'watermelon' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_papaya FROM food WHERE name_vi = 'Đu đủ' OR LOWER(name) = 'papaya' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_dragon_fruit FROM food WHERE name_vi = 'Thanh long' OR LOWER(name) = 'dragon fruit' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_soursop FROM food WHERE name_vi = 'Mãng cầu' OR LOWER(name) = 'soursop' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_tamarind FROM food WHERE name_vi = 'Me' OR LOWER(name) = 'tamarind' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_kumquat FROM food WHERE name_vi = 'Tắc' OR LOWER(name) = 'kumquat' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_peach FROM food WHERE name_vi = 'Đào' OR LOWER(name) = 'peach' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_young_rice FROM food WHERE name_vi = 'Cốm' OR LOWER(name) = 'young rice' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_peanut FROM food WHERE name_vi = 'Đậu phộng' OR LOWER(name) = 'peanut' ORDER BY food_id LIMIT 1;
  SELECT food_id INTO v_food_soybean FROM food WHERE name_vi = 'Đậu nành' OR LOWER(name) = 'soybean' ORDER BY food_id LIMIT 1;

  -- Ensure ice foods are not missing FoodNutrient (insert 0 kcal row)
  IF v_n_energy IS NOT NULL THEN
    IF v_food_ice IS NOT NULL AND NOT EXISTS (SELECT 1 FROM foodnutrient WHERE food_id = v_food_ice AND nutrient_id = v_n_energy) THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_ice, v_n_energy, 0);
    END IF;
    IF v_food_ice_alt IS NOT NULL AND NOT EXISTS (SELECT 1 FROM foodnutrient WHERE food_id = v_food_ice_alt AND nutrient_id = v_n_energy) THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g) VALUES (v_food_ice_alt, v_n_energy, 0);
    END IF;
  END IF;

  -- 1) tra-ao-cam-sa
  SELECT drink_id INTO v_drink_id FROM drink WHERE slug = 'tra-ao-cam-sa' LIMIT 1;
  IF v_drink_id IS NOT NULL THEN
    DELETE FROM drinkingredient WHERE drink_id = v_drink_id;
    INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
    VALUES
      (v_drink_id, v_food_black_tea, 5, 'g', 1, 'Tea'),
      (v_drink_id, v_food_honey, 15, 'g', 2, 'Honey'),
      (v_drink_id, v_food_water, 300, 'ml', 3, 'Water'),
      (v_drink_id, v_food_ice, 100, 'g', 4, 'Ice')
    ON CONFLICT (drink_id, food_id) DO UPDATE
    SET amount_g = EXCLUDED.amount_g,
        unit = EXCLUDED.unit,
        display_order = EXCLUDED.display_order,
        notes = EXCLUDED.notes;

    INSERT INTO drinknutrient(drink_id, nutrient_id, amount_per_100ml)
    SELECT v_drink_id, n.nutrient_id, v.amount
    FROM (VALUES
      ('ENERC_KCAL', 20::numeric),
      ('CHOCDF', 5::numeric),
      ('K', 10::numeric)
    ) v(code, amount)
    JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
    ON CONFLICT (drink_id, nutrient_id) DO UPDATE
    SET amount_per_100ml = EXCLUDED.amount_per_100ml;

    PERFORM calculate_drink_nutrients(v_drink_id);
  END IF;

  -- 2) nuoc-rau-ma
  SELECT drink_id INTO v_drink_id FROM drink WHERE slug = 'nuoc-rau-ma' LIMIT 1;
  IF v_drink_id IS NOT NULL THEN
    DELETE FROM drinkingredient WHERE drink_id = v_drink_id;
    INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
    VALUES
      (v_drink_id, v_food_pennywort, 60, 'g', 1, 'Pennywort'),
      (v_drink_id, v_food_sugar, 10, 'g', 2, 'Sugar'),
      (v_drink_id, v_food_water, 230, 'ml', 3, 'Water'),
      (v_drink_id, v_food_ice, 80, 'g', 4, 'Ice')
    ON CONFLICT (drink_id, food_id) DO UPDATE
    SET amount_g = EXCLUDED.amount_g,
        unit = EXCLUDED.unit,
        display_order = EXCLUDED.display_order,
        notes = EXCLUDED.notes;

    INSERT INTO drinknutrient(drink_id, nutrient_id, amount_per_100ml)
    SELECT v_drink_id, n.nutrient_id, v.amount
    FROM (VALUES
      ('ENERC_KCAL', 25::numeric),
      ('CHOCDF', 6::numeric),
      ('VITC', 10::numeric),
      ('CA', 20::numeric)
    ) v(code, amount)
    JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
    ON CONFLICT (drink_id, nutrient_id) DO UPDATE
    SET amount_per_100ml = EXCLUDED.amount_per_100ml;

    PERFORM calculate_drink_nutrients(v_drink_id);
  END IF;

  -- 3) tra-gung-mat-ong
  SELECT drink_id INTO v_drink_id FROM drink WHERE slug = 'tra-gung-mat-ong' LIMIT 1;
  IF v_drink_id IS NOT NULL THEN
    DELETE FROM drinkingredient WHERE drink_id = v_drink_id;
    INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
    VALUES
      (v_drink_id, v_food_ginger, 15, 'g', 1, 'Ginger'),
      (v_drink_id, v_food_honey, 20, 'g', 2, 'Honey'),
      (v_drink_id, v_food_lime, 10, 'g', 3, 'Lime'),
      (v_drink_id, v_food_water, 260, 'ml', 4, 'Water')
    ON CONFLICT (drink_id, food_id) DO UPDATE
    SET amount_g = EXCLUDED.amount_g,
        unit = EXCLUDED.unit,
        display_order = EXCLUDED.display_order,
        notes = EXCLUDED.notes;

    INSERT INTO drinknutrient(drink_id, nutrient_id, amount_per_100ml)
    SELECT v_drink_id, n.nutrient_id, v.amount
    FROM (VALUES
      ('ENERC_KCAL', 18::numeric),
      ('CHOCDF', 4::numeric),
      ('VITC', 2::numeric)
    ) v(code, amount)
    JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
    ON CONFLICT (drink_id, nutrient_id) DO UPDATE
    SET amount_per_100ml = EXCLUDED.amount_per_100ml;

    PERFORM calculate_drink_nutrients(v_drink_id);
  END IF;

  -- 4) nuoc-nha-am
  SELECT drink_id INTO v_drink_id FROM drink WHERE slug = 'nuoc-nha-am' LIMIT 1;
  IF v_drink_id IS NOT NULL THEN
    DELETE FROM drinkingredient WHERE drink_id = v_drink_id;
    INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
    VALUES
      (v_drink_id, v_food_aloe, 60, 'g', 1, 'Aloe vera'),
      (v_drink_id, v_food_honey, 15, 'g', 2, 'Honey'),
      (v_drink_id, v_food_lime, 10, 'g', 3, 'Lime'),
      (v_drink_id, v_food_water, 250, 'ml', 4, 'Water'),
      (v_drink_id, v_food_ice, 80, 'g', 5, 'Ice')
    ON CONFLICT (drink_id, food_id) DO UPDATE
    SET amount_g = EXCLUDED.amount_g,
        unit = EXCLUDED.unit,
        display_order = EXCLUDED.display_order,
        notes = EXCLUDED.notes;

    INSERT INTO drinknutrient(drink_id, nutrient_id, amount_per_100ml)
    SELECT v_drink_id, n.nutrient_id, v.amount
    FROM (VALUES
      ('ENERC_KCAL', 15::numeric),
      ('CHOCDF', 4::numeric),
      ('VITC', 2::numeric)
    ) v(code, amount)
    JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
    ON CONFLICT (drink_id, nutrient_id) DO UPDATE
    SET amount_per_100ml = EXCLUDED.amount_per_100ml;

    PERFORM calculate_drink_nutrients(v_drink_id);
  END IF;

  -- 5) nuoc-dua-tuoi-1
  SELECT drink_id INTO v_drink_id FROM drink WHERE slug = 'nuoc-dua-tuoi-1' LIMIT 1;
  IF v_drink_id IS NOT NULL THEN
    DELETE FROM drinkingredient WHERE drink_id = v_drink_id;
    INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
    VALUES
      (v_drink_id, v_food_coconut_water, 400, 'ml', 1, 'Coconut water'),
      (v_drink_id, v_food_ice, 80, 'g', 2, 'Ice')
    ON CONFLICT (drink_id, food_id) DO UPDATE
    SET amount_g = EXCLUDED.amount_g,
        unit = EXCLUDED.unit,
        display_order = EXCLUDED.display_order,
        notes = EXCLUDED.notes;

    INSERT INTO drinknutrient(drink_id, nutrient_id, amount_per_100ml)
    SELECT v_drink_id, n.nutrient_id, v.amount
    FROM (VALUES
      ('ENERC_KCAL', 19::numeric),
      ('CHOCDF', 3.7::numeric),
      ('PROCNT', 0.2::numeric),
      ('K', 250::numeric),
      ('NA', 105::numeric)
    ) v(code, amount)
    JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
    ON CONFLICT (drink_id, nutrient_id) DO UPDATE
    SET amount_per_100ml = EXCLUDED.amount_per_100ml;

    PERFORM calculate_drink_nutrients(v_drink_id);
  END IF;

  -- 6) nuoc-chanh-muoi
  SELECT drink_id INTO v_drink_id FROM drink WHERE slug = 'nuoc-chanh-muoi' LIMIT 1;
  IF v_drink_id IS NOT NULL THEN
    DELETE FROM drinkingredient WHERE drink_id = v_drink_id;
    INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
    VALUES
      (v_drink_id, v_food_lime, 30, 'g', 1, 'Lime'),
      (v_drink_id, v_food_sugar, 15, 'g', 2, 'Sugar'),
      (v_drink_id, v_food_water, 300, 'ml', 3, 'Water'),
      (v_drink_id, v_food_ice, 80, 'g', 4, 'Ice')
    ON CONFLICT (drink_id, food_id) DO UPDATE
    SET amount_g = EXCLUDED.amount_g,
        unit = EXCLUDED.unit,
        display_order = EXCLUDED.display_order,
        notes = EXCLUDED.notes;

    INSERT INTO drinknutrient(drink_id, nutrient_id, amount_per_100ml)
    SELECT v_drink_id, n.nutrient_id, v.amount
    FROM (VALUES
      ('ENERC_KCAL', 30::numeric),
      ('CHOCDF', 8.8::numeric),
      ('VITC', 15::numeric),
      ('NA', 30::numeric)
    ) v(code, amount)
    JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
    ON CONFLICT (drink_id, nutrient_id) DO UPDATE
    SET amount_per_100ml = EXCLUDED.amount_per_100ml;

    PERFORM calculate_drink_nutrients(v_drink_id);
  END IF;

  -- 7) nuoc-chanh-day
  SELECT drink_id INTO v_drink_id FROM drink WHERE slug = 'nuoc-chanh-day' LIMIT 1;
  IF v_drink_id IS NOT NULL THEN
    DELETE FROM drinkingredient WHERE drink_id = v_drink_id;
    INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
    VALUES
      (v_drink_id, v_food_passion_fruit, 80, 'g', 1, 'Passion fruit'),
      (v_drink_id, v_food_honey, 15, 'g', 2, 'Honey'),
      (v_drink_id, v_food_water, 260, 'ml', 3, 'Water'),
      (v_drink_id, v_food_ice, 80, 'g', 4, 'Ice')
    ON CONFLICT (drink_id, food_id) DO UPDATE
    SET amount_g = EXCLUDED.amount_g,
        unit = EXCLUDED.unit,
        display_order = EXCLUDED.display_order,
        notes = EXCLUDED.notes;

    INSERT INTO drinknutrient(drink_id, nutrient_id, amount_per_100ml)
    SELECT v_drink_id, n.nutrient_id, v.amount
    FROM (VALUES
      ('ENERC_KCAL', 40::numeric),
      ('CHOCDF', 10::numeric),
      ('VITC', 20::numeric)
    ) v(code, amount)
    JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
    ON CONFLICT (drink_id, nutrient_id) DO UPDATE
    SET amount_per_100ml = EXCLUDED.amount_per_100ml;

    PERFORM calculate_drink_nutrients(v_drink_id);
  END IF;

  -- 8) tra-chanh-bac-ha
  SELECT drink_id INTO v_drink_id FROM drink WHERE slug = 'tra-chanh-bac-ha' LIMIT 1;
  IF v_drink_id IS NOT NULL THEN
    DELETE FROM drinkingredient WHERE drink_id = v_drink_id;
    INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
    VALUES
      (v_drink_id, v_food_green_tea, 3, 'g', 1, 'Green tea'),
      (v_drink_id, v_food_mint, 10, 'g', 2, 'Mint'),
      (v_drink_id, v_food_lime, 25, 'g', 3, 'Lime'),
      (v_drink_id, v_food_honey, 15, 'g', 4, 'Honey'),
      (v_drink_id, v_food_water, 250, 'ml', 5, 'Water'),
      (v_drink_id, v_food_ice, 80, 'g', 6, 'Ice')
    ON CONFLICT (drink_id, food_id) DO UPDATE
    SET amount_g = EXCLUDED.amount_g,
        unit = EXCLUDED.unit,
        display_order = EXCLUDED.display_order,
        notes = EXCLUDED.notes;

    INSERT INTO drinknutrient(drink_id, nutrient_id, amount_per_100ml)
    SELECT v_drink_id, n.nutrient_id, v.amount
    FROM (VALUES
      ('ENERC_KCAL', 20::numeric),
      ('CHOCDF', 5::numeric),
      ('VITC', 10::numeric)
    ) v(code, amount)
    JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
    ON CONFLICT (drink_id, nutrient_id) DO UPDATE
    SET amount_per_100ml = EXCLUDED.amount_per_100ml;

    PERFORM calculate_drink_nutrients(v_drink_id);
  END IF;

  -- 9) sua-me-en
  SELECT drink_id INTO v_drink_id FROM drink WHERE slug = 'sua-me-en' LIMIT 1;
  IF v_drink_id IS NOT NULL THEN
    DELETE FROM drinkingredient WHERE drink_id = v_drink_id;
    INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
    VALUES
      (v_drink_id, v_food_black_sesame, 30, 'g', 1, 'Black sesame'),
      (v_drink_id, v_food_milk, 250, 'ml', 2, 'Milk'),
      (v_drink_id, v_food_sugar, 10, 'g', 3, 'Sugar')
    ON CONFLICT (drink_id, food_id) DO UPDATE
    SET amount_g = EXCLUDED.amount_g,
        unit = EXCLUDED.unit,
        display_order = EXCLUDED.display_order,
        notes = EXCLUDED.notes;

    INSERT INTO drinknutrient(drink_id, nutrient_id, amount_per_100ml)
    SELECT v_drink_id, n.nutrient_id, v.amount
    FROM (VALUES
      ('ENERC_KCAL', 90::numeric),
      ('PROCNT', 3::numeric),
      ('FAT', 3.5::numeric),
      ('CHOCDF', 10::numeric),
      ('CA', 80::numeric),
      ('FE', 1::numeric)
    ) v(code, amount)
    JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
    ON CONFLICT (drink_id, nutrient_id) DO UPDATE
    SET amount_per_100ml = EXCLUDED.amount_per_100ml;

    PERFORM calculate_drink_nutrients(v_drink_id);
  END IF;

  -- Backfill ingredient recipes for remaining template drinks missing ingredients.
  FOR r IN
    SELECT d.drink_id, d.slug, d.name, d.vietnamese_name, COALESCE(d.default_volume_ml, 250) AS default_volume_ml
    FROM drink d
    WHERE d.is_template = TRUE
      AND NOT EXISTS (SELECT 1 FROM drinkingredient di WHERE di.drink_id = d.drink_id)
    ORDER BY d.drink_id
  LOOP
    v_volume_ml := COALESCE(r.default_volume_ml, 250);
    v_recipe_fruit := NULL;

    IF r.vietnamese_name ILIKE '%cam%' OR r.name ILIKE '%orange%' THEN
      v_recipe_fruit := v_food_orange;
    ELSIF r.vietnamese_name ILIKE '%dưa hấu%' OR r.name ILIKE '%watermelon%' THEN
      v_recipe_fruit := v_food_watermelon;
    ELSIF r.vietnamese_name ILIKE '%đu đủ%' OR r.name ILIKE '%papaya%' THEN
      v_recipe_fruit := v_food_papaya;
    ELSIF r.vietnamese_name ILIKE '%thanh long%' OR r.name ILIKE '%dragon fruit%' THEN
      v_recipe_fruit := v_food_dragon_fruit;
    ELSIF r.vietnamese_name ILIKE '%mãng cầu%' OR r.name ILIKE '%soursop%' THEN
      v_recipe_fruit := v_food_soursop;
    ELSIF r.vietnamese_name ILIKE '%nước me%' OR r.name ILIKE '%tamarind%' THEN
      v_recipe_fruit := v_food_tamarind;
    ELSIF r.vietnamese_name ILIKE '%tắc%' OR r.vietnamese_name ILIKE '%quat%' OR r.name ILIKE '%kumquat%' THEN
      v_recipe_fruit := v_food_kumquat;
    ELSIF r.vietnamese_name ILIKE '%đào%' OR r.name ILIKE '%peach%' THEN
      v_recipe_fruit := v_food_peach;
    ELSIF r.vietnamese_name ILIKE '%cốm%' THEN
      v_recipe_fruit := v_food_young_rice;
    END IF;

    DELETE FROM drinkingredient WHERE drink_id = r.drink_id;

    -- Coffee-based
    IF r.vietnamese_name ILIKE '%cà phê%' OR r.name ILIKE '%coffee%' THEN
      INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (r.drink_id, v_food_coffee, 15, 'g', 1, 'Coffee'),
        (r.drink_id, v_food_sugar, 10, 'g', 2, 'Sugar'),
        (r.drink_id, v_food_water, v_volume_ml, 'ml', 3, 'Water'),
        (r.drink_id, v_food_ice, 80, 'g', 4, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

    -- Tea-based
    ELSIF r.vietnamese_name ILIKE 'trà %' OR r.name ILIKE '%tea%' THEN
      INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (r.drink_id,
          CASE
            WHEN r.vietnamese_name ILIKE '%đen%' THEN v_food_black_tea
            ELSE v_food_green_tea
          END,
          3, 'g', 1, 'Tea leaves'
        ),
        (r.drink_id, v_food_honey, 10, 'g', 2, 'Honey'),
        (r.drink_id, v_food_water, v_volume_ml, 'ml', 3, 'Water'),
        (r.drink_id, v_food_ice, 80, 'g', 4, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

    -- Milk-based
    ELSIF r.vietnamese_name ILIKE 'sữa%' OR r.name ILIKE '%milk%' THEN
      INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (r.drink_id, v_food_milk, v_volume_ml, 'ml', 1, 'Milk'),
        (r.drink_id, v_food_sugar, 10, 'g', 2, 'Sugar')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

    -- Smoothie
    ELSIF r.vietnamese_name ILIKE '%sinh tố%' OR r.name ILIKE '%smoothie%' THEN
      INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (r.drink_id, COALESCE(v_recipe_fruit, v_food_orange), 150, 'g', 1, 'Fruit'),
        (r.drink_id, v_food_milk, LEAST(v_volume_ml, 200), 'ml', 2, 'Milk'),
        (r.drink_id, v_food_ice, 80, 'g', 3, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

    -- Juice / generic water-based
    ELSE
      IF r.vietnamese_name ILIKE '%chanh%' OR r.name ILIKE '%lemon%' THEN
        INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
        VALUES
          (r.drink_id, v_food_lime, 30, 'g', 1, 'Lime'),
          (r.drink_id, v_food_sugar, 15, 'g', 2, 'Sugar'),
          (r.drink_id, v_food_water, v_volume_ml, 'ml', 3, 'Water'),
          (r.drink_id, v_food_ice, 80, 'g', 4, 'Ice')
        ON CONFLICT (drink_id, food_id) DO UPDATE
        SET amount_g = EXCLUDED.amount_g,
            unit = EXCLUDED.unit,
            display_order = EXCLUDED.display_order,
            notes = EXCLUDED.notes;
      ELSIF r.vietnamese_name ILIKE '%dừa%' OR r.name ILIKE '%coconut%' THEN
        INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
        VALUES
          (r.drink_id, v_food_coconut_water, v_volume_ml, 'ml', 1, 'Coconut water'),
          (r.drink_id, v_food_ice, 80, 'g', 2, 'Ice')
        ON CONFLICT (drink_id, food_id) DO UPDATE
        SET amount_g = EXCLUDED.amount_g,
            unit = EXCLUDED.unit,
            display_order = EXCLUDED.display_order,
            notes = EXCLUDED.notes;
      ELSIF v_recipe_fruit IS NOT NULL THEN
        INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
        VALUES
          (r.drink_id, v_recipe_fruit, 180, 'g', 1, 'Fruit'),
          (r.drink_id, v_food_water, v_volume_ml, 'ml', 2, 'Water'),
          (r.drink_id, v_food_ice, 80, 'g', 3, 'Ice')
        ON CONFLICT (drink_id, food_id) DO UPDATE
        SET amount_g = EXCLUDED.amount_g,
            unit = EXCLUDED.unit,
            display_order = EXCLUDED.display_order,
            notes = EXCLUDED.notes;
      ELSE
        INSERT INTO drinkingredient(drink_id, food_id, amount_g, unit, display_order, notes)
        VALUES
          (r.drink_id, v_food_water, v_volume_ml, 'ml', 1, 'Water'),
          (r.drink_id, v_food_ice, 80, 'g', 2, 'Ice')
        ON CONFLICT (drink_id, food_id) DO UPDATE
        SET amount_g = EXCLUDED.amount_g,
            unit = EXCLUDED.unit,
            display_order = EXCLUDED.display_order,
            notes = EXCLUDED.notes;
      END IF;
    END IF;

    SELECT EXISTS (SELECT 1 FROM drinknutrient dn WHERE dn.drink_id = r.drink_id)
    INTO v_has_nutrients;

    SELECT EXISTS (
      SELECT 1
      FROM drinkingredient di
      JOIN foodnutrient fn ON fn.food_id = di.food_id
      WHERE di.drink_id = r.drink_id
    )
    INTO v_can_compute;

    IF v_can_compute THEN
      PERFORM calculate_drink_nutrients(r.drink_id);
    END IF;
  END LOOP;
END $$;

COMMIT;
