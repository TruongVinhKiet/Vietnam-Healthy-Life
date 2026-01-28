-- Migration: create tables to store per-user, per-day, per-meal targets and entries
-- 2025_create_user_meal_tables.sql

-- Table: user_meal_targets
-- Purpose: store the target amounts the user aims to consume for each meal (breakfast/lunch/snack/dinner)
-- This allows the app to load "target per meal" values (initially 0 or computed from daily targets)
CREATE TABLE IF NOT EXISTS user_meal_targets (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  target_date DATE NOT NULL DEFAULT CURRENT_DATE,
  meal_type VARCHAR(16) NOT NULL,
  target_kcal NUMERIC(10,2) DEFAULT 0,
  target_carbs NUMERIC(10,2) DEFAULT 0,
  target_protein NUMERIC(10,2) DEFAULT 0,
  target_fat NUMERIC(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_user_meal_targets_user_date_meal ON user_meal_targets(user_id, target_date, meal_type);

-- Table: meal_entries
-- Purpose: store detailed additions the user makes with the '+' action (food items, weight, computed macros)
-- Each time the user uses + to add a food/item, insert into this table. The app/backend can then recalc summaries.
CREATE TABLE IF NOT EXISTS meal_entries (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  meal_type VARCHAR(16) NOT NULL,
  food_id INTEGER,
  weight_g NUMERIC(10,2),
  kcal NUMERIC(10,2) DEFAULT 0,
  carbs NUMERIC(10,2) DEFAULT 0,
  protein NUMERIC(10,2) DEFAULT 0,
  fat NUMERIC(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table: user_meal_summaries
-- Purpose: keep a quick aggregate of consumed totals per user/date/meal so the app can load totals quickly
CREATE TABLE IF NOT EXISTS user_meal_summaries (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  summary_date DATE NOT NULL DEFAULT CURRENT_DATE,
  meal_type VARCHAR(16) NOT NULL,
  consumed_kcal NUMERIC(12,2) DEFAULT 0,
  consumed_carbs NUMERIC(12,2) DEFAULT 0,
  consumed_protein NUMERIC(12,2) DEFAULT 0,
  consumed_fat NUMERIC(12,2) DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, summary_date, meal_type)
);

-- Trigger tips (not implemented here):
-- - When inserting into meal_entries, update/insert corresponding user_meal_summaries row by summing the macros.
-- - When deleting/updating meal_entries, adjust the summary accordingly.
-- Alternatively the backend can recalc summaries on demand and store them here.
