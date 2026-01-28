-- Migration: Fix amino acid tracking and water log trigger
-- Issues:
-- 1. UserAminoIntake table missing date column (needed for daily tracking)
-- 2. Water log trigger using wrong column name (NEW.id instead of NEW.water_log_id)
-- 3. calculate_daily_nutrient_intake not reading from UserAminoIntake table
-- 4. AI analysis accept not inserting into UserAminoIntake

BEGIN;

-- ============================================================
-- 1. Add date column to UserAminoIntake table
-- ============================================================
ALTER TABLE UserAminoIntake
ADD COLUMN IF NOT EXISTS date DATE;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_amino_intake_user_date 
ON UserAminoIntake(user_id, date);

-- Add unique constraint for user_id, date, amino_acid_id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'ux_user_amino_intake_user_date_amino'
    ) THEN
        ALTER TABLE UserAminoIntake
        ADD CONSTRAINT ux_user_amino_intake_user_date_amino 
        UNIQUE (user_id, date, amino_acid_id);
    END IF;
END $$;

-- Update existing records to set date from recorded_at
UPDATE UserAminoIntake
SET date = DATE(recorded_at)
WHERE date IS NULL AND recorded_at IS NOT NULL;

-- Set default date for future records
ALTER TABLE UserAminoIntake
ALTER COLUMN date SET DEFAULT CURRENT_DATE;

-- ============================================================
-- 2. Fix water log trigger - use water_log_id instead of id
-- ============================================================
CREATE OR REPLACE FUNCTION trg_log_water_logged() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'water_logged', 'waterlog', NEW.water_log_id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 3. Update calculate_daily_nutrient_intake to read from UserAminoIntake
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
    -- Calculate nutrient intake from meals for all nutrient types
    -- Use meal_entries (new system) UNION MealItem (old system for backward compatibility)
    RETURN QUERY
    WITH meal_items_today AS (
        -- New system: meal_entries
        SELECT me.food_id, me.weight_g
        FROM meal_entries me
        WHERE me.user_id = p_user_id AND me.entry_date = p_date
        UNION ALL
        -- Old system: MealItem (for backward compatibility)
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
    -- FIXED: Read from UserAminoIntake (populated by trigger) instead of recalculating from FoodNutrient
    -- Also include manual intake from UserNutrientManualLog for amino acids
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
    -- Read from UserFiberIntake (populated by trigger) instead of recalculating from FoodNutrient
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
    -- Read from UserFattyAcidIntake (populated by trigger) instead of recalculating from FoodNutrient
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

