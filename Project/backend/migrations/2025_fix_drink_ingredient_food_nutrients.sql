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

  v_food_passion_fruit_purple INT;
  v_food_aloe INT;
  v_food_mint INT;
  v_food_black_sesame INT;
  v_food_coffee INT;
  v_food_papaya INT;
  v_food_dragon_fruit INT;
  v_food_soursop INT;
  v_food_tamarind INT;
  v_food_kumquat INT;

  r RECORD;
BEGIN
  INSERT INTO nutrient(name, unit, nutrient_code)
  SELECT 'Water', 'g', 'WATER'
  WHERE NOT EXISTS (SELECT 1 FROM nutrient WHERE UPPER(nutrient_code) = 'WATER');

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

  SELECT food_id INTO v_food_passion_fruit_purple
  FROM food
  WHERE name ILIKE '%chanh%day%tim%'
     OR COALESCE(name_vi, '') ILIKE '%chanh%day%'
  ORDER BY food_id
  LIMIT 1;

  SELECT food_id INTO v_food_aloe
  FROM food
  WHERE name_vi = 'Nha đam' OR LOWER(name) = 'aloe vera'
  ORDER BY food_id
  LIMIT 1;

  SELECT food_id INTO v_food_mint
  FROM food
  WHERE name_vi = 'Bạc hà' OR LOWER(name) = 'mint leaves'
  ORDER BY food_id
  LIMIT 1;

  SELECT food_id INTO v_food_black_sesame
  FROM food
  WHERE name_vi = 'Mè đen' OR LOWER(name) = 'black sesame'
  ORDER BY food_id
  LIMIT 1;

  SELECT food_id INTO v_food_coffee
  FROM food
  WHERE name_vi = 'Cà phê' OR LOWER(name) = 'coffee beans'
  ORDER BY food_id
  LIMIT 1;

  SELECT food_id INTO v_food_papaya
  FROM food
  WHERE name_vi = 'Đu đủ' OR LOWER(name) = 'papaya'
  ORDER BY food_id
  LIMIT 1;

  SELECT food_id INTO v_food_dragon_fruit
  FROM food
  WHERE name_vi = 'Thanh long' OR LOWER(name) = 'dragon fruit'
  ORDER BY food_id
  LIMIT 1;

  SELECT food_id INTO v_food_soursop
  FROM food
  WHERE name_vi = 'Mãng cầu' OR LOWER(name) = 'soursop'
  ORDER BY food_id
  LIMIT 1;

  SELECT food_id INTO v_food_tamarind
  FROM food
  WHERE name_vi = 'Me' OR LOWER(name) = 'tamarind'
  ORDER BY food_id
  LIMIT 1;

  SELECT food_id INTO v_food_kumquat
  FROM food
  WHERE name_vi = 'Tắc' OR LOWER(name) = 'kumquat'
  ORDER BY food_id
  LIMIT 1;

  IF v_food_passion_fruit_purple IS NOT NULL THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_energy, 97)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_protein, 2.2)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_fat, 0.7)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_carb, 23.4)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_fiber, 10.4)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_water, 72.9)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_vitc IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_vitc, 30)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_ca, 12)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_k, 348)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_na, 28)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_mg, 29)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_passion_fruit_purple, v_n_fe, 1.6)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  IF v_food_aloe IS NOT NULL THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_energy, 15)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_protein, 0.76)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_fat, 0.15)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_carb, 3.75)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_fiber, 0.2)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_water, 96)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_vitc IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_vitc, 3)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_ca, 8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_k, 40)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_na, 14)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_mg, 11)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_aloe, v_n_fe, 0.25)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  IF v_food_mint IS NOT NULL THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_energy, 44)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_protein, 3.3)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_fat, 0.7)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_carb, 8.4)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_fiber, 6.8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_water, 85.6)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_vitc IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_vitc, 31.8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_ca, 199)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_k, 458)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_na, 30)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_mg, 63)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_mint, v_n_fe, 11.9)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  IF v_food_black_sesame IS NOT NULL THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_energy, 573)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_protein, 17.7)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_fat, 49.7)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_carb, 23.5)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_fiber, 11.8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_water, 4.7)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_ca, 975)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_k, 468)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_na, 11)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_mg, 351)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_black_sesame, v_n_fe, 14.6)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  IF v_food_coffee IS NOT NULL THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_energy, 1)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_protein, 0.12)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_fat, 0)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_carb, 0)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_fiber, 0)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_water, 99.4)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_ca, 2)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_k, 49)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_na, 2)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_mg, 3)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_coffee, v_n_fe, 0.01)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  IF v_food_papaya IS NOT NULL THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_energy, 43)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_protein, 0.47)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_fat, 0.26)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_carb, 10.8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_fiber, 1.7)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_water, 88.8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_vitc IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_vitc, 60.9)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_ca, 20)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_k, 182)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_na, 8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_mg, 21)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_papaya, v_n_fe, 0.25)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  IF v_food_dragon_fruit IS NOT NULL THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_energy, 57)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_protein, 1.1)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_fat, 0.1)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_carb, 12.9)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_fiber, 3)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_water, 83)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_vitc IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_vitc, 2.5)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_ca, 18)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_k, 268)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_na, 1)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_mg, 40)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_dragon_fruit, v_n_fe, 0.74)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  IF v_food_soursop IS NOT NULL THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_energy, 66)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_protein, 1)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_fat, 0.3)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_carb, 16.8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_fiber, 3.3)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_water, 81.2)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_vitc IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_vitc, 20.6)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_ca, 14)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_k, 278)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_na, 14)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_mg, 21)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_soursop, v_n_fe, 0.6)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  IF v_food_tamarind IS NOT NULL THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_energy, 239)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_protein, 2.8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_fat, 0.6)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_carb, 62.5)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_fiber, 5.1)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_water, 31.4)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_vitc IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_vitc, 3.5)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_ca, 74)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_k, 628)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_na, 28)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_mg, 92)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_tamarind, v_n_fe, 2.8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  IF v_food_kumquat IS NOT NULL THEN
    IF v_n_energy IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_energy, 71)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_protein IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_protein, 1.9)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fat IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_fat, 0.9)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_carb IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_carb, 15.9)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fiber IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_fiber, 6.5)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_water IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_water, 80.8)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_vitc IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_vitc, 43.9)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_ca IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_ca, 62)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_k IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_k, 186)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_na IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_na, 10)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_mg IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_mg, 20)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
    IF v_n_fe IS NOT NULL THEN
      INSERT INTO foodnutrient(food_id, nutrient_id, amount_per_100g)
      VALUES (v_food_kumquat, v_n_fe, 0.9)
      ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;
    END IF;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
    FOR r IN
      SELECT DISTINCT di.drink_id
      FROM drinkingredient di
      WHERE di.food_id IN (
        v_food_passion_fruit_purple,
        v_food_aloe,
        v_food_mint,
        v_food_black_sesame,
        v_food_coffee,
        v_food_papaya,
        v_food_dragon_fruit,
        v_food_soursop,
        v_food_tamarind,
        v_food_kumquat
      )
    LOOP
      PERFORM calculate_drink_nutrients(r.drink_id);
    END LOOP;
  END IF;
END $$;

COMMIT;
