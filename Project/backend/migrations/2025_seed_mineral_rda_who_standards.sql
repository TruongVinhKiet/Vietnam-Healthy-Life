-- Migration: Seed Mineral RDA data based on WHO/FDA standards
-- Age and sex-specific recommended daily allowances

BEGIN;

-- ============================================================
-- CALCIUM (Ca) - mg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 0, 0, 200, 'mg', 'AI for infants 0-6 months'
FROM Mineral WHERE UPPER(code) IN ('CA', 'MIN_CA')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 1, 1, 260, 'mg', 'AI for infants 7-12 months'
FROM Mineral WHERE UPPER(code) IN ('CA', 'MIN_CA')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 1, 3, 700, 'mg', 'RDA for children 1-3 years'
FROM Mineral WHERE UPPER(code) IN ('CA', 'MIN_CA')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 4, 8, 1000, 'mg', 'RDA for children 4-8 years'
FROM Mineral WHERE UPPER(code) IN ('CA', 'MIN_CA')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 9, 18, 1300, 'mg', 'RDA for adolescents (peak bone growth)'
FROM Mineral WHERE UPPER(code) IN ('CA', 'MIN_CA')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 19, 50, 1000, 'mg', 'RDA for adults 19-50'
FROM Mineral WHERE UPPER(code) IN ('CA', 'MIN_CA')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'male', 51, 70, 1000, 'mg', 'RDA for males 51-70'
FROM Mineral WHERE UPPER(code) IN ('CA', 'MIN_CA')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'female', 51, 120, 1200, 'mg', 'RDA for females 51+ (postmenopausal)'
FROM Mineral WHERE UPPER(code) IN ('CA', 'MIN_CA')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'male', 71, 120, 1200, 'mg', 'RDA for males 71+'
FROM Mineral WHERE UPPER(code) IN ('CA', 'MIN_CA')
ON CONFLICT DO NOTHING;

-- ============================================================
-- IRON (Fe) - mg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 0, 0, 0.27, 'mg', 'AI for infants 0-6 months'
FROM Mineral WHERE UPPER(code) IN ('FE', 'MIN_FE')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 1, 1, 11, 'mg', 'RDA for infants 7-12 months'
FROM Mineral WHERE UPPER(code) IN ('FE', 'MIN_FE')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 1, 3, 7, 'mg', 'RDA for children 1-3 years'
FROM Mineral WHERE UPPER(code) IN ('FE', 'MIN_FE')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 4, 8, 10, 'mg', 'RDA for children 4-8 years'
FROM Mineral WHERE UPPER(code) IN ('FE', 'MIN_FE')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 9, 13, 8, 'mg', 'RDA for children 9-13 years'
FROM Mineral WHERE UPPER(code) IN ('FE', 'MIN_FE')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'male', 14, 18, 11, 'mg', 'RDA for males 14-18 years'
FROM Mineral WHERE UPPER(code) IN ('FE', 'MIN_FE')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'male', 19, 120, 8, 'mg', 'RDA for adult males'
FROM Mineral WHERE UPPER(code) IN ('FE', 'MIN_FE')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'female', 14, 18, 15, 'mg', 'RDA for females 14-18 years (menstruating)'
FROM Mineral WHERE UPPER(code) IN ('FE', 'MIN_FE')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'female', 19, 50, 18, 'mg', 'RDA for females 19-50 (menstruating)'
FROM Mineral WHERE UPPER(code) IN ('FE', 'MIN_FE')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'female', 51, 120, 8, 'mg', 'RDA for postmenopausal females'
FROM Mineral WHERE UPPER(code) IN ('FE', 'MIN_FE')
ON CONFLICT DO NOTHING;

-- ============================================================
-- MAGNESIUM (Mg) - mg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'male', 19, 30, 400, 'mg', 'RDA for males 19-30'
FROM Mineral WHERE UPPER(code) IN ('MG', 'MIN_MG')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'male', 31, 120, 420, 'mg', 'RDA for males 31+'
FROM Mineral WHERE UPPER(code) IN ('MG', 'MIN_MG')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'female', 19, 30, 310, 'mg', 'RDA for females 19-30'
FROM Mineral WHERE UPPER(code) IN ('MG', 'MIN_MG')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'female', 31, 120, 320, 'mg', 'RDA for females 31+'
FROM Mineral WHERE UPPER(code) IN ('MG', 'MIN_MG')
ON CONFLICT DO NOTHING;

-- ============================================================
-- ZINC (Zn) - mg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'male', 19, 120, 11, 'mg', 'RDA for adult males'
FROM Mineral WHERE UPPER(code) IN ('ZN', 'MIN_ZN')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'female', 19, 120, 8, 'mg', 'RDA for adult females'
FROM Mineral WHERE UPPER(code) IN ('ZN', 'MIN_ZN')
ON CONFLICT DO NOTHING;

-- ============================================================
-- POTASSIUM (K) - mg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'male', 19, 120, 3400, 'mg', 'AI for adult males'
FROM Mineral WHERE UPPER(code) IN ('K', 'MIN_K')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'female', 19, 120, 2600, 'mg', 'AI for adult females'
FROM Mineral WHERE UPPER(code) IN ('K', 'MIN_K')
ON CONFLICT DO NOTHING;

-- ============================================================
-- SODIUM (Na) - mg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 19, 50, 1500, 'mg', 'AI for adults 19-50'
FROM Mineral WHERE UPPER(code) IN ('NA', 'MIN_NA')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 51, 70, 1300, 'mg', 'AI for adults 51-70'
FROM Mineral WHERE UPPER(code) IN ('NA', 'MIN_NA')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 71, 120, 1200, 'mg', 'AI for adults 71+'
FROM Mineral WHERE UPPER(code) IN ('NA', 'MIN_NA')
ON CONFLICT DO NOTHING;

-- ============================================================
-- SELENIUM (Se) - µg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 19, 120, 55, 'µg', 'RDA for adults'
FROM Mineral WHERE UPPER(code) IN ('SE', 'MIN_SE')
ON CONFLICT DO NOTHING;

-- ============================================================
-- IODINE (I) - µg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 19, 120, 150, 'µg', 'RDA for adults'
FROM Mineral WHERE UPPER(code) IN ('I', 'MIN_I')
ON CONFLICT DO NOTHING;

-- ============================================================
-- PHOSPHORUS (P) - mg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 19, 70, 700, 'mg', 'RDA for adults'
FROM Mineral WHERE UPPER(code) IN ('P', 'MIN_P')
ON CONFLICT DO NOTHING;

-- ============================================================
-- COPPER (Cu) - µg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, NULL, 19, 120, 900, 'µg', 'RDA for adults'
FROM Mineral WHERE UPPER(code) IN ('CU', 'MIN_CU')
ON CONFLICT DO NOTHING;

-- ============================================================
-- MANGANESE (Mn) - mg/day
-- ============================================================

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'male', 19, 120, 2.3, 'mg', 'AI for adult males'
FROM Mineral WHERE UPPER(code) IN ('MN', 'MIN_MN')
ON CONFLICT DO NOTHING;

INSERT INTO MineralRDA(mineral_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT mineral_id, 'female', 19, 120, 1.8, 'mg', 'AI for adult females'
FROM Mineral WHERE UPPER(code) IN ('MN', 'MIN_MN')
ON CONFLICT DO NOTHING;

COMMIT;
