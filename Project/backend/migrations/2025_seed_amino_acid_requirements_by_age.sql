-- Migration: Seed Amino Acid Requirements by Age Groups (WHO/FAO standards)
-- Based on WHO/FAO/UNU 2007 report: Protein and amino acid requirements in human nutrition
-- Requirements are in mg per kg body weight per day
-- Reference: FiberRequirement structure for age/sex-specific requirements

BEGIN;

-- Clear existing generic requirements (those without age ranges)
-- We'll replace them with age-specific ones
DELETE FROM AminoRequirement WHERE age_min IS NULL AND age_max IS NULL;

-- ============================================================
-- HISTIDINE (HIS) - 14 mg/kg/day for adults
-- ============================================================
-- Infants 0-6 months: 28 mg/kg (higher requirement)
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 0, 0, 28, 'mg', TRUE, 'WHO/FAO requirement for infants 0-6 months'
FROM AminoAcid WHERE code = 'HIS'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months: 20 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 1, 20, 'mg', TRUE, 'WHO/FAO requirement for infants 7-12 months'
FROM AminoAcid WHERE code = 'HIS'
ON CONFLICT DO NOTHING;

-- Children 1-3 years: 16 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 3, 16, 'mg', TRUE, 'WHO/FAO requirement for children 1-3 years'
FROM AminoAcid WHERE code = 'HIS'
ON CONFLICT DO NOTHING;

-- Children 4-8 years: 15 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 4, 8, 15, 'mg', TRUE, 'WHO/FAO requirement for children 4-8 years'
FROM AminoAcid WHERE code = 'HIS'
ON CONFLICT DO NOTHING;

-- Adults 19+ years: 14 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 19, 120, 14, 'mg', TRUE, 'WHO/FAO adult requirement 14 mg/kg/day'
FROM AminoAcid WHERE code = 'HIS'
ON CONFLICT DO NOTHING;

-- ============================================================
-- ISOLEUCINE (ILE) - 19 mg/kg/day for adults
-- ============================================================
-- Infants 0-6 months: 46 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 0, 0, 46, 'mg', TRUE, 'WHO/FAO requirement for infants 0-6 months'
FROM AminoAcid WHERE code = 'ILE'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months: 43 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 1, 43, 'mg', TRUE, 'WHO/FAO requirement for infants 7-12 months'
FROM AminoAcid WHERE code = 'ILE'
ON CONFLICT DO NOTHING;

-- Children 1-3 years: 28 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 3, 28, 'mg', TRUE, 'WHO/FAO requirement for children 1-3 years'
FROM AminoAcid WHERE code = 'ILE'
ON CONFLICT DO NOTHING;

-- Children 4-8 years: 22 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 4, 8, 22, 'mg', TRUE, 'WHO/FAO requirement for children 4-8 years'
FROM AminoAcid WHERE code = 'ILE'
ON CONFLICT DO NOTHING;

-- Adults 19+ years: 19 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 19, 120, 19, 'mg', TRUE, 'WHO/FAO adult requirement 19 mg/kg/day'
FROM AminoAcid WHERE code = 'ILE'
ON CONFLICT DO NOTHING;

-- ============================================================
-- LEUCINE (LEU) - 42 mg/kg/day for adults
-- ============================================================
-- Infants 0-6 months: 93 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 0, 0, 93, 'mg', TRUE, 'WHO/FAO requirement for infants 0-6 months'
FROM AminoAcid WHERE code = 'LEU'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months: 89 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 1, 89, 'mg', TRUE, 'WHO/FAO requirement for infants 7-12 months'
FROM AminoAcid WHERE code = 'LEU'
ON CONFLICT DO NOTHING;

-- Children 1-3 years: 63 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 3, 63, 'mg', TRUE, 'WHO/FAO requirement for children 1-3 years'
FROM AminoAcid WHERE code = 'LEU'
ON CONFLICT DO NOTHING;

-- Children 4-8 years: 49 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 4, 8, 49, 'mg', TRUE, 'WHO/FAO requirement for children 4-8 years'
FROM AminoAcid WHERE code = 'LEU'
ON CONFLICT DO NOTHING;

