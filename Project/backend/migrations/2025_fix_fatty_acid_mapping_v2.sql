-- Migration: Fix NutrientMapping for ALA, LA, EPA, DHA fatty acids
-- Problem: NutrientMapping has unique constraint on nutrient_id
-- Solution: Update existing mappings or insert new rows for different fatty_acid_id

BEGIN;

-- Drop unique constraint on nutrient_id if exists (allow multiple mappings per nutrient)
ALTER TABLE NutrientMapping DROP CONSTRAINT IF EXISTS nutrientmapping_nutrient_id_key;

-- Now add the missing mappings

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

