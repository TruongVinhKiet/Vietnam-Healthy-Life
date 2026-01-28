-- Migration: add macro and calorie multiplier columns to UserSetting
ALTER TABLE IF EXISTS UserSetting
  ADD COLUMN IF NOT EXISTS calorie_multiplier DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS macro_protein_pct DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS macro_fat_pct DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS macro_carb_pct DOUBLE PRECISION;

-- No-op when columns already exist; designed for Postgres.
