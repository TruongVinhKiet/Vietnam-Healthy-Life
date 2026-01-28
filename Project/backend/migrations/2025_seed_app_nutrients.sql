-- Seed the Nutrient table with nutrients present in the app
-- Inserts are idempotent via WHERE NOT EXISTS
BEGIN;

-- Macros used across the app and triggers
INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Energy (Calories)', 'kcal', 'ENERC_KCAL'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'ENERC_KCAL');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Protein', 'g', 'PROCNT'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'PROCNT');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Total Fat', 'g', 'FAT'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FAT');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Carbohydrate, by difference', 'g', 'CHOCDF'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'CHOCDF');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Dietary Fiber (total)', 'g', 'FIBTG'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FIBTG');

-- Fiber subtypes
INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Soluble Fiber', 'g', 'FIB_SOL'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_SOL');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Insoluble Fiber', 'g', 'FIB_INSOL'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_INSOL');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Resistant Starch', 'g', 'FIB_RS'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_RS');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Beta-Glucan', 'g', 'FIB_BGLU'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FIB_BGLU');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Cholesterol', 'mg', 'CHOLESTEROL'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'CHOLESTEROL');

-- Vitamins (match Vitamin.code so vitamin detail enrichment can find foods)
INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin A', 'µg', 'VITA'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITA');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin D', 'IU', 'VITD'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITD');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin E', 'mg', 'VITE'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITE');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin K', 'µg', 'VITK'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITK');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin C', 'mg', 'VITC'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITC');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin B1 (Thiamine)', 'mg', 'VITB1'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB1');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin B2 (Riboflavin)', 'mg', 'VITB2'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB2');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin B3 (Niacin)', 'mg', 'VITB3'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB3');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin B5 (Pantothenic acid)', 'mg', 'VITB5'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB5');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin B6 (Pyridoxine)', 'mg', 'VITB6'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB6');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin B7 (Biotin)', 'µg', 'VITB7'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB7');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin B9 (Folate)', 'µg', 'VITB9'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB9');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Vitamin B12 (Cobalamin)', 'µg', 'VITB12'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'VITB12');

-- Minerals (match Mineral.code mapping logic MIN_* -> code)
INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Calcium (Ca)', 'mg', 'CA'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'CA');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Phosphorus (P)', 'mg', 'P'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'P');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Magnesium (Mg)', 'mg', 'MG'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'MG');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Potassium (K)', 'mg', 'K'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'K');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Sodium (Na)', 'mg', 'NA'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'NA');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Iron (Fe)', 'mg', 'FE'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FE');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Zinc (Zn)', 'mg', 'ZN'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'ZN');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Copper (Cu)', 'mg', 'CU'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'CU');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Manganese (Mn)', 'mg', 'MN'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'MN');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Iodine (I)', 'µg', 'I'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'I');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Selenium (Se)', 'µg', 'SE'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'SE');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Chromium (Cr)', 'µg', 'CR'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'CR');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Molybdenum (Mo)', 'µg', 'MO'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'MO');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Fluoride (F)', 'mg', 'F'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'F');

-- Fatty acid mapping-related nutrient codes used by NutrientMapping
INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Monounsaturated Fat (MUFA)', 'g', 'FAMS'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FAMS');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Polyunsaturated Fat (PUFA)', 'g', 'FAPU'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FAPU');

-- Saturated fat and trans fat
INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Saturated Fat (SFA)', 'g', 'FASAT'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FASAT');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Trans Fat (total)', 'g', 'FATRN'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FATRN');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'EPA (Eicosapentaenoic acid)', 'g', 'FAEPA'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FAEPA');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'DHA (Docosahexaenoic acid)', 'g', 'FADHA'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FADHA');

-- Combined omega-3s
INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'EPA + DHA (combined)', 'g', 'FAEPA_DHA'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FAEPA_DHA');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Linoleic acid (LA) 18:2 n-6', 'g', 'FA18_2N6C'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FA18_2N6C');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Alpha-linolenic acid (ALA) 18:3 n-3', 'g', 'FA18_3N3'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'FA18_3N3');

-- Ensure group_name is set for Home groups (idempotent)
UPDATE Nutrient
SET group_name = 'Vitamins'
WHERE UPPER(nutrient_code) IN (
	'VITA','VITD','VITE','VITK','VITC','VITB1','VITB2','VITB3','VITB5','VITB6','VITB7','VITB9','VITB12'
);

UPDATE Nutrient
SET group_name = 'Minerals'
WHERE UPPER(nutrient_code) IN (
	'CA','P','MG','K','NA','FE','ZN','CU','MN','I','SE','CR','MO','F'
);

UPDATE Nutrient
SET group_name = 'Dietary Fiber'
WHERE UPPER(nutrient_code) IN (
	'FIBTG','FIB_SOL','FIB_INSOL','FIB_RS','FIB_BGLU'
);

UPDATE Nutrient
SET group_name = 'Fat / Fatty acids'
WHERE UPPER(nutrient_code) IN (
		'FAT','FASAT','FAMS','FAPU','FA18_3N3','FAEPA','FADHA','FAEPA_DHA','FA18_2N6C','FATRN','CHOLESTEROL'
);

-- Amino acids (Essential)
INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Histidine', 'g', 'AMINO_HIS'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_HIS');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Isoleucine', 'g', 'AMINO_ILE'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_ILE');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Leucine', 'g', 'AMINO_LEU'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_LEU');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Lysine', 'g', 'AMINO_LYS'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_LYS');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Methionine', 'g', 'AMINO_MET'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_MET');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Phenylalanine', 'g', 'AMINO_PHE'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_PHE');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Threonine', 'g', 'AMINO_THR'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_THR');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Tryptophan', 'g', 'AMINO_TRP'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_TRP');

INSERT INTO Nutrient(name, unit, nutrient_code)
SELECT 'Valine', 'g', 'AMINO_VAL'
WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE UPPER(nutrient_code) = 'AMINO_VAL');

UPDATE Nutrient
SET group_name = 'Amino acids'
WHERE UPPER(nutrient_code) IN (
	'AMINO_HIS','AMINO_ILE','AMINO_LEU','AMINO_LYS','AMINO_MET','AMINO_PHE','AMINO_THR','AMINO_TRP','AMINO_VAL'
);

COMMIT;
