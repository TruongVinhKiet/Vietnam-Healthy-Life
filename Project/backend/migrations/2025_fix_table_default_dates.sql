-- ================================================================
-- FIX TABLE DEFAULT VALUES TO USE VIETNAM TIMEZONE
-- ================================================================
-- Sửa các bảng có DEFAULT CURRENT_DATE thành get_vietnam_date()
-- Date: 2025-12-13
-- ================================================================

BEGIN;

-- 1. Fix user_meal_targets.target_date
ALTER TABLE user_meal_targets 
  ALTER COLUMN target_date SET DEFAULT get_vietnam_date();

-- 2. Fix meal_entries.entry_date
ALTER TABLE meal_entries 
  ALTER COLUMN entry_date SET DEFAULT get_vietnam_date();

-- 3. Fix user_meal_summaries.summary_date
ALTER TABLE user_meal_summaries 
  ALTER COLUMN summary_date SET DEFAULT get_vietnam_date();

-- 4. Fix usernutrienttracking.date
ALTER TABLE usernutrienttracking 
  ALTER COLUMN date SET DEFAULT get_vietnam_date();

-- 5. Fix userhealthcondition.diagnosed_date
ALTER TABLE userhealthcondition 
  ALTER COLUMN diagnosed_date SET DEFAULT get_vietnam_date();

-- 6. Fix userhealthcondition.treatment_start_date
ALTER TABLE userhealthcondition 
  ALTER COLUMN treatment_start_date SET DEFAULT get_vietnam_date();

-- 7. Fix water_intake.date
ALTER TABLE water_intake 
  ALTER COLUMN date SET DEFAULT get_vietnam_date();

-- 8. Fix usernutrientmanuallog.log_date
ALTER TABLE usernutrientmanuallog 
  ALTER COLUMN log_date SET DEFAULT get_vietnam_date();

-- 9. Check and fix DailySummary.date if exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'dailysummary' AND column_name = 'date'
  ) THEN
    ALTER TABLE DailySummary 
      ALTER COLUMN date SET DEFAULT get_vietnam_date();
    RAISE NOTICE 'Fixed DailySummary.date default';
  END IF;
END $$;

-- 10. Check and fix Meal.meal_date if exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'meal' AND column_name = 'meal_date'
  ) THEN
    -- Check if default is CURRENT_DATE
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'meal' 
        AND column_name = 'meal_date'
        AND column_default LIKE '%CURRENT_DATE%'
    ) THEN
      ALTER TABLE Meal 
        ALTER COLUMN meal_date SET DEFAULT get_vietnam_date();
      RAISE NOTICE 'Fixed Meal.meal_date default';
    END IF;
  END IF;
END $$;

-- 11. Check and fix WaterLog.date if exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'waterlog' AND column_name = 'date'
  ) THEN
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'waterlog' 
        AND column_name = 'date'
        AND column_default LIKE '%CURRENT_DATE%'
    ) THEN
      ALTER TABLE WaterLog 
        ALTER COLUMN date SET DEFAULT get_vietnam_date();
      RAISE NOTICE 'Fixed WaterLog.date default';
    END IF;
  END IF;
END $$;

-- 12. Fix user_daily_meal_suggestions.date
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_daily_meal_suggestions' AND column_name = 'date'
  ) THEN
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'user_daily_meal_suggestions' 
        AND column_name = 'date'
        AND column_default LIKE '%CURRENT_DATE%'
    ) THEN
      ALTER TABLE user_daily_meal_suggestions 
        ALTER COLUMN date SET DEFAULT get_vietnam_date();
      RAISE NOTICE 'Fixed user_daily_meal_suggestions.date default';
    END IF;
  END IF;
END $$;

-- 13. Verify all changes
SELECT 
  table_name, 
  column_name, 
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND column_default LIKE '%vietnam%'
ORDER BY table_name, column_name;

COMMIT;

-- ================================================================
-- SUMMARY
-- ================================================================
-- Đã sửa 8+ bảng để sử dụng get_vietnam_date() thay vì CURRENT_DATE
-- Các bảng được sửa:
-- 1. user_meal_targets
-- 2. meal_entries
-- 3. user_meal_summaries
-- 4. usernutrienttracking
-- 5. userhealthcondition (2 columns)
-- 6. water_intake
-- 7. usernutrientmanuallog
-- 8. DailySummary (nếu có)
-- 9. Meal (nếu có)
-- 10. WaterLog (nếu có)
-- 11. user_daily_meal_suggestions (nếu có)
-- ================================================================
