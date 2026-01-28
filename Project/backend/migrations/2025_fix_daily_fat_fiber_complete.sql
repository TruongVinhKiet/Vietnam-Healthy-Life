-- Migration: Complete fix for daily fat and fiber requirements
-- This migration:
-- 1. Ensures FattyAcidRequirement has TOTAL_FAT entry
-- 2. Fixes calculate_daily_nutrient_intake to map nutrient codes correctly
-- 3. Populates UserFiberRequirement and UserFattyAcidRequirement for all users

BEGIN;

-- ============================================================
-- Step 1: Ensure TOTAL_FAT requirement exists in FattyAcidRequirement
-- ============================================================
INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT fa.fatty_acid_id, NULL, NULL, NULL, NULL, 'g', FALSE, TRUE, 30, 'Total fat: default 30% of energy (range 25-35%)'
FROM FattyAcid fa 
WHERE fa.code = 'TOTAL_FAT' 
  AND NOT EXISTS (
    SELECT 1 FROM FattyAcidRequirement fr 
    WHERE fr.fatty_acid_id = fa.fatty_acid_id
  );

-- ============================================================
-- Step 2: Ensure TOTAL_FIBER requirement exists in FiberRequirement
-- ============================================================
INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT f.fiber_id, NULL, NULL, NULL, 25, 'g', FALSE, FALSE, NULL, 'WHO/FAO recommended total dietary fiber (general adult guidance ~25 g/day)'
FROM Fiber f
WHERE f.code = 'TOTAL_FIBER'
  AND NOT EXISTS (
    SELECT 1 FROM FiberRequirement fr 
    WHERE fr.fiber_id = f.fiber_id
  );

-- ============================================================
-- Step 3: Fix calculate_daily_nutrient_intake function with proper nutrient code mapping
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
    amino_acid_intake AS (
        SELECT 
            'amino_acid'::VARCHAR(20) as nutrient_type,
            aa.amino_acid_id::INT as nutrient_id,
            aa.code as nutrient_code,
            aa.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(uar.recommended, 0) as target_amount,
            'mg'::VARCHAR(20) as unit,
            CASE 
                WHEN COALESCE(uar.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(uar.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM AminoAcid aa
        LEFT JOIN UserAminoRequirement uar ON uar.amino_acid_id = aa.amino_acid_id AND uar.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(aa.code)
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY aa.amino_acid_id, aa.code, aa.name, uar.recommended
    ),
    fiber_intake AS (
        SELECT 
            'fiber'::VARCHAR(20) as nutrient_type,
            f.fiber_id::INT as nutrient_id,
            f.code as nutrient_code,
            f.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(ufr.recommended, 0) as target_amount,
            f.unit,
            CASE 
                WHEN COALESCE(ufr.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(ufr.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Fiber f
        LEFT JOIN UserFiberRequirement ufr ON ufr.fiber_id = f.fiber_id AND ufr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(
            CASE f.code
                WHEN 'TOTAL_FIBER' THEN 'FIBTG'
                WHEN 'SOLUBLE_FIBER' THEN 'FIB_SOL'
                WHEN 'INSOLUBLE_FIBER' THEN 'FIB_INSOL'
                WHEN 'RESISTANT_STARCH' THEN 'FIB_RS'
                WHEN 'BETA_GLUCAN' THEN 'FIB_BGLU'
                ELSE f.code
            END
        )
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY f.fiber_id, f.code, f.name, f.unit, ufr.recommended
    ),
    fatty_acid_intake AS (
        SELECT 
            'fatty_acid'::VARCHAR(20) as nutrient_type,
            fa.fatty_acid_id::INT as nutrient_id,
            fa.code as nutrient_code,
            fa.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(ufar.recommended, 0) as target_amount,
            fa.unit,
            CASE 
                WHEN COALESCE(ufar.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(ufar.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM FattyAcid fa
        LEFT JOIN UserFattyAcidRequirement ufar ON ufar.fatty_acid_id = fa.fatty_acid_id AND ufar.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(
            CASE fa.code
                WHEN 'TOTAL_FAT' THEN 'FAT'
                WHEN 'SFA' THEN 'FASAT'
                WHEN 'MUFA' THEN 'FAMS'
                WHEN 'PUFA' THEN 'FAPU'
                WHEN 'ALA' THEN 'FA18_3N3'
                WHEN 'EPA' THEN 'FAEPA'
                WHEN 'DHA' THEN 'FADHA'
                WHEN 'EPA_DHA' THEN 'FAEPA_DHA'
                WHEN 'LA' THEN 'FA18_2N6C'
                WHEN 'TRANS_FAT' THEN 'FATRN'
                ELSE fa.code
            END
        )
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY fa.fatty_acid_id, fa.code, fa.name, fa.unit, ufar.recommended
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

-- ============================================================
-- Step 4: Populate UserFiberRequirement and UserFattyAcidRequirement for all existing users
-- ============================================================
DO $$
DECLARE
    v_user RECORD;
    v_fiber_count INT := 0;
    v_fatty_count INT := 0;
BEGIN
    RAISE NOTICE 'Starting to populate UserFiberRequirement and UserFattyAcidRequirement for all users...';
    
    FOR v_user IN SELECT user_id FROM "User" LOOP
        BEGIN
            PERFORM refresh_user_fiber_requirements(v_user.user_id);
            v_fiber_count := v_fiber_count + 1;
            
            PERFORM refresh_user_fatty_requirements(v_user.user_id);
            v_fatty_count := v_fatty_count + 1;
            
            IF (v_fiber_count + v_fatty_count) % 20 = 0 THEN
                RAISE NOTICE 'Processed % users...', v_fiber_count;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Error processing user %: %', v_user.user_id, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Completed populating requirements for % users', v_fiber_count;
END $$;

-- ============================================================
-- Step 5: Verify the data was populated
-- ============================================================
DO $$
DECLARE
    v_fiber_count INT;
    v_fatty_count INT;
    v_user_count INT;
    v_total_fat_count INT;
    v_total_fiber_count INT;
BEGIN
    SELECT COUNT(*) INTO v_user_count FROM "User";
    SELECT COUNT(*) INTO v_fiber_count FROM UserFiberRequirement;
    SELECT COUNT(*) INTO v_fatty_count FROM UserFattyAcidRequirement;
    
    -- Check specifically for TOTAL_FAT and TOTAL_FIBER
    SELECT COUNT(*) INTO v_total_fat_count 
    FROM UserFattyAcidRequirement ufar
    JOIN FattyAcid fa ON fa.fatty_acid_id = ufar.fatty_acid_id
    WHERE fa.code = 'TOTAL_FAT';
    
    SELECT COUNT(*) INTO v_total_fiber_count 
    FROM UserFiberRequirement ufr
    JOIN Fiber f ON f.fiber_id = ufr.fiber_id
    WHERE f.code = 'TOTAL_FIBER';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE 'Total users: %', v_user_count;
    RAISE NOTICE 'UserFiberRequirement records: %', v_fiber_count;
    RAISE NOTICE 'UserFattyAcidRequirement records: %', v_fatty_count;
    RAISE NOTICE 'TOTAL_FIBER requirements: %', v_total_fiber_count;
    RAISE NOTICE 'TOTAL_FAT requirements: %', v_total_fat_count;
    RAISE NOTICE '========================================';
END $$;

COMMIT;

