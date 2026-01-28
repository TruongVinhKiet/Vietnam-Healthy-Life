-- ============================================================
-- DISH MANAGEMENT SYSTEM - MIGRATION
-- Purpose: Enable users to create and manage complete dishes (món ăn)
--          composed of multiple ingredients with automatic nutrient calculation
-- Author: System
-- Date: 2025
-- ============================================================

-- ============================================================
-- I. CORE DISH TABLES
-- ============================================================

-- Table: Dish
-- Purpose: Store dish metadata (name, description, images)
-- Each dish represents a complete meal or recipe composed of multiple foods
CREATE TABLE IF NOT EXISTS Dish (
    dish_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    vietnamese_name VARCHAR(200),  -- for bilingual support
    description TEXT,
    category VARCHAR(50),  -- 'noodle', 'rice', 'sandwich', 'soup', etc.
    serving_size_g NUMERIC(10,2) DEFAULT 100,  -- standard serving size in grams
    image_url TEXT,
    is_template BOOLEAN DEFAULT FALSE,  -- true for admin-created standard dishes
    is_public BOOLEAN DEFAULT TRUE,     -- false for user's private custom dishes
    created_by_user INT REFERENCES "User"(user_id) ON DELETE SET NULL,
    created_by_admin INT REFERENCES Admin(admin_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CHECK (serving_size_g > 0),
    CHECK (
        (created_by_user IS NOT NULL AND created_by_admin IS NULL) OR
        (created_by_user IS NULL AND created_by_admin IS NOT NULL)
    )
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_dish_name ON Dish(name);
CREATE INDEX IF NOT EXISTS idx_dish_category ON Dish(category);
CREATE INDEX IF NOT EXISTS idx_dish_creator_user ON Dish(created_by_user);
CREATE INDEX IF NOT EXISTS idx_dish_creator_admin ON Dish(created_by_admin);
CREATE INDEX IF NOT EXISTS idx_dish_is_template ON Dish(is_template);
CREATE INDEX IF NOT EXISTS idx_dish_is_public ON Dish(is_public);

-- ============================================================
-- II. DISH INGREDIENTS (JUNCTION TABLE)
-- ============================================================

-- Table: DishIngredient
-- Purpose: Map dishes to their ingredient foods with specific weights
-- This table enables calculation of dish nutrients from ingredient compositions
CREATE TABLE IF NOT EXISTS DishIngredient (
    dish_ingredient_id SERIAL PRIMARY KEY,
    dish_id INT NOT NULL REFERENCES Dish(dish_id) ON DELETE CASCADE,
    food_id INT NOT NULL REFERENCES Food(food_id) ON DELETE RESTRICT,
    weight_g NUMERIC(10,2) NOT NULL,  -- weight of this ingredient in the dish
    notes TEXT,  -- optional preparation notes for this ingredient
    display_order INT DEFAULT 0,  -- order to display ingredients in UI
    
    -- Constraints
    CHECK (weight_g > 0),
    UNIQUE(dish_id, food_id)  -- prevent duplicate ingredients in same dish
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_dish_ingredient_dish ON DishIngredient(dish_id);
CREATE INDEX IF NOT EXISTS idx_dish_ingredient_food ON DishIngredient(food_id);
CREATE INDEX IF NOT EXISTS idx_dish_ingredient_order ON DishIngredient(dish_id, display_order);

-- ============================================================
-- III. DISH IMAGES (SUPPORT MULTIPLE IMAGES PER DISH)
-- ============================================================

-- Table: DishImage
-- Purpose: Store multiple images for each dish (main photo, step-by-step, etc.)
CREATE TABLE IF NOT EXISTS DishImage (
    dish_image_id SERIAL PRIMARY KEY,
    dish_id INT NOT NULL REFERENCES Dish(dish_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    image_type VARCHAR(20) DEFAULT 'photo',  -- 'photo', 'step', 'ingredient', etc.
    is_primary BOOLEAN DEFAULT FALSE,  -- primary image for thumbnails
    display_order INT DEFAULT 0,
    caption TEXT,
    uploaded_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_dish_image_dish ON DishImage(dish_id);
CREATE INDEX IF NOT EXISTS idx_dish_image_primary ON DishImage(dish_id, is_primary);

-- ============================================================
-- IV. EXTEND MEALITEM TO SUPPORT DISHES
-- ============================================================

-- Add dish_id column to MealItem to support logging dishes instead of individual foods
ALTER TABLE MealItem
    ADD COLUMN IF NOT EXISTS dish_id INT REFERENCES Dish(dish_id) ON DELETE SET NULL;

-- Drop existing constraint if it exists (PostgreSQL doesn't support IF NOT EXISTS for constraints)
ALTER TABLE MealItem DROP CONSTRAINT IF EXISTS chk_mealitem_food_or_dish;

-- Add constraint: MealItem must have either food_id OR dish_id, not both
ALTER TABLE MealItem
    ADD CONSTRAINT chk_mealitem_food_or_dish CHECK (
        (food_id IS NOT NULL AND dish_id IS NULL) OR
        (food_id IS NULL AND dish_id IS NOT NULL)
    );

-- Index for dish-based meal items
CREATE INDEX IF NOT EXISTS idx_mealitem_dish ON MealItem(dish_id);

-- ============================================================
-- V. DISH STATISTICS TABLE
-- ============================================================

-- Table: DishStatistics
-- Purpose: Cache aggregated statistics about dish usage for admin dashboard
CREATE TABLE IF NOT EXISTS DishStatistics (
    stat_id SERIAL PRIMARY KEY,
    dish_id INT NOT NULL REFERENCES Dish(dish_id) ON DELETE CASCADE,
    total_times_logged INT DEFAULT 0,  -- how many times this dish was logged in meals
    unique_users_count INT DEFAULT 0,  -- how many different users logged this dish
    avg_rating NUMERIC(3,2),  -- average user rating (future feature)
    last_logged_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(dish_id)
);

-- Index
CREATE INDEX IF NOT EXISTS idx_dish_stats_dish ON DishStatistics(dish_id);
CREATE INDEX IF NOT EXISTS idx_dish_stats_popular ON DishStatistics(total_times_logged DESC);

-- ============================================================
-- VI. COMPUTED NUTRIENT STORAGE FOR DISHES
-- ============================================================

-- Table: DishNutrient
-- Purpose: Store pre-calculated nutrient values per 100g of dish
-- Calculated by summing (ingredient_weight_g * nutrient_per_100g / 100) for all ingredients
-- This mirrors FoodNutrient structure but for composed dishes
CREATE TABLE IF NOT EXISTS DishNutrient (
    dish_nutrient_id SERIAL PRIMARY KEY,
    dish_id INT NOT NULL REFERENCES Dish(dish_id) ON DELETE CASCADE,
    nutrient_id INT NOT NULL REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
    amount_per_100g NUMERIC(12,6) DEFAULT 0,  -- nutrient amount per 100g of complete dish
    calculated_at TIMESTAMP DEFAULT NOW(),
    
    UNIQUE(dish_id, nutrient_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_dish_nutrient_dish ON DishNutrient(dish_id);
CREATE INDEX IF NOT EXISTS idx_dish_nutrient_nutrient ON DishNutrient(nutrient_id);

-- ============================================================
-- VII. FUNCTIONS FOR DISH NUTRIENT CALCULATION
-- ============================================================

-- Function: calculate_dish_nutrients
-- Purpose: Calculate and store all nutrient values for a dish based on its ingredients
-- This function should be called after creating/updating dish ingredients
CREATE OR REPLACE FUNCTION calculate_dish_nutrients(p_dish_id INT) RETURNS VOID AS $$
DECLARE
    v_total_weight NUMERIC;
    v_nutrient RECORD;
    v_amount NUMERIC;
BEGIN
    -- Get total weight of all ingredients in the dish
    SELECT SUM(weight_g) INTO v_total_weight
    FROM DishIngredient
    WHERE dish_id = p_dish_id;
    
    -- If no ingredients, clear all nutrients and return
    IF v_total_weight IS NULL OR v_total_weight = 0 THEN
        DELETE FROM DishNutrient WHERE dish_id = p_dish_id;
        RETURN;
    END IF;
    
    -- For each nutrient in the system, calculate the dish's content
    FOR v_nutrient IN SELECT nutrient_id FROM Nutrient LOOP
        -- Sum up contributions from all ingredients
        -- Formula: (ingredient_weight * nutrient_per_100g / 100) for each ingredient
        -- Then normalize to per 100g of total dish weight
        SELECT SUM(
            di.weight_g * COALESCE(fn.amount_per_100g, 0) / 100.0
        ) * 100.0 / v_total_weight
        INTO v_amount
        FROM DishIngredient di
        LEFT JOIN FoodNutrient fn ON fn.food_id = di.food_id 
            AND fn.nutrient_id = v_nutrient.nutrient_id
        WHERE di.dish_id = p_dish_id;
        
        -- Upsert into DishNutrient
        IF v_amount IS NOT NULL AND v_amount > 0 THEN
            INSERT INTO DishNutrient(dish_id, nutrient_id, amount_per_100g, calculated_at)
            VALUES (p_dish_id, v_nutrient.nutrient_id, ROUND(v_amount, 6), NOW())
            ON CONFLICT (dish_id, nutrient_id) DO UPDATE
            SET amount_per_100g = EXCLUDED.amount_per_100g,
                calculated_at = EXCLUDED.calculated_at;
        ELSE
            -- Remove zero/null nutrients to keep table clean
            DELETE FROM DishNutrient 
            WHERE dish_id = p_dish_id AND nutrient_id = v_nutrient.nutrient_id;
        END IF;
    END LOOP;
    
    -- Update dish's updated_at timestamp
    UPDATE Dish SET updated_at = NOW() WHERE dish_id = p_dish_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- VIII. TRIGGERS FOR AUTOMATIC NUTRIENT RECALCULATION
-- ============================================================

-- Trigger function: recalculate dish nutrients when ingredients change
CREATE OR REPLACE FUNCTION trg_recalc_dish_nutrients() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM calculate_dish_nutrients(OLD.dish_id);
        RETURN OLD;
    ELSE
        PERFORM calculate_dish_nutrients(NEW.dish_id);
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to DishIngredient table
DROP TRIGGER IF EXISTS trg_dish_ingredient_changed ON DishIngredient;
CREATE TRIGGER trg_dish_ingredient_changed
AFTER INSERT OR UPDATE OR DELETE ON DishIngredient
FOR EACH ROW EXECUTE FUNCTION trg_recalc_dish_nutrients();

-- ============================================================
-- IX. ENHANCED MEALITEM NUTRIENT COMPUTATION (SUPPORT DISHES)
-- ============================================================

-- Update the existing compute_mealitem_nutrients function to handle dishes
-- This replaces the original function in schema.sql
CREATE OR REPLACE FUNCTION compute_mealitem_nutrients() RETURNS TRIGGER AS $$
DECLARE
    v_kcal NUMERIC := 0;
    v_protein NUMERIC := 0;
    v_fat NUMERIC := 0;
    v_carb NUMERIC := 0;
BEGIN
    -- Case 1: MealItem has a dish_id (using composed dish)
    IF NEW.dish_id IS NOT NULL THEN
        -- Get nutrients from DishNutrient table
        SELECT dn.amount_per_100g INTO v_kcal
        FROM DishNutrient dn
        JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
        WHERE dn.dish_id = NEW.dish_id AND n.nutrient_code = 'ENERC_KCAL'
        LIMIT 1;
        
        SELECT dn.amount_per_100g INTO v_protein
        FROM DishNutrient dn
        JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
        WHERE dn.dish_id = NEW.dish_id AND n.nutrient_code = 'PROCNT'
        LIMIT 1;
        
        SELECT dn.amount_per_100g INTO v_fat
        FROM DishNutrient dn
        JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
        WHERE dn.dish_id = NEW.dish_id AND n.nutrient_code = 'FAT'
        LIMIT 1;
        
        SELECT dn.amount_per_100g INTO v_carb
        FROM DishNutrient dn
        JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
        WHERE dn.dish_id = NEW.dish_id AND n.nutrient_code = 'CHOCDF'
        LIMIT 1;
        
        -- Fallback to name-based lookup if code not found
        IF v_kcal IS NULL OR v_kcal = 0 THEN
            SELECT dn.amount_per_100g INTO v_kcal 
            FROM DishNutrient dn 
            JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id 
            WHERE dn.dish_id = NEW.dish_id 
            AND (LOWER(n.name) LIKE '%calor%' OR LOWER(n.name) LIKE '%energy%')
            LIMIT 1;
        END IF;
        IF v_protein IS NULL OR v_protein = 0 THEN
            SELECT dn.amount_per_100g INTO v_protein 
            FROM DishNutrient dn 
            JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id 
            WHERE dn.dish_id = NEW.dish_id AND LOWER(n.name) LIKE '%protein%'
            LIMIT 1;
        END IF;
        IF v_fat IS NULL OR v_fat = 0 THEN
            SELECT dn.amount_per_100g INTO v_fat 
            FROM DishNutrient dn 
            JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id 
            WHERE dn.dish_id = NEW.dish_id AND LOWER(n.name) LIKE '%fat%'
            LIMIT 1;
        END IF;
        IF v_carb IS NULL OR v_carb = 0 THEN
            SELECT dn.amount_per_100g INTO v_carb 
            FROM DishNutrient dn 
            JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id 
            WHERE dn.dish_id = NEW.dish_id 
            AND (LOWER(n.name) LIKE '%carb%' OR LOWER(n.name) LIKE '%carbo%')
            LIMIT 1;
        END IF;
    
    -- Case 2: MealItem has a food_id (traditional individual food)
    ELSIF NEW.food_id IS NOT NULL THEN
        -- Use existing food nutrient lookup (keep original logic)
        SELECT fn.amount_per_100g INTO v_kcal
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id AND n.nutrient_code = 'ENERC_KCAL'
        LIMIT 1;
        
        SELECT fn.amount_per_100g INTO v_protein
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id AND n.nutrient_code = 'PROCNT'
        LIMIT 1;
        
        SELECT fn.amount_per_100g INTO v_fat
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id AND n.nutrient_code = 'FAT'
        LIMIT 1;
        
        SELECT fn.amount_per_100g INTO v_carb
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id AND n.nutrient_code = 'CHOCDF'
        LIMIT 1;
        
        -- Fallback name-based lookup
        IF v_kcal IS NULL OR v_kcal = 0 THEN
            SELECT fn.amount_per_100g INTO v_kcal 
            FROM FoodNutrient fn 
            JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
            WHERE fn.food_id = NEW.food_id 
            AND (LOWER(n.name) LIKE '%calor%' OR LOWER(n.name) LIKE '%energy%')
            LIMIT 1;
        END IF;
        IF v_protein IS NULL OR v_protein = 0 THEN
            SELECT fn.amount_per_100g INTO v_protein 
            FROM FoodNutrient fn 
            JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
            WHERE fn.food_id = NEW.food_id AND LOWER(n.name) LIKE '%protein%'
            LIMIT 1;
        END IF;
        IF v_fat IS NULL OR v_fat = 0 THEN
            SELECT fn.amount_per_100g INTO v_fat 
            FROM FoodNutrient fn 
            JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
            WHERE fn.food_id = NEW.food_id AND LOWER(n.name) LIKE '%fat%'
            LIMIT 1;
        END IF;
        IF v_carb IS NULL OR v_carb = 0 THEN
            SELECT fn.amount_per_100g INTO v_carb 
            FROM FoodNutrient fn 
            JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
            WHERE fn.food_id = NEW.food_id 
            AND (LOWER(n.name) LIKE '%carb%' OR LOWER(n.name) LIKE '%carbo%')
            LIMIT 1;
        END IF;
    
    -- Case 3: Neither food_id nor dish_id provided (should not happen due to constraint)
    ELSE
        NEW.calories := 0;
        NEW.protein := 0;
        NEW.fat := 0;
        NEW.carbs := 0;
        RETURN NEW;
    END IF;
    
    -- Null-safe coalescing
    v_kcal := COALESCE(v_kcal, 0);
    v_protein := COALESCE(v_protein, 0);
    v_fat := COALESCE(v_fat, 0);
    v_carb := COALESCE(v_carb, 0);
    
    -- Compute per item (weight_g is serving weight)
    NEW.calories := ROUND((v_kcal * NEW.weight_g) / 100.0, 2);
    NEW.protein := ROUND((v_protein * NEW.weight_g) / 100.0, 2);
    NEW.fat := ROUND((v_fat * NEW.weight_g) / 100.0, 2);
    NEW.carbs := ROUND((v_carb * NEW.weight_g) / 100.0, 2);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger already exists in schema.sql, but recreate to ensure latest function is used
DROP TRIGGER IF EXISTS trg_compute_mealitem_nutrients ON MealItem;
CREATE TRIGGER trg_compute_mealitem_nutrients
BEFORE INSERT OR UPDATE ON MealItem
FOR EACH ROW EXECUTE FUNCTION compute_mealitem_nutrients();

-- ============================================================
-- X. DISH USAGE STATISTICS TRACKING
-- ============================================================

-- Function: update_dish_statistics
-- Purpose: Update usage statistics when a dish is logged in a meal
CREATE OR REPLACE FUNCTION update_dish_statistics() RETURNS TRIGGER AS $$
DECLARE
    v_dish_id INT;
    v_user_id INT;
BEGIN
    IF TG_OP = 'INSERT' AND NEW.dish_id IS NOT NULL THEN
        v_dish_id := NEW.dish_id;
        SELECT user_id INTO v_user_id FROM Meal WHERE meal_id = NEW.meal_id;
        
        -- Upsert statistics
        INSERT INTO DishStatistics(dish_id, total_times_logged, unique_users_count, last_logged_at)
        VALUES (v_dish_id, 1, 1, NOW())
        ON CONFLICT (dish_id) DO UPDATE
        SET total_times_logged = DishStatistics.total_times_logged + 1,
            last_logged_at = NOW(),
            unique_users_count = (
                SELECT COUNT(DISTINCT m.user_id)
                FROM MealItem mi
                JOIN Meal m ON m.meal_id = mi.meal_id
                WHERE mi.dish_id = v_dish_id
            ),
            updated_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for dish statistics
DROP TRIGGER IF EXISTS trg_dish_statistics ON MealItem;
CREATE TRIGGER trg_dish_statistics
AFTER INSERT ON MealItem
FOR EACH ROW EXECUTE FUNCTION update_dish_statistics();

-- ============================================================
-- XI. HELPER FUNCTIONS FOR DISH MANAGEMENT
-- ============================================================

-- Function: get_dish_total_weight
-- Purpose: Calculate total weight of all ingredients in a dish
CREATE OR REPLACE FUNCTION get_dish_total_weight(p_dish_id INT) RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT SUM(weight_g) INTO v_total FROM DishIngredient WHERE dish_id = p_dish_id;
    RETURN COALESCE(v_total, 0);
END;
$$ LANGUAGE plpgsql;

-- Function: get_dish_ingredient_count
-- Purpose: Get number of ingredients in a dish
CREATE OR REPLACE FUNCTION get_dish_ingredient_count(p_dish_id INT) RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM DishIngredient WHERE dish_id = p_dish_id;
    RETURN COALESCE(v_count, 0);
END;
$$ LANGUAGE plpgsql;

-- Function: get_user_custom_dish_count
-- Purpose: Get count of custom dishes created by a specific user
CREATE OR REPLACE FUNCTION get_user_custom_dish_count(p_user_id INT) RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Dish WHERE created_by_user = p_user_id;
    RETURN COALESCE(v_count, 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- XII. VIEWS FOR EASY QUERYING
-- ============================================================

-- View: dish_with_stats
-- Purpose: Join dishes with their statistics for easy querying
CREATE OR REPLACE VIEW dish_with_stats AS
SELECT 
    d.dish_id,
    d.name,
    d.vietnamese_name,
    d.description,
    d.category,
    d.serving_size_g,
    d.image_url,
    d.is_template,
    d.is_public,
    d.created_by_user,
    d.created_by_admin,
    d.created_at,
    d.updated_at,
    COALESCE(ds.total_times_logged, 0) AS times_logged,
    COALESCE(ds.unique_users_count, 0) AS unique_users,
    ds.last_logged_at,
    get_dish_ingredient_count(d.dish_id) AS ingredient_count,
    get_dish_total_weight(d.dish_id) AS total_weight_g
FROM Dish d
LEFT JOIN DishStatistics ds ON ds.dish_id = d.dish_id;

-- View: dish_with_macros
-- Purpose: Show dishes with their main macronutrients (per 100g)
CREATE OR REPLACE VIEW dish_with_macros AS
SELECT 
    d.dish_id,
    d.name,
    d.category,
    d.serving_size_g,
    d.is_template,
    COALESCE(kcal.amount_per_100g, 0) AS calories_per_100g,
    COALESCE(prot.amount_per_100g, 0) AS protein_per_100g,
    COALESCE(fat.amount_per_100g, 0) AS fat_per_100g,
    COALESCE(carb.amount_per_100g, 0) AS carbs_per_100g
FROM Dish d
LEFT JOIN (
    SELECT dish_id, amount_per_100g
    FROM DishNutrient dn
    JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
    WHERE n.nutrient_code = 'ENERC_KCAL'
) kcal ON kcal.dish_id = d.dish_id
LEFT JOIN (
    SELECT dish_id, amount_per_100g
    FROM DishNutrient dn
    JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
    WHERE n.nutrient_code = 'PROCNT'
) prot ON prot.dish_id = d.dish_id
LEFT JOIN (
    SELECT dish_id, amount_per_100g
    FROM DishNutrient dn
    JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
    WHERE n.nutrient_code = 'FAT'
) fat ON fat.dish_id = d.dish_id
LEFT JOIN (
    SELECT dish_id, amount_per_100g
    FROM DishNutrient dn
    JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
    WHERE n.nutrient_code = 'CHOCDF'
) carb ON carb.dish_id = d.dish_id;

-- ============================================================
-- XIII. COMMENTS FOR DOCUMENTATION
-- ============================================================

COMMENT ON TABLE Dish IS 'Stores complete dish/recipe definitions composed of multiple foods';
COMMENT ON TABLE DishIngredient IS 'Junction table mapping dishes to their ingredient foods with weights';
COMMENT ON TABLE DishImage IS 'Stores multiple images per dish for UI display';
COMMENT ON TABLE DishNutrient IS 'Pre-calculated nutrient values per 100g of complete dish';
COMMENT ON TABLE DishStatistics IS 'Cached usage statistics for admin dashboard analytics';

COMMENT ON COLUMN Dish.is_template IS 'True for admin-created standard dishes available to all users';
COMMENT ON COLUMN Dish.is_public IS 'False for user private dishes, true for shared dishes';
COMMENT ON COLUMN DishIngredient.weight_g IS 'Weight in grams of this ingredient in the dish recipe';
COMMENT ON COLUMN DishNutrient.amount_per_100g IS 'Nutrient amount per 100g of the complete dish (calculated from ingredients)';

-- ============================================================
-- END OF DISH MANAGEMENT MIGRATION
-- ============================================================
