-- Migration: nutrient -> Fiber / FattyAcid mapping and improved MealItem intake handler
-- Purpose: create mapping table to map FoodNutrient.nutrient_id to canonical Fiber/FattyAcid entries,
-- add specific upsert helpers and replace compute_and_upsert_fiber_fattyintake() to use the mapping.

-- NutrientMapping table DDL moved to `schema.sql` (canonical table definitions centralized there).
-- This migration keeps the mapping seed INSERTs and mapping-driven functions/triggers.

-- Seed mappings for common nutrient codes (if nutrients exist)
-- FIBTG -> TOTAL_FIBER
INSERT INTO NutrientMapping(nutrient_id, fiber_id, factor, notes)
SELECT n.nutrient_id, f.fiber_id, 1.0, 'USDA FIBTG -> TOTAL_FIBER'
FROM Nutrient n CROSS JOIN Fiber f
WHERE upper(n.nutrient_code) = 'FIBTG' AND f.code = 'TOTAL_FIBER'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- FAT -> TOTAL_FAT
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FAT -> TOTAL_FAT'
FROM Nutrient n CROSS JOIN FattyAcid fa
WHERE upper(n.nutrient_code) = 'FAT' AND fa.code = 'TOTAL_FAT'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- MUFA -> FAMS mapping
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FAMS -> MUFA'
FROM Nutrient n CROSS JOIN FattyAcid fa
WHERE upper(n.nutrient_code) = 'FAMS' AND fa.code = 'MUFA'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- PUFA -> FAPU mapping
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FAPU -> PUFA'
FROM Nutrient n CROSS JOIN FattyAcid fa
WHERE upper(n.nutrient_code) = 'FAPU' AND fa.code = 'PUFA'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- EPA/DHA -> EPA_DHA (note: some datasets use FAEPA / FADHA)
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1000.0, 'FAEPA (g->mg) -> EPA_DHA'
FROM Nutrient n CROSS JOIN FattyAcid fa
WHERE upper(n.nutrient_code) IN ('FAEPA','EPA') AND fa.code = 'EPA_DHA'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1000.0, 'FADHA (g->mg) -> EPA_DHA'
FROM Nutrient n CROSS JOIN FattyAcid fa
WHERE upper(n.nutrient_code) IN ('FADHA','DHA') AND fa.code = 'EPA_DHA'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- LA and ALA common codes
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FA18_2N6C -> PUFA (LA)'
FROM Nutrient n CROSS JOIN FattyAcid fa
WHERE upper(n.nutrient_code) = 'FA18_2N6C' AND fa.code = 'PUFA'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FA18_3N3 -> PUFA (ALA)'
FROM Nutrient n CROSS JOIN FattyAcid fa
WHERE upper(n.nutrient_code) = 'FA18_3N3' AND fa.code = 'PUFA'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- Generic fallback: if nutrient name contains 'fiber' map to TOTAL_FIBER
INSERT INTO NutrientMapping(nutrient_id, fiber_id, factor, notes)
SELECT n.nutrient_id, f.fiber_id, 1.0, 'name contains fiber -> TOTAL_FIBER'
FROM Nutrient n CROSS JOIN Fiber f
WHERE (lower(n.name) LIKE '%fiber%' OR lower(n.name) LIKE '%fibre%') AND f.code = 'TOTAL_FIBER'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- Add helper: upsert for a specific fiber_id
CREATE OR REPLACE FUNCTION upsert_user_fiber_intake_specific(p_user INT, p_date DATE, p_fiber_id INT, p_amount NUMERIC) RETURNS VOID AS $$
BEGIN
    IF p_fiber_id IS NULL THEN RETURN; END IF;
    INSERT INTO UserFiberIntake(user_id, date, fiber_id, amount)
    VALUES (p_user, p_date, p_fiber_id, COALESCE(p_amount,0))
    ON CONFLICT (user_id, date, fiber_id) DO UPDATE
    SET amount = COALESCE(UserFiberIntake.amount,0) + EXCLUDED.amount;
END;
$$ LANGUAGE plpgsql;

-- Add helper: upsert for a specific fatty_acid_id
CREATE OR REPLACE FUNCTION upsert_user_fatty_intake_specific(p_user INT, p_date DATE, p_fatty_id INT, p_amount NUMERIC) RETURNS VOID AS $$
BEGIN
    IF p_fatty_id IS NULL THEN RETURN; END IF;
    INSERT INTO UserFattyAcidIntake(user_id, date, fatty_acid_id, amount)
    VALUES (p_user, p_date, p_fatty_id, COALESCE(p_amount,0))
    ON CONFLICT (user_id, date, fatty_acid_id) DO UPDATE
    SET amount = COALESCE(UserFattyAcidIntake.amount,0) + EXCLUDED.amount;
END;
$$ LANGUAGE plpgsql;

-- Replace compute_and_upsert_fiber_fattyintake to use NutrientMapping
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

    FOR rec IN
        SELECT nm.fiber_id, nm.fatty_acid_id, nm.factor, fn.amount_per_100g
        FROM FoodNutrient fn
        JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = v_food_id
    LOOP
        IF rec.fiber_id IS NOT NULL THEN
            PERFORM upsert_user_fiber_intake_specific(v_user, v_date, rec.fiber_id, COALESCE(rec.amount_per_100g,0) * COALESCE(rec.factor,1.0) * v_weight_factor);
        END IF;
        IF rec.fatty_acid_id IS NOT NULL THEN
            PERFORM upsert_user_fatty_intake_specific(v_user, v_date, rec.fatty_acid_id, COALESCE(rec.amount_per_100g,0) * COALESCE(rec.factor,1.0) * v_weight_factor);
        END IF;
    END LOOP;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Reattach trigger
DROP TRIGGER IF EXISTS trg_compute_fiber_fattyintake ON MealItem;
CREATE TRIGGER trg_compute_fiber_fattyintake
AFTER INSERT OR UPDATE OR DELETE ON MealItem
FOR EACH ROW EXECUTE FUNCTION compute_and_upsert_fiber_fattyintake();

-- Done: mapping table and improved trigger installed.
