-- Migration: Seed Vitamin RDA data based on WHO/FDA standards
-- Age and sex-specific recommended daily allowances

BEGIN;

-- ============================================================
-- VITAMIN A (Retinol) - µg RAE/day
-- ============================================================

-- Infants 0-6 months
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 0, 0, 400, 'µg', 'Adequate Intake (AI) for infants 0-6 months'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 1, 1, 500, 'µg', 'AI for infants 7-12 months'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Children 1-3 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 1, 3, 300, 'µg', 'RDA for children 1-3 years'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Children 4-8 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 4, 8, 400, 'µg', 'RDA for children 4-8 years'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Males 9-13 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 9, 13, 600, 'µg', 'RDA for males 9-13 years'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Males 14-18 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 14, 18, 900, 'µg', 'RDA for males 14-18 years'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Males 19-50 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 19, 50, 900, 'µg', 'RDA for adult males'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Males 51+ years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 51, 120, 900, 'µg', 'RDA for males 51+ years'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Females 9-13 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 9, 13, 600, 'µg', 'RDA for females 9-13 years'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Females 14-18 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 14, 18, 700, 'µg', 'RDA for females 14-18 years'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Females 19-50 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 19, 50, 700, 'µg', 'RDA for adult females'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- Females 51+ years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 51, 120, 700, 'µg', 'RDA for females 51+ years'
FROM Vitamin WHERE UPPER(code) = 'VITA'
ON CONFLICT DO NOTHING;

-- ============================================================
-- VITAMIN D (Cholecalciferol) - IU/day
-- ============================================================

-- Infants 0-12 months
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 0, 1, 400, 'IU', 'AI for infants'
FROM Vitamin WHERE UPPER(code) = 'VITD'
ON CONFLICT DO NOTHING;

-- Children 1-18 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 1, 18, 600, 'IU', 'RDA for children and adolescents'
FROM Vitamin WHERE UPPER(code) = 'VITD'
ON CONFLICT DO NOTHING;

-- Adults 19-70 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 19, 70, 600, 'IU', 'RDA for adults'
FROM Vitamin WHERE UPPER(code) = 'VITD'
ON CONFLICT DO NOTHING;

-- Adults 71+ years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 71, 120, 800, 'IU', 'RDA for elderly'
FROM Vitamin WHERE UPPER(code) = 'VITD'
ON CONFLICT DO NOTHING;

-- ============================================================
-- VITAMIN E (Alpha-tocopherol) - mg/day
-- ============================================================

-- Infants 0-6 months
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 0, 0, 4, 'mg', 'AI for infants 0-6 months'
FROM Vitamin WHERE UPPER(code) = 'VITE'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 1, 1, 5, 'mg', 'AI for infants 7-12 months'
FROM Vitamin WHERE UPPER(code) = 'VITE'
ON CONFLICT DO NOTHING;

-- Children 1-3 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 1, 3, 6, 'mg', 'RDA for children 1-3 years'
FROM Vitamin WHERE UPPER(code) = 'VITE'
ON CONFLICT DO NOTHING;

-- Children 4-8 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 4, 8, 7, 'mg', 'RDA for children 4-8 years'
FROM Vitamin WHERE UPPER(code) = 'VITE'
ON CONFLICT DO NOTHING;

-- Adolescents 9-18 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 9, 18, 11, 'mg', 'RDA for adolescents'
FROM Vitamin WHERE UPPER(code) = 'VITE'
ON CONFLICT DO NOTHING;

-- Adults 19+ years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 19, 120, 15, 'mg', 'RDA for adults'
FROM Vitamin WHERE UPPER(code) = 'VITE'
ON CONFLICT DO NOTHING;

-- ============================================================
-- VITAMIN K - µg/day
-- ============================================================

-- Infants 0-6 months
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 0, 0, 2, 'µg', 'AI for infants 0-6 months'
FROM Vitamin WHERE UPPER(code) = 'VITK'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 1, 1, 2.5, 'µg', 'AI for infants 7-12 months'
FROM Vitamin WHERE UPPER(code) = 'VITK'
ON CONFLICT DO NOTHING;

-- Children 1-3 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 1, 3, 30, 'µg', 'AI for children 1-3 years'
FROM Vitamin WHERE UPPER(code) = 'VITK'
ON CONFLICT DO NOTHING;

-- Children 4-8 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 4, 8, 55, 'µg', 'AI for children 4-8 years'
FROM Vitamin WHERE UPPER(code) = 'VITK'
ON CONFLICT DO NOTHING;

-- Males 9-13 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 9, 13, 60, 'µg', 'AI for males 9-13 years'
FROM Vitamin WHERE UPPER(code) = 'VITK'
ON CONFLICT DO NOTHING;

-- Males 14-18 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 14, 18, 75, 'µg', 'AI for males 14-18 years'
FROM Vitamin WHERE UPPER(code) = 'VITK'
ON CONFLICT DO NOTHING;

-- Males 19+ years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 19, 120, 120, 'µg', 'AI for adult males'
FROM Vitamin WHERE UPPER(code) = 'VITK'
ON CONFLICT DO NOTHING;

-- Females 9-13 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 9, 13, 60, 'µg', 'AI for females 9-13 years'
FROM Vitamin WHERE UPPER(code) = 'VITK'
ON CONFLICT DO NOTHING;

