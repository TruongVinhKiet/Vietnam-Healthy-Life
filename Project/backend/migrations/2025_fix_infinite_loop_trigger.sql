-- ================================================================
-- FIX INFINITE LOOP IN AUTO DAILY RESET TRIGGER
-- ================================================================
-- Xóa trigger auto-reset trên userprofile vì nó gây vòng lặp
-- Date: 2025-12-13
-- ================================================================

BEGIN;

-- 1. Drop the problematic trigger on userprofile
DROP TRIGGER IF EXISTS auto_daily_reset_on_userprofile_update ON userprofile;

-- 2. Keep only triggers on data entry points (waterlog, meal_entries)
-- These are safe because reset functions don't modify these tables

-- 3. Verify remaining triggers
SELECT 
  tgname as trigger_name,
  tgrelid::regclass as table_name,
  proname as function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgisinternal = false 
  AND tgname LIKE '%auto_daily_reset%'
ORDER BY tgname;

COMMIT;

-- ================================================================
-- NOTES
-- ================================================================
-- Auto-reset triggers chỉ còn trên:
-- 1. waterlog - Khi user log nước đầu tiên trong ngày
-- 2. meal_entries - Khi user thêm món ăn đầu tiên trong ngày
--
-- Không có trigger trên userprofile để tránh vòng lặp vì
-- reset_daily_mediterranean_utc7() UPDATE userprofile
-- ================================================================
