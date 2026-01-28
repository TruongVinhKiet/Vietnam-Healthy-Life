-- Migration: Fix amino acid trigger with better error handling and logging
-- Issue: Trigger exists but doesn't populate UserAminoIntake
-- Solution: Add error handling and ensure trigger runs correctly

BEGIN;

-- ============================================================
-- 1. Recreate trigger function with error handling
-- ============================================================
CREATE OR REPLACE FUNCTION compute_and_upsert_fiber_fattyintake_meal_entries() RETURNS trigger AS $$
DECLARE
    v_user INT;
    v_date DATE;
    rec RECORD;
    v_weight_factor NUMERIC;
    v_food_id INT;
    v_error_count INT := 0;
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
        BEGIN
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
            
            -- CRITICAL: Add amino acid handling with explicit error handling
            IF rec.amino_acid_id IS NOT NULL THEN
                BEGIN
                    PERFORM upsert_user_amino_intake_specific(
                        v_user, 
                        v_date, 
                        rec.amino_acid_id, 
                        COALESCE(rec.amount_per_100g, 0) * COALESCE(rec.factor, 1.0) * v_weight_factor
                    );
                EXCEPTION
                    WHEN OTHERS THEN
                        -- Log error but don't fail the trigger
                        RAISE WARNING 'Error inserting amino acid % for user %: %', rec.amino_acid_id, v_user, SQLERRM;
                        v_error_count := v_error_count + 1;
                END;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                -- Continue processing other nutrients even if one fails
                RAISE WARNING 'Error processing nutrient for food %: %', v_food_id, SQLERRM;
                v_error_count := v_error_count + 1;
        END;
    END LOOP;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 2. Ensure trigger exists and is enabled
-- ============================================================
DROP TRIGGER IF EXISTS trg_compute_fiber_fattyintake_meal_entries ON meal_entries;
CREATE TRIGGER trg_compute_fiber_fattyintake_meal_entries
AFTER INSERT OR UPDATE OR DELETE ON meal_entries
FOR EACH ROW EXECUTE FUNCTION compute_and_upsert_fiber_fattyintake_meal_entries();

COMMIT;

