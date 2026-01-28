-- ================================================================
-- COMPREHENSIVE FIX FOR CHAT TIMEZONE - FIX ALL ORDER BY CLAUSES
-- ================================================================
-- Fix tất cả ORDER BY để sử dụng converted timestamps
-- Date: 2025-12-13
-- ================================================================

BEGIN;

-- This migration is informational - actual fixes are in controller code
-- All ORDER BY clauses in chat queries must use converted timestamps:
-- ORDER BY (created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh') ASC

-- Pattern to use in all queries:
-- SELECT (created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh') AS created_at
-- FROM table
-- ORDER BY (created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh') ASC

COMMENT ON FUNCTION format_vietnam_timestamp_iso(TIMESTAMP WITH TIME ZONE) IS 
'CRITICAL: Use this to format timestamps with +07:00 timezone for Flutter client';

COMMIT;

