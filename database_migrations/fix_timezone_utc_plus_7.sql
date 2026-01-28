-- ================================================================
-- FIX TIMEZONE TO UTC+7 (Vietnam Time)
-- ================================================================
-- This migration ensures all date/time operations use Vietnam timezone
-- and adds helper functions for consistent date handling
-- ================================================================

-- 1. Set database timezone to UTC+7
SET TIMEZONE='Asia/Ho_Chi_Minh';

-- 2. Create helper function to get current Vietnam date
CREATE OR REPLACE FUNCTION get_vietnam_date()
RETURNS DATE AS $$
BEGIN
  RETURN (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION get_vietnam_date() IS 'Returns current date in Vietnam timezone (UTC+7)';

-- 3. Create helper function to convert timestamp to Vietnam date
CREATE OR REPLACE FUNCTION to_vietnam_date(ts TIMESTAMP WITH TIME ZONE)
RETURNS DATE AS $$
BEGIN
  RETURN (ts AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION to_vietnam_date(TIMESTAMP WITH TIME ZONE) IS 'Converts timestamp to Vietnam timezone date';

-- 4. Create helper function to get start of day in Vietnam timezone
CREATE OR REPLACE FUNCTION vietnam_date_start(d DATE)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
  RETURN (d || ' 00:00:00')::TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION vietnam_date_start(DATE) IS 'Returns start of day (00:00:00) in Vietnam timezone';

-- 5. Create helper function to get end of day in Vietnam timezone
CREATE OR REPLACE FUNCTION vietnam_date_end(d DATE)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
  RETURN (d || ' 23:59:59')::TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION vietnam_date_end(DATE) IS 'Returns end of day (23:59:59) in Vietnam timezone';

-- 6. Update DailySummary table to ensure date column uses Vietnam timezone
-- Add index for better performance on date queries
CREATE INDEX IF NOT EXISTS idx_dailysummary_user_date_vietnam 
ON DailySummary(user_id, to_vietnam_date(created_at));

-- 7. Update Water_Intake table index
CREATE INDEX IF NOT EXISTS idx_waterintake_user_date_vietnam 
ON Water_Intake(user_id, to_vietnam_date(created_at));

-- 8. Create trigger to automatically set Vietnam date on insert/update
CREATE OR REPLACE FUNCTION set_vietnam_date_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_TABLE_NAME = 'DailySummary' AND NEW.date IS NULL THEN
    NEW.date := get_vietnam_date();
  END IF;
  IF TG_TABLE_NAME = 'Water_Intake' AND NEW.date IS NULL THEN
    NEW.date := get_vietnam_date();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. Apply triggers to relevant tables
DROP TRIGGER IF EXISTS set_vietnam_date_dailysummary ON DailySummary;
CREATE TRIGGER set_vietnam_date_dailysummary
  BEFORE INSERT ON DailySummary
  FOR EACH ROW
  EXECUTE FUNCTION set_vietnam_date_trigger();

DROP TRIGGER IF EXISTS set_vietnam_date_waterintake ON Water_Intake;
CREATE TRIGGER set_vietnam_date_waterintake
  BEFORE INSERT ON Water_Intake
  FOR EACH ROW
  EXECUTE FUNCTION set_vietnam_date_trigger();

-- 10. Create view for today's summary (Vietnam timezone)
CREATE OR REPLACE VIEW today_summary_vietnam AS
SELECT 
  ds.*,
  get_vietnam_date() as current_vietnam_date
FROM DailySummary ds
WHERE ds.date = get_vietnam_date();

COMMENT ON VIEW today_summary_vietnam IS 'Shows today''s daily summary in Vietnam timezone';

-- 11. Create view for today's water intake (Vietnam timezone)
CREATE OR REPLACE VIEW today_water_vietnam AS
SELECT 
  wi.*,
  get_vietnam_date() as current_vietnam_date
FROM Water_Intake wi
WHERE wi.date = get_vietnam_date();

COMMENT ON VIEW today_water_vietnam IS 'Shows today''s water intake in Vietnam timezone';

-- ================================================================
-- VERIFICATION QUERIES
-- ================================================================
-- Run these to verify timezone is correctly set:
--
-- SELECT get_vietnam_date() as vietnam_date, CURRENT_DATE as utc_date;
-- SELECT CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh' as vietnam_time;
-- SELECT * FROM today_summary_vietnam;
-- SELECT * FROM today_water_vietnam;
-- ================================================================
