SET client_encoding = 'UTF8';

BEGIN;

DO $$
DECLARE
  v_food_water INT;
  v_drink_water INT;
  r RECORD;
BEGIN
  IF to_regclass('food') IS NULL THEN
    RETURN;
  END IF;

  SELECT food_id
  INTO v_food_water
  FROM food
  WHERE LOWER(TRIM(name)) IN ('water', 'filtered water')
  ORDER BY food_id
  LIMIT 1;

  IF v_food_water IS NULL THEN
    INSERT INTO food(name, category)
    VALUES ('Water', 'Beverages')
    RETURNING food_id INTO v_food_water;
  END IF;

  IF to_regclass('drink') IS NULL OR to_regclass('drinkingredient') IS NULL THEN
    RETURN;
  END IF;

  SELECT drink_id
  INTO v_drink_water
  FROM drink
  WHERE slug = 'nuoc-loc'
  ORDER BY drink_id
  LIMIT 1;

  IF v_drink_water IS NULL THEN
    INSERT INTO drink(
      name,
      vietnamese_name,
      slug,
      description,
      category,
      base_liquid,
      default_volume_ml,
      hydration_ratio,
      sugar_free,
      is_template,
      is_public
    )
    VALUES (
      'Filtered Water',
      U&'N\01B0\1EDBc l\1ECDc',
      'nuoc-loc',
      'Plain water',
      'water',
      'water',
      250,
      1.0,
      TRUE,
      TRUE,
      TRUE
    )
    RETURNING drink_id INTO v_drink_water;
  END IF;

  IF v_drink_water IS NOT NULL THEN
    UPDATE drink
    SET vietnamese_name = U&'N\01B0\1EDBc l\1ECDc'
    WHERE drink_id = v_drink_water
      AND (vietnamese_name IS NULL OR vietnamese_name = 'Nuoc loc');
  END IF;

  INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
  SELECT v_drink_water, v_food_water, 250, 'ml', 1, 'Water'
  WHERE v_drink_water IS NOT NULL AND v_food_water IS NOT NULL
  ON CONFLICT (drink_id, food_id) DO NOTHING;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
    FOR r IN
      INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
      SELECT d.drink_id, v_food_water, COALESCE(d.default_volume_ml, 250), 'ml', 1, 'Auto water'
      FROM drink d
      WHERE v_food_water IS NOT NULL AND NOT EXISTS (
        SELECT 1
        FROM drinkingredient di
        WHERE di.drink_id = d.drink_id
      )
      ON CONFLICT (drink_id, food_id) DO NOTHING
      RETURNING drink_id
    LOOP
      PERFORM calculate_drink_nutrients(r.drink_id);
    END LOOP;

    IF v_drink_water IS NOT NULL THEN
      PERFORM calculate_drink_nutrients(v_drink_water);
    END IF;
  ELSE
    INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
    SELECT d.drink_id, v_food_water, COALESCE(d.default_volume_ml, 250), 'ml', 1, 'Auto water'
    FROM drink d
    WHERE v_food_water IS NOT NULL AND NOT EXISTS (
      SELECT 1
      FROM drinkingredient di
      WHERE di.drink_id = d.drink_id
    )
    ON CONFLICT (drink_id, food_id) DO NOTHING;
  END IF;
END $$;

COMMIT;
