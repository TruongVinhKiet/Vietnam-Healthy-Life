-- ================================================================
-- FIX CRITICAL BUG: TIMEZONE FUNCTIONS MUST BE VOLATILE NOT IMMUTABLE
-- ================================================================
-- IMMUTABLE functions are cached by PostgreSQL and don't re-evaluate
-- This causes get_vietnam_date() to return stale dates!
-- Date: 2025-12-13 16:08
-- ================================================================

BEGIN;

-- 1. Fix get_vietnam_date() - MUST be VOLATILE to re-evaluate every time
DROP FUNCTION IF EXISTS get_vietnam_date() CASCADE;
CREATE OR REPLACE FUNCTION get_vietnam_date()
RETURNS DATE AS $$
BEGIN
  RETURN (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE;
END;
$$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION get_vietnam_date() IS 'Returns current date in Vietnam timezone (UTC+7) - VOLATILE to prevent caching';

-- 2. Fix to_vietnam_date() - Should be STABLE (deterministic for same input within transaction)
DROP FUNCTION IF EXISTS to_vietnam_date(TIMESTAMP WITH TIME ZONE) CASCADE;
CREATE OR REPLACE FUNCTION to_vietnam_date(ts TIMESTAMP WITH TIME ZONE)
RETURNS DATE AS $$
BEGIN
  RETURN (ts AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION to_vietnam_date(TIMESTAMP WITH TIME ZONE) IS 'Converts timestamp to Vietnam timezone date - STABLE';

-- 3. Fix vietnam_date_start() - Should be STABLE
DROP FUNCTION IF EXISTS vietnam_date_start(DATE) CASCADE;
CREATE OR REPLACE FUNCTION vietnam_date_start(d DATE)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
  RETURN (d || ' 00:00:00')::TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh';
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION vietnam_date_start(DATE) IS 'Returns start of day (00:00:00) in Vietnam timezone - STABLE';

-- 4. Fix vietnam_date_end() - Should be STABLE
DROP FUNCTION IF EXISTS vietnam_date_end(DATE) CASCADE;
CREATE OR REPLACE FUNCTION vietnam_date_end(d DATE)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
  RETURN (d || ' 23:59:59')::TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh';
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION vietnam_date_end(DATE) IS 'Returns end of day (23:59:59) in Vietnam timezone - STABLE';

-- 5. Verify the fix
DO $$
DECLARE
  v_date DATE;
  v_time TIME;
BEGIN
  v_date := get_vietnam_date();
  v_time := (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::TIME;
  
  RAISE NOTICE 'Current Vietnam date: %', v_date;
  RAISE NOTICE 'Current Vietnam time: %', v_time;
  RAISE NOTICE 'Expected date: 2025-12-13';
  
  IF v_date != '2025-12-13' THEN
    RAISE WARNING 'Date mismatch! Got % but expected 2025-12-13', v_date;
  ELSE
    RAISE NOTICE 'Date is correct! ✓';
  END IF;
END $$;

COMMIT;

-- ================================================================
-- EXPLANATION
-- ================================================================
-- IMMUTABLE: Function always returns same result for same input
--            PostgreSQL caches result, never re-evaluates
--            ❌ WRONG for get_vietnam_date() - date changes daily!
--
-- STABLE:    Function returns same result for same input WITHIN A TRANSACTION
--            Can be optimized but re-evaluates across transactions
--            ✓ OK for to_vietnam_date() - deterministic for same timestamp
--
-- VOLATILE:  Function can return different results even with same input
--            Never cached, always re-evaluated
--            ✓ REQUIRED for get_vietnam_date() - depends on CURRENT_TIMESTAMP
-- ================================================================
