-- ============================================================
-- FIX MISSING SCHEMA ELEMENTS
-- Fixes missing tables and columns causing runtime errors
-- Date: 2025-11-19
-- ============================================================

BEGIN;

-- ============================================================
-- 1. CREATE MISSING VITAMINNUTRIENT MAPPING TABLE
-- Maps USDA Nutrient IDs to canonical Vitamin IDs
-- ============================================================

CREATE TABLE IF NOT EXISTS VitaminNutrient (
    vitamin_nutrient_id SERIAL PRIMARY KEY,
    vitamin_id INT NOT NULL REFERENCES Vitamin(vitamin_id) ON DELETE CASCADE,
    nutrient_id INT NOT NULL REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
    amount NUMERIC(10,3) DEFAULT 0,  -- amount per 100g
    factor NUMERIC(10,6) DEFAULT 1.0, -- conversion factor if needed
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(vitamin_id, nutrient_id)
);

CREATE INDEX IF NOT EXISTS idx_vitamin_nutrient_vitamin ON VitaminNutrient(vitamin_id);
CREATE INDEX IF NOT EXISTS idx_vitamin_nutrient_nutrient ON VitaminNutrient(nutrient_id);

-- ============================================================
-- 2. CREATE MISSING MINERALNUTRIENT MAPPING TABLE
-- Maps USDA Nutrient IDs to canonical Mineral IDs
-- ============================================================

CREATE TABLE IF NOT EXISTS MineralNutrient (
    mineral_nutrient_id SERIAL PRIMARY KEY,
    mineral_id INT NOT NULL REFERENCES Mineral(mineral_id) ON DELETE CASCADE,
    nutrient_id INT NOT NULL REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
    amount NUMERIC(10,3) DEFAULT 0,  -- amount per 100g
    factor NUMERIC(10,6) DEFAULT 1.0, -- conversion factor if needed
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(mineral_id, nutrient_id)
);

CREATE INDEX IF NOT EXISTS idx_mineral_nutrient_mineral ON MineralNutrient(mineral_id);
CREATE INDEX IF NOT EXISTS idx_mineral_nutrient_nutrient ON MineralNutrient(nutrient_id);

-- ============================================================
-- 3. ADD MISSING medication_details COLUMN TO MedicationSchedule
-- ============================================================

ALTER TABLE MedicationSchedule 
ADD COLUMN IF NOT EXISTS medication_details JSONB DEFAULT '{}'::jsonb;

COMMENT ON COLUMN MedicationSchedule.medication_details IS 'JSON object containing medication name, dosage, instructions, etc.';

-- ============================================================
-- 4. ADD MISSING is_deleted COLUMN TO ADMIN TABLES
-- ============================================================

ALTER TABLE Admin 
ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

-- ============================================================
-- 5. POPULATE VITAMINNUTRIENT MAPPING TABLE
-- Map common USDA nutrient codes to Vitamin table entries
-- ============================================================

-- Vitamin A (Retinol)
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin A'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITA' 
  AND n.nutrient_code IN ('VITA_RAE', 'RETOL')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin D
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin D'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITD' 
  AND n.nutrient_code IN ('VITD', 'CHOCAL')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin E
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin E'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITE' 
  AND n.nutrient_code IN ('TOCPHA', 'VITE')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin K
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin K'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITK' 
  AND n.nutrient_code IN ('VITK1', 'VITK')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin C
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin C'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITC' 
  AND n.nutrient_code IN ('VITC', 'ASC')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin B1 (Thiamine)
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin B1'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITB1' 
  AND n.nutrient_code IN ('THIA', 'VITB1')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin B2 (Riboflavin)
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin B2'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITB2' 
  AND n.nutrient_code IN ('RIBF', 'VITB2')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin B3 (Niacin)
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin B3'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITB3' 
  AND n.nutrient_code IN ('NIA', 'VITB3')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin B5 (Pantothenic acid)
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin B5'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITB5' 
  AND n.nutrient_code IN ('PANTAC', 'VITB5')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin B6 (Pyridoxine)
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin B6'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITB6' 
  AND n.nutrient_code IN ('VITB6A', 'VITB6')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin B7 (Biotin)
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin B7'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITB7' 
  AND n.nutrient_code IN ('BIOT', 'VITB7')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin B9 (Folate)
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin B9'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITB9' 
  AND n.nutrient_code IN ('FOL', 'FOLAC', 'FOLDFE')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- Vitamin B12 (Cobalamin)
INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
SELECT 
    v.vitamin_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Vitamin B12'
FROM Vitamin v
CROSS JOIN Nutrient n
WHERE v.code = 'VITB12' 
  AND n.nutrient_code IN ('VITB12', 'COBA')
  AND NOT EXISTS (
    SELECT 1 FROM VitaminNutrient vn 
    WHERE vn.vitamin_id = v.vitamin_id AND vn.nutrient_id = n.nutrient_id
  );

-- ============================================================
-- 6. POPULATE MINERALNUTRIENT MAPPING TABLE
-- Map common USDA nutrient codes to Mineral table entries
-- ============================================================

-- Calcium
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Calcium'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'CA' 
  AND n.nutrient_code IN ('CA', 'CALCIUM')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Phosphorus
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Phosphorus'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'P' 
  AND n.nutrient_code IN ('P', 'PHOS')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Magnesium
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Magnesium'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'MG' 
  AND n.nutrient_code IN ('MG', 'MAGNESIUM')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Potassium
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Potassium'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'K' 
  AND n.nutrient_code IN ('K', 'POTASSIUM')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Sodium
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Sodium'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'NA' 
  AND n.nutrient_code IN ('NA', 'SODIUM')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Iron
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Iron'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'FE' 
  AND n.nutrient_code IN ('FE', 'IRON')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Zinc
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Zinc'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'ZN' 
  AND n.nutrient_code IN ('ZN', 'ZINC')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Copper
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Copper'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'CU' 
  AND n.nutrient_code IN ('CU', 'COPPER')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Manganese
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Manganese'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'MN' 
  AND n.nutrient_code IN ('MN', 'MANGANESE')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Selenium
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Selenium'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'SE' 
  AND n.nutrient_code IN ('SE', 'SELENIUM')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Iodine
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Iodine'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'I' 
  AND n.nutrient_code IN ('ID', 'IODINE')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Chromium
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Chromium'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'CR' 
  AND n.nutrient_code IN ('CR', 'CHROMIUM')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Molybdenum
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Molybdenum'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'MO' 
  AND n.nutrient_code IN ('MO', 'MOLYBDENUM')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- Fluoride
INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
SELECT 
    m.mineral_id,
    n.nutrient_id,
    1.0,
    'USDA ' || n.nutrient_code || ' -> Fluoride'
FROM Mineral m
CROSS JOIN Nutrient n
WHERE m.code = 'F' 
  AND n.nutrient_code IN ('FD', 'FLUORIDE')
  AND NOT EXISTS (
    SELECT 1 FROM MineralNutrient mn 
    WHERE mn.mineral_id = m.mineral_id AND mn.nutrient_id = n.nutrient_id
  );

-- ============================================================
-- 7. UPDATE calculate_daily_nutrient_intake FUNCTION
-- Fix the function to properly calculate vitamin/mineral intake
-- ============================================================

