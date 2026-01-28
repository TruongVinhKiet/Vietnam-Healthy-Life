-- ================================================================
-- FIX CHAT QUERIES ORDER BY - USE CONVERTED TIMESTAMPS
-- ================================================================
-- Vấn đề: ORDER BY dùng created_at gốc (UTC) nhưng SELECT convert sang VN timezone
-- Kết quả: Messages bị sắp xếp sai thứ tự
-- Date: 2025-12-13
-- ================================================================

-- Note: This migration is informational - actual fixes are in controllers
-- All ORDER BY clauses now use converted timestamps

COMMENT ON FUNCTION get_vietnam_timestamp() IS 'CRITICAL: Always ORDER BY converted timestamp, not original created_at';

-- Example of correct pattern:
-- ORDER BY (created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh') ASC

