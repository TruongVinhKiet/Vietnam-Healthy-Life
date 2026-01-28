-- Migration: Add amino acid tracking to meal triggers
-- This fixes the issue where fiber/fatty acid tracking works but amino acids don't update

BEGIN;

-- Add amino_acid_id column to NutrientMapping table
ALTER TABLE NutrientMapping
ADD COLUMN IF NOT EXISTS amino_acid_id INT REFERENCES AminoAcid(amino_acid_id) ON DELETE CASCADE;

-- Create helper function to upsert amino acid intake
CREATE OR REPLACE FUNCTION upsert_user_amino_intake_specific(
    p_user INT,
    p_date DATE,
    p_amino_id INT,
    p_amount NUMERIC
) RETURNS VOID AS $$
BEGIN
    IF p_amino_id IS NULL THEN RETURN; END IF;

    INSERT INTO UserAminoIntake(user_id, date, amino_acid_id, amount)
    VALUES (p_user, p_date, p_amino_id, COALESCE(p_amount, 0))
    ON CONFLICT (user_id, date, amino_acid_id) DO UPDATE
    SET amount = COALESCE(UserAminoIntake.amount, 0) + EXCLUDED.amount;
END;
$$ LANGUAGE plpgsql;

-- Update the MealItem trigger function to include amino acids
CREATE OR REPLACE FUNCTION compute_and_upsert_fiber_fattyintake() RETURNS trigger AS $$
DECLARE
    v_user INT;
    v_date DATE;
    rec RECORD;
    v_weight_factor NUMERIC;
    v_food_id INT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = OLD.meal_id;
        v_food_id := OLD.food_id;
        v_weight_factor := OLD.weight_g / 100.0;
    ELSE
        SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = NEW.meal_id;
        v_food_id := NEW.food_id;
        v_weight_factor := NEW.weight_g / 100.0;
    END IF;

    IF v_food_id IS NULL OR v_user IS NULL OR v_date IS NULL THEN
        RETURN NULL;
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
        
        -- ADD AMINO ACID HANDLING
        IF rec.amino_acid_id IS NOT NULL THEN
            PERFORM upsert_user_amino_intake_specific(
                v_user, 
                v_date, 
                rec.amino_acid_id, 
                COALESCE(rec.amount_per_100g, 0) * COALESCE(rec.factor, 1.0) * v_weight_factor
            );
        END IF;
    END LOOP;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Update the meal_entries trigger function to include amino acids
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
        
        -- ADD AMINO ACID HANDLING
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

-- Recreate triggers to use updated functions
DROP TRIGGER IF EXISTS trg_compute_fiber_fattyintake ON MealItem;
CREATE TRIGGER trg_compute_fiber_fattyintake
AFTER INSERT OR UPDATE OR DELETE ON MealItem
FOR EACH ROW EXECUTE FUNCTION compute_and_upsert_fiber_fattyintake();

DROP TRIGGER IF EXISTS trg_compute_fiber_fattyintake_meal_entries ON meal_entries;
CREATE TRIGGER trg_compute_fiber_fattyintake_meal_entries
AFTER INSERT OR UPDATE OR DELETE ON meal_entries
FOR EACH ROW EXECUTE FUNCTION compute_and_upsert_fiber_fattyintake_meal_entries();

COMMIT;
