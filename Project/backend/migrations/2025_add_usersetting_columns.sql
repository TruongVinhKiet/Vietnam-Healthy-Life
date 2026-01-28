-- Migration: add new UserSetting columns for seasonal UI, weather, and background
ALTER TABLE IF EXISTS UserSetting
  ADD COLUMN IF NOT EXISTS seasonal_ui_enabled BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS seasonal_mode VARCHAR(20) DEFAULT 'auto',
  ADD COLUMN IF NOT EXISTS seasonal_custom_bg TEXT,
  ADD COLUMN IF NOT EXISTS falling_leaves_enabled BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS weather_enabled BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS weather_city VARCHAR(100),
  ADD COLUMN IF NOT EXISTS weather_last_update TIMESTAMP,
  ADD COLUMN IF NOT EXISTS weather_last_data JSONB,
  ADD COLUMN IF NOT EXISTS background_image_url TEXT;

-- Ensure basic columns exist (idempotent)
ALTER TABLE IF EXISTS UserSetting
  ADD COLUMN IF NOT EXISTS theme VARCHAR(20) DEFAULT 'light',
  ADD COLUMN IF NOT EXISTS language VARCHAR(10) DEFAULT 'vi',
  ADD COLUMN IF NOT EXISTS font_size VARCHAR(20) DEFAULT 'medium',
  ADD COLUMN IF NOT EXISTS unit_system VARCHAR(10) DEFAULT 'metric';
