-- Migration: add effect_intensity to UserSetting (low/medium/high)
ALTER TABLE IF EXISTS UserSetting
  ADD COLUMN IF NOT EXISTS effect_intensity VARCHAR(20) DEFAULT 'medium';