-- Adults 19+ years: 42 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 19, 120, 42, 'mg', TRUE, 'WHO/FAO adult requirement 42 mg/kg/day'
FROM AminoAcid WHERE code = 'LEU'
ON CONFLICT DO NOTHING;

-- ============================================================
-- LYSINE (LYS) - 30 mg/kg/day for adults
-- ============================================================
-- Infants 0-6 months: 66 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 0, 0, 66, 'mg', TRUE, 'WHO/FAO requirement for infants 0-6 months'
FROM AminoAcid WHERE code = 'LYS'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months: 64 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 1, 64, 'mg', TRUE, 'WHO/FAO requirement for infants 7-12 months'
FROM AminoAcid WHERE code = 'LYS'
ON CONFLICT DO NOTHING;

-- Children 1-3 years: 58 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 3, 58, 'mg', TRUE, 'WHO/FAO requirement for children 1-3 years'
FROM AminoAcid WHERE code = 'LYS'
ON CONFLICT DO NOTHING;

-- Children 4-8 years: 45 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 4, 8, 45, 'mg', TRUE, 'WHO/FAO requirement for children 4-8 years'
FROM AminoAcid WHERE code = 'LYS'
ON CONFLICT DO NOTHING;

-- Adults 19+ years: 30 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 19, 120, 30, 'mg', TRUE, 'WHO/FAO adult requirement 30 mg/kg/day'
FROM AminoAcid WHERE code = 'LYS'
ON CONFLICT DO NOTHING;

-- ============================================================
-- METHIONINE (MET) - 15 mg/kg/day for adults (Met + Cys combined)
-- ============================================================
-- Infants 0-6 months: 33 mg/kg (Met + Cys)
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 0, 0, 33, 'mg', TRUE, 'WHO/FAO requirement for infants 0-6 months (Met + Cys)'
FROM AminoAcid WHERE code = 'MET'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months: 30 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 1, 30, 'mg', TRUE, 'WHO/FAO requirement for infants 7-12 months (Met + Cys)'
FROM AminoAcid WHERE code = 'MET'
ON CONFLICT DO NOTHING;

-- Children 1-3 years: 27 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 3, 27, 'mg', TRUE, 'WHO/FAO requirement for children 1-3 years (Met + Cys)'
FROM AminoAcid WHERE code = 'MET'
ON CONFLICT DO NOTHING;

-- Children 4-8 years: 21 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 4, 8, 21, 'mg', TRUE, 'WHO/FAO requirement for children 4-8 years (Met + Cys)'
FROM AminoAcid WHERE code = 'MET'
ON CONFLICT DO NOTHING;

-- Adults 19+ years: 15 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 19, 120, 15, 'mg', TRUE, 'WHO/FAO adult requirement 15 mg/kg/day (Met + Cys)'
FROM AminoAcid WHERE code = 'MET'
ON CONFLICT DO NOTHING;

-- ============================================================
-- PHENYLALANINE (PHE) - 25 mg/kg/day for adults (Phe + Tyr combined)
-- ============================================================
-- Infants 0-6 months: 52 mg/kg (Phe + Tyr)
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 0, 0, 52, 'mg', TRUE, 'WHO/FAO requirement for infants 0-6 months (Phe + Tyr)'
FROM AminoAcid WHERE code = 'PHE'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months: 46 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 1, 46, 'mg', TRUE, 'WHO/FAO requirement for infants 7-12 months (Phe + Tyr)'
FROM AminoAcid WHERE code = 'PHE'
ON CONFLICT DO NOTHING;

-- Children 1-3 years: 41 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 3, 41, 'mg', TRUE, 'WHO/FAO requirement for children 1-3 years (Phe + Tyr)'
FROM AminoAcid WHERE code = 'PHE'
ON CONFLICT DO NOTHING;

-- Children 4-8 years: 31 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 4, 8, 31, 'mg', TRUE, 'WHO/FAO requirement for children 4-8 years (Phe + Tyr)'
FROM AminoAcid WHERE code = 'PHE'
ON CONFLICT DO NOTHING;

-- Adults 19+ years: 25 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 19, 120, 25, 'mg', TRUE, 'WHO/FAO adult requirement 25 mg/kg/day (Phe + Tyr)'
FROM AminoAcid WHERE code = 'PHE'
ON CONFLICT DO NOTHING;

