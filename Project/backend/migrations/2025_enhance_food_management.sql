-- ============================================================
-- ENHANCEMENT: Food Management System
-- Adds enhanced fields and indexes for food management features
-- ============================================================

-- Add additional fields to Food table for better management
ALTER TABLE Food 
    ADD COLUMN IF NOT EXISTS description TEXT,
    ADD COLUMN IF NOT EXISTS serving_size_g NUMERIC(10,2) DEFAULT 100.00,
    ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS created_by_user INT REFERENCES "User"(user_id) ON DELETE SET NULL;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_food_category ON Food(category);
CREATE INDEX IF NOT EXISTS idx_food_name ON Food(name);
CREATE INDEX IF NOT EXISTS idx_food_active ON Food(is_active);
CREATE INDEX IF NOT EXISTS idx_foodnutrient_food ON FoodNutrient(food_id);
CREATE INDEX IF NOT EXISTS idx_foodnutrient_nutrient ON FoodNutrient(nutrient_id);

-- Add unique constraint to prevent duplicate food-nutrient mappings
ALTER TABLE FoodNutrient 
    DROP CONSTRAINT IF EXISTS unique_food_nutrient,
    ADD CONSTRAINT unique_food_nutrient UNIQUE(food_id, nutrient_id);

-- Create function to update Food updated_at timestamp
CREATE OR REPLACE FUNCTION update_food_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for Food timestamp
DROP TRIGGER IF EXISTS trg_update_food_timestamp ON Food;
CREATE TRIGGER trg_update_food_timestamp
    BEFORE UPDATE ON Food
    FOR EACH ROW
    EXECUTE FUNCTION update_food_timestamp();

-- Add food categories reference table (optional but recommended)
CREATE TABLE IF NOT EXISTS FoodCategory (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert common food categories
INSERT INTO FoodCategory (category_name, description, icon) VALUES
    ('Vegetables', 'All types of vegetables', '🥦'),
    ('Fruits', 'Fresh and dried fruits', '🍎'),
    ('Grains', 'Rice, bread, pasta, cereals', '🌾'),
    ('Protein Foods', 'Meat, poultry, fish, eggs, beans', '🥩'),
    ('Dairy', 'Milk, cheese, yogurt', '🥛'),
    ('Oils & Fats', 'Cooking oils, butter, margarine', '🧈'),
    ('Beverages', 'Drinks and liquids', '🥤'),
    ('Snacks', 'Chips, crackers, sweets', '🍿'),
    ('Mixed Dishes', 'Combined food items', '🍱'),
    ('Others', 'Miscellaneous food items', '🍽️')
ON CONFLICT (category_name) DO NOTHING;

-- Comments for documentation
COMMENT ON COLUMN Food.description IS 'Detailed description of the food item';
COMMENT ON COLUMN Food.serving_size_g IS 'Standard serving size in grams';
COMMENT ON COLUMN Food.is_verified IS 'Whether the food data has been verified by admin';
COMMENT ON COLUMN Food.is_active IS 'Whether the food is active and available for selection';
COMMENT ON COLUMN Food.created_by_user IS 'User who created this food item (for user-contributed foods)';
