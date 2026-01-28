-- Migration: add weather_effects_enabled to UserSetting
ALTER TABLE IF EXISTS UserSetting
  ADD COLUMN IF NOT EXISTS weather_effects_enabled BOOLEAN DEFAULT TRUE;
