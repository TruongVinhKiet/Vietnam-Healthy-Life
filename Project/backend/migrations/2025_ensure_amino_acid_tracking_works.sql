-- Migration: Ensure amino acid tracking works correctly
-- This fixes the issue where amino acids show 0% even after adding meals
-- 
-- Issues to fix:
-- 1. Ensure NutrientMapping has amino_acid_id mappings
-- 2. Ensure trigger function includes amino acids
-- 3. Ensure calculate_daily_nutrient_intake reads from UserAminoIntake

BEGIN;

-- ============================================================
-- 1. Ensure NutrientMapping has amino_acid_id column
-- ============================================================
ALTER TABLE NutrientMapping
ADD COLUMN IF NOT EXISTS amino_acid_id INT REFERENCES AminoAcid(amino_acid_id) ON DELETE CASCADE;

-- ============================================================
-- 2. Ensure amino acid mappings exist in NutrientMapping
-- ============================================================
-- Map AMINO_LEU -> LEU
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_LEU (g->mg) -> LEU'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_LEU' AND UPPER(aa.code) = 'LEU'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id AND amino_acid_id = aa.amino_acid_id);

-- Map AMINO_LYS -> LYS
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_LYS (g->mg) -> LYS'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_LYS' AND UPPER(aa.code) = 'LYS'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id AND amino_acid_id = aa.amino_acid_id);

-- Map AMINO_VAL -> VAL
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_VAL (g->mg) -> VAL'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_VAL' AND UPPER(aa.code) = 'VAL'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id AND amino_acid_id = aa.amino_acid_id);

-- Map AMINO_ILE -> ILE
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_ILE (g->mg) -> ILE'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_ILE' AND UPPER(aa.code) = 'ILE'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id AND amino_acid_id = aa.amino_acid_id);

-- Map AMINO_MET -> MET
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_MET (g->mg) -> MET'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_MET' AND UPPER(aa.code) = 'MET'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id AND amino_acid_id = aa.amino_acid_id);

-- Map AMINO_TRP -> TRP
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_TRP (g->mg) -> TRP'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_TRP' AND UPPER(aa.code) = 'TRP'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id AND amino_acid_id = aa.amino_acid_id);

-- Map AMINO_HIS -> HIS
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_HIS (g->mg) -> HIS'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_HIS' AND UPPER(aa.code) = 'HIS'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id AND amino_acid_id = aa.amino_acid_id);

-- Map AMINO_PHE -> PHE
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_PHE (g->mg) -> PHE'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_PHE' AND UPPER(aa.code) = 'PHE'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id AND amino_acid_id = aa.amino_acid_id);

-- Map AMINO_THR -> THR
INSERT INTO NutrientMapping(nutrient_id, amino_acid_id, factor, notes)
SELECT n.nutrient_id, aa.amino_acid_id, 1000.0, 'AMINO_THR (g->mg) -> THR'
FROM Nutrient n CROSS JOIN AminoAcid aa
WHERE UPPER(n.nutrient_code) = 'AMINO_THR' AND UPPER(aa.code) = 'THR'
  AND NOT EXISTS (SELECT 1 FROM NutrientMapping WHERE nutrient_id = n.nutrient_id AND amino_acid_id = aa.amino_acid_id);

-- ============================================================
-- 3. Ensure helper function exists
-- ============================================================
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

-- ============================================================
-- 4. Ensure trigger function includes amino acids
-- ============================================================
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
-- 5. Ensure trigger exists
-- ============================================================
DROP TRIGGER IF EXISTS trg_compute_fiber_fattyintake_meal_entries ON meal_entries;
CREATE TRIGGER trg_compute_fiber_fattyintake_meal_entries
AFTER INSERT OR UPDATE OR DELETE ON meal_entries
FOR EACH ROW EXECUTE FUNCTION compute_and_upsert_fiber_fattyintake_meal_entries();

-- ============================================================
-- 6. Ensure calculate_daily_nutrient_intake reads from UserAminoIntake
-- ============================================================
DROP FUNCTION IF EXISTS calculate_daily_nutrient_intake(INT, DATE);

