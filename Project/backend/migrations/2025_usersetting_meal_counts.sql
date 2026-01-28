-- Migration: Add meal item count columns to usersetting
-- Purpose: Store user preferences for number of dishes/drinks per meal
-- Date: 2025-12-08

-- Add new columns for meal item counts
ALTER TABLE usersetting 
ADD COLUMN IF NOT EXISTS breakfast_dish_count INTEGER DEFAULT 2 CHECK (breakfast_dish_count >= 0 AND breakfast_dish_count <= 2),
ADD COLUMN IF NOT EXISTS breakfast_drink_count INTEGER DEFAULT 1 CHECK (breakfast_drink_count >= 0 AND breakfast_drink_count <= 2),
ADD COLUMN IF NOT EXISTS lunch_dish_count INTEGER DEFAULT 2 CHECK (lunch_dish_count >= 0 AND lunch_dish_count <= 2),
ADD COLUMN IF NOT EXISTS lunch_drink_count INTEGER DEFAULT 1 CHECK (lunch_drink_count >= 0 AND lunch_drink_count <= 2),
ADD COLUMN IF NOT EXISTS dinner_dish_count INTEGER DEFAULT 2 CHECK (dinner_dish_count >= 0 AND dinner_dish_count <= 2),
ADD COLUMN IF NOT EXISTS dinner_drink_count INTEGER DEFAULT 1 CHECK (dinner_drink_count >= 0 AND dinner_drink_count <= 2),
ADD COLUMN IF NOT EXISTS snack_dish_count INTEGER DEFAULT 1 CHECK (snack_dish_count >= 0 AND snack_dish_count <= 2),
ADD COLUMN IF NOT EXISTS snack_drink_count INTEGER DEFAULT 1 CHECK (snack_drink_count >= 0 AND snack_drink_count <= 2);

-- Trigger: Validate meal item counts (Option C - max 2 each)
CREATE OR REPLACE FUNCTION validate_meal_item_counts()
RETURNS TRIGGER AS $$
BEGIN
  -- Validate breakfast
  IF NEW.breakfast_dish_count > 2 THEN
    RAISE EXCEPTION 'Breakfast should not have more than 2 dishes for health';
  END IF;
  IF NEW.breakfast_drink_count > 2 THEN
    RAISE EXCEPTION 'Breakfast should not have more than 2 drinks for health';
  END IF;
  
  -- Validate lunch
  IF NEW.lunch_dish_count > 2 THEN
    RAISE EXCEPTION 'Lunch should not have more than 2 dishes for health';
  END IF;
  IF NEW.lunch_drink_count > 2 THEN
    RAISE EXCEPTION 'Lunch should not have more than 2 drinks for health';
  END IF;
  
  -- Validate dinner
  IF NEW.dinner_dish_count > 2 THEN
    RAISE EXCEPTION 'Dinner should not have more than 2 dishes for health';
  END IF;
  IF NEW.dinner_drink_count > 2 THEN
    RAISE EXCEPTION 'Dinner should not have more than 2 drinks for health';
  END IF;
  
  -- Validate snack
  IF NEW.snack_dish_count > 2 THEN
    RAISE EXCEPTION 'Snack should not have more than 2 dishes for health';
  END IF;
  IF NEW.snack_drink_count > 2 THEN
    RAISE EXCEPTION 'Snack should not have more than 2 drinks for health';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validate_meal_counts ON usersetting;
CREATE TRIGGER trigger_validate_meal_counts
BEFORE INSERT OR UPDATE ON usersetting
FOR EACH ROW
EXECUTE FUNCTION validate_meal_item_counts();

-- Set default values for existing users
UPDATE usersetting 
SET 
  breakfast_dish_count = COALESCE(breakfast_dish_count, 2),
  breakfast_drink_count = COALESCE(breakfast_drink_count, 1),
  lunch_dish_count = COALESCE(lunch_dish_count, 2),
  lunch_drink_count = COALESCE(lunch_drink_count, 1),
  dinner_dish_count = COALESCE(dinner_dish_count, 2),
  dinner_drink_count = COALESCE(dinner_drink_count, 1),
  snack_dish_count = COALESCE(snack_dish_count, 1),
  snack_drink_count = COALESCE(snack_drink_count, 1)
WHERE breakfast_dish_count IS NULL;

-- Comments
COMMENT ON COLUMN usersetting.breakfast_dish_count IS 'Number of breakfast dishes (max 2 for health)';
COMMENT ON COLUMN usersetting.breakfast_drink_count IS 'Number of breakfast drinks (max 2)';
COMMENT ON COLUMN usersetting.lunch_dish_count IS 'Number of lunch dishes (max 2)';
COMMENT ON COLUMN usersetting.lunch_drink_count IS 'Number of lunch drinks (max 2)';
COMMENT ON COLUMN usersetting.dinner_dish_count IS 'Number of dinner dishes (max 2)';
COMMENT ON COLUMN usersetting.dinner_drink_count IS 'Number of dinner drinks (max 2)';
COMMENT ON COLUMN usersetting.snack_dish_count IS 'Number of snack dishes (max 2)';
COMMENT ON COLUMN usersetting.snack_drink_count IS 'Number of snack drinks (max 2)';

-- Success message
DO $$
DECLARE
  updated_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO updated_count FROM usersetting WHERE breakfast_dish_count IS NOT NULL;
  RAISE NOTICE 'SUCCESS: Added meal count columns to usersetting table';
  RAISE NOTICE 'Updated % existing user settings with default values', updated_count;
END $$;