CREATE OR REPLACE FUNCTION calculate_daily_nutrient_intake(
    p_user_id INT,
    p_date DATE
) RETURNS TABLE(
    nutrient_type VARCHAR(20),
    nutrient_id INT,
    nutrient_name VARCHAR(100),
    total_amount NUMERIC(10,3),
    target_amount NUMERIC(10,3),
    unit VARCHAR(20),
    percent_of_target NUMERIC(5,2)
) AS $$
BEGIN
    RETURN QUERY
    -- Vitamins
    SELECT 
        'vitamin'::VARCHAR(20) as nutrient_type,
        v.vitamin_id as nutrient_id,
        v.name::VARCHAR(100) as nutrient_name,
        COALESCE(SUM(fn.amount_per_100g * mi.weight_g / 100.0), 0)::NUMERIC(10,3) as total_amount,
        COALESCE(uvr.recommended, v.recommended_daily, 0)::NUMERIC(10,3) as target_amount,
        COALESCE(v.unit, 'mg')::VARCHAR(20) as unit,
        CASE 
            WHEN COALESCE(uvr.recommended, v.recommended_daily, 0) > 0 THEN 
                (COALESCE(SUM(fn.amount_per_100g * mi.weight_g / 100.0), 0) / COALESCE(uvr.recommended, v.recommended_daily) * 100)::NUMERIC(5,2)
            ELSE 0::NUMERIC(5,2)
        END as percent_of_target
    FROM Vitamin v
    LEFT JOIN VitaminNutrient vn ON v.vitamin_id = vn.vitamin_id
    LEFT JOIN FoodNutrient fn ON vn.nutrient_id = fn.nutrient_id
    LEFT JOIN MealItem mi ON fn.food_id = mi.food_id
    LEFT JOIN Meal m ON mi.meal_id = m.meal_id AND m.user_id = p_user_id AND m.meal_date = p_date
    LEFT JOIN UserVitaminRequirement uvr ON v.vitamin_id = uvr.vitamin_id AND uvr.user_id = p_user_id
    GROUP BY v.vitamin_id, v.name, v.unit, v.recommended_daily, uvr.recommended
    
    UNION ALL
    
    -- Minerals
    SELECT 
        'mineral'::VARCHAR(20),
        min.mineral_id,
        min.name::VARCHAR(100),
        COALESCE(SUM(fn.amount_per_100g * mi.weight_g / 100.0), 0)::NUMERIC(10,3),
        COALESCE(umr.recommended, min.recommended_daily, 0)::NUMERIC(10,3),
        COALESCE(min.unit, 'mg')::VARCHAR(20),
        CASE 
            WHEN COALESCE(umr.recommended, min.recommended_daily, 0) > 0 THEN 
                (COALESCE(SUM(fn.amount_per_100g * mi.weight_g / 100.0), 0) / COALESCE(umr.recommended, min.recommended_daily) * 100)::NUMERIC(5,2)
            ELSE 0::NUMERIC(5,2)
        END
    FROM Mineral min
    LEFT JOIN MineralNutrient mn ON min.mineral_id = mn.mineral_id
    LEFT JOIN FoodNutrient fn ON mn.nutrient_id = fn.nutrient_id
    LEFT JOIN MealItem mi ON fn.food_id = mi.food_id
    LEFT JOIN Meal m ON mi.meal_id = m.meal_id AND m.user_id = p_user_id AND m.meal_date = p_date
    LEFT JOIN UserMineralRequirement umr ON min.mineral_id = umr.mineral_id AND umr.user_id = p_user_id
    GROUP BY min.mineral_id, min.name, min.unit, min.recommended_daily, umr.recommended;
END;
$$ LANGUAGE plpgsql;

COMMIT;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

DO $$
DECLARE
    v_vitamin_nutrient_count INT;
    v_mineral_nutrient_count INT;
    v_medication_column_exists BOOLEAN;
    v_admin_column_exists BOOLEAN;
BEGIN
    SELECT COUNT(*) INTO v_vitamin_nutrient_count FROM VitaminNutrient;
    SELECT COUNT(*) INTO v_mineral_nutrient_count FROM MineralNutrient;
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'medicationschedule' AND column_name = 'medication_details'
    ) INTO v_medication_column_exists;
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'admin' AND column_name = 'is_deleted'
    ) INTO v_admin_column_exists;
    
    RAISE NOTICE '=== MIGRATION RESULTS ===';
    RAISE NOTICE 'VitaminNutrient mappings: %', v_vitamin_nutrient_count;
    RAISE NOTICE 'MineralNutrient mappings: %', v_mineral_nutrient_count;
    RAISE NOTICE 'MedicationSchedule.medication_details exists: %', v_medication_column_exists;
    RAISE NOTICE 'Admin.is_deleted exists: %', v_admin_column_exists;
    RAISE NOTICE '========================';
END $$;