-- Females 14-18 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 14, 18, 75, 'µg', 'AI for females 14-18 years'
FROM Vitamin WHERE UPPER(code) = 'VITK'
ON CONFLICT DO NOTHING;

-- Females 19+ years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 19, 120, 90, 'µg', 'AI for adult females'
FROM Vitamin WHERE UPPER(code) = 'VITK'
ON CONFLICT DO NOTHING;

-- ============================================================
-- VITAMIN C (Ascorbic acid) - mg/day
-- ============================================================

-- Infants 0-6 months
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 0, 0, 40, 'mg', 'AI for infants 0-6 months'
FROM Vitamin WHERE UPPER(code) = 'VITC'
ON CONFLICT DO NOTHING;

-- Infants 7-12 months
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 1, 1, 50, 'mg', 'AI for infants 7-12 months'
FROM Vitamin WHERE UPPER(code) = 'VITC'
ON CONFLICT DO NOTHING;

-- Children 1-3 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 1, 3, 15, 'mg', 'RDA for children 1-3 years'
FROM Vitamin WHERE UPPER(code) = 'VITC'
ON CONFLICT DO NOTHING;

-- Children 4-8 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 4, 8, 25, 'mg', 'RDA for children 4-8 years'
FROM Vitamin WHERE UPPER(code) = 'VITC'
ON CONFLICT DO NOTHING;

-- Children 9-13 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 9, 13, 45, 'mg', 'RDA for children 9-13 years'
FROM Vitamin WHERE UPPER(code) = 'VITC'
ON CONFLICT DO NOTHING;

-- Males 14-18 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 14, 18, 75, 'mg', 'RDA for males 14-18 years'
FROM Vitamin WHERE UPPER(code) = 'VITC'
ON CONFLICT DO NOTHING;

-- Males 19+ years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 19, 120, 90, 'mg', 'RDA for adult males'
FROM Vitamin WHERE UPPER(code) = 'VITC'
ON CONFLICT DO NOTHING;

-- Females 14-18 years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 14, 18, 65, 'mg', 'RDA for females 14-18 years'
FROM Vitamin WHERE UPPER(code) = 'VITC'
ON CONFLICT DO NOTHING;

-- Females 19+ years
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 19, 120, 75, 'mg', 'RDA for adult females'
FROM Vitamin WHERE UPPER(code) = 'VITC'
ON CONFLICT DO NOTHING;

-- ============================================================
-- B VITAMINS
-- ============================================================

-- VITAMIN B1 (Thiamine) - mg/day
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 19, 120, 1.2, 'mg', 'RDA for adult males'
FROM Vitamin WHERE UPPER(code) = 'VITB1'
ON CONFLICT DO NOTHING;

INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 19, 120, 1.1, 'mg', 'RDA for adult females'
FROM Vitamin WHERE UPPER(code) = 'VITB1'
ON CONFLICT DO NOTHING;

-- VITAMIN B2 (Riboflavin) - mg/day
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 19, 120, 1.3, 'mg', 'RDA for adult males'
FROM Vitamin WHERE UPPER(code) = 'VITB2'
ON CONFLICT DO NOTHING;

INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 19, 120, 1.1, 'mg', 'RDA for adult females'
FROM Vitamin WHERE UPPER(code) = 'VITB2'
ON CONFLICT DO NOTHING;

-- VITAMIN B3 (Niacin) - mg/day
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 19, 120, 16, 'mg', 'RDA for adult males'
FROM Vitamin WHERE UPPER(code) = 'VITB3'
ON CONFLICT DO NOTHING;

INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 19, 120, 14, 'mg', 'RDA for adult females'
FROM Vitamin WHERE UPPER(code) = 'VITB3'
ON CONFLICT DO NOTHING;

-- VITAMIN B6 (Pyridoxine) - mg/day
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 19, 50, 1.3, 'mg', 'RDA for adult males 19-50'
FROM Vitamin WHERE UPPER(code) = 'VITB6'
ON CONFLICT DO NOTHING;

INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'male', 51, 120, 1.7, 'mg', 'RDA for males 51+'
FROM Vitamin WHERE UPPER(code) = 'VITB6'
ON CONFLICT DO NOTHING;

INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 19, 50, 1.3, 'mg', 'RDA for adult females 19-50'
FROM Vitamin WHERE UPPER(code) = 'VITB6'
ON CONFLICT DO NOTHING;

INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, 'female', 51, 120, 1.5, 'mg', 'RDA for females 51+'
FROM Vitamin WHERE UPPER(code) = 'VITB6'
ON CONFLICT DO NOTHING;

-- VITAMIN B9 (Folate) - µg/day
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 19, 120, 400, 'µg', 'RDA for adults'
FROM Vitamin WHERE UPPER(code) = 'VITB9'
ON CONFLICT DO NOTHING;

-- VITAMIN B12 (Cobalamin) - µg/day
INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, notes)
SELECT vitamin_id, NULL, 19, 120, 2.4, 'µg', 'RDA for adults'
FROM Vitamin WHERE UPPER(code) = 'VITB12'
ON CONFLICT DO NOTHING;

COMMIT;
