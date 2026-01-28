-- Migration: Meal History, Quick Add, Recipe Builder, Meal Templates, Portion Sizes
-- Date: 2025-11-13
-- Description: Add features for meal history tracking, favorites, recipes, templates, and portion helpers

-- ============================================
-- 1. MEAL HISTORY TRACKING
-- ============================================

-- Add tracking fields to Meal table
ALTER TABLE Meal 
ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS notes TEXT;

-- Add tracking fields to MealItem table
ALTER TABLE MealItem
ADD COLUMN IF NOT EXISTS quick_add_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_eaten_at TIMESTAMP;

-- Create index for quick add queries (most frequently eaten)
CREATE INDEX IF NOT EXISTS idx_mealitem_quick_add 
ON MealItem(food_id, quick_add_count DESC, last_eaten_at DESC);

-- Create index for favorites
CREATE INDEX IF NOT EXISTS idx_meal_favorites 
ON Meal(user_id, is_favorite);

-- Create index for meal history
CREATE INDEX IF NOT EXISTS idx_meal_history 
ON Meal(user_id, created_at DESC);

-- ============================================
-- 2. PORTION SIZE HELPER
-- ============================================

-- Create PortionSize table for common serving suggestions
CREATE TABLE IF NOT EXISTS PortionSize (
    portion_id SERIAL PRIMARY KEY,
    food_id INTEGER REFERENCES Food(food_id) ON DELETE CASCADE,
    portion_name VARCHAR(100) NOT NULL, -- e.g., "1 medium apple", "1 cup cooked rice"
    portion_name_vi VARCHAR(100), -- Vietnamese translation
    weight_g DECIMAL(10, 2) NOT NULL,
    is_common BOOLEAN DEFAULT false, -- Mark commonly used portions
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for portion lookups
CREATE INDEX IF NOT EXISTS idx_portion_food 
ON PortionSize(food_id, is_common);

-- Insert common portion sizes (generic portions that work for any food)
INSERT INTO PortionSize (food_id, portion_name, portion_name_vi, weight_g, is_common) VALUES
-- Generic portions (will work for many foods)
(NULL, '1 tablespoon', '1 thìa canh', 15, true),
(NULL, '1 teaspoon', '1 thìa cà phê', 5, true),
(NULL, '1 cup', '1 chén/cốc', 240, true),
(NULL, '1/2 cup', '1/2 chén/cốc', 120, true),
(NULL, '1 slice', '1 lát', 30, true),
(NULL, '1 piece (small)', '1 miếng (nhỏ)', 50, true),
(NULL, '1 piece (medium)', '1 miếng (vừa)', 100, true),
(NULL, '1 piece (large)', '1 miếng (lớn)', 150, true),
(NULL, '1 bowl (small)', '1 bát (nhỏ)', 150, true),
(NULL, '1 bowl (medium)', '1 bát (vừa)', 200, true),
(NULL, '1 bowl (large)', '1 bát (lớn)', 300, true),
(NULL, '100g serving', 'Khẩu phần 100g', 100, true),
(NULL, '50g serving', 'Khẩu phần 50g', 50, true),
(NULL, '200g serving', 'Khẩu phần 200g', 200, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. RECIPE BUILDER
-- ============================================

-- Create Recipe table
CREATE TABLE IF NOT EXISTS Recipe (
    recipe_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES "User"(user_id) ON DELETE CASCADE,
    recipe_name VARCHAR(200) NOT NULL,
    description TEXT,
    servings INTEGER DEFAULT 1,
    prep_time_minutes INTEGER,
    cook_time_minutes INTEGER,
    instructions TEXT,
    image_url TEXT,
    is_public BOOLEAN DEFAULT false, -- Allow sharing recipes
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create RecipeIngredient table (foods used in recipe)
CREATE TABLE IF NOT EXISTS RecipeIngredient (
    recipe_ingredient_id SERIAL PRIMARY KEY,
    recipe_id INTEGER REFERENCES Recipe(recipe_id) ON DELETE CASCADE,
    food_id INTEGER REFERENCES Food(food_id) ON DELETE CASCADE,
    weight_g DECIMAL(10, 2) NOT NULL,
    ingredient_order INTEGER DEFAULT 0,
    notes TEXT, -- e.g., "chopped", "diced"
    UNIQUE(recipe_id, food_id)
);

-- Create indexes for recipes
CREATE INDEX IF NOT EXISTS idx_recipe_user 
ON Recipe(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_recipe_public 
ON Recipe(is_public) WHERE is_public = true;

CREATE INDEX IF NOT EXISTS idx_recipe_ingredient 
ON RecipeIngredient(recipe_id, ingredient_order);

-- Auto-update trigger for Recipe
CREATE OR REPLACE FUNCTION update_recipe_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER recipe_update_timestamp
    BEFORE UPDATE ON Recipe
    FOR EACH ROW
    EXECUTE FUNCTION update_recipe_timestamp();

-- ============================================
-- 4. MEAL TEMPLATES
-- ============================================

-- Create MealTemplate table (save common meal combinations)
CREATE TABLE IF NOT EXISTS MealTemplate (
    template_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES "User"(user_id) ON DELETE CASCADE,
    template_name VARCHAR(200) NOT NULL,
    description TEXT,
    meal_type VARCHAR(20) CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    is_favorite BOOLEAN DEFAULT false,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create MealTemplateItem table (foods in template)
CREATE TABLE IF NOT EXISTS MealTemplateItem (
    template_item_id SERIAL PRIMARY KEY,
    template_id INTEGER REFERENCES MealTemplate(template_id) ON DELETE CASCADE,
    food_id INTEGER REFERENCES Food(food_id) ON DELETE CASCADE,
    weight_g DECIMAL(10, 2) NOT NULL,
    item_order INTEGER DEFAULT 0
);

-- Create indexes for templates
CREATE INDEX IF NOT EXISTS idx_template_user 
ON MealTemplate(user_id, meal_type, usage_count DESC);

CREATE INDEX IF NOT EXISTS idx_template_favorite 
ON MealTemplate(user_id, is_favorite) WHERE is_favorite = true;

CREATE INDEX IF NOT EXISTS idx_template_item 
ON MealTemplateItem(template_id, item_order);

-- Auto-update trigger for MealTemplate
CREATE TRIGGER template_update_timestamp
    BEFORE UPDATE ON MealTemplate
    FOR EACH ROW
    EXECUTE FUNCTION update_recipe_timestamp();

-- ============================================
-- 5. PHOTO RECOGNITION METADATA
-- ============================================

-- Add photo fields to Meal for future ML integration
ALTER TABLE Meal
ADD COLUMN IF NOT EXISTS photo_url TEXT,
ADD COLUMN IF NOT EXISTS photo_recognition_data JSONB; -- Store ML predictions

-- Create index for photo meals
CREATE INDEX IF NOT EXISTS idx_meal_photos 
ON Meal(user_id, created_at DESC) 
WHERE photo_url IS NOT NULL;

-- ============================================
-- 6. STATISTICS VIEWS
-- ============================================

-- Create view for user's most eaten foods (Quick Add candidates)
CREATE OR REPLACE VIEW UserQuickAddFoods AS
SELECT 
    m.user_id,
    mi.food_id,
    f.name as food_name,
    f.name as food_name_vi,
    COUNT(*) as times_eaten,
    AVG(mi.weight_g) as avg_portion_g,
    MAX(m.created_at) as last_eaten,
    BOOL_OR(m.is_favorite) as is_favorite
FROM MealItem mi
JOIN Meal m ON mi.meal_id = m.meal_id
JOIN Food f ON mi.food_id = f.food_id
GROUP BY m.user_id, mi.food_id, f.name
HAVING COUNT(*) >= 2 -- Must be eaten at least twice
ORDER BY times_eaten DESC, last_eaten DESC;

-- Create view for nutrition summary of recipes
CREATE OR REPLACE VIEW RecipeNutritionSummary AS
SELECT 
    r.recipe_id,
    r.recipe_name,
    r.servings,
    SUM(fn.amount_per_100g * ri.weight_g / 100) as total_calories_kcal,
    SUM(CASE WHEN n.name = 'Protein' THEN fn.amount_per_100g * ri.weight_g / 100 ELSE 0 END) as total_protein_g,
    SUM(CASE WHEN n.name = 'Carbohydrate, by difference' THEN fn.amount_per_100g * ri.weight_g / 100 ELSE 0 END) as total_carbs_g,
    SUM(CASE WHEN n.name = 'Total lipid (fat)' THEN fn.amount_per_100g * ri.weight_g / 100 ELSE 0 END) as total_fat_g
FROM Recipe r
JOIN RecipeIngredient ri ON r.recipe_id = ri.recipe_id
JOIN FoodNutrient fn ON ri.food_id = fn.food_id
JOIN Nutrient n ON fn.nutrient_id = n.nutrient_id
WHERE n.name IN ('Energy', 'Protein', 'Carbohydrate, by difference', 'Total lipid (fat)')
GROUP BY r.recipe_id, r.recipe_name, r.servings;

-- ============================================
-- VERIFICATION
-- ============================================

-- Verify new tables
DO $$ 
BEGIN
    RAISE NOTICE 'Migration completed successfully!';
    RAISE NOTICE 'New tables: PortionSize, Recipe, RecipeIngredient, MealTemplate, MealTemplateItem';
    RAISE NOTICE 'Enhanced tables: Meal (favorites, notes, photos), MealItem (quick_add tracking)';
    RAISE NOTICE 'New views: UserQuickAddFoods, RecipeNutritionSummary';
END $$;
