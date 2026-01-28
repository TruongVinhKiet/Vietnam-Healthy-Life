-- Import healthcondition table from CSV
-- CSV file: healthcondition.csv
-- Generated: 2025-12-29 16:49:05
-- Total rows: 88

BEGIN;

CREATE TEMP TABLE tmp_healthcondition (LIKE healthcondition INCLUDING ALL);

\copy tmp_healthcondition (condition_id, condition_code, name_vi, name_en)
FROM 'C:/Users/Asus/Downloads/Dataset/Generated_Data/healthcondition/healthcondition.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO healthcondition (condition_id, condition_code, name_vi, name_en)
SELECT condition_id, condition_code, name_vi, name_en
FROM tmp_healthcondition
ON CONFLICT DO NOTHING;

DROP TABLE tmp_healthcondition;

COMMIT;

SELECT COUNT(*) AS total_rows_in_healthcondition FROM healthcondition;
