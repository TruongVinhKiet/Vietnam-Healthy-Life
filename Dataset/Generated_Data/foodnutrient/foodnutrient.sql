-- Import foodnutrient table from CSV
-- CSV file: foodnutrient.csv
-- Generated: 2025-12-29 17:24:56
-- Total rows: 7,742

BEGIN;

CREATE TEMP TABLE tmp_foodnutrient (LIKE foodnutrient INCLUDING ALL);

\copy tmp_foodnutrient (food_id, nutrient_id, amount_per_100g)
FROM 'C:/Users/Asus/Downloads/Dataset/Generated_Data/foodnutrient/foodnutrient.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g)
SELECT food_id, nutrient_id, amount_per_100g
FROM tmp_foodnutrient
ON CONFLICT DO NOTHING;

DROP TABLE tmp_foodnutrient;

COMMIT;

SELECT COUNT(*) AS total_rows_in_foodnutrient FROM foodnutrient;
