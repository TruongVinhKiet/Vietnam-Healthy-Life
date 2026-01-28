-- ================================================================
-- FIX REMAINING TIMEZONE FUNCTIONS - COMPREHENSIVE UPDATE
-- ================================================================
-- Sửa các functions còn lại để sử dụng Vietnam timezone (UTC+7)
-- Date: 2025-12-13
-- ================================================================

BEGIN;

-- 1. Fix check_and_notify_nutrient_deficiencies() function
-- Replace CURRENT_DATE with get_vietnam_date()
CREATE OR REPLACE FUNCTION check_and_notify_nutrient_deficiencies()
RETURNS void AS $$
DECLARE
  v_user_id INT;
  v_date DATE;
  v_nutrient_name TEXT;
  v_deficiency_count INT;
BEGIN
  -- Use Vietnam date instead of CURRENT_DATE
  v_date := get_vietnam_date();
  
  -- Loop through all users
  FOR v_user_id IN 
    SELECT DISTINCT user_id FROM "user" WHERE is_active = true
  LOOP
    -- Check for vitamin deficiencies
    INSERT INTO user_notifications (user_id, notification_type, title, message, is_read, created_at)
    SELECT 
      v_user_id,
      'nutrient_deficiency',
      'Thiếu chất dinh dưỡng',
      'Bạn đang thiếu ' || COUNT(*) || ' loại vitamin. Hãy bổ sung ngay!',
      false,
      CURRENT_TIMESTAMP
    FROM calculate_daily_nutrient_intake(v_user_id, v_date)
    WHERE nutrient_type = 'vitamin' 
      AND percentage < 50
    HAVING COUNT(*) > 0;
    
    -- Check for mineral deficiencies
    INSERT INTO user_notifications (user_id, notification_type, title, message, is_read, created_at)
    SELECT 
      v_user_id,
      'nutrient_deficiency',
      'Thiếu khoáng chất',
      'Bạn đang thiếu ' || COUNT(*) || ' loại khoáng chất. Hãy bổ sung ngay!',
      false,
      CURRENT_TIMESTAMP
    FROM calculate_daily_nutrient_intake(v_user_id, v_date)
    WHERE nutrient_type = 'mineral' 
      AND percentage < 50
    HAVING COUNT(*) > 0;
  END LOOP;
  
  RAISE NOTICE 'Nutrient deficiency check completed for date: %', v_date;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_and_notify_nutrient_deficiencies() IS 'Kiểm tra và thông báo thiếu dinh dưỡng - uses Vietnam timezone';

-- 2. Verify and update auto_expire_pins() if it uses date comparisons
CREATE OR REPLACE FUNCTION auto_expire_pins()
RETURNS TRIGGER AS $$
DECLARE
  v_vietnam_date DATE;
BEGIN
  -- Get current Vietnam date
  v_vietnam_date := get_vietnam_date();
  
  -- Auto-expire pins where suggestion_date is in the past
  UPDATE user_pinned_suggestions
  SET is_pinned = false, updated_at = CURRENT_TIMESTAMP
  WHERE user_id = NEW.user_id 
    AND is_pinned = true
    AND suggestion_date < v_vietnam_date;
    
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION auto_expire_pins() IS 'Tự động hết hạn các gợi ý đã pin - uses Vietnam timezone';

-- 3. Create a comprehensive daily reset scheduler function
-- This function should be called by a cron job at 00:00 Vietnam time every day
CREATE OR REPLACE FUNCTION perform_daily_reset_utc7()
RETURNS void AS $$
DECLARE
  v_vietnam_date DATE;
  v_vietnam_time TIME;
  v_reset_count INT;
