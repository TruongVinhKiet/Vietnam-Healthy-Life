-- Migration: Add admin-facing fields to Nutrient and contraindications table
-- - Adds group_name, image_url, benefits to Nutrient
-- - Creates NutrientContraindication to store simple condition-name based contraindications per nutrient
-- Notes:
--   Avoid using reserved word "group" as column name. Use group_name instead.

ALTER TABLE IF EXISTS Nutrient
    ADD COLUMN IF NOT EXISTS group_name VARCHAR(50),
    ADD COLUMN IF NOT EXISTS image_url TEXT,
    ADD COLUMN IF NOT EXISTS benefits TEXT;

-- Dedicated contraindication table for simple admin CRUD
CREATE TABLE IF NOT EXISTS NutrientContraindication (
    contra_id SERIAL PRIMARY KEY,
    nutrient_id INT REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
    condition_name VARCHAR(100) NOT NULL,
    note TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(nutrient_id, condition_name)
);

-- Optional helper view: counts by group for dashboard stats
CREATE OR REPLACE VIEW NutrientGroupStats AS
SELECT COALESCE(group_name, 'Uncategorized') AS group_name,
       COUNT(*) AS total
FROM Nutrient
GROUP BY 1
ORDER BY total DESC;
