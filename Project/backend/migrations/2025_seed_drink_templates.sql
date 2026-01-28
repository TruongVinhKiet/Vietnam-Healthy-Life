-- Seed default drink templates with nutrient data
BEGIN;

-- Filtered water
WITH inserted AS (
  INSERT INTO Drink (
    name, vietnamese_name, description, category, base_liquid,
    default_volume_ml, hydration_ratio, sugar_free, is_template, is_public, slug
  )
  VALUES (
    'Filtered Water', 'Nước lọc', 'Nước lọc tinh khiết', 'water', 'water',
    250, 1.0, TRUE, TRUE, 'nuoc-loc'
  )
  ON CONFLICT (slug) DO UPDATE
  SET default_volume_ml = EXCLUDED.default_volume_ml,
      hydration_ratio = EXCLUDED.hydration_ratio
  RETURNING drink_id
)
INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
SELECT drink_id, n.nutrient_id,
       CASE
         WHEN n.nutrient_code = 'K' THEN 2
         WHEN n.nutrient_code = 'NA' THEN 1
         ELSE 0
       END
FROM inserted
CROSS JOIN Nutrient n
WHERE n.nutrient_code IN ('K','NA')
ON CONFLICT (drink_id, nutrient_id) DO UPDATE
SET amount_per_100ml = EXCLUDED.amount_per_100ml;

-- Coconut water
WITH inserted AS (
  INSERT INTO Drink (
    name, vietnamese_name, description, category, base_liquid,
    default_volume_ml, hydration_ratio, sugar_free, is_template, is_public, slug
  )
  VALUES (
    'Coconut Water', 'Nước dừa', 'Nước dừa tươi nguyên chất', 'water', 'coconut water',
    250, 0.9, TRUE, TRUE, 'nuoc-dua'
  )
  ON CONFLICT (slug) DO UPDATE
  SET default_volume_ml = EXCLUDED.default_volume_ml,
      hydration_ratio = EXCLUDED.hydration_ratio
  RETURNING drink_id
)
INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
SELECT drink_id, n.nutrient_id,
       CASE
         WHEN n.nutrient_code = 'ENERC_KCAL' THEN 18
         WHEN n.nutrient_code = 'PROCNT' THEN 0.2
         WHEN n.nutrient_code = 'CHOCDF' THEN 3.7
         WHEN n.nutrient_code = 'K' THEN 250
         WHEN n.nutrient_code = 'MG' THEN 25
         ELSE 0
       END
FROM inserted
CROSS JOIN Nutrient n
WHERE n.nutrient_code IN ('ENERC_KCAL','PROCNT','CHOCDF','K','MG')
ON CONFLICT (drink_id, nutrient_id) DO UPDATE
SET amount_per_100ml = EXCLUDED.amount_per_100ml;

-- Black tea
WITH inserted AS (
  INSERT INTO Drink (
    name, vietnamese_name, description, category, base_liquid,
    default_volume_ml, hydration_ratio, sugar_free, is_template, is_public, slug
  )
  VALUES (
    'Black Tea (Hot)', 'Trà đen nóng', 'Trà đen nấu nóng', 'tea', 'hot water',
    200, 0.8, TRUE, TRUE, 'tra-den'
  )
  ON CONFLICT (slug) DO UPDATE
  SET default_volume_ml = EXCLUDED.default_volume_ml,
      hydration_ratio = EXCLUDED.hydration_ratio
  RETURNING drink_id
)
INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
SELECT drink_id, n.nutrient_id,
       CASE
         WHEN n.nutrient_code = 'ENERC_KCAL' THEN 1
         WHEN n.nutrient_code = 'K' THEN 12
         WHEN n.nutrient_code = 'MG' THEN 2
         WHEN n.nutrient_code = 'CA' THEN 0.3
         ELSE 0
       END
FROM inserted
CROSS JOIN Nutrient n
WHERE n.nutrient_code IN ('ENERC_KCAL','K','MG','CA')
ON CONFLICT (drink_id, nutrient_id) DO UPDATE
SET amount_per_100ml = EXCLUDED.amount_per_100ml;

COMMIT;

