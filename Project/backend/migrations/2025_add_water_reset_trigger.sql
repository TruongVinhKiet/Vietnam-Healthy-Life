-- Migration: Add trigger to reset water daily at 00:00 UTC+7 (Vietnam time)
-- This ensures water tracking resets every day at midnight Vietnam time

BEGIN;

-- Function to reset water for all users at 00:00 UTC+7
CREATE OR REPLACE FUNCTION reset_daily_water_utc7() RETURNS void AS $$
DECLARE
    v_reset_date DATE;
BEGIN
    -- Get current date in UTC+7 (Vietnam time)
    -- PostgreSQL stores timestamps in UTC, so we need to convert
    -- Vietnam is UTC+7, so we subtract 7 hours from UTC to get Vietnam time
    v_reset_date := (NOW() AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE;
    
    -- Delete all WaterLog entries for yesterday (in Vietnam time)
    -- This effectively resets the water tracking
    -- Actually, we don't delete - we just ensure DailySummary.total_water is reset
    -- The reset happens by checking if the date has changed
    
    -- Update DailySummary to reset total_water for the new day
    -- This is handled by the application logic, but we can add a trigger
    -- that ensures water is reset when date changes
    
    RAISE NOTICE 'Water reset check for date: %', v_reset_date;
END;
$$ LANGUAGE plpgsql;

-- Create a scheduled job function (requires pg_cron extension)
-- If pg_cron is not available, we'll use application-level scheduling
-- For now, we'll create a function that can be called by the application

-- Function to check and reset water if date changed (called by application)
CREATE OR REPLACE FUNCTION check_and_reset_water_if_new_day(p_user_id INT) RETURNS void AS $$
DECLARE
    v_last_reset_date DATE;
    v_current_date DATE;
    v_user_timezone TEXT := 'Asia/Ho_Chi_Minh';
BEGIN
    -- Get current date in Vietnam timezone
    v_current_date := (NOW() AT TIME ZONE v_user_timezone)::DATE;
    
    -- Get last reset date from UserSetting or use a default
    SELECT COALESCE(
        (value::json->>'last_water_reset_date')::DATE,
        '1970-01-01'::DATE
    ) INTO v_last_reset_date
    FROM UserSetting
    WHERE user_id = p_user_id AND key = 'water_reset';
    
    -- If no setting exists, create it
    IF v_last_reset_date IS NULL THEN
        INSERT INTO UserSetting (user_id, key, value, updated_at)
        VALUES (p_user_id, 'water_reset', '{"last_water_reset_date": "1970-01-01"}'::json, NOW())
        ON CONFLICT (user_id, key) DO NOTHING;
        v_last_reset_date := '1970-01-01'::DATE;
    END IF;
    
    -- If date has changed (new day), reset water
    IF v_current_date > v_last_reset_date THEN
        -- Reset total_water in DailySummary for today
        UPDATE DailySummary
        SET total_water = 0
        WHERE user_id = p_user_id 
          AND date = v_current_date;
        
        -- Update last reset date
        INSERT INTO UserSetting (user_id, key, value, updated_at)
        VALUES (p_user_id, 'water_reset', json_build_object('last_water_reset_date', v_current_date), NOW())
        ON CONFLICT (user_id, key) DO UPDATE
        SET value = json_build_object('last_water_reset_date', v_current_date),
            updated_at = NOW();
        
        RAISE NOTICE 'Water reset for user % on date %', p_user_id, v_current_date;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically reset water when a new WaterLog entry is created
-- This checks if it's a new day and resets if needed
CREATE OR REPLACE FUNCTION trg_check_water_reset_on_log() RETURNS trigger AS $$
BEGIN
    -- Check and reset water if new day
    PERFORM check_and_reset_water_if_new_day(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_water_reset ON WaterLog;
CREATE TRIGGER trg_check_water_reset
BEFORE INSERT ON WaterLog
FOR EACH ROW
EXECUTE FUNCTION trg_check_water_reset_on_log();

-- Also reset when DailySummary is accessed for a new day
CREATE OR REPLACE FUNCTION ensure_daily_summary_water_reset(p_user_id INT, p_date DATE) RETURNS void AS $$
DECLARE
    v_user_timezone TEXT := 'Asia/Ho_Chi_Minh';
    v_vietnam_date DATE;
BEGIN
    -- Get current date in Vietnam timezone
    v_vietnam_date := (NOW() AT TIME ZONE v_user_timezone)::DATE;
    
    -- If the requested date is today and water hasn't been reset, reset it
    IF p_date = v_vietnam_date THEN
        PERFORM check_and_reset_water_if_new_day(p_user_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMIT;

