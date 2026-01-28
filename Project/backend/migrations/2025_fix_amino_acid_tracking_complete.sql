-- Migration: Complete fix for amino acid tracking
-- Issues:
-- 1. UserAminoRequirement not populated -> percentage = 0
-- 2. UserAminoIntake not populated -> trigger not working
-- 3. Need to recalculate existing meal entries

BEGIN;

-- ============================================================
-- 1. Populate UserAminoRequirement for all existing users
-- ============================================================
DO $$
DECLARE
    u RECORD;
BEGIN
    FOR u IN SELECT user_id FROM "User" LOOP
        BEGIN
            PERFORM refresh_user_amino_requirements(u.user_id);
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Failed to refresh amino requirements for user %: %', u.user_id, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Populated UserAminoRequirement for all users';
END $$;

-- ============================================================
-- 2. Recalculate UserAminoIntake from existing meal_entries
-- ============================================================
-- This will populate UserAminoIntake for all existing meal entries
DO $$
DECLARE
    rec RECORD;
    v_amount NUMERIC;
BEGIN
    -- Loop through all meal_entries and recalculate amino acids
    FOR rec IN
        SELECT DISTINCT me.user_id, me.entry_date, me.food_id, me.weight_g
        FROM meal_entries me
        WHERE me.entry_date >= CURRENT_DATE - INTERVAL '7 days' -- Last 7 days
    LOOP
        -- Calculate amino acids for this meal entry
        FOR v_amount IN
            SELECT COALESCE(fn.amount_per_100g, 0) * COALESCE(nm.factor, 1.0) * (rec.weight_g / 100.0)
            FROM FoodNutrient fn
            JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
            WHERE fn.food_id = rec.food_id
            AND nm.amino_acid_id IS NOT NULL
        LOOP
            -- This will be handled by the trigger logic below
            NULL;
        END LOOP;
        
        -- Manually trigger the amino acid calculation
        PERFORM upsert_user_amino_intake_specific(
            rec.user_id,
            rec.entry_date,
            nm.amino_acid_id,
            COALESCE(fn.amount_per_100g, 0) * COALESCE(nm.factor, 1.0) * (rec.weight_g / 100.0)
        )
        FROM FoodNutrient fn
        JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = rec.food_id
        AND nm.amino_acid_id IS NOT NULL;
    END LOOP;
    
    RAISE NOTICE 'Recalculated UserAminoIntake from existing meal entries';
END $$;

-- ============================================================
-- 3. Ensure trigger function is correct and will work
-- ============================================================
-- Verify the trigger function exists and is correct
CREATE OR REPLACE FUNCTION compute_and_upsert_fiber_fattyintake_meal_entries() RETURNS trigger AS $$
DECLARE
    v_user INT;
    v_date DATE;
    rec RECORD;
    v_weight_factor NUMERIC;
    v_food_id INT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_user := OLD.user_id;
        v_date := OLD.entry_date;
        v_food_id := OLD.food_id;
        v_weight_factor := COALESCE(OLD.weight_g, 0) / 100.0;
    ELSE
        v_user := NEW.user_id;
        v_date := NEW.entry_date;
        v_food_id := NEW.food_id;
        v_weight_factor := COALESCE(NEW.weight_g, 0) / 100.0;
    END IF;

    IF v_food_id IS NULL OR v_user IS NULL OR v_date IS NULL THEN
        RETURN COALESCE(NEW, OLD);
    END IF;

    -- Loop through all mapped nutrients and update fiber, fatty acids, AND amino acids
    FOR rec IN
        SELECT nm.fiber_id, nm.fatty_acid_id, nm.amino_acid_id, nm.factor, fn.amount_per_100g
        FROM FoodNutrient fn
        JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = v_food_id
    LOOP
        IF rec.fiber_id IS NOT NULL THEN
            PERFORM upsert_user_fiber_intake_specific(
                v_user, 
                v_date, 
                rec.fiber_id, 
                COALESCE(rec.amount_per_100g, 0) * COALESCE(rec.factor, 1.0) * v_weight_factor
            );
        END IF;
        
        IF rec.fatty_acid_id IS NOT NULL THEN
            PERFORM upsert_user_fatty_intake_specific(
                v_user, 
                v_date, 
                rec.fatty_acid_id, 
                COALESCE(rec.amount_per_100g, 0) * COALESCE(rec.factor, 1.0) * v_weight_factor
            );
        END IF;
        
        -- CRITICAL: Add amino acid handling
        IF rec.amino_acid_id IS NOT NULL THEN
            PERFORM upsert_user_amino_intake_specific(
                v_user, 
                v_date, 
                rec.amino_acid_id, 
                COALESCE(rec.amount_per_100g, 0) * COALESCE(rec.factor, 1.0) * v_weight_factor
            );
        END IF;
    END LOOP;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 4. Recalculate UserAminoIntake properly (fix the DO block above)
-- ============================================================
-- Delete and recalculate to ensure accuracy
DELETE FROM UserAminoIntake WHERE date >= CURRENT_DATE - INTERVAL '7 days';

-- Now recalculate properly
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT me.user_id, me.entry_date, me.food_id, me.weight_g
        FROM meal_entries me
        WHERE me.entry_date >= CURRENT_DATE - INTERVAL '7 days'
    LOOP
        -- Calculate and insert amino acids for this meal entry
        PERFORM upsert_user_amino_intake_specific(
            rec.user_id,
            rec.entry_date,
            nm.amino_acid_id,
            COALESCE(fn.amount_per_100g, 0) * COALESCE(nm.factor, 1.0) * (rec.weight_g / 100.0)
        )
        FROM FoodNutrient fn
        JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = rec.food_id
        AND nm.amino_acid_id IS NOT NULL;
    END LOOP;
    
    RAISE NOTICE 'Recalculated UserAminoIntake from meal_entries';
END $$;

COMMIT;