CREATE OR REPLACE FUNCTION calculate_daily_nutrient_intake(
    p_user_id INT,
    p_date DATE
) RETURNS TABLE(
    nutrient_type VARCHAR(20),
    nutrient_id INT,
    nutrient_code VARCHAR(50),
    nutrient_name VARCHAR(100),
    current_amount NUMERIC,
    target_amount NUMERIC,
    unit VARCHAR(20),
    percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH meal_items_today AS (
        SELECT me.food_id, me.weight_g
        FROM meal_entries me
        WHERE me.user_id = p_user_id AND me.entry_date = p_date
        UNION ALL
        SELECT mi.food_id, mi.weight_g
        FROM MealItem mi
        JOIN Meal m ON m.meal_id = mi.meal_id
        WHERE m.user_id = p_user_id AND m.meal_date = p_date
    ),
    vitamin_intake AS (
        SELECT 
            'vitamin'::VARCHAR(20) as nutrient_type,
            v.vitamin_id::INT as nutrient_id,
            v.code as nutrient_code,
            v.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(uvr.recommended, v.recommended_daily::NUMERIC, 0) as target_amount,
            v.unit,
            CASE 
                WHEN COALESCE(uvr.recommended, v.recommended_daily::NUMERIC, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(uvr.recommended, v.recommended_daily::NUMERIC, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Vitamin v
        LEFT JOIN UserVitaminRequirement uvr ON uvr.vitamin_id = v.vitamin_id AND uvr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY v.vitamin_id, v.code, v.name, v.unit, v.recommended_daily, uvr.recommended
    ),
    mineral_intake AS (
        SELECT 
            'mineral'::VARCHAR(20) as nutrient_type,
            m.mineral_id::INT as nutrient_id,
            m.code as nutrient_code,
            m.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(umr.recommended, m.recommended_daily::NUMERIC, 0) as target_amount,
            m.unit,
            CASE 
                WHEN COALESCE(umr.recommended, m.recommended_daily::NUMERIC, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(umr.recommended, m.recommended_daily::NUMERIC, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Mineral m
        LEFT JOIN UserMineralRequirement umr ON umr.mineral_id = m.mineral_id AND umr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(REPLACE(m.code, 'MIN_', ''))
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY m.mineral_id, m.code, m.name, m.unit, m.recommended_daily, umr.recommended
    ),
    -- CRITICAL: Read from UserAminoIntake (populated by trigger) + UserNutrientManualLog
    amino_acid_intake AS (
        SELECT 
            'amino_acid'::VARCHAR(20) as nutrient_type,
            aa.amino_acid_id::INT as nutrient_id,
            aa.code as nutrient_code,
            aa.name as nutrient_name,
            -- Sum from UserAminoIntake (trigger-populated) + UserNutrientManualLog (manual/AI)
            COALESCE(
                (SELECT SUM(uai.amount) FROM UserAminoIntake uai
                 WHERE uai.user_id = p_user_id AND uai.date = p_date AND uai.amino_acid_id = aa.amino_acid_id),
                0
            ) + COALESCE(
                (SELECT SUM(unml.amount) FROM UserNutrientManualLog unml
                 WHERE unml.user_id = p_user_id AND unml.log_date = p_date 
                 AND unml.nutrient_type = 'amino_acid' AND unml.nutrient_id = aa.amino_acid_id),
                0
            ) as current_amount,
            COALESCE(uar.recommended, 0) as target_amount,
            'mg'::VARCHAR(20) as unit,
            CASE 
                WHEN COALESCE(uar.recommended, 0) > 0 
                THEN (
                    (COALESCE(
                        (SELECT SUM(uai.amount) FROM UserAminoIntake uai
                         WHERE uai.user_id = p_user_id AND uai.date = p_date AND uai.amino_acid_id = aa.amino_acid_id),
                        0
                    ) + COALESCE(
                        (SELECT SUM(unml.amount) FROM UserNutrientManualLog unml
                         WHERE unml.user_id = p_user_id AND unml.log_date = p_date 
                         AND unml.nutrient_type = 'amino_acid' AND unml.nutrient_id = aa.amino_acid_id),
                        0
                    )) / COALESCE(uar.recommended, 1)
                ) * 100
                ELSE 0 
            END as percentage
        FROM AminoAcid aa
        LEFT JOIN UserAminoRequirement uar ON uar.amino_acid_id = aa.amino_acid_id AND uar.user_id = p_user_id
    ),
    fiber_intake AS (
        SELECT 
            'fiber'::VARCHAR(20) as nutrient_type,
            f.fiber_id::INT as nutrient_id,
            f.code as nutrient_code,
            f.name as nutrient_name,
            COALESCE(ufi.amount, 0) as current_amount,
            COALESCE(ufr.recommended, 0) as target_amount,
            f.unit,
            CASE 
                WHEN COALESCE(ufr.recommended, 0) > 0 
                THEN (COALESCE(ufi.amount, 0) / COALESCE(ufr.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Fiber f
        LEFT JOIN UserFiberRequirement ufr ON ufr.fiber_id = f.fiber_id AND ufr.user_id = p_user_id
        LEFT JOIN UserFiberIntake ufi ON ufi.fiber_id = f.fiber_id AND ufi.user_id = p_user_id AND ufi.date = p_date
    ),
    fatty_acid_intake AS (
        SELECT 
            'fatty_acid'::VARCHAR(20) as nutrient_type,
            fa.fatty_acid_id::INT as nutrient_id,
            fa.code as nutrient_code,
            fa.name as nutrient_name,
            COALESCE(ufai.amount, 0) as current_amount,
            COALESCE(ufar.recommended, 0) as target_amount,
            fa.unit,
            CASE 
                WHEN COALESCE(ufar.recommended, 0) > 0 
                THEN (COALESCE(ufai.amount, 0) / COALESCE(ufar.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM FattyAcid fa
        LEFT JOIN UserFattyAcidRequirement ufar ON ufar.fatty_acid_id = fa.fatty_acid_id AND ufar.user_id = p_user_id
        LEFT JOIN UserFattyAcidIntake ufai ON ufai.fatty_acid_id = fa.fatty_acid_id AND ufai.user_id = p_user_id AND ufai.date = p_date
    )
    SELECT * FROM vitamin_intake
    UNION ALL
    SELECT * FROM mineral_intake
    UNION ALL
    SELECT * FROM amino_acid_intake
    UNION ALL
    SELECT * FROM fiber_intake
    UNION ALL
    SELECT * FROM fatty_acid_intake;
END;
$$ LANGUAGE plpgsql;

COMMIT;

