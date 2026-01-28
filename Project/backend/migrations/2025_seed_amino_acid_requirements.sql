-- Seed AminoRequirement table with WHO/FAO standards
-- Essential amino acids requirements in mg/kg body weight per day

BEGIN;

-- Histidine (HIS): 14 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, NULL, NULL, 14, 'mg', TRUE, 'WHO/FAO adult requirement 14 mg/kg/day'
FROM AminoAcid WHERE code = 'HIS'
AND NOT EXISTS (SELECT 1 FROM AminoRequirement ar WHERE ar.amino_acid_id = (SELECT amino_acid_id FROM AminoAcid WHERE code = 'HIS'));

-- Isoleucine (ILE): 19 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, NULL, NULL, 19, 'mg', TRUE, 'WHO/FAO adult requirement 19 mg/kg/day'
FROM AminoAcid WHERE code = 'ILE'
AND NOT EXISTS (SELECT 1 FROM AminoRequirement ar WHERE ar.amino_acid_id = (SELECT amino_acid_id FROM AminoAcid WHERE code = 'ILE'));

-- Leucine (LEU): 42 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, NULL, NULL, 42, 'mg', TRUE, 'WHO/FAO adult requirement 42 mg/kg/day'
FROM AminoAcid WHERE code = 'LEU'
AND NOT EXISTS (SELECT 1 FROM AminoRequirement ar WHERE ar.amino_acid_id = (SELECT amino_acid_id FROM AminoAcid WHERE code = 'LEU'));

-- Lysine (LYS): 30 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, NULL, NULL, 30, 'mg', TRUE, 'WHO/FAO adult requirement 30 mg/kg/day'
FROM AminoAcid WHERE code = 'LYS'
AND NOT EXISTS (SELECT 1 FROM AminoRequirement ar WHERE ar.amino_acid_id = (SELECT amino_acid_id FROM AminoAcid WHERE code = 'LYS'));

-- Methionine (MET): 15 mg/kg (combined with cysteine)
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, NULL, NULL, 15, 'mg', TRUE, 'WHO/FAO adult requirement 15 mg/kg/day (Met + Cys)'
FROM AminoAcid WHERE code = 'MET'
AND NOT EXISTS (SELECT 1 FROM AminoRequirement ar WHERE ar.amino_acid_id = (SELECT amino_acid_id FROM AminoAcid WHERE code = 'MET'));

-- Phenylalanine (PHE): 25 mg/kg (combined with tyrosine)
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, NULL, NULL, 25, 'mg', TRUE, 'WHO/FAO adult requirement 25 mg/kg/day (Phe + Tyr)'
FROM AminoAcid WHERE code = 'PHE'
AND NOT EXISTS (SELECT 1 FROM AminoRequirement ar WHERE ar.amino_acid_id = (SELECT amino_acid_id FROM AminoAcid WHERE code = 'PHE'));

-- Threonine (THR): 15 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, NULL, NULL, 15, 'mg', TRUE, 'WHO/FAO adult requirement 15 mg/kg/day'
FROM AminoAcid WHERE code = 'THR'
AND NOT EXISTS (SELECT 1 FROM AminoRequirement ar WHERE ar.amino_acid_id = (SELECT amino_acid_id FROM AminoAcid WHERE code = 'THR'));

-- Tryptophan (TRP): 4 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, NULL, NULL, 4, 'mg', TRUE, 'WHO/FAO adult requirement 4 mg/kg/day'
FROM AminoAcid WHERE code = 'TRP'
AND NOT EXISTS (SELECT 1 FROM AminoRequirement ar WHERE ar.amino_acid_id = (SELECT amino_acid_id FROM AminoAcid WHERE code = 'TRP'));

-- Valine (VAL): 26 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, NULL, NULL, 26, 'mg', TRUE, 'WHO/FAO adult requirement 26 mg/kg/day'
FROM AminoAcid WHERE code = 'VAL'
AND NOT EXISTS (SELECT 1 FROM AminoRequirement ar WHERE ar.amino_acid_id = (SELECT amino_acid_id FROM AminoAcid WHERE code = 'VAL'));

COMMIT;

-- Verify
SELECT COUNT(*) as requirement_count FROM AminoRequirement;
