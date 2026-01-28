-- Add wind_direction column to UserSetting
-- Stores user-preferred wind direction in degrees (0..360)

ALTER TABLE "UserSetting"
  ADD COLUMN IF NOT EXISTS wind_direction DOUBLE PRECISION DEFAULT 0;
