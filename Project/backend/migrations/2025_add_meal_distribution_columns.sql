-- Migration: add meal distribution percentage columns to UserSetting
-- Adds four numeric columns storing percent values (e.g., 25.00)

ALTER TABLE IF EXISTS UserSetting
    ADD COLUMN IF NOT EXISTS meal_pct_breakfast NUMERIC(5,2) DEFAULT 25.00,
    ADD COLUMN IF NOT EXISTS meal_pct_lunch NUMERIC(5,2) DEFAULT 35.00,
    ADD COLUMN IF NOT EXISTS meal_pct_snack NUMERIC(5,2) DEFAULT 10.00,
    ADD COLUMN IF NOT EXISTS meal_pct_dinner NUMERIC(5,2) DEFAULT 30.00;

-- Note: After adding this migration to your DB, run it (psql or migration tooling) so the columns exist.
