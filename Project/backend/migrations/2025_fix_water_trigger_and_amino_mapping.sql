-- Migration: Fix water trigger and add amino acid mappings
-- Issues:
-- 1. Water trigger using wrong column name (logged_at instead of log_date)
-- 2. NutrientMapping missing amino acid mappings (needed for trigger to work)

BEGIN;

-- ============================================================
-- 1. Fix water trigger - use log_date instead of logged_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_water_intake_from_waterlog()
RETURNS TRIGGER AS $$
BEGIN
    -- When add/edit WaterLog, update Water_Intake
    INSERT INTO Water_Intake (user_id, date, today_water_ml, from_drinks_ml, last_updated)
    VALUES (
        NEW.user_id,
        NEW.log_date,  -- FIXED: Use log_date instead of DATE(NEW.logged_at)
        NEW.amount_ml,
        NEW.amount_ml,
        NOW()
    )
    ON CONFLICT (user_id, date) 
    DO UPDATE SET
        today_water_ml = Water_Intake.today_water_ml + (NEW.amount_ml - COALESCE(OLD.amount_ml, 0)),
        from_drinks_ml = Water_Intake.from_drinks_ml + (NEW.amount_ml - COALESCE(OLD.amount_ml, 0)),
        last_updated = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 2. Add amino acid mappings to NutrientMapping table
-- ============================================================
-- Map AMINO_LEU -> LEU
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_LEU (g->mg) -> LEU'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_LEU' AND UPPER(aa.code) = 'LEU'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- Map AMINO_LYS -> LYS
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_LYS (g->mg) -> LYS'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_LYS' AND UPPER(aa.code) = 'LYS'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- Map AMINO_VAL -> VAL
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_VAL (g->mg) -> VAL'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_VAL' AND UPPER(aa.code) = 'VAL'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- Map AMINO_ILE -> ILE
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_ILE (g->mg) -> ILE'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_ILE' AND UPPER(aa.code) = 'ILE'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- Map AMINO_MET -> MET
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_MET (g->mg) -> MET'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_MET' AND UPPER(aa.code) = 'MET'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- Map AMINO_TRP -> TRP
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_TRP (g->mg) -> TRP'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_TRP' AND UPPER(aa.code) = 'TRP'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- Map AMINO_HIS -> HIS
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_HIS (g->mg) -> HIS'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_HIS' AND UPPER(aa.code) = 'HIS'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- Map AMINO_PHE -> PHE
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_PHE (g->mg) -> PHE'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_PHE' AND UPPER(aa.code) = 'PHE'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- Map AMINO_THR -> THR
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_THR (g->mg) -> THR'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_THR' AND UPPER(aa.code) = 'THR'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id);

-- ============================================================
-- 3. Ensure trigger function has amino acid handling
-- ============================================================
-- Recreate the meal_entries trigger function to include amino acids
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

-- Ensure trigger exists
DROP TRIGGER IF EXISTS trg_compute_fiber_fattyintake_meal_entries ON meal_entries;
CREATE TRIGGER trg_compute_fiber_fattyintake_meal_entries
AFTER INSERT OR UPDATE OR DELETE ON meal_entries
FOR EACH ROW EXECUTE FUNCTION compute_and_upsert_fiber_fattyintake_meal_entries();

COMMIT;

