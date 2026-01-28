-- Migration: Fix NutrientMapping for Fiber and FattyAcid
-- Problem: NutrientMapping doesn't map individual fiber/fat nutrient codes to their respective Fiber/FattyAcid tables
-- Solution: Add proper mappings so trigger can calculate intake correctly

BEGIN;

-- ============================================================
-- FIBER MAPPINGS
-- Map nutrient codes to Fiber table entries
-- ============================================================

-- RESISTANT_STARCH -> Resistant Starch fiber
INSERT INTO NutrientMapping(nutrient_id, fiber_id, factor, notes)
SELECT n.nutrient_id, f.fiber_id, 1.0, 'RESISTANT_STARCH -> Resistant Starch'
FROM Nutrient n 
CROSS JOIN Fiber f
WHERE UPPER(n.nutrient_code) = 'RESISTANT_STARCH' 
AND UPPER(f.code) = 'RESISTANT_STARCH'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fiber_id = f.fiber_id
);

-- Also try FIB_RS
INSERT INTO NutrientMapping(nutrient_id, fiber_id, factor, notes)
SELECT n.nutrient_id, f.fiber_id, 1.0, 'FIB_RS -> Resistant Starch'
FROM Nutrient n 
CROSS JOIN Fiber f
WHERE UPPER(n.nutrient_code) = 'FIB_RS' 
AND UPPER(f.code) = 'RESISTANT_STARCH'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fiber_id = f.fiber_id
);

-- BETA_GLUCAN -> Beta-Glucan fiber
INSERT INTO NutrientMapping(nutrient_id, fiber_id, factor, notes)
SELECT n.nutrient_id, f.fiber_id, 1.0, 'BETA_GLUCAN -> Beta-Glucan'
FROM Nutrient n 
CROSS JOIN Fiber f
WHERE UPPER(n.nutrient_code) = 'BETA_GLUCAN' 
AND UPPER(f.code) = 'BETA_GLUCAN'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fiber_id = f.fiber_id
);

-- Also try FIB_BGLU
INSERT INTO NutrientMapping(nutrient_id, fiber_id, factor, notes)
SELECT n.nutrient_id, f.fiber_id, 1.0, 'FIB_BGLU -> Beta-Glucan'
FROM Nutrient n 
CROSS JOIN Fiber f
WHERE UPPER(n.nutrient_code) = 'FIB_BGLU' 
AND UPPER(f.code) = 'BETA_GLUCAN'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fiber_id = f.fiber_id
);

-- INSOLUBLE_FIBER -> Insoluble Fiber
INSERT INTO NutrientMapping(nutrient_id, fiber_id, factor, notes)
SELECT n.nutrient_id, f.fiber_id, 1.0, 'INSOLUBLE_FIBER -> Insoluble Fiber'
FROM Nutrient n 
CROSS JOIN Fiber f
WHERE UPPER(n.nutrient_code) = 'INSOLUBLE_FIBER' 
AND UPPER(f.code) = 'INSOLUBLE_FIBER'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fiber_id = f.fiber_id
);

-- Also update FIB_INSOL to map to INSOLUBLE_FIBER instead of TOTAL_FIBER
UPDATE NutrientMapping 
SET fiber_id = (SELECT fiber_id FROM Fiber WHERE UPPER(code) = 'INSOLUBLE_FIBER')
WHERE nutrient_id = (SELECT nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_INSOL')
AND fiber_id IS NOT NULL;

-- SOLUBLE_FIBER -> Soluble Fiber
INSERT INTO NutrientMapping(nutrient_id, fiber_id, factor, notes)
SELECT n.nutrient_id, f.fiber_id, 1.0, 'SOLUBLE_FIBER -> Soluble Fiber'
FROM Nutrient n 
CROSS JOIN Fiber f
WHERE UPPER(n.nutrient_code) = 'SOLUBLE_FIBER' 
AND UPPER(f.code) = 'SOLUBLE_FIBER'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fiber_id = f.fiber_id
);

