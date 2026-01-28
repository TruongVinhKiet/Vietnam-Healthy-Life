-- Migration: Fix amino acid age matching and populate requirements
-- Issue: User age 18 doesn't match adult requirements (age_min = 19)
-- Solution: Update logic to handle age 18 as adult, and populate requirements

BEGIN;

-- ============================================================
-- 1. Fix compute_user_amino_requirement to handle age 18
-- ============================================================
CREATE OR REPLACE FUNCTION compute_user_amino_requirement(p_user_id INT, p_amino_id INT)
RETURNS TABLE(base NUMERIC, multiplier NUMERIC, recommended NUMERIC, unit TEXT) AS $$
DECLARE
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
    v_per_kg BOOLEAN;
BEGIN
    -- Get user info
    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;
    IF v_age IS NULL THEN v_age := 25; END IF; -- Default age if null
    IF v_weight IS NULL THEN v_weight := 70; END IF; -- Default weight if null

    -- Pick the most specific AminoRequirement row matching sex/age
    -- FIX: Treat age 18 as adult (age >= 19)
    SELECT ar.amount, ar.unit, ar.per_kg INTO v_base, v_unit, v_per_kg
    FROM AminoRequirement ar
    WHERE ar.amino_acid_id = p_amino_id
      AND (ar.sex IS NULL OR lower(ar.sex) = lower(COALESCE(v_gender,'')) OR lower(ar.sex) = 'both')
      AND (
        (ar.age_min IS NULL AND ar.age_max IS NULL) OR 
        (v_age BETWEEN COALESCE(ar.age_min, -9999) AND COALESCE(ar.age_max, 99999)) OR
        (v_age >= 18 AND ar.age_min = 19) -- Treat 18 as adult
      )
    ORDER BY 
      CASE WHEN v_age >= 18 AND ar.age_min = 19 THEN 0 ELSE 1 END, -- Prefer adult for age 18
      (ar.age_min IS NOT NULL) DESC, 
      (ar.age_max IS NOT NULL) DESC
    LIMIT 1;

    IF v_base IS NULL THEN
        RETURN; -- no recommendation available
    END IF;

    -- activity and goal heuristics
    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.2, 0.20 );
    END IF;
    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN v_mult := v_mult + 0.03; 
        ELSIF lower(v_goal) = 'gain_weight' THEN v_mult := v_mult - 0.01; 
        END IF;
    END IF;
    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN v_mult := v_mult + 0.02; END IF;

    -- compute final recommended number, handling per-kg
    IF v_per_kg = TRUE THEN
        RETURN QUERY SELECT v_base, v_mult, ROUND(v_base * v_weight * v_mult, 3), v_unit;
    ELSE
        RETURN QUERY SELECT v_base, v_mult, ROUND(v_base * v_mult, 3), v_unit;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 2. Populate UserAminoRequirement for all users
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
-- 3. Recalculate UserAminoIntake from ALL meal_entries (not just today)
-- ============================================================
-- Clear existing data for last 30 days
DELETE FROM UserAminoIntake WHERE date >= CURRENT_DATE - INTERVAL '30 days';

-- Recalculate from meal_entries
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT me.user_id, me.entry_date, me.food_id, me.weight_g
        FROM meal_entries me
        WHERE me.entry_date >= CURRENT_DATE - INTERVAL '30 days'
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

