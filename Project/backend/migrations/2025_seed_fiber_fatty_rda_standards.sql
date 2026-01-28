-- Migration: Seed Fiber and Fatty Acid requirements based on DRI standards
-- Age and sex-specific recommended daily allowances

BEGIN;

-- ============================================================
-- FIBER REQUIREMENTS
-- ============================================================

-- Total Fiber (FIBTG) - g/day

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, NULL, 0, 0, 0, 'g', 'Not established for infants 0-6 months'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, NULL, 1, 1, 0, 'g', 'Not established for infants 7-12 months'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, NULL, 1, 3, 19, 'g', 'AI for children 1-3 years'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, NULL, 4, 8, 25, 'g', 'AI for children 4-8 years'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'male', 9, 13, 31, 'g', 'AI for males 9-13 years'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'male', 14, 18, 38, 'g', 'AI for males 14-18 years'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'male', 19, 50, 38, 'g', 'AI for adult males 19-50'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'male', 51, 120, 30, 'g', 'AI for males 51+'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'female', 9, 13, 26, 'g', 'AI for females 9-13 years'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'female', 14, 18, 26, 'g', 'AI for females 14-18 years'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'female', 19, 50, 25, 'g', 'AI for adult females 19-50'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'female', 51, 120, 21, 'g', 'AI for females 51+'
FROM Fiber WHERE UPPER(code) = 'FIBTG'
ON CONFLICT DO NOTHING;

-- ============================================================
-- FATTY ACID REQUIREMENTS
-- ============================================================

-- Omega-3 (ALA - Alpha-linolenic acid) - g/day

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 19, 120, 1.6, 'g', 'AI for adult males'
FROM FattyAcid WHERE UPPER(code) = 'FA18_3N3'
ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 19, 120, 1.1, 'g', 'AI for adult females'
FROM FattyAcid WHERE UPPER(code) = 'FA18_3N3'
ON CONFLICT DO NOTHING;

-- Omega-6 (LA - Linoleic acid) - g/day

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 19, 50, 17, 'g', 'AI for adult males 19-50'
FROM FattyAcid WHERE UPPER(code) = 'FA18_2N6C'
ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 51, 120, 14, 'g', 'AI for males 51+'
FROM FattyAcid WHERE UPPER(code) = 'FA18_2N6C'
ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 19, 50, 12, 'g', 'AI for adult females 19-50'
FROM FattyAcid WHERE UPPER(code) = 'FA18_2N6C'
ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 51, 120, 11, 'g', 'AI for females 51+'
FROM FattyAcid WHERE UPPER(code) = 'FA18_2N6C'
ON CONFLICT DO NOTHING;

-- EPA + DHA combined recommendation - mg/day
-- Note: WHO recommends 250-500mg EPA+DHA per day for cardiovascular health

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, NULL, 19, 120, 250, 'mg', 'WHO recommendation for cardiovascular health (minimum)'
FROM FattyAcid WHERE UPPER(code) = 'FAEPA_DHA'
ON CONFLICT DO NOTHING;

-- Individual EPA - mg/day (optional)

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, NULL, 19, 120, 125, 'mg', 'Approximate EPA contribution (half of combined rec)'
FROM FattyAcid WHERE UPPER(code) = 'FAEPA'
ON CONFLICT DO NOTHING;

-- Individual DHA - mg/day (optional)

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, NULL, 19, 120, 125, 'mg', 'Approximate DHA contribution (half of combined rec)'
FROM FattyAcid WHERE UPPER(code) = 'FADHA'
ON CONFLICT DO NOTHING;

-- Total PUFA (Polyunsaturated Fatty Acids) - % of energy
-- Typically 5-10% of total energy intake

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, is_energy_pct, energy_pct, unit, notes)
SELECT fatty_acid_id, NULL, 19, 120, 0, TRUE, 0.075, '%', 'AMDR: 5-10% of energy (7.5% midpoint)'
FROM FattyAcid WHERE UPPER(code) = 'FAPU'
ON CONFLICT DO NOTHING;

-- Total MUFA (Monounsaturated Fatty Acids) - % of energy
-- Fill remainder of fat intake (typically 10-15%)

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, is_energy_pct, energy_pct, unit, notes)
SELECT fatty_acid_id, NULL, 19, 120, 0, TRUE, 0.125, '%', 'AMDR: 10-15% of energy (12.5% midpoint)'
FROM FattyAcid WHERE UPPER(code) = 'FAMS'
ON CONFLICT DO NOTHING;

COMMIT;
