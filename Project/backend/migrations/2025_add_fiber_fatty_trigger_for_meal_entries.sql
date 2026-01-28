-- Migration: Add trigger for meal_entries to compute fiber and fatty acid intake
-- This ensures that when dishes are added (which insert into meal_entries),
-- fiber and fatty acids are properly calculated and stored

BEGIN;

-- Create function to compute fiber and fatty acid intake from meal_entries
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

    -- Calculate fiber and fatty acid intake from FoodNutrient using NutrientMapping
    FOR rec IN
        SELECT nm.fiber_id, nm.fatty_acid_id, nm.factor, fn.amount_per_100g
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
    END LOOP;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create trigger on meal_entries table
DROP TRIGGER IF EXISTS trg_compute_fiber_fattyintake_meal_entries ON meal_entries;
CREATE TRIGGER trg_compute_fiber_fattyintake_meal_entries
AFTER INSERT OR UPDATE OR DELETE ON meal_entries
FOR EACH ROW EXECUTE FUNCTION compute_and_upsert_fiber_fattyintake_meal_entries();

COMMIT;

