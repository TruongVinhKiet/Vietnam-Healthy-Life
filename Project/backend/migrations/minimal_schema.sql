-- ============================================================
-- MINIMAL SCHEMA FOR MY DIARY APP
-- Creates essential tables for advanced features to work
-- ============================================================

BEGIN;

-- User table
CREATE TABLE IF NOT EXISTS "User" (
  user_id SERIAL PRIMARY KEY,
  full_name VARCHAR(255),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  age INT,
  gender VARCHAR(10),
  sex VARCHAR(10),
  date_of_birth DATE,
  height_cm DECIMAL(5,2),
  weight_kg DECIMAL(5,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Nutrient table
CREATE TABLE IF NOT EXISTS Nutrient (
  nutrient_id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  nutrient_code VARCHAR(50) UNIQUE,
  unit VARCHAR(20),
  category VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Food table
CREATE TABLE IF NOT EXISTS Food (
  food_id SERIAL PRIMARY KEY,
  name VARCHAR(500) NOT NULL,
  name_vi VARCHAR(500),
  category VARCHAR(100),
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- FoodNutrient join table
CREATE TABLE IF NOT EXISTS FoodNutrient (
  food_nutrient_id SERIAL PRIMARY KEY,
  food_id INT NOT NULL REFERENCES Food(food_id) ON DELETE CASCADE,
  nutrient_id INT NOT NULL REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
  amount_per_100g DECIMAL(15,6),
  UNIQUE(food_id, nutrient_id)
);

-- Vitamin table
CREATE TABLE IF NOT EXISTS Vitamin (
  vitamin_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mineral table
CREATE TABLE IF NOT EXISTS Mineral (
  mineral_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- VitaminNutrient mapping
CREATE TABLE IF NOT EXISTS VitaminNutrient (
  mapping_id SERIAL PRIMARY KEY,
  vitamin_id INT NOT NULL REFERENCES Vitamin(vitamin_id) ON DELETE CASCADE,
  nutrient_id INT NOT NULL REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
  amount DECIMAL(10,4) DEFAULT 1.0,
  factor VARCHAR(50),
  UNIQUE(vitamin_id, nutrient_id)
);

-- MineralNutrient mapping
CREATE TABLE IF NOT EXISTS MineralNutrient (
  mapping_id SERIAL PRIMARY KEY,
  mineral_id INT NOT NULL REFERENCES Mineral(mineral_id) ON DELETE CASCADE,
  nutrient_id INT NOT NULL REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
  amount DECIMAL(10,4) DEFAULT 1.0,
  factor VARCHAR(50),
  UNIQUE(mineral_id, nutrient_id)
);

-- HealthCondition table
CREATE TABLE IF NOT EXISTS HealthCondition (
  condition_id SERIAL PRIMARY KEY,
  name_en VARCHAR(200) NOT NULL,
  name_vi VARCHAR(200) NOT NULL,
  description TEXT,
  severity VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ConditionNutrientEffect
CREATE TABLE IF NOT EXISTS ConditionNutrientEffect (
  effect_id SERIAL PRIMARY KEY,
  condition_id INT NOT NULL REFERENCES HealthCondition(condition_id) ON DELETE CASCADE,
  nutrient_id INT NOT NULL REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
  effect_type VARCHAR(20) NOT NULL CHECK (effect_type IN ('increase', 'decrease')),
  adjustment_percent INT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(condition_id, nutrient_id)
);

-- ConditionFoodRecommendation
CREATE TABLE IF NOT EXISTS ConditionFoodRecommendation (
  recommendation_id SERIAL PRIMARY KEY,
  condition_id INT NOT NULL REFERENCES HealthCondition(condition_id) ON DELETE CASCADE,
  food_id INT NOT NULL REFERENCES Food(food_id) ON DELETE CASCADE,
  recommendation_type VARCHAR(20) NOT NULL CHECK (recommendation_type IN ('recommend', 'avoid')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(condition_id, food_id)
);

-- Fiber table
CREATE TABLE IF NOT EXISTS Fiber (
  fiber_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- FiberRequirement
CREATE TABLE IF NOT EXISTS FiberRequirement (
  requirement_id SERIAL PRIMARY KEY,
  fiber_id INT NOT NULL REFERENCES Fiber(fiber_id) ON DELETE CASCADE,
  sex VARCHAR(10) NOT NULL CHECK (sex IN ('male', 'female')),
  age_min INT NOT NULL,
  age_max INT NOT NULL,
  rda_value DECIMAL(10,2) NOT NULL,
  unit VARCHAR(10) DEFAULT 'g',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiber_id, sex, age_min, age_max)
);

-- FoodCategory
CREATE TABLE IF NOT EXISTS FoodCategory (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  name_vi VARCHAR(100),
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- PortionSize
CREATE TABLE IF NOT EXISTS PortionSize (
  portion_id SERIAL PRIMARY KEY,
  food_id INT NOT NULL REFERENCES Food(food_id) ON DELETE CASCADE,
  portion_name VARCHAR(100) NOT NULL,
  portion_name_vi VARCHAR(100),
  weight_g DECIMAL(10,2) NOT NULL,
  is_common BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Recipe table
CREATE TABLE IF NOT EXISTS Recipe (
  recipe_id SERIAL PRIMARY KEY,
  user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
  recipe_name VARCHAR(300) NOT NULL,
  description TEXT,
  servings INT DEFAULT 1,
  prep_time_minutes INT,
  cook_time_minutes INT,
  instructions TEXT,
  image_url TEXT,
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RecipeIngredient
CREATE TABLE IF NOT EXISTS RecipeIngredient (
  recipe_ingredient_id SERIAL PRIMARY KEY,
  recipe_id INT NOT NULL REFERENCES Recipe(recipe_id) ON DELETE CASCADE,
  food_id INT NOT NULL REFERENCES Food(food_id) ON DELETE CASCADE,
  weight_g DECIMAL(10,2) NOT NULL,
  ingredient_order INT DEFAULT 1,
  notes TEXT
);

-- Suggestion table
CREATE TABLE IF NOT EXISTS Suggestion (
  suggestion_id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  date DATE NOT NULL,
  nutrient_id INT REFERENCES Nutrient(nutrient_id) ON DELETE SET NULL,
  deficiency_amount DECIMAL(10,2),
  suggested_food_id INT REFERENCES Food(food_id) ON DELETE SET NULL,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Admin table
CREATE TABLE IF NOT EXISTS Admin (
  admin_id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  role_id INT,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Role table
CREATE TABLE IF NOT EXISTS Role (
  role_id SERIAL PRIMARY KEY,
  role_name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Permission table
CREATE TABLE IF NOT EXISTS Permission (
  permission_id SERIAL PRIMARY KEY,
  permission_name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RolePermission junction table
CREATE TABLE IF NOT EXISTS RolePermission (
  role_permission_id SERIAL PRIMARY KEY,
  role_id INT NOT NULL REFERENCES Role(role_id) ON DELETE CASCADE,
  permission_id INT NOT NULL REFERENCES Permission(permission_id) ON DELETE CASCADE,
  UNIQUE(role_id, permission_id)
);

-- Meal table
CREATE TABLE IF NOT EXISTS Meal (
  meal_id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  meal_date DATE NOT NULL,
  meal_type VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MealItem table
CREATE TABLE IF NOT EXISTS MealItem (
  meal_item_id SERIAL PRIMARY KEY,
  meal_id INT NOT NULL REFERENCES Meal(meal_id) ON DELETE CASCADE,
  food_id INT REFERENCES Food(food_id) ON DELETE SET NULL,
  weight_g DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- UserVitaminRequirement
CREATE TABLE IF NOT EXISTS UserVitaminRequirement (
  requirement_id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  vitamin_id INT NOT NULL REFERENCES Vitamin(vitamin_id) ON DELETE CASCADE,
  target_amount DECIMAL(10,2) NOT NULL,
  unit VARCHAR(20),
  UNIQUE(user_id, vitamin_id)
);

-- UserMineralRequirement
CREATE TABLE IF NOT EXISTS UserMineralRequirement (
  requirement_id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  mineral_id INT NOT NULL REFERENCES Mineral(mineral_id) ON DELETE CASCADE,
  target_amount DECIMAL(10,2) NOT NULL,
  unit VARCHAR(20),
  UNIQUE(user_id, mineral_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_food_nutrient_food ON FoodNutrient(food_id);
CREATE INDEX IF NOT EXISTS idx_food_nutrient_nutrient ON FoodNutrient(nutrient_id);
CREATE INDEX IF NOT EXISTS idx_vitamin_nutrient_vitamin ON VitaminNutrient(vitamin_id);
CREATE INDEX IF NOT EXISTS idx_mineral_nutrient_mineral ON MineralNutrient(mineral_id);
CREATE INDEX IF NOT EXISTS idx_condition_nutrient_effect_condition ON ConditionNutrientEffect(condition_id);
CREATE INDEX IF NOT EXISTS idx_condition_food_rec_condition ON ConditionFoodRecommendation(condition_id);
CREATE INDEX IF NOT EXISTS idx_portion_food ON PortionSize(food_id);
CREATE INDEX IF NOT EXISTS idx_meal_user_date ON Meal(user_id, meal_date);
CREATE INDEX IF NOT EXISTS idx_meal_item_meal ON MealItem(meal_id);

COMMIT;

-- Verification
DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
    
    RAISE NOTICE '✅ Created % tables successfully', v_count;
END $$;
