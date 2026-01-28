-- Migration: Full recalculate all fiber and fatty acid intake from meal_entries

BEGIN;

-- Clear existing intake data for today
DELETE FROM UserFiberIntake WHERE date = CURRENT_DATE;
DELETE FROM UserFattyAcidIntake WHERE date = CURRENT_DATE;

-- Debug: Show meal entries for today
DO $$
DECLARE
    rec RECORD;
BEGIN
    RAISE NOTICE 'Meal entries for today:';
    FOR rec IN 
        SELECT me.id, me.user_id, me.food_id, f.name, me.weight_g
        FROM meal_entries me
        JOIN Food f ON f.food_id = me.food_id
        WHERE me.entry_date = CURRENT_DATE
    LOOP
        RAISE NOTICE 'Entry %: user=%, food=% (%), weight=%g', 
            rec.id, rec.user_id, rec.food_id, rec.name, rec.weight_g;
    END LOOP;
END $$;

-- Recalculate Fiber intake for ALL fiber types
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

-- Recalculate FattyAcid intake for ALL fatty acid types
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

-- Debug: Show what was inserted
DO $$
DECLARE
    rec RECORD;
BEGIN
    RAISE NOTICE 'UserFiberIntake after recalculation:';
    FOR rec IN 
        SELECT ufi.user_id, f.code, ufi.amount 
        FROM UserFiberIntake ufi 
        JOIN Fiber f ON f.fiber_id = ufi.fiber_id 
        WHERE ufi.date = CURRENT_DATE
    LOOP
        RAISE NOTICE 'Fiber: user=%, code=%, amount=%', rec.user_id, rec.code, rec.amount;
    END LOOP;
    
    RAISE NOTICE 'UserFattyAcidIntake after recalculation:';
    FOR rec IN 
        SELECT ufai.user_id, fa.code, ufai.amount 
        FROM UserFattyAcidIntake ufai 
        JOIN FattyAcid fa ON fa.fatty_acid_id = ufai.fatty_acid_id 
        WHERE ufai.date = CURRENT_DATE
    LOOP
        RAISE NOTICE 'FattyAcid: user=%, code=%, amount=%', rec.user_id, rec.code, rec.amount;
    END LOOP;
END $$;

COMMIT;

