-- ============================================================
-- CREATE TABLES FOR ADVANCED FEATURES
-- Creates missing schema for extended functionality
-- Date: 2025-11-19
-- ============================================================

BEGIN;

-- ============================================================
-- 1. HEALTHCONDITION (base table)
-- ============================================================

CREATE TABLE IF NOT EXISTS HealthCondition (
  condition_id SERIAL PRIMARY KEY,
  name_en VARCHAR(200) NOT NULL,
  name_vi VARCHAR(200) NOT NULL,
  description TEXT,
  severity VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert common conditions
INSERT INTO HealthCondition (name_en, name_vi, description, severity) VALUES
('Type 2 Diabetes', 'Tiểu đường type 2', 'High blood sugar levels', 'high'),
('Hypertension', 'Cao huyết áp', 'High blood pressure', 'high'),
('High Cholesterol', 'Mỡ máu cao', 'High cholesterol levels', 'medium'),
('Obesity', 'Béo phì', 'Excessive body fat', 'medium'),
('Gout', 'Gout', 'High uric acid', 'medium'),
('Fatty Liver', 'Gan nhiễm mỡ', 'Fat buildup in liver', 'medium'),
('Kidney Disease', 'Bệnh thận', 'Impaired kidney function', 'high'),
('Anemia', 'Thiếu máu', 'Low red blood cells', 'medium'),
('Osteoporosis', 'Loãng xương', 'Weak bones', 'medium'),
('Heart Disease', 'Bệnh tim', 'Cardiovascular problems', 'high')
ON CONFLICT DO NOTHING;

DO $$ BEGIN RAISE NOTICE 'Created HealthCondition table'; END $$;

-- ============================================================
-- 2. CONDITIONNUTRIENTEFFECT
-- How health conditions affect nutrient requirements
-- ============================================================

CREATE TABLE IF NOT EXISTS ConditionNutrientEffect (
  effect_id SERIAL PRIMARY KEY,
  condition_id INT NOT NULL REFERENCES HealthCondition(condition_id) ON DELETE CASCADE,
  nutrient_id INT NOT NULL REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
  effect_type VARCHAR(20) NOT NULL CHECK (effect_type IN ('increase', 'decrease')),
  adjustment_percent INT NOT NULL, -- positive for increase, negative for decrease
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(condition_id, nutrient_id)
);

CREATE INDEX idx_condition_nutrient_effect_condition ON ConditionNutrientEffect(condition_id);
CREATE INDEX idx_condition_nutrient_effect_nutrient ON ConditionNutrientEffect(nutrient_id);

DO $$ BEGIN RAISE NOTICE 'Created ConditionNutrientEffect table'; END $$;

-- ============================================================
-- 2. CONDITIONFOODRECOMMENDATION
-- Foods to recommend or avoid for health conditions
-- ============================================================

CREATE TABLE IF NOT EXISTS ConditionFoodRecommendation (
  recommendation_id SERIAL PRIMARY KEY,
  condition_id INT NOT NULL REFERENCES HealthCondition(condition_id) ON DELETE CASCADE,
  food_id INT NOT NULL REFERENCES Food(food_id) ON DELETE CASCADE,
  recommendation_type VARCHAR(20) NOT NULL CHECK (recommendation_type IN ('recommend', 'avoid')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(condition_id, food_id)
);

CREATE INDEX idx_condition_food_rec_condition ON ConditionFoodRecommendation(condition_id);
CREATE INDEX idx_condition_food_rec_food ON ConditionFoodRecommendation(food_id);

DO $$ BEGIN RAISE NOTICE 'Created ConditionFoodRecommendation table'; END $$;

-- ============================================================
-- 3. FIBER (if not exists)
-- Fiber types tracking
-- ============================================================

CREATE TABLE IF NOT EXISTS Fiber (
  fiber_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default fiber types
INSERT INTO Fiber (name, code, description) VALUES
('Total Dietary Fiber', 'TOTAL_FIBER', 'Total fiber from all sources'),
('Soluble Fiber', 'SOLUBLE_FIBER', 'Fiber that dissolves in water')
ON CONFLICT (code) DO NOTHING;

DO $$ BEGIN RAISE NOTICE 'Created Fiber table'; END $$;

-- ============================================================
-- 4. FIBERREQUIREMENT
-- RDA for fiber by age/sex
-- ============================================================

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

CREATE INDEX idx_fiber_req_fiber ON FiberRequirement(fiber_id);

DO $$ BEGIN RAISE NOTICE 'Created FiberRequirement table'; END $$;

-- ============================================================
-- 5. FOODCATEGORY
-- Food categories for organization
-- ============================================================

CREATE TABLE IF NOT EXISTS FoodCategory (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  name_vi VARCHAR(100),
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

DO $$ BEGIN RAISE NOTICE 'Created FoodCategory table'; END $$;

-- ============================================================
-- 6. PORTIONSIZE
-- Standard portion sizes for foods
-- ============================================================

CREATE TABLE IF NOT EXISTS PortionSize (
  portion_id SERIAL PRIMARY KEY,
  food_id INT NOT NULL REFERENCES Food(food_id) ON DELETE CASCADE,
  portion_name VARCHAR(100) NOT NULL,
  portion_name_vi VARCHAR(100),
  weight_g DECIMAL(10,2) NOT NULL,
  is_common BOOLEAN DEFAULT false, -- commonly used portion
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_portion_food ON PortionSize(food_id);
CREATE INDEX idx_portion_common ON PortionSize(is_common) WHERE is_common = true;

DO $$ BEGIN RAISE NOTICE 'Created PortionSize table'; END $$;

COMMIT;

-- ============================================================
-- VERIFICATION
-- ============================================================

DO $$
DECLARE
    v_tables TEXT[];
BEGIN
    SELECT ARRAY_AGG(table_name) INTO v_tables
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
      AND table_name IN (
        'conditionnutrienteffect', 
        'conditionfoodrecommendation',
        'fiber',
        'fiberrequirement',
        'foodcategory',
        'portionsize'
      );
    
    RAISE NOTICE '';
    RAISE NOTICE '=== TABLES CREATED ===';
    RAISE NOTICE 'Tables: %', v_tables;
    RAISE NOTICE '=====================';
END $$;
