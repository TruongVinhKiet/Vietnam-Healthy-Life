-- Migration: Populate UserAminoRequirement and recalculate UserAminoIntake
-- This fixes amino acids showing 0% by:
-- 1. Creating UserAminoRequirement for all users with default values
-- 2. Recalculating UserAminoIntake from existing meal_entries

BEGIN;

-- ============================================================
-- 1. Populate UserAminoRequirement for all users
-- ============================================================
-- Use default weight of 70kg if user doesn't have weight
DO $$
DECLARE
    u RECORD;
    aa_rec RECORD;
    v_recommended NUMERIC;
    v_weight NUMERIC;
    v_age INT;
    ar_rec RECORD;
BEGIN
    FOR u IN SELECT user_id, COALESCE(weight_kg, 70) as weight, COALESCE(age, 25) as age FROM "User" LOOP
        FOR aa_rec IN SELECT amino_acid_id, code FROM AminoAcid LOOP
            -- Find matching AminoRequirement
            SELECT ar.amount, ar.per_kg INTO ar_rec
            FROM AminoRequirement ar
            WHERE ar.amino_acid_id = aa_rec.amino_acid_id
            AND (ar.age_min IS NULL OR u.age >= ar.age_min)
            AND (ar.age_max IS NULL OR u.age <= ar.age_max)
            ORDER BY (ar.age_min IS NOT NULL) DESC, (ar.age_max IS NOT NULL) DESC
            LIMIT 1;
            
            IF FOUND AND ar_rec.amount IS NOT NULL THEN
                IF ar_rec.per_kg = TRUE THEN
                    v_recommended := ar_rec.amount * u.weight;
                ELSE
                    v_recommended := ar_rec.amount;
                END IF;
                
                -- Insert or update UserAminoRequirement
                INSERT INTO UserAminoRequirement(user_id, amino_acid_id, base, multiplier, recommended, unit, updated_at)
                VALUES (u.user_id, aa_rec.amino_acid_id, ar_rec.amount, 1.0, v_recommended, 'mg', NOW())
                ON CONFLICT (user_id, amino_acid_id) DO UPDATE
                SET base = EXCLUDED.base, multiplier = EXCLUDED.multiplier, recommended = EXCLUDED.recommended, unit = EXCLUDED.unit, updated_at = EXCLUDED.updated_at;
            END IF;
        END LOOP;
    END LOOP;
    
    RAISE NOTICE 'Populated UserAminoRequirement for all users';
END $$;

-- ============================================================
-- 2. Recalculate UserAminoIntake from meal_entries
-- ============================================================
-- Clear existing data for last 7 days
DELETE FROM UserAminoIntake WHERE date >= CURRENT_DATE - INTERVAL '7 days';

-- Recalculate from meal_entries
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT me.user_id, me.entry_date, me.food_id, me.weight_g
        FROM meal_entries me
        WHERE me.entry_date >= CURRENT_DATE - INTERVAL '7 days'
    LOOP
        -- Insert amino acids for this meal entry
        INSERT INTO UserAminoIntake(user_id, date, amino_acid_id, amount)
        SELECT 
            rec.user_id,
            rec.entry_date,
            nm.amino_acid_id,
            COALESCE(fn.amount_per_100g, 0) * COALESCE(nm.factor, 1.0) * (rec.weight_g / 100.0)
        FROM FoodNutrient fn
        JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = rec.food_id
        AND nm.amino_acid_id IS NOT NULL
        ON CONFLICT (user_id, date, amino_acid_id) DO UPDATE
        SET amount = UserAminoIntake.amount + EXCLUDED.amount;
    END LOOP;
    
    RAISE NOTICE 'Recalculated UserAminoIntake from meal_entries';
END $$;

COMMIT;

