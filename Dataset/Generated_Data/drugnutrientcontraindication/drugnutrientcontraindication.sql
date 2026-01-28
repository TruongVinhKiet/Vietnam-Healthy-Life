-- Import drugnutrientcontraindication table from CSV
-- CSV file: drugnutrientcontraindication.csv
-- Generated: 2025-12-29 17:24:57
-- Total rows: 251

BEGIN;

CREATE TEMP TABLE tmp_drugnutrientcontraindication (LIKE drugnutrientcontraindication INCLUDING ALL);

\copy tmp_drugnutrientcontraindication (drug_id, nutrient_id, warning_message_vi, warning_message_en, severity)
FROM 'C:/Users/Asus/Downloads/Dataset/Generated_Data/drugnutrientcontraindication/drugnutrientcontraindication.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO drugnutrientcontraindication (drug_id, nutrient_id, warning_message_vi, warning_message_en, severity)
SELECT drug_id, nutrient_id, warning_message_vi, warning_message_en, severity
FROM tmp_drugnutrientcontraindication
ON CONFLICT DO NOTHING;

DROP TABLE tmp_drugnutrientcontraindication;

COMMIT;

SELECT COUNT(*) AS total_rows_in_drugnutrientcontraindication FROM drugnutrientcontraindication;
