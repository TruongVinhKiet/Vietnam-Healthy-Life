-- Seed Fiber and Fatty Acid Requirements (Fixed Codes)
BEGIN;

-- ============================================================
-- FIBER REQUIREMENTS (using actual codes)
-- ============================================================

-- TOTAL_FIBER
INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, NULL, 1, 3, 19, 'g', 'AI for children 1-3 years'
FROM Fiber WHERE code = 'TOTAL_FIBER' ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, NULL, 4, 8, 25, 'g', 'AI for children 4-8 years'
FROM Fiber WHERE code = 'TOTAL_FIBER' ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'male', 9, 13, 31, 'g', 'AI for males 9-13 years'
FROM Fiber WHERE code = 'TOTAL_FIBER' ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'male', 14, 18, 38, 'g', 'AI for males 14-18 years'
FROM Fiber WHERE code = 'TOTAL_FIBER' ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'male', 19, 50, 38, 'g', 'AI for adult males 19-50'
FROM Fiber WHERE code = 'TOTAL_FIBER' ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'male', 51, 120, 30, 'g', 'AI for males 51+'
FROM Fiber WHERE code = 'TOTAL_FIBER' ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'female', 9, 13, 26, 'g', 'AI for females 9-13 years'
FROM Fiber WHERE code = 'TOTAL_FIBER' ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'female', 14, 18, 26, 'g', 'AI for females 14-18 years'
FROM Fiber WHERE code = 'TOTAL_FIBER' ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'female', 19, 50, 25, 'g', 'AI for adult females 19-50'
FROM Fiber WHERE code = 'TOTAL_FIBER' ON CONFLICT DO NOTHING;

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fiber_id, 'female', 51, 120, 21, 'g', 'AI for females 51+'
FROM Fiber WHERE code = 'TOTAL_FIBER' ON CONFLICT DO NOTHING;

-- ============================================================
-- FATTY ACID REQUIREMENTS
-- ============================================================

-- SATURATED FAT - limit to <10% of total energy
INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_energy_pct, energy_pct, notes)
SELECT fatty_acid_id, NULL, 0, 120, 10, '% energy', TRUE, 10.0, 'Limit saturated fat to less than 10% of total energy'
FROM FattyAcid WHERE code = 'SATURATED' ON CONFLICT DO NOTHING;

-- TRANS FAT - limit to <1% of total energy
INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_energy_pct, energy_pct, notes)
SELECT fatty_acid_id, NULL, 0, 120, 1, '% energy', TRUE, 1.0, 'Limit trans fat to less than 1% of total energy'
FROM FattyAcid WHERE code = 'TRANS' ON CONFLICT DO NOTHING;

-- OMEGA-3 (ALA) - g/day
INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 1, 3, 0.7, 'g', 'AI for boys 1-3 years'
FROM FattyAcid WHERE code = 'OMEGA3' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 4, 8, 0.9, 'g', 'AI for boys 4-8 years'
FROM FattyAcid WHERE code = 'OMEGA3' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 9, 13, 1.2, 'g', 'AI for boys 9-13 years'
FROM FattyAcid WHERE code = 'OMEGA3' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 14, 120, 1.6, 'g', 'AI for males 14+ years'
FROM FattyAcid WHERE code = 'OMEGA3' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 1, 3, 0.7, 'g', 'AI for girls 1-3 years'
FROM FattyAcid WHERE code = 'OMEGA3' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 4, 8, 0.9, 'g', 'AI for girls 4-8 years'
FROM FattyAcid WHERE code = 'OMEGA3' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 9, 13, 1.0, 'g', 'AI for girls 9-13 years'
FROM FattyAcid WHERE code = 'OMEGA3' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 14, 120, 1.1, 'g', 'AI for females 14+ years'
FROM FattyAcid WHERE code = 'OMEGA3' ON CONFLICT DO NOTHING;

-- OMEGA-6 (LA) - g/day
INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 1, 3, 7, 'g', 'AI for boys 1-3 years'
FROM FattyAcid WHERE code = 'OMEGA6' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 4, 8, 10, 'g', 'AI for boys 4-8 years'
FROM FattyAcid WHERE code = 'OMEGA6' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 9, 13, 12, 'g', 'AI for boys 9-13 years'
FROM FattyAcid WHERE code = 'OMEGA6' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'male', 14, 120, 17, 'g', 'AI for males 14+ years'
FROM FattyAcid WHERE code = 'OMEGA6' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 1, 3, 7, 'g', 'AI for girls 1-3 years'
FROM FattyAcid WHERE code = 'OMEGA6' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 4, 8, 10, 'g', 'AI for girls 4-8 years'
FROM FattyAcid WHERE code = 'OMEGA6' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 9, 13, 10, 'g', 'AI for girls 9-13 years'
FROM FattyAcid WHERE code = 'OMEGA6' ON CONFLICT DO NOTHING;

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, notes)
SELECT fatty_acid_id, 'female', 14, 120, 12, 'g', 'AI for females 14+ years'
FROM FattyAcid WHERE code = 'OMEGA6' ON CONFLICT DO NOTHING;

COMMIT;

-- Verify
SELECT 'FiberRequirement' as table_name, COUNT(*) as count FROM FiberRequirement
UNION ALL SELECT 'FattyAcidRequirement', COUNT(*) FROM FattyAcidRequirement;
