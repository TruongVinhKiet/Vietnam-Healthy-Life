
SET client_encoding = 'UTF8';

BEGIN;

-- Nutrient ID reference:
-- 1 = ENERC_KCAL (Energy/Calories)
-- 2 = PROCNT (Protein)
-- 3 = FAT (Fat)
-- 4 = CHOCDF (Carbohydrates)
-- 5 = FIBTG (Fiber)
-- 15 = VITC (Vitamin C)
-- 24 = CA (Calcium)
-- 26 = MG (Magnesium)
-- 27 = K (Potassium)
-- 28 = NA (Sodium)

-- Restore nutrients for "Trà sả gừng" (Ginger Lemongrass Tea)
-- Typical values per 100ml for ginger lemongrass tea:
-- - 200 ml serving = 200 ml default volume
-- - Low calories, minimal nutrients, mostly water-based

INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml)
SELECT d.drink_id, n.nutrient_id, n.amount_per_100ml
FROM drink d,
(VALUES
  (1, 12.0),   -- Energy (kcal) - very low calorie tea
  (2, 0.1),    -- Protein
  (3, 0.05),   -- Fat
  (4, 3.0),    -- Carbohydrates (from honey/sugar if added)
  (15, 2.0),   -- Vitamin C (from lemongrass and ginger)
  (27, 25.0),  -- Potassium (from ginger)
  (26, 5.0),   -- Magnesium (trace amounts)
  (24, 3.0)    -- Calcium (trace amounts)
) AS n(nutrient_id, amount_per_100ml)
WHERE LOWER(d.vietnamese_name) LIKE '%trà sả gừng%' 
   OR LOWER(d.name) LIKE '%lemongrass%ginger%tea%'
   OR LOWER(d.name) LIKE '%ginger%lemongrass%tea%'
   OR (LOWER(d.vietnamese_name) LIKE '%sả%' AND LOWER(d.vietnamese_name) LIKE '%gừng%')
ON CONFLICT (drink_id, nutrient_id)
DO UPDATE SET amount_per_100ml = EXCLUDED.amount_per_100ml;

-- Restore nutrients for "Nước vải hồng ép lạnh" (Lychee Rose Cold Pressed Water)
-- Typical values per 100ml for lychee rose water:
-- - 250 ml serving = 250 ml default volume
-- - Moderate calories from lychee fruit, low nutrients

INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml)
SELECT d.drink_id, n.nutrient_id, n.amount_per_100ml
FROM drink d,
(VALUES
  (1, 42.0),   -- Energy (kcal) - lychee has natural sugars
  (2, 0.5),    -- Protein
  (3, 0.1),    -- Fat
  (4, 10.5),   -- Carbohydrates (natural fruit sugars from lychee)
  (5, 0.3),    -- Fiber
  (15, 35.0),  -- Vitamin C (lychee is rich in vitamin C)
  (27, 85.0),  -- Potassium (from lychee)
  (24, 5.0),   -- Calcium
  (26, 8.0),   -- Magnesium
  (28, 2.0)    -- Sodium (very low)
) AS n(nutrient_id, amount_per_100ml)
WHERE LOWER(d.vietnamese_name) LIKE '%nước vải hồng%ép lạnh%'
   OR LOWER(d.vietnamese_name) LIKE '%vải hồng ép lạnh%'
   OR LOWER(d.name) LIKE '%lychee%rose%cold%pressed%'
   OR LOWER(d.name) LIKE '%lychee%rose%water%'
   OR (LOWER(d.vietnamese_name) LIKE '%vải%' AND LOWER(d.vietnamese_name) LIKE '%hồng%')
ON CONFLICT (drink_id, nutrient_id)
DO UPDATE SET amount_per_100ml = EXCLUDED.amount_per_100ml;

COMMIT;

-- Verify the data was inserted
-- SELECT d.drink_id, d.name, d.vietnamese_name, n.nutrient_code, n.name as nutrient_name, dn.amount_per_100ml
-- FROM drink d
-- JOIN drinknutrient dn ON d.drink_id = dn.drink_id
-- JOIN nutrient n ON dn.nutrient_id = n.nutrient_id
-- WHERE LOWER(d.vietnamese_name) LIKE '%trà sả gừng%' 
--    OR LOWER(d.vietnamese_name) LIKE '%vải hồng ép lạnh%'
-- ORDER BY d.drink_id, n.nutrient_code;

