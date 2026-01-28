-- Import nutrient table from CSV
-- CSV file: nutrient.csv
-- Generated: 2025-12-29 17:24:56
-- Total rows: 60

BEGIN;

CREATE TEMP TABLE tmp_nutrient (LIKE nutrient INCLUDING ALL);

\copy tmp_nutrient (nutrient_id, name, name_vi, nutrient_code, unit)
FROM 'C:/Users/Asus/Downloads/Dataset/Generated_Data/nutrient/nutrient.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO nutrient (nutrient_id, name, name_vi, nutrient_code, unit)
SELECT nutrient_id, name, name_vi, nutrient_code, unit
FROM tmp_nutrient
ON CONFLICT DO NOTHING;

DROP TABLE tmp_nutrient;

COMMIT;

SELECT COUNT(*) AS total_rows_in_nutrient FROM nutrient;