-- Also update FIB_SOL to map to SOLUBLE_FIBER instead of TOTAL_FIBER
UPDATE NutrientMapping 
SET fiber_id = (SELECT fiber_id FROM Fiber WHERE UPPER(code) = 'SOLUBLE_FIBER')
WHERE nutrient_id = (SELECT nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_SOL')
AND fiber_id IS NOT NULL;

-- TOTAL_FIBER -> Total Dietary Fiber
INSERT INTO NutrientMapping(nutrient_id, fiber_id, factor, notes)
SELECT n.nutrient_id, f.fiber_id, 1.0, 'TOTAL_FIBER -> Total Dietary Fiber'
FROM Nutrient n 
CROSS JOIN Fiber f
WHERE UPPER(n.nutrient_code) = 'TOTAL_FIBER' 
AND UPPER(f.code) = 'TOTAL_FIBER'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fiber_id = f.fiber_id
);

-- ============================================================
-- FATTY ACID MAPPINGS
-- Map nutrient codes to FattyAcid table entries
-- ============================================================

-- ALA -> ALA
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'ALA -> ALA'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'ALA' 
AND UPPER(fa.code) = 'ALA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- EPA -> EPA
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'EPA -> EPA'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'EPA' 
AND UPPER(fa.code) = 'EPA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- DHA -> DHA
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'DHA -> DHA'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'DHA' 
AND UPPER(fa.code) = 'DHA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- EPA_DHA -> EPA_DHA
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'EPA_DHA -> EPA_DHA Combined'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'EPA_DHA' 
AND UPPER(fa.code) = 'EPA_DHA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- LA -> LA
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'LA -> LA'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'LA' 
AND UPPER(fa.code) = 'LA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- CHOLESTEROL -> CHOLESTEROL
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'CHOLESTEROL -> CHOLESTEROL'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'CHOLESTEROL' 
AND UPPER(fa.code) = 'CHOLESTEROL'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- TOTAL_FAT -> TOTAL_FAT
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'TOTAL_FAT -> TOTAL_FAT'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'TOTAL_FAT' 
AND UPPER(fa.code) = 'TOTAL_FAT'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- PUFA -> PUFA
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'PUFA -> PUFA'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'PUFA' 
AND UPPER(fa.code) = 'PUFA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- TRANS_FAT -> TRANS_FAT
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'TRANS_FAT -> TRANS_FAT'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'TRANS_FAT' 
AND UPPER(fa.code) = 'TRANS_FAT'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- MUFA -> MUFA
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'MUFA -> MUFA'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'MUFA' 
AND UPPER(fa.code) = 'MUFA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- SFA -> SFA
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'SFA -> SFA'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'SFA' 
AND UPPER(fa.code) = 'SFA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- Also map FASAT to SFA
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FASAT -> SFA'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'FASAT' 
AND UPPER(fa.code) = 'SFA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- Map FATRN to TRANS_FAT
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FATRN -> TRANS_FAT'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'FATRN' 
AND UPPER(fa.code) = 'TRANS_FAT'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- Map CHOLE to CHOLESTEROL
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'CHOLE -> CHOLESTEROL'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'CHOLE' 
AND UPPER(fa.code) = 'CHOLESTEROL'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

COMMIT;

-- Verify
SELECT 'Fiber mappings:' as info;
SELECT nm.nutrient_id, n.nutrient_code, nm.fiber_id, f.code as fiber_code
FROM NutrientMapping nm
JOIN Nutrient n ON n.nutrient_id = nm.nutrient_id
JOIN Fiber f ON f.fiber_id = nm.fiber_id
WHERE nm.fiber_id IS NOT NULL;

SELECT 'FattyAcid mappings:' as info;
SELECT nm.nutrient_id, n.nutrient_code, nm.fatty_acid_id, fa.code as fatty_acid_code
FROM NutrientMapping nm
JOIN Nutrient n ON n.nutrient_id = nm.nutrient_id
JOIN FattyAcid fa ON fa.fatty_acid_id = nm.fatty_acid_id
WHERE nm.fatty_acid_id IS NOT NULL;

