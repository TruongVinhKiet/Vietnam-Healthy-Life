-- Migration: Fix recalculate all fiber and fatty acid intake from meal_entries
-- This recalculates ALL intake data for ALL users

BEGIN;

-- Clear existing intake data for today for all users
DELETE FROM UserFiberIntake WHERE date = CURRENT_DATE;
DELETE FROM UserFattyAcidIntake WHERE date = CURRENT_DATE;

-- Recalculate Fiber intake for ALL fiber types and ALL users
INSERT INTO UserFiberIntake (user_id, fiber_id, date, amount)
SELECT 
    me.user_id,
    nm.fiber_id,
    me.entry_date,
    SUM(fn.amount_per_100g * me.weight_g / 100.0 * COALESCE(nm.factor, 1.0))
FROM meal_entries me
JOIN FoodNutrient fn ON fn.food_id = me.food_id
JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
WHERE me.entry_date = CURRENT_DATE
  AND nm.fiber_id IS NOT NULL
GROUP BY me.user_id, nm.fiber_id, me.entry_date
ON CONFLICT (user_id, fiber_id, date) 
DO UPDATE SET amount = EXCLUDED.amount;

-- Recalculate FattyAcid intake for ALL fatty acid types and ALL users
INSERT INTO UserFattyAcidIntake (user_id, fatty_acid_id, date, amount)
SELECT 
    me.user_id,
    nm.fatty_acid_id,
    me.entry_date,
    SUM(fn.amount_per_100g * me.weight_g / 100.0 * COALESCE(nm.factor, 1.0))
FROM meal_entries me
JOIN FoodNutrient fn ON fn.food_id = me.food_id
JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
WHERE me.entry_date = CURRENT_DATE
  AND nm.fatty_acid_id IS NOT NULL
GROUP BY me.user_id, nm.fatty_acid_id, me.entry_date
ON CONFLICT (user_id, fatty_acid_id, date) 
DO UPDATE SET amount = EXCLUDED.amount;

COMMIT;

-- Debug verification
SELECT 'UserFiberIntake count by fiber_code:' as info;
SELECT f.code, COUNT(*) as user_count, SUM(ufi.amount) as total_amount
FROM UserFiberIntake ufi 
JOIN Fiber f ON f.fiber_id = ufi.fiber_id 
WHERE ufi.date = CURRENT_DATE
GROUP BY f.code;

SELECT 'UserFattyAcidIntake count by fatty_acid_code:' as info;
SELECT fa.code, COUNT(*) as user_count, SUM(ufai.amount) as total_amount
FROM UserFattyAcidIntake ufai 
JOIN FattyAcid fa ON fa.fatty_acid_id = ufai.fatty_acid_id 
WHERE ufai.date = CURRENT_DATE
GROUP BY fa.code;

