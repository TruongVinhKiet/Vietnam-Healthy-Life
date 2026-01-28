-- Migration: Create user_daily_meal_suggestions table
-- Purpose: Store daily meal/drink suggestions for users
-- Date: 2025-12-08

-- Drop existing table if exists (for clean migration)
DROP TABLE IF EXISTS user_daily_meal_suggestions CASCADE;

-- Create main suggestions table
CREATE TABLE user_daily_meal_suggestions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  date DATE NOT NULL,
  meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  dish_id INTEGER REFERENCES dish(dish_id) ON DELETE CASCADE,
  drink_id INTEGER REFERENCES drink(drink_id) ON DELETE CASCADE,
  is_accepted BOOLEAN DEFAULT FALSE,
  is_rejected BOOLEAN DEFAULT FALSE,
  suggestion_score DECIMAL(5,2) DEFAULT 0.00, -- Score phù hợp (0-100)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CONSTRAINT check_dish_or_drink CHECK (
    (dish_id IS NOT NULL AND drink_id IS NULL) OR 
    (dish_id IS NULL AND drink_id IS NOT NULL)
  ),
  
  CONSTRAINT unique_suggestion UNIQUE (user_id, date, meal_type, dish_id, drink_id)
);

-- Indexes for fast query
CREATE INDEX idx_daily_suggestions_user_date 
  ON user_daily_meal_suggestions(user_id, date);

CREATE INDEX idx_daily_suggestions_meal_type 
  ON user_daily_meal_suggestions(meal_type);

CREATE INDEX idx_daily_suggestions_accepted 
  ON user_daily_meal_suggestions(is_accepted) 
  WHERE is_accepted = TRUE;

CREATE INDEX idx_daily_suggestions_date 
  ON user_daily_meal_suggestions(date);

-- Trigger: Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_daily_suggestions_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_daily_suggestions_timestamp
BEFORE UPDATE ON user_daily_meal_suggestions
FOR EACH ROW
EXECUTE FUNCTION update_daily_suggestions_timestamp();

-- Function: Cleanup old suggestions (>7 days)
CREATE OR REPLACE FUNCTION cleanup_old_daily_suggestions()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM user_daily_meal_suggestions
  WHERE date < CURRENT_DATE - INTERVAL '7 days';
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function: Remove suggestions when meal time passed
CREATE OR REPLACE FUNCTION cleanup_passed_meal_suggestions(p_user_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
  v_breakfast_time TIME;
  v_lunch_time TIME;
  v_dinner_time TIME;
  v_snack_time TIME;
  v_current_time TIME;
BEGIN
  -- Get user's meal times from settings
  SELECT 
    COALESCE(breakfast_time, '07:00:00')::TIME,
    COALESCE(lunch_time, '11:00:00')::TIME,
    COALESCE(dinner_time, '18:00:00')::TIME,
    COALESCE(snack_time, '15:00:00')::TIME
  INTO v_breakfast_time, v_lunch_time, v_dinner_time, v_snack_time
  FROM usersetting
  WHERE user_id = p_user_id;
  
  v_current_time := CURRENT_TIME;
  
  -- Delete suggestions for meals that have passed
  DELETE FROM user_daily_meal_suggestions
  WHERE user_id = p_user_id
    AND date = CURRENT_DATE
    AND is_accepted = FALSE
    AND (
      (meal_type = 'breakfast' AND v_current_time > v_lunch_time) OR
      (meal_type = 'lunch' AND v_current_time > v_dinner_time) OR
      (meal_type = 'dinner' AND v_current_time > TIME '23:59:59') OR
      (meal_type = 'snack' AND v_current_time > v_dinner_time)
    );
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Comments for documentation
COMMENT ON TABLE user_daily_meal_suggestions IS 'Luu goi y bua an/do uong hang ngay cho user';
COMMENT ON COLUMN user_daily_meal_suggestions.suggestion_score IS 'Diem phu hop dua tren nutrients gap va health conditions (0-100)';
COMMENT ON COLUMN user_daily_meal_suggestions.is_accepted IS 'User da chap nhan goi y nay';
COMMENT ON COLUMN user_daily_meal_suggestions.is_rejected IS 'User da tu choi goi y nay';
COMMENT ON FUNCTION cleanup_old_daily_suggestions() IS 'Xoa goi y cu hon 7 ngay';
COMMENT ON FUNCTION cleanup_passed_meal_suggestions(INTEGER) IS 'Xoa goi y cua bua an da qua';

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'SUCCESS: Created user_daily_meal_suggestions table with indexes and triggers';
END $$;