BEGIN
  -- Get current Vietnam date and time
  v_vietnam_date := get_vietnam_date();
  v_vietnam_time := (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::TIME;
  
  RAISE NOTICE 'Starting daily reset at Vietnam time: % %', v_vietnam_date, v_vietnam_time;
  
  -- 1. Reset water tracking
  PERFORM reset_daily_water_utc7();
  
  -- 2. Reset Mediterranean diet tracking
  PERFORM reset_daily_mediterranean_utc7();
  
  -- 3. Cleanup old daily meal suggestions (older than 7 days)
  SELECT cleanup_old_daily_suggestions() INTO v_reset_count;
  RAISE NOTICE 'Cleaned up % old meal suggestions', v_reset_count;
  
  -- 4. Check and notify nutrient deficiencies for yesterday
  PERFORM check_and_notify_nutrient_deficiencies();
  
  -- 5. Auto-expire old pinned suggestions (delete expired ones)
  DELETE FROM user_pinned_suggestions
  WHERE expires_at < CURRENT_TIMESTAMP;
  
  GET DIAGNOSTICS v_reset_count = ROW_COUNT;
  RAISE NOTICE 'Auto-expired % pinned suggestions', v_reset_count;
  
  -- 6. Log the reset
  INSERT INTO daily_reset_history (reset_type, reset_date, reset_timestamp)
  VALUES ('full_daily_reset', v_vietnam_date, CURRENT_TIMESTAMP)
  ON CONFLICT (reset_type, reset_date) DO NOTHING;
  
  RAISE NOTICE 'Daily reset completed successfully for %', v_vietnam_date;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION perform_daily_reset_utc7() IS 'Thực hiện tất cả các reset hàng ngày lúc 00:00 Vietnam time - GỌI HÀM NÀY TỪ CRON JOB';

-- 4. Create helper function to check if it's time to reset (can be called from application)
CREATE OR REPLACE FUNCTION should_perform_daily_reset()
RETURNS BOOLEAN AS $$
DECLARE
  v_vietnam_date DATE;
  v_last_reset_date DATE;
BEGIN
  v_vietnam_date := get_vietnam_date();
  
  -- Check last full reset
  SELECT reset_date INTO v_last_reset_date
  FROM daily_reset_history
  WHERE reset_type = 'full_daily_reset'
  ORDER BY reset_date DESC
  LIMIT 1;
  
  -- Return true if we haven't reset today yet
  RETURN (v_last_reset_date IS NULL OR v_last_reset_date < v_vietnam_date);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION should_perform_daily_reset() IS 'Kiểm tra xem đã đến lúc reset hàng ngày chưa';

-- 5. Create trigger function to auto-reset on first access of new day
CREATE OR REPLACE FUNCTION trg_auto_daily_reset()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if we need to reset for new day
  IF should_perform_daily_reset() THEN
    PERFORM perform_daily_reset_utc7();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION trg_auto_daily_reset() IS 'Trigger function để tự động reset khi bắt đầu ngày mới';

-- 6. Apply auto-reset trigger to key tables that are accessed frequently
-- This ensures reset happens automatically when users start using the app each day

DROP TRIGGER IF EXISTS auto_daily_reset_on_waterlog ON waterlog;
CREATE TRIGGER auto_daily_reset_on_waterlog
  BEFORE INSERT ON waterlog
  FOR EACH STATEMENT
  EXECUTE FUNCTION trg_auto_daily_reset();

DROP TRIGGER IF EXISTS auto_daily_reset_on_meal_entry ON meal_entries;
CREATE TRIGGER auto_daily_reset_on_meal_entry
  BEFORE INSERT ON meal_entries
  FOR EACH STATEMENT
  EXECUTE FUNCTION trg_auto_daily_reset();

DROP TRIGGER IF EXISTS auto_daily_reset_on_userprofile_update ON userprofile;
CREATE TRIGGER auto_daily_reset_on_userprofile_update
  BEFORE UPDATE ON userprofile
  FOR EACH STATEMENT
  EXECUTE FUNCTION trg_auto_daily_reset();

-- 7. Verify all timezone helper functions exist
DO $$
BEGIN
  -- Check if get_vietnam_date() exists
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc WHERE proname = 'get_vietnam_date'
  ) THEN
    RAISE EXCEPTION 'Function get_vietnam_date() does not exist. Please run fix_timezone_utc_plus_7.sql first.';
  END IF;
  
  -- Check if to_vietnam_date() exists
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc WHERE proname = 'to_vietnam_date'
  ) THEN
    RAISE EXCEPTION 'Function to_vietnam_date() does not exist. Please run fix_timezone_utc_plus_7.sql first.';
  END IF;
  
  RAISE NOTICE 'All timezone helper functions are present.';
END $$;

COMMIT;

-- ================================================================
-- USAGE INSTRUCTIONS
-- ================================================================
-- 
-- 1. Auto Reset (Recommended):
--    Các triggers đã được tạo sẽ tự động gọi reset khi có activity đầu tiên
--    trong ngày mới. Không cần setup cron job.
--
-- 2. Manual Reset (Nếu cần):
--    SELECT perform_daily_reset_utc7();
--
-- 3. Check if reset needed:
--    SELECT should_perform_daily_reset();
--
-- 4. External Cron Job (Tùy chọn):
--    Nếu muốn chủ động reset lúc đúng 00:00 VN time, setup cron:
--    
--    Linux/Mac crontab (chạy lúc 00:00 UTC+7 = 17:00 UTC ngày hôm trước):
--    0 17 * * * psql -U postgres -d Health -c "SELECT perform_daily_reset_utc7();"
--    
--    Windows Task Scheduler:
--    Time: 00:00 daily
--    Action: powershell.exe -Command "$env:PGPASSWORD='password'; psql -U postgres -d Health -c 'SELECT perform_daily_reset_utc7();'"
--
-- ================================================================
