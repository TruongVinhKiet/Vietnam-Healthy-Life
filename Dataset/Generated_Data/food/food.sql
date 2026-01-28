-- Import food table from CSV
-- CSV file: food.csv
-- Generated: 2025-12-29 17:24:56
-- Total rows: 432

BEGIN;

CREATE TEMP TABLE tmp_food (LIKE food INCLUDING ALL);

\copy tmp_food (food_id, name, name_vi, is_verified, is_active)
FROM 'C:/Users/Asus/Downloads/Dataset/Generated_Data/food/food.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO food (food_id, name, name_vi, is_verified, is_active)
SELECT food_id, name, name_vi, is_verified, is_active
FROM tmp_food
ON CONFLICT DO NOTHING;

DROP TABLE tmp_food;

COMMIT;

SELECT COUNT(*) AS total_rows_in_food FROM food;
