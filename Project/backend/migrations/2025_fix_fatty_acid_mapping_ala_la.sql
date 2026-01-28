-- Migration: Fix NutrientMapping for ALA and LA fatty acids
-- Add mappings for FA18_3N3 -> ALA and FA18_2N6C -> LA

BEGIN;

-- FA18_3N3 should map to ALA (not just PUFA)
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FA18_3N3 -> ALA (Alpha-Linolenic Acid)'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'FA18_3N3' 
AND UPPER(fa.code) = 'ALA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- FA18_2N6C should map to LA (not just PUFA)
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FA18_2N6C -> LA (Linoleic Acid)'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'FA18_2N6C' 
AND UPPER(fa.code) = 'LA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- FAEPA should also map to EPA separately
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FAEPA -> EPA'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'FAEPA' 
AND UPPER(fa.code) = 'EPA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

-- FADHA should also map to DHA separately
INSERT INTO NutrientMapping(nutrient_id, fatty_acid_id, factor, notes)
SELECT n.nutrient_id, fa.fatty_acid_id, 1.0, 'FADHA -> DHA'
FROM Nutrient n 
CROSS JOIN FattyAcid fa
WHERE UPPER(n.nutrient_code) = 'FADHA' 
AND UPPER(fa.code) = 'DHA'
AND NOT EXISTS (
    SELECT 1 FROM NutrientMapping nm 
    WHERE nm.nutrient_id = n.nutrient_id AND nm.fatty_acid_id = fa.fatty_acid_id
);

COMMIT;

-- Verify
SELECT nm.nutrient_id, n.nutrient_code, nm.fatty_acid_id, fa.code as fatty_acid_code
FROM NutrientMapping nm
JOIN Nutrient n ON n.nutrient_id = nm.nutrient_id
JOIN FattyAcid fa ON fa.fatty_acid_id = nm.fatty_acid_id
WHERE nm.fatty_acid_id IS NOT NULL
ORDER BY fa.code;