-- ============================================================
-- THREONINE (THR) - 15 mg/kg/day for adults
-- ============================================================
-- Infants 0-6 months: 43 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 0, 0, 43, 'mg', TRUE, 'WHO/FAO requirement for infants 0-6 months'
FROM AminoAcid WHERE code = 'THR'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months: 35 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 1, 35, 'mg', TRUE, 'WHO/FAO requirement for infants 7-12 months'
FROM AminoAcid WHERE code = 'THR'
ON CONFLICT DO NOTHING;

-- Children 1-3 years: 34 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 3, 34, 'mg', TRUE, 'WHO/FAO requirement for children 1-3 years'
FROM AminoAcid WHERE code = 'THR'
ON CONFLICT DO NOTHING;

-- Children 4-8 years: 28 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 4, 8, 28, 'mg', TRUE, 'WHO/FAO requirement for children 4-8 years'
FROM AminoAcid WHERE code = 'THR'
ON CONFLICT DO NOTHING;

-- Adults 19+ years: 15 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 19, 120, 15, 'mg', TRUE, 'WHO/FAO adult requirement 15 mg/kg/day'
FROM AminoAcid WHERE code = 'THR'
ON CONFLICT DO NOTHING;

-- ============================================================
-- TRYPTOPHAN (TRP) - 4 mg/kg/day for adults
-- ============================================================
-- Infants 0-6 months: 12.5 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 0, 0, 12.5, 'mg', TRUE, 'WHO/FAO requirement for infants 0-6 months'
FROM AminoAcid WHERE code = 'TRP'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months: 11 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 1, 11, 'mg', TRUE, 'WHO/FAO requirement for infants 7-12 months'
FROM AminoAcid WHERE code = 'TRP'
ON CONFLICT DO NOTHING;

-- Children 1-3 years: 8.5 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 3, 8.5, 'mg', TRUE, 'WHO/FAO requirement for children 1-3 years'
FROM AminoAcid WHERE code = 'TRP'
ON CONFLICT DO NOTHING;

-- Children 4-8 years: 6.6 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 4, 8, 6.6, 'mg', TRUE, 'WHO/FAO requirement for children 4-8 years'
FROM AminoAcid WHERE code = 'TRP'
ON CONFLICT DO NOTHING;

-- Adults 19+ years: 4 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 19, 120, 4, 'mg', TRUE, 'WHO/FAO adult requirement 4 mg/kg/day'
FROM AminoAcid WHERE code = 'TRP'
ON CONFLICT DO NOTHING;

-- ============================================================
-- VALINE (VAL) - 26 mg/kg/day for adults
-- ============================================================
-- Infants 0-6 months: 55 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 0, 0, 55, 'mg', TRUE, 'WHO/FAO requirement for infants 0-6 months'
FROM AminoAcid WHERE code = 'VAL'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months: 49 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 1, 49, 'mg', TRUE, 'WHO/FAO requirement for infants 7-12 months'
FROM AminoAcid WHERE code = 'VAL'
ON CONFLICT DO NOTHING;

-- Children 1-3 years: 37 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 1, 3, 37, 'mg', TRUE, 'WHO/FAO requirement for children 1-3 years'
FROM AminoAcid WHERE code = 'VAL'
ON CONFLICT DO NOTHING;

-- Children 4-8 years: 29 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 4, 8, 29, 'mg', TRUE, 'WHO/FAO requirement for children 4-8 years'
FROM AminoAcid WHERE code = 'VAL'
ON CONFLICT DO NOTHING;

-- Adults 19+ years: 26 mg/kg
INSERT INTO AminoRequirement(amino_acid_id, sex, age_min, age_max, amount, unit, per_kg, notes)
SELECT amino_acid_id, NULL, 19, 120, 26, 'mg', TRUE, 'WHO/FAO adult requirement 26 mg/kg/day'
FROM AminoAcid WHERE code = 'VAL'
ON CONFLICT DO NOTHING;

COMMIT;

-- Verify counts
SELECT 
  aa.code,
  COUNT(*) as requirement_count,
  MIN(age_min) as min_age,
  MAX(age_max) as max_age
FROM AminoRequirement ar
JOIN AminoAcid aa ON aa.amino_acid_id = ar.amino_acid_id
GROUP BY aa.code
ORDER BY aa.code;

