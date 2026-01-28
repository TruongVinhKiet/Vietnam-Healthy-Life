-- Import drughealthcondition table from CSV
-- CSV file: drughealthcondition.csv
-- Generated: 2025-12-29 17:24:57
-- Total rows: 200

BEGIN;

CREATE TEMP TABLE tmp_drughealthcondition (LIKE drughealthcondition INCLUDING ALL);

\copy tmp_drughealthcondition (drug_id, condition_id, treatment_notes, treatment_notes_vi, is_primary)
FROM 'C:/Users/Asus/Downloads/Dataset/Generated_Data/drughealthcondition/drughealthcondition.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO drughealthcondition (drug_id, condition_id, treatment_notes, treatment_notes_vi, is_primary)
SELECT drug_id, condition_id, treatment_notes, treatment_notes_vi, is_primary
FROM tmp_drughealthcondition
ON CONFLICT DO NOTHING;

DROP TABLE tmp_drughealthcondition;

COMMIT;

SELECT COUNT(*) AS total_rows_in_drughealthcondition FROM drughealthcondition;
