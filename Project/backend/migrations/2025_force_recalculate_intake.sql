-- Migration: Force recalculate all fiber and fatty acid intake
-- Delete old and insert new

BEGIN;

-- Clear ALL intake data for today
TRUNCATE UserFiberIntake;
TRUNCATE UserFattyAcidIntake;

-- Recalculate Fiber intake
INSERT INTO UserFiberIntake (user_id, fiber_id, date, amount)
SELECT 
    me.user_id,
    nm.fiber_id,
    me.entry_date,
    SUM(fn.amount_per_100g * me.weight_g / 100.0 * COALESCE(nm.factor, 1.0))
FROM meal_entries me
JOIN FoodNutrient fn ON fn.food_id = me.food_id
JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
JOIN Fiber f ON f.fiber_id = nm.fiber_id
WHERE nm.fiber_id IS NOT NULL
GROUP BY me.user_id, nm.fiber_id, me.entry_date;

-- Recalculate FattyAcid intake
INSERT INTO UserFattyAcidIntake (user_id, fatty_acid_id, date, amount)
SELECT 
    me.user_id,
    nm.fatty_acid_id,
    me.entry_date,
    SUM(fn.amount_per_100g * me.weight_g / 100.0 * COALESCE(nm.factor, 1.0))
FROM meal_entries me
JOIN FoodNutrient fn ON fn.food_id = me.food_id
JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
JOIN FattyAcid fa ON fa.fatty_acid_id = nm.fatty_acid_id
WHERE nm.fatty_acid_id IS NOT NULL
GROUP BY me.user_id, nm.fatty_acid_id, me.entry_date;

COMMIT;

-- Verify
SELECT 'UserFiberIntake after recalculation:' as info;
SELECT ufi.user_id, f.code, ufi.amount 
FROM UserFiberIntake ufi 
JOIN Fiber f ON f.fiber_id = ufi.fiber_id 
WHERE ufi.date = CURRENT_DATE AND ufi.user_id = 5
ORDER BY f.code;

SELECT 'UserFattyAcidIntake after recalculation:' as info;
SELECT ufai.user_id, fa.code, ufai.amount 
FROM UserFattyAcidIntake ufai 
JOIN FattyAcid fa ON fa.fatty_acid_id = ufai.fatty_acid_id 
WHERE ufai.date = CURRENT_DATE AND ufai.user_id = 5
ORDER BY fa.code;

