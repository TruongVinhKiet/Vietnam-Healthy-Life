-- Import drug table from CSV
-- CSV file: drug.csv
-- Generated: 2025-12-29 17:24:56
-- Total rows: 2,094

BEGIN;

CREATE TEMP TABLE tmp_drug (LIKE drug INCLUDING ALL);

\copy tmp_drug (drug_id, name, name_vi, source_link, is_active)
FROM 'C:/Users/Asus/Downloads/Dataset/Generated_Data/drug/drug.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO drug (drug_id, name, name_vi, source_link, is_active)
SELECT drug_id, name, name_vi, source_link, is_active
FROM tmp_drug
ON CONFLICT DO NOTHING;

DROP TABLE tmp_drug;

COMMIT;

SELECT COUNT(*) AS total_rows_in_drug FROM drug;
