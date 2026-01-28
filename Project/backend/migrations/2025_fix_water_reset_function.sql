-- Fix check_and_reset_water_if_new_day function to use individual columns instead of JSON value column
-- The UserSetting table has individual columns, not a JSON 'value' column

CREATE OR REPLACE FUNCTION public.check_and_reset_water_if_new_day(p_user_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_last_reset_date DATE;
    v_current_date DATE;
    v_user_timezone TEXT := 'Asia/Ho_Chi_Minh';
BEGIN
    -- Get current date in Vietnam timezone
    v_current_date := (NOW() AT TIME ZONE v_user_timezone)::DATE;
    
    -- Get last reset date from UserSetting - use a custom column or just check daily summary
    -- Since UserSetting doesn't have a last_water_reset_date column, we'll check DailySummary instead
    SELECT MAX(date) INTO v_last_reset_date
    FROM DailySummary
    WHERE user_id = p_user_id;
    
    -- If no data exists, use default date
    IF v_last_reset_date IS NULL THEN
        v_last_reset_date := '1970-01-01'::DATE;
    END IF;
    
    -- If date has changed (new day), reset water
    IF v_current_date > v_last_reset_date THEN
        -- Insert or update DailySummary for today with reset water
        INSERT INTO DailySummary (user_id, date, total_water, total_calories, total_protein, total_fat, total_carbs, total_fiber)
        VALUES (p_user_id, v_current_date, 0, 0, 0, 0, 0, 0)
        ON CONFLICT (user_id, date) DO UPDATE
        SET total_water = 0;
        
        RAISE NOTICE 'Water reset for user % on date %', p_user_id, v_current_date;
    END IF;
END;
$$;

-- Recreate the trigger function
CREATE OR REPLACE FUNCTION public.trg_check_water_reset_on_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check and reset water for new day before inserting log
    PERFORM check_and_reset_water_if_new_day(NEW.user_id);
    RETURN NEW;
END;
$$;
