-- Ensure nutrient names are unique (case-insensitive)
-- Safe to run multiple times
CREATE UNIQUE INDEX IF NOT EXISTS uniq_nutrient_name_ci ON Nutrient ((LOWER(name)));
