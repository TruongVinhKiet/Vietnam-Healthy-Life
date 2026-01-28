-- ================================================================
-- FIX ALL TIMEZONE FUNCTIONS AND TRIGGERS TO USE UTC+7 (Vietnam Time)
-- ================================================================
-- This migration ensures all database functions and triggers use Vietnam timezone
-- Date: 2025-12-XX
-- ================================================================

BEGIN;

-- 1. Fix cleanup_old_daily_suggestions() function
CREATE OR REPLACE FUNCTION cleanup_old_daily_suggestions()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM user_daily_meal_suggestions
  WHERE date < get_vietnam_date() - INTERVAL '7 days';
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cleanup_old_daily_suggestions() IS 'Xoa goi y cu hon 7 ngay - uses Vietnam timezone';

-- 2. Fix cleanup_passed_meal_suggestions() function
CREATE OR REPLACE FUNCTION cleanup_passed_meal_suggestions(p_user_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
  v_breakfast_time TIME;
  v_lunch_time TIME;
  v_dinner_time TIME;
  v_snack_time TIME;
  v_current_time TIME;
  v_current_date DATE;
BEGIN
  -- Get user's meal times from settings
  SELECT 
    COALESCE(breakfast_time, '07:00:00')::TIME,
    COALESCE(lunch_time, '11:00:00')::TIME,
    COALESCE(dinner_time, '18:00:00')::TIME,
    COALESCE(snack_time, '15:00:00')::TIME
  INTO v_breakfast_time, v_lunch_time, v_dinner_time, v_snack_time
  FROM usersetting
  WHERE user_id = p_user_id;
  
  -- Get current time and date in Vietnam timezone
  v_current_time := (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::TIME;
  v_current_date := get_vietnam_date();
  
  -- Delete suggestions for meals that have passed
  DELETE FROM user_daily_meal_suggestions
  WHERE user_id = p_user_id
    AND date = v_current_date
    AND is_accepted = FALSE
    AND (
      (meal_type = 'breakfast' AND v_current_time > v_lunch_time) OR
      (meal_type = 'lunch' AND v_current_time > v_dinner_time) OR
      (meal_type = 'dinner' AND v_current_time > TIME '23:59:59') OR
      (meal_type = 'snack' AND v_current_time > v_dinner_time)
    );
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cleanup_passed_meal_suggestions(INTEGER) IS 'Xoa goi y cua bua an da qua - uses Vietnam timezone';

-- 3. Fix reset_daily_mediterranean_utc7() function to use proper timezone conversion
CREATE OR REPLACE FUNCTION reset_daily_mediterranean_utc7() RETURNS void AS $$
DECLARE
  vietnam_date DATE;
  last_reset_date DATE;
BEGIN
  -- Get current date in Vietnam timezone
  vietnam_date := get_vietnam_date();
  
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
    VALUES ('mediterranean', vietnam_date, CURRENT_TIMESTAMP)
    ON CONFLICT (reset_type, reset_date) DO NOTHING;
    
    RAISE NOTICE 'Mediterranean diet reset completed for % users on %', 
      (SELECT COUNT(*) FROM userprofile), vietnam_date;
  END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION reset_daily_mediterranean_utc7() IS 'Resets Mediterranean diet tracking daily at 00:00 UTC+7 - uses get_vietnam_date()';

-- 4. Fix trg_check_mediterranean_reset_on_update() trigger function
CREATE OR REPLACE FUNCTION trg_check_mediterranean_reset_on_update() RETURNS trigger AS $$
DECLARE
  vietnam_date DATE;
  last_reset_date DATE;
BEGIN
  -- Get current date in Vietnam timezone
  vietnam_date := get_vietnam_date();
  
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

COMMENT ON FUNCTION trg_check_mediterranean_reset_on_update() IS 'Trigger function to check and reset Mediterranean diet on userprofile updates - uses get_vietnam_date()';

COMMIT;

-- ================================================================
-- VERIFICATION
-- ================================================================
-- Run these to verify:
-- SELECT get_vietnam_date() as vietnam_date, CURRENT_DATE as utc_date;
-- SELECT cleanup_old_daily_suggestions();
-- ================================================================

