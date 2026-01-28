-- Migration: Add trigger to reset Mediterranean diet and Fat tracking daily at 00:00 UTC+7 (Vietnam time)
-- This ensures consistency across all daily tracking features
-- Date: 2025-12-06

-- Function to reset Mediterranean diet totals for all users at 00:00 UTC+7
CREATE OR REPLACE FUNCTION reset_daily_mediterranean_utc7() RETURNS void AS $$
DECLARE
  utc_now TIMESTAMP;
  vietnam_now TIMESTAMP;
  vietnam_date DATE;
  last_reset_date DATE;
BEGIN
  -- Get current time in Vietnam (UTC+7)
  utc_now := NOW() AT TIME ZONE 'UTC';
  vietnam_now := utc_now + INTERVAL '7 hours';
  vietnam_date := DATE(vietnam_now);
  
  -- Check if we already reset today (Vietnam time)
  SELECT reset_date INTO last_reset_date
  FROM daily_reset_history
  WHERE reset_type = 'mediterranean'
  ORDER BY reset_date DESC
  LIMIT 1;
  
  -- Only reset if we haven't reset today
  IF last_reset_date IS NULL OR last_reset_date < vietnam_date THEN
    -- Reset today_calories, today_protein, today_fat, today_carbs in userprofile
    UPDATE userprofile
    SET 
      today_calories = 0,
      today_protein = 0,
      today_fat = 0,
      today_carbs = 0;
    
    -- Log the reset
    INSERT INTO daily_reset_history (reset_type, reset_date, reset_timestamp)
    VALUES ('mediterranean', vietnam_date, vietnam_now);
    
    RAISE NOTICE 'Mediterranean diet reset completed for % users on %', 
      (SELECT COUNT(*) FROM userprofile), vietnam_date;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to check and trigger Mediterranean reset on any profile update
CREATE OR REPLACE FUNCTION trg_check_mediterranean_reset_on_update() RETURNS trigger AS $$
DECLARE
  utc_now TIMESTAMP;
  vietnam_now TIMESTAMP;
  vietnam_date DATE;
  last_reset_date DATE;
BEGIN
  -- Get current time in Vietnam (UTC+7)
  utc_now := NOW() AT TIME ZONE 'UTC';
  vietnam_now := utc_now + INTERVAL '7 hours';
  vietnam_date := DATE(vietnam_now);
  
  -- Check last reset date
  SELECT reset_date INTO last_reset_date
  FROM daily_reset_history
  WHERE reset_type = 'mediterranean'
  ORDER BY reset_date DESC
  LIMIT 1;
  
  -- If new day in Vietnam, reset all users
  IF last_reset_date IS NULL OR last_reset_date < vietnam_date THEN
    PERFORM reset_daily_mediterranean_utc7();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trg_check_mediterranean_reset ON userprofile;

-- Create trigger to automatically reset Mediterranean diet when userprofile is updated
CREATE TRIGGER trg_check_mediterranean_reset
  BEFORE UPDATE ON userprofile
  FOR EACH ROW
  EXECUTE FUNCTION trg_check_mediterranean_reset_on_update();

-- Create daily_reset_history table if not exists (for tracking resets)
CREATE TABLE IF NOT EXISTS daily_reset_history (
  reset_id SERIAL PRIMARY KEY,
  reset_type VARCHAR(50) NOT NULL, -- 'water', 'mediterranean', 'fat', etc.
  reset_date DATE NOT NULL,
  reset_timestamp TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(reset_type, reset_date)
);

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_daily_reset_type_date ON daily_reset_history(reset_type, reset_date DESC);

-- Perform initial reset if needed
SELECT reset_daily_mediterranean_utc7();

-- Grant permissions
GRANT EXECUTE ON FUNCTION reset_daily_mediterranean_utc7() TO PUBLIC;
GRANT EXECUTE ON FUNCTION trg_check_mediterranean_reset_on_update() TO PUBLIC;

COMMENT ON FUNCTION reset_daily_mediterranean_utc7() IS 'Resets Mediterranean diet tracking (calories, protein, fat, carbs) for all users daily at 00:00 UTC+7';
COMMENT ON FUNCTION trg_check_mediterranean_reset_on_update() IS 'Trigger function to check and reset Mediterranean diet on userprofile updates';
COMMENT ON TABLE daily_reset_history IS 'Tracks daily reset operations for various features (water, mediterranean, etc.)';
