-- Migration: create UserSetting table and common columns
-- Adds UserSetting table used by settingsService and settingsController

CREATE TABLE IF NOT EXISTS UserSetting (
  user_id INT PRIMARY KEY REFERENCES "User"(user_id) ON DELETE CASCADE,
  theme VARCHAR(50) DEFAULT 'default',
  language VARCHAR(20) DEFAULT 'en',
  font_size NUMERIC(4,2) DEFAULT 14,
  unit_system VARCHAR(20) DEFAULT 'metric',
  seasonal_ui_enabled BOOLEAN DEFAULT FALSE,
  seasonal_mode VARCHAR(50),
  seasonal_custom_bg TEXT,
  falling_leaves_enabled BOOLEAN DEFAULT FALSE,
  weather_enabled BOOLEAN DEFAULT FALSE,
  weather_effects_enabled BOOLEAN DEFAULT FALSE,
  weather_city VARCHAR(200),
  weather_last_update TIMESTAMPTZ,
  weather_last_data JSONB,
  background_image_url TEXT,
  background_image_enabled BOOLEAN DEFAULT FALSE,
  effect_intensity NUMERIC(5,2) DEFAULT 1.0,
  wind_direction VARCHAR(20),
  calorie_multiplier NUMERIC(6,3) DEFAULT 1.0,
  macro_protein_pct NUMERIC(5,2) DEFAULT 20.0,
  macro_fat_pct NUMERIC(5,2) DEFAULT 30.0,
  macro_carb_pct NUMERIC(5,2) DEFAULT 50.0,
  meal_pct_breakfast NUMERIC(5,2) DEFAULT 25.0,
  meal_pct_lunch NUMERIC(5,2) DEFAULT 35.0,
  meal_pct_snack NUMERIC(5,2) DEFAULT 10.0,
  meal_pct_dinner NUMERIC(5,2) DEFAULT 30.0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure a default row is created for any existing users (safe to run)
-- This will NOT modify existing rows beyond inserting missing ones
DO $$
BEGIN
  INSERT INTO UserSetting (user_id)
  SELECT user_id FROM "User" u
  WHERE NOT EXISTS (SELECT 1 FROM UserSetting s WHERE s.user_id = u.user_id);
EXCEPTION WHEN others THEN
  -- ignore to keep migration idempotent in environments where "User" may not exist yet
  RAISE NOTICE 'Could not populate UserSetting defaults: %', SQLERRM;
END;
$$;