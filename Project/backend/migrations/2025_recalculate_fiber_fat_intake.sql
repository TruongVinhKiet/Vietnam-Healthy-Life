-- Migration: Recalculate UserFiberIntake and UserFattyAcidIntake from meal_entries
-- This recalculates all intake data using the updated NutrientMapping

BEGIN;

-- Clear existing intake data for today
DELETE FROM UserFiberIntake WHERE date = CURRENT_DATE;
DELETE FROM UserFattyAcidIntake WHERE date = CURRENT_DATE;

-- Recalculate Fiber intake
INSERT INTO UserFiberIntake (user_id, fiber_id, date, amount)
SELECT 
    me.user_id,
    nm.fiber_id,
    me.entry_date,
    SUM(fn.amount_per_100g * me.weight_g / 100.0 * COALESCE(nm.factor, 1.0))
FROM meal_entries me
JOIN FoodNutrient fn ON fn.food_id = me.food_id
JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id AND nm.fiber_id IS NOT NULL
WHERE me.entry_date = CURRENT_DATE
GROUP BY me.user_id, nm.fiber_id, me.entry_date
ON CONFLICT (user_id, fiber_id, date) 
DO UPDATE SET amount = EXCLUDED.amount;

-- Recalculate FattyAcid intake
INSERT INTO UserFattyAcidIntake (user_id, fatty_acid_id, date, amount)
SELECT 
    me.user_id,
    nm.fatty_acid_id,
    me.entry_date,
    SUM(fn.amount_per_100g * me.weight_g / 100.0 * COALESCE(nm.factor, 1.0))
FROM meal_entries me
JOIN FoodNutrient fn ON fn.food_id = me.food_id
JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id AND nm.fatty_acid_id IS NOT NULL
WHERE me.entry_date = CURRENT_DATE
GROUP BY me.user_id, nm.fatty_acid_id, me.entry_date
ON CONFLICT (user_id, fatty_acid_id, date) 
DO UPDATE SET amount = EXCLUDED.amount;

COMMIT;

-- Verify
SELECT 'UserFiberIntake after recalculation:' as info;
SELECT ufi.user_id, f.code, ufi.amount 
FROM UserFiberIntake ufi 
JOIN Fiber f ON f.fiber_id = ufi.fiber_id 
WHERE ufi.date = CURRENT_DATE;

SELECT 'UserFattyAcidIntake after recalculation:' as info;
SELECT ufai.user_id, fa.code, ufai.amount 
FROM UserFattyAcidIntake ufai 
JOIN FattyAcid fa ON fa.fatty_acid_id = ufai.fatty_acid_id 
WHERE ufai.date = CURRENT_DATE;

