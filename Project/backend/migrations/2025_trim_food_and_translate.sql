-- Migration: Trim Food and FoodNutrient to <=900 unique names and add Vietnamese translations
-- Safe for PostgreSQL. Run on your DB used by the app.
-- It will: keep up to 900 foods (one per normalized name), delete other foods and their nutrients,
-- add a 'name_vi' column (if missing) and apply pattern-based translations for common terms.

BEGIN;

-- Create a temp table of unique foods (one row per normalized name) keeping the smallest food_id
-- then limit to 900 entries (you can change the limit if needed)
WITH ranked AS (
  SELECT *, row_number() OVER (PARTITION BY lower(trim(name)) ORDER BY food_id) AS rn
  FROM "Food"
), unique_foods AS (
  SELECT * FROM ranked WHERE rn = 1 ORDER BY food_id LIMIT 900
)
-- Delete foods not in the chosen unique set
DELETE FROM "Food"
WHERE food_id NOT IN (SELECT food_id FROM unique_foods);

-- Remove FoodNutrient rows that reference deleted foods
DELETE FROM "FoodNutrient"
WHERE food_id NOT IN (SELECT food_id FROM "Food");

-- Add a Vietnamese name column if it doesn't exist
ALTER TABLE "Food" ADD COLUMN IF NOT EXISTS name_vi TEXT;

-- Initialize name_vi with the original name
UPDATE "Food" SET name_vi = name;

-- Apply a set of pattern replacements to translate common words/phrases into Vietnamese.
-- These are best-effort automated translations (pattern-based). Review results and refine as needed.
-- Note: (?i) makes the regexp case-insensitive. 'g' flag for global replacement.

-- Milk-related translations
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)lactose free', 'không lactose', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)fat free|skim', 'không béo', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)low fat|reduced fat|2%|1%|\(1%\)|\(2%\)', 'ít béo', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)whole', 'nguyên kem', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)milk', 'Sữa', 'g');

-- Dairy & common items
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)yogurt|yoghurt', 'Sữa chua', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)cheese', 'Phô mai', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)butter', 'Bơ', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)egg', 'Trứng', 'g');

-- Meats & fish
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)chicken', 'Thịt gà', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)beef', 'Thịt bò', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)pork', 'Thịt heo', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)fish', 'Cá', 'g');

-- Staples & produce
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)rice', 'Gạo', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)bread', 'Bánh mì', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)apple', 'Táo', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)banana', 'Chuối', 'g');

-- Generic cleanups (translate some common adjectives)
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)unsweetened', 'không đường', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)sweetened', 'có đường', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)low sugar', 'ít đường', 'g');
UPDATE "Food" SET name_vi = regexp_replace(name_vi, '(?i)organic', 'hữu cơ', 'g');

-- Trim whitespace
UPDATE "Food" SET name_vi = trim(name_vi);

COMMIT;

-- After running this migration, review the table to confirm it contains <=900 rows and translations are acceptable.
-- Example verification queries:
-- SELECT count(*) FROM "Food";
-- SELECT count(*) FROM "FoodNutrient";
-- SELECT food_id, name, name_vi FROM "Food" ORDER BY food_id LIMIT 50;

-- IMPORTANT: Back up your DB before running this migration. This script deletes rows.
