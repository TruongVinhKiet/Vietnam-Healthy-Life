-- ================================================================
-- FIX TIMEZONE CONVERSION - SIMPLIFIED APPROACH
-- ================================================================
-- The issue: Complex AT TIME ZONE conversions can be confusing
-- Solution: Use simple CURRENT_TIMESTAMP + INTERVAL approach
-- Date: 2025-12-13 16:11
-- ================================================================

BEGIN;

-- 1. Simplified get_vietnam_date() - Direct conversion
CREATE OR REPLACE FUNCTION get_vietnam_date()
RETURNS DATE AS $$
BEGIN
  -- Convert current timestamp to Vietnam timezone and extract date
  RETURN (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE;
END;
$$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION get_vietnam_date() IS 'Returns current date in Vietnam timezone (UTC+7) - VOLATILE';

-- 2. Fix to_vietnam_date()
CREATE OR REPLACE FUNCTION to_vietnam_date(ts TIMESTAMP WITH TIME ZONE)
RETURNS DATE AS $$
BEGIN
  RETURN (ts AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION to_vietnam_date(TIMESTAMP WITH TIME ZONE) IS 'Converts timestamp to Vietnam timezone date - STABLE';

-- 3. Test the function
DO $$
DECLARE
  v_date DATE;
  v_time TIME;
  v_timestamp TIMESTAMPTZ;
BEGIN
  RAISE NOTICE '=== TIMEZONE DEBUG ===';
  RAISE NOTICE 'Server timezone: %', current_setting('TIMEZONE');
  RAISE NOTICE 'Server CURRENT_TIMESTAMP: %', CURRENT_TIMESTAMP;
  
  v_timestamp := CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh';
  RAISE NOTICE 'Vietnam TIMESTAMP: %', v_timestamp;
  
  v_date := get_vietnam_date();
  v_time := (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh')::TIME;
  
  RAISE NOTICE 'Vietnam DATE: %', v_date;
  RAISE NOTICE 'Vietnam TIME: %', v_time;
  RAISE NOTICE 'Expected: 2025-12-13';
  
  IF v_date = '2025-12-13' THEN
    RAISE NOTICE '✓✓✓ DATE IS CORRECT! ✓✓✓';
  ELSE
    RAISE WARNING 'Date mismatch! Got % but expected 2025-12-13', v_date;
  END IF;
END $$;

-- 4. Recreate views that were dropped
CREATE OR REPLACE VIEW today_summary_vietnam AS
SELECT 
  ds.*,
  get_vietnam_date() as current_vietnam_date
FROM DailySummary ds
WHERE ds.date = get_vietnam_date();

COMMENT ON VIEW today_summary_vietnam IS 'Shows today''s daily summary in Vietnam timezone';

CREATE OR REPLACE VIEW today_water_vietnam AS
SELECT 
  wi.*,
  get_vietnam_date() as current_vietnam_date
FROM Water_Intake wi
WHERE wi.date = get_vietnam_date();

COMMENT ON VIEW today_water_vietnam IS 'Shows today''s water intake in Vietnam timezone';

-- 5. Restore table defaults
ALTER TABLE user_meal_targets ALTER COLUMN target_date SET DEFAULT get_vietnam_date();
ALTER TABLE meal_entries ALTER COLUMN entry_date SET DEFAULT get_vietnam_date();
ALTER TABLE user_meal_summaries ALTER COLUMN summary_date SET DEFAULT get_vietnam_date();
ALTER TABLE usernutrienttracking ALTER COLUMN date SET DEFAULT get_vietnam_date();
ALTER TABLE userhealthcondition ALTER COLUMN diagnosed_date SET DEFAULT get_vietnam_date();
ALTER TABLE userhealthcondition ALTER COLUMN treatment_start_date SET DEFAULT get_vietnam_date();
ALTER TABLE water_intake ALTER COLUMN date SET DEFAULT get_vietnam_date();
ALTER TABLE usernutrientmanuallog ALTER COLUMN log_date SET DEFAULT get_vietnam_date();
ALTER TABLE dailysummary ALTER COLUMN date SET DEFAULT get_vietnam_date();

COMMIT;
