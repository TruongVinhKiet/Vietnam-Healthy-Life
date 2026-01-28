-- Add meal settings columns to usersetting table
-- This allows users to customize their daily meal suggestions

ALTER TABLE usersetting 
ADD COLUMN IF NOT EXISTS breakfast_dish_count INTEGER DEFAULT 2,
ADD COLUMN IF NOT EXISTS breakfast_drink_count INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS lunch_dish_count INTEGER DEFAULT 2,
ADD COLUMN IF NOT EXISTS lunch_drink_count INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS dinner_dish_count INTEGER DEFAULT 2,
ADD COLUMN IF NOT EXISTS dinner_drink_count INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS snack_dish_count INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS snack_drink_count INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS breakfast_percentage INTEGER DEFAULT 25,
ADD COLUMN IF NOT EXISTS lunch_percentage INTEGER DEFAULT 35,
ADD COLUMN IF NOT EXISTS dinner_percentage INTEGER DEFAULT 30,
ADD COLUMN IF NOT EXISTS snack_percentage INTEGER DEFAULT 10;

-- Add check constraint to ensure percentages sum to 100
ALTER TABLE usersetting 
ADD CONSTRAINT check_meal_percentages 
CHECK (
  breakfast_percentage + lunch_percentage + dinner_percentage + snack_percentage = 100
);

COMMENT ON COLUMN usersetting.breakfast_dish_count IS 'Number of dishes suggested for breakfast';
COMMENT ON COLUMN usersetting.breakfast_drink_count IS 'Number of drinks suggested for breakfast';
COMMENT ON COLUMN usersetting.lunch_dish_count IS 'Number of dishes suggested for lunch';
COMMENT ON COLUMN usersetting.lunch_drink_count IS 'Number of drinks suggested for lunch';
COMMENT ON COLUMN usersetting.dinner_dish_count IS 'Number of dishes suggested for dinner';
COMMENT ON COLUMN usersetting.dinner_drink_count IS 'Number of drinks suggested for dinner';
COMMENT ON COLUMN usersetting.snack_dish_count IS 'Number of dishes suggested for snacks';
COMMENT ON COLUMN usersetting.snack_drink_count IS 'Number of drinks suggested for snacks';
COMMENT ON COLUMN usersetting.breakfast_percentage IS 'Percentage of daily nutrients for breakfast (0-100)';
COMMENT ON COLUMN usersetting.lunch_percentage IS 'Percentage of daily nutrients for lunch (0-100)';
COMMENT ON COLUMN usersetting.dinner_percentage IS 'Percentage of daily nutrients for dinner (0-100)';
COMMENT ON COLUMN usersetting.snack_percentage IS 'Percentage of daily nutrients for snacks (0-100)';
