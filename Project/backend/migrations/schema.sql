-- ============================================================
-- DATABASE: Health and Nutrition Tracker
-- AUTHOR: Trương Vĩnh Kiệt
-- VERSION: FINAL (ONLY TABLE STRUCTURE)
-- ============================================================

-- ============================================================
-- I. NGƯỜI DÙNG & HỒ SƠ CÁ NHÂN
-- ============================================================

CREATE TABLE IF NOT EXISTS "User" (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    age INT CHECK (age > 0),
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    height_cm NUMERIC(5,2) CHECK (height_cm > 0),
    weight_kg NUMERIC(5,2) CHECK (weight_kg > 0),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS UserProfile (
    user_id INT PRIMARY KEY REFERENCES "User"(user_id) ON DELETE CASCADE,
    activity_level VARCHAR(50),
    diet_type VARCHAR(50),
    allergies TEXT,
    health_goals TEXT,
    goal_type VARCHAR(20),                     -- lose_weight / maintain / gain_weight
    goal_weight NUMERIC(5,2),
    activity_factor NUMERIC(3,2),
    bmr NUMERIC(10,2),                         -- Basal Metabolic Rate
    tdee NUMERIC(10,2),                        -- Total Daily Energy Expenditure
    daily_calorie_target NUMERIC(10,2),
    daily_protein_target NUMERIC(10,2),
    daily_fat_target NUMERIC(10,2),
    daily_carb_target NUMERIC(10,2),
    -- daily_water_target stores the suggested water intake in milliliters per day
    daily_water_target NUMERIC(10,2)
);

-- Migration: add meal distribution percentage columns to UserSetting
-- Adds four numeric columns storing percent values (e.g., 25.00)

ALTER TABLE IF EXISTS UserSetting
    ADD COLUMN IF NOT EXISTS meal_pct_breakfast NUMERIC(5,2) DEFAULT 25.00,
    ADD COLUMN IF NOT EXISTS meal_pct_lunch NUMERIC(5,2) DEFAULT 35.00,
    ADD COLUMN IF NOT EXISTS meal_pct_snack NUMERIC(5,2) DEFAULT 10.00,
    ADD COLUMN IF NOT EXISTS meal_pct_dinner NUMERIC(5,2) DEFAULT 30.00;

-- Note: After adding this migration to your DB, run it (psql or migration tooling) so the columns exist.


CREATE TABLE IF NOT EXISTS UserSetting (
    user_id INT PRIMARY KEY REFERENCES "User"(user_id) ON DELETE CASCADE,
    theme VARCHAR(20) DEFAULT 'light',            -- 'light' / 'dark' / other theme names
    language VARCHAR(10) DEFAULT 'vi',            -- e.g. 'vi', 'en'
    font_size VARCHAR(20) DEFAULT 'medium',       -- 'small' / 'medium' / 'large'
    unit_system VARCHAR(10) DEFAULT 'metric',     -- 'metric' / 'imperial'

    -- Seasonal UI settings
    seasonal_ui_enabled BOOLEAN DEFAULT FALSE,   -- bật/tắt chế độ giao diện theo mùa
    seasonal_mode VARCHAR(20) DEFAULT 'auto',    -- 'auto' (theo tháng) / 'manual' / 'off'
    seasonal_custom_bg TEXT,                      -- URL của ảnh background tuỳ chỉnh cho chế độ mùa (nếu người dùng chọn)
    falling_leaves_enabled BOOLEAN DEFAULT TRUE, -- hiệu ứng lá rụng (app có thể đã có sẵn)

    -- Weather-based background / theme
    weather_enabled BOOLEAN DEFAULT FALSE,       -- bật/tắt cập nhật giao diện theo thời tiết
    weather_city VARCHAR(100),                    -- tên thành phố do người dùng nhập (e.g. 'Cà Mau', 'TP HCM')
    weather_last_update TIMESTAMP,                -- thời điểm lần cuối cập nhật weather
    weather_last_data JSONB,                      -- lưu payload thời tiết thô (có thể chứa icon, temp, condition)

    -- Backward-compatible single-image field
    background_image_url TEXT                      -- ảnh background chung (nếu có)
    ,calorie_multiplier NUMERIC(4,2),              -- optional multiplier (e.g., 0.85, 1.15)
    macro_protein_pct NUMERIC(5,2),                -- percent values (e.g., 25.00)
    macro_fat_pct NUMERIC(5,2),
    macro_carb_pct NUMERIC(5,2)
    ,wind_direction DOUBLE PRECISION DEFAULT 0,    -- preferred wind direction in degrees 0..360
    weather_effects_enabled BOOLEAN DEFAULT TRUE  -- whether weather effects (icons/overlays) are enabled
);

CREATE TABLE IF NOT EXISTS UserActivityLog (
    log_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    action TEXT,
    log_time TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- II. QUẢN TRỊ & PHÂN QUYỀN
-- ============================================================

CREATE TABLE IF NOT EXISTS Admin (
    admin_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS AdminRole (
    admin_id INT REFERENCES Admin(admin_id) ON DELETE CASCADE,
    role_id INT REFERENCES Role(role_id) ON DELETE CASCADE,
    PRIMARY KEY (admin_id, role_id)
);

-- ============================================================
-- III. THỰC PHẨM & DINH DƯỠNG (CÓ LIÊN KẾT VỚI ADMIN)
-- ============================================================

CREATE TABLE IF NOT EXISTS Food (
    food_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    image_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    created_by_admin INT REFERENCES Admin(admin_id) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS Nutrient (
    nutrient_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    nutrient_code VARCHAR(50),
    unit VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    created_by_admin INT REFERENCES Admin(admin_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS FoodNutrient (
    food_nutrient_id SERIAL PRIMARY KEY,
    food_id INT REFERENCES Food(food_id) ON DELETE CASCADE,
    nutrient_id INT REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
    amount_per_100g NUMERIC(10,2) NOT NULL CHECK (amount_per_100g >= 0)
);

CREATE TABLE IF NOT EXISTS FoodTag (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS FoodTagMapping (
    food_id INT REFERENCES Food(food_id) ON DELETE CASCADE,
    tag_id INT REFERENCES FoodTag(tag_id) ON DELETE CASCADE,
    PRIMARY KEY (food_id, tag_id)
);

-- ============================================================
-- IV. BỮA ĂN & NHẬT KÝ ĂN UỐNG
-- ============================================================

CREATE TABLE IF NOT EXISTS Meal (
    meal_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    meal_type VARCHAR(20) CHECK (meal_type IN ('breakfast','lunch','dinner','snack')),
    meal_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS MealItem (
    meal_item_id SERIAL PRIMARY KEY,
    meal_id INT REFERENCES Meal(meal_id) ON DELETE CASCADE,
    food_id INT REFERENCES Food(food_id) ON DELETE CASCADE,
    weight_g NUMERIC(10,2) NOT NULL CHECK (weight_g > 0)
);

CREATE TABLE IF NOT EXISTS MealNote (
    note_id SERIAL PRIMARY KEY,
    meal_id INT REFERENCES Meal(meal_id) ON DELETE CASCADE,
    note TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- V. THEO DÕI SỨC KHỎE & GỢI Ý
-- ============================================================

CREATE TABLE IF NOT EXISTS DailySummary (
    summary_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    total_calories NUMERIC(10,2) DEFAULT 0,
    total_protein NUMERIC(10,2) DEFAULT 0,
    total_fiber NUMERIC(10,2) DEFAULT 0,
    total_carbs NUMERIC(10,2) DEFAULT 0,
    total_fat NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS Suggestion (
    suggestion_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    nutrient_id INT REFERENCES Nutrient(nutrient_id),
    deficiency_amount NUMERIC(10,2),
    suggested_food_id INT REFERENCES Food(food_id),
    note TEXT
);

CREATE TABLE IF NOT EXISTS HealthCondition (
    health_condition_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    condition_name VARCHAR(100) NOT NULL,
    severity VARCHAR(50)
);

-- ============================================================
-- VI. MỤC TIÊU & HỖ TRỢ NGƯỜI BỆNH
-- ============================================================

CREATE TABLE IF NOT EXISTS UserGoal (
    goal_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    goal_type VARCHAR(20) NOT NULL,
    goal_weight NUMERIC(5,2),
    activity_factor NUMERIC(3,2),
    bmr NUMERIC(10,2),
    tdee NUMERIC(10,2),
    daily_calorie_target NUMERIC(10,2),
    daily_protein_target NUMERIC(10,2),
    daily_fat_target NUMERIC(10,2),
    daily_carb_target NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ConditionNutrientEffect (
    condition_effect_id SERIAL PRIMARY KEY,
    condition_name VARCHAR(100) NOT NULL,
    nutrient_id INT REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
    effect_type VARCHAR(10) CHECK (effect_type IN ('increase', 'decrease')),
    impact_percent NUMERIC(5,2) DEFAULT 0,
    impact_note TEXT
);

CREATE TABLE IF NOT EXISTS ConditionFoodRecommendation (
    recommendation_id SERIAL PRIMARY KEY,
    condition_name VARCHAR(100) NOT NULL,
    food_id INT REFERENCES Food(food_id) ON DELETE CASCADE,
    recommendation_type VARCHAR(10) CHECK (recommendation_type IN ('recommend', 'avoid')),
    note TEXT
);

CREATE TABLE IF NOT EXISTS ConditionEffectLog (
    effect_log_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    condition_name VARCHAR(100),
    nutrient_id INT REFERENCES Nutrient(nutrient_id),
    effect_type VARCHAR(10),
    impact_percent NUMERIC(5,2),
    applied_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- ✅ HOÀN TẤT: 23 BẢNG (KHÔNG FUNCTION/TRIGGER)
-- ============================================================

-- ============================================================
-- VII. AUTOMATIC NUTRIENT COMPUTATION & DAILY AGGREGATES TRIGGERS
--  - store computed calories/protein/fat/carbs per MealItem
--  - keep DailySummary up-to-date on insert/update/delete of MealItem
-- ============================================================

-- add computed nutrient columns to MealItem (if not present)
ALTER TABLE MealItem
        ADD COLUMN IF NOT EXISTS calories NUMERIC(10,2) DEFAULT 0,
        ADD COLUMN IF NOT EXISTS protein NUMERIC(10,2) DEFAULT 0,
        ADD COLUMN IF NOT EXISTS fat NUMERIC(10,2) DEFAULT 0,
        ADD COLUMN IF NOT EXISTS carbs NUMERIC(10,2) DEFAULT 0;

-- function: compute nutrients for a meal item from FoodNutrient/Nutrient
CREATE OR REPLACE FUNCTION compute_mealitem_nutrients() RETURNS trigger AS $$
DECLARE
        v_kcal NUMERIC := 0;
        v_protein NUMERIC := 0;
        v_fat NUMERIC := 0;
        v_carb NUMERIC := 0;
BEGIN
        -- Defensive: if no food_id provided, keep zeros
        IF NEW.food_id IS NULL THEN
                NEW.calories := 0;
                NEW.protein := 0;
                NEW.fat := 0;
                NEW.carbs := 0;
                RETURN NEW;
        END IF;

        -- Preferred: match by canonical nutrient_code (if available). Codes follow common standards e.g. ENERC_KCAL, PROCNT, FAT, CHOCDF
        SELECT fn.amount_per_100g
            INTO v_kcal
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id
          AND n.nutrient_code = 'ENERC_KCAL'
        LIMIT 1;

        SELECT fn.amount_per_100g
            INTO v_protein
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id
          AND n.nutrient_code = 'PROCNT'
        LIMIT 1;

        SELECT fn.amount_per_100g
            INTO v_fat
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id
          AND n.nutrient_code = 'FAT'
        LIMIT 1;

        SELECT fn.amount_per_100g
            INTO v_carb
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id
          AND n.nutrient_code = 'CHOCDF'
        LIMIT 1;

        -- Fallback: if code-based lookup returned null, try fuzzy name/unit heuristics for backwards compatibility
        IF v_kcal IS NULL OR v_kcal = 0 THEN
            SELECT fn.amount_per_100g INTO v_kcal FROM FoodNutrient fn JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id WHERE fn.food_id = NEW.food_id AND ( lower(n.name) LIKE '%calor%' OR lower(n.name) LIKE '%energy%' OR lower(n.unit) LIKE '%kcal%') LIMIT 1;
        END IF;
        IF v_protein IS NULL OR v_protein = 0 THEN
            SELECT fn.amount_per_100g INTO v_protein FROM FoodNutrient fn JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id WHERE fn.food_id = NEW.food_id AND lower(n.name) LIKE '%protein%' LIMIT 1;
        END IF;
        IF v_fat IS NULL OR v_fat = 0 THEN
            SELECT fn.amount_per_100g INTO v_fat FROM FoodNutrient fn JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id WHERE fn.food_id = NEW.food_id AND lower(n.name) LIKE '%fat%' LIMIT 1;
        END IF;
        IF v_carb IS NULL OR v_carb = 0 THEN
            SELECT fn.amount_per_100g INTO v_carb FROM FoodNutrient fn JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id WHERE fn.food_id = NEW.food_id AND (lower(n.name) LIKE '%carb%' OR lower(n.name) LIKE '%carbo%') LIMIT 1;
        END IF;

        -- Null-safe
        v_kcal := COALESCE(v_kcal, 0);
        v_protein := COALESCE(v_protein, 0);
        v_fat := COALESCE(v_fat, 0);
        v_carb := COALESCE(v_carb, 0);

        -- compute per item (weight_g is per-item weight in grams)
        NEW.calories := round((v_kcal * NEW.weight_g) / 100.0, 2);
        NEW.protein := round((v_protein * NEW.weight_g) / 100.0, 2);
        NEW.fat := round((v_fat * NEW.weight_g) / 100.0, 2);
        NEW.carbs := round((v_carb * NEW.weight_g) / 100.0, 2);

        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- helper: ensure a DailySummary row exists and increment totals (upsert)
CREATE OR REPLACE FUNCTION upsert_daily_summary(p_user_id INT, p_date DATE, p_cal NUMERIC, p_prot NUMERIC, p_fat NUMERIC, p_carb NUMERIC) RETURNS VOID AS $$
BEGIN
        INSERT INTO DailySummary(user_id, date, total_calories, total_protein, total_fat, total_carbs)
        VALUES (p_user_id, p_date, COALESCE(p_cal,0), COALESCE(p_prot,0), COALESCE(p_fat,0), COALESCE(p_carb,0))
        ON CONFLICT (user_id, date) DO UPDATE
        SET total_calories = DailySummary.total_calories + EXCLUDED.total_calories,
            total_protein = DailySummary.total_protein + EXCLUDED.total_protein,
            total_fat = DailySummary.total_fat + EXCLUDED.total_fat,
            total_carbs = DailySummary.total_carbs + EXCLUDED.total_carbs;
END;
$$ LANGUAGE plpgsql;

-- function: adjust daily summary when MealItem is inserted/updated/deleted
CREATE OR REPLACE FUNCTION adjust_daily_summary_on_mealitem_change() RETURNS trigger AS $$
DECLARE
        v_user INT;
        v_date DATE;
BEGIN
        IF TG_OP = 'INSERT' THEN
                SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = NEW.meal_id;
                PERFORM upsert_daily_summary(v_user, v_date, NEW.calories, NEW.protein, NEW.fat, NEW.carbs);
                RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
                SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = NEW.meal_id;
                -- if meal_date or user changed, handle decrement on old row and increment on new
                IF (OLD.meal_id IS DISTINCT FROM NEW.meal_id) THEN
                        -- decrement old
                        SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = OLD.meal_id;
                        UPDATE DailySummary SET total_calories = GREATEST(total_calories - COALESCE(OLD.calories,0),0), total_protein = GREATEST(total_protein - COALESCE(OLD.protein,0),0), total_fat = GREATEST(total_fat - COALESCE(OLD.fat,0),0), total_carbs = GREATEST(total_carbs - COALESCE(OLD.carbs,0),0) WHERE user_id = v_user AND date = v_date;
                        -- increment new
                        SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = NEW.meal_id;
                        PERFORM upsert_daily_summary(v_user, v_date, NEW.calories, NEW.protein, NEW.fat, NEW.carbs);
                ELSE
                        -- same meal: apply delta
                        UPDATE DailySummary SET
                            total_calories = GREATEST(total_calories + COALESCE(NEW.calories,0) - COALESCE(OLD.calories,0),0),
                            total_protein = GREATEST(total_protein + COALESCE(NEW.protein,0) - COALESCE(OLD.protein,0),0),
                            total_fat = GREATEST(total_fat + COALESCE(NEW.fat,0) - COALESCE(OLD.fat,0),0),
                            total_carbs = GREATEST(total_carbs + COALESCE(NEW.carbs,0) - COALESCE(OLD.carbs,0),0)
                        WHERE user_id = v_user AND date = v_date;
                END IF;
                RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
            SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = OLD.meal_id;
            UPDATE DailySummary SET total_calories = GREATEST(total_calories - COALESCE(OLD.calories,0),0), total_protein = GREATEST(total_protein - COALESCE(OLD.protein,0),0), total_fat = GREATEST(total_fat - COALESCE(OLD.fat,0),0), total_carbs = GREATEST(total_carbs - COALESCE(OLD.carbs,0),0) WHERE user_id = v_user AND date = v_date;
                RETURN OLD;
        END IF;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- create triggers
DROP TRIGGER IF EXISTS trg_compute_mealitem_nutrients ON MealItem;
CREATE TRIGGER trg_compute_mealitem_nutrients
BEFORE INSERT OR UPDATE ON MealItem
FOR EACH ROW EXECUTE FUNCTION compute_mealitem_nutrients();

DROP TRIGGER IF EXISTS trg_adjust_daily_summary_mealitem ON MealItem;
CREATE TRIGGER trg_adjust_daily_summary_mealitem
AFTER INSERT OR UPDATE OR DELETE ON MealItem
FOR EACH ROW EXECUTE FUNCTION adjust_daily_summary_on_mealitem_change();

-- End of automatic nutrient/summary triggers

-- ============================================================
-- VIII. AUTOMATIC DAILY WATER TARGET COMPUTATION
--  - compute and store `daily_water_target` (ml/day) in UserProfile
--  Formula used (frontend/back-end agreed):
--    water_ml = round( (tdee * 1.0) + (weight_kg * 5 * (activity_factor - 1.2)), 2 )
--  Only computed when User.weight_kg, UserProfile.tdee and UserProfile.activity_factor are available.
--  If values are missing, the field is left untouched to allow manual overrides.
-- ============================================================

-- function: compute daily water target and set NEW.daily_water_target before insert/update
CREATE OR REPLACE FUNCTION compute_userprofile_daily_water_target() RETURNS trigger AS $$
DECLARE
    v_weight NUMERIC;
    v_tdee NUMERIC;
    v_activity NUMERIC;
    v_water_ml NUMERIC;
BEGIN
    -- load weight from User table
    SELECT weight_kg INTO v_weight FROM "User" WHERE user_id = NEW.user_id;

    v_tdee := NEW.tdee;
    v_activity := NEW.activity_factor;

    -- if any required value is missing, do not overwrite manual value
    IF v_weight IS NULL OR v_tdee IS NULL OR v_activity IS NULL THEN
        RETURN NEW;
    END IF;

    -- compute using agreed formula and ensure non-negative
    v_water_ml := ROUND( (v_tdee * 1.0) + (v_weight * 5 * (v_activity - 1.2)), 2 );
    v_water_ml := GREATEST(v_water_ml, 0);

    NEW.daily_water_target := v_water_ml;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger to compute water target before inserts/updates to UserProfile
DROP TRIGGER IF EXISTS trg_compute_userprofile_daily_water ON UserProfile;
CREATE TRIGGER trg_compute_userprofile_daily_water
BEFORE INSERT OR UPDATE ON UserProfile
FOR EACH ROW EXECUTE FUNCTION compute_userprofile_daily_water_target();

-- Backfill: compute daily_water_target for existing rows that have required inputs
-- Backfill moved to `backend/migrations/2025_backfill_userprofile_water_target.sql`
-- Run the backfill migration separately after applying the structural schema and before relying on daily_water_target values.

-- ============================================================
-- Trigger: when a user's weight changes, cause UserProfile to be updated
-- so the UserProfile BEFORE UPDATE trigger will recompute daily_water_target
-- ============================================================

CREATE OR REPLACE FUNCTION notify_user_weight_change() RETURNS trigger AS $$
BEGIN
    -- if the user has a UserProfile row, do a no-op update to fire the UserProfile triggers
    IF EXISTS (SELECT 1 FROM UserProfile WHERE user_id = NEW.user_id) THEN
        UPDATE UserProfile SET tdee = tdee WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_user_weight_changed ON "User";
CREATE TRIGGER trg_user_weight_changed
AFTER UPDATE OF weight_kg ON "User"
FOR EACH ROW
WHEN (OLD.weight_kg IS DISTINCT FROM NEW.weight_kg)
EXECUTE FUNCTION notify_user_weight_change();

-- ============================================================
-- IX. VITAMINS TABLE
--  - store canonical vitamin definitions and recommended daily amounts
--  - useful for showing top vitamins on the home screen and powering a full vitamins page
-- ============================================================

CREATE TABLE IF NOT EXISTS Vitamin (
    vitamin_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,        -- short code e.g. VITD, VITC
    name VARCHAR(100) NOT NULL,              -- human-friendly name
    description TEXT,                        -- optional short description
    unit VARCHAR(20) DEFAULT 'mg',           -- unit for RDA (mg, IU, µg, etc.)
    recommended_daily NUMERIC(10,3),         -- recommended daily amount in unit above
    created_at TIMESTAMP DEFAULT NOW(),
    created_by_admin INT REFERENCES Admin(admin_id) ON DELETE SET NULL
);

-- Insert a sensible default set of commonly-tracked vitamins (if not present)
-- Seeds for common vitamins moved to `backend/migrations/2025_seed_vitamins.sql`
-- Run that migration separately after applying the structural schema.

-- ============================================================
-- SQL helper functions for Vitamins
--  1) upsert_vitamin(...) - insert or update a vitamin row by code
--  2) upsert_vitamin_by_name(...) - convenience wrapper that derives a code from the name
--  3) compute_user_vitamin_requirement(user_id, vitamin_id) - computes a per-user recommended amount
--     based on user profile (activity_factor, goal_type, gender, weight, tdee).
--
-- NOTE: These functions implement conservative heuristics for demonstration. Replace with
-- authoritative RDA rules when available (age/sex-specific tables, pregnancy/lactation, etc.).
-- ============================================================

CREATE OR REPLACE FUNCTION upsert_vitamin(p_code TEXT, p_name TEXT, p_description TEXT, p_unit TEXT, p_recommended NUMERIC) RETURNS INT AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO Vitamin(code,name,description,unit,recommended_daily,created_by_admin)
    VALUES (p_code, p_name, p_description, p_unit, p_recommended, NULL)
    ON CONFLICT (code) DO UPDATE
    SET name = EXCLUDED.name,
        description = EXCLUDED.description,
        unit = EXCLUDED.unit,
        recommended_daily = EXCLUDED.recommended_daily
    RETURNING vitamin_id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION upsert_vitamin_by_name(p_name TEXT, p_unit TEXT, p_recommended NUMERIC) RETURNS INT AS $$
DECLARE
    v_code TEXT := 'VIT' || regexp_replace(upper(coalesce(p_name,'')), '[^A-Z0-9]', '', 'g');
BEGIN
    RETURN upsert_vitamin(v_code, p_name, NULL, p_unit, p_recommended);
END;
$$ LANGUAGE plpgsql;

-- Compute per-user requirement for a vitamin by applying simple multipliers
-- Inputs: user_id, vitamin_id
-- Returns: base (baseline RDA), multiplier applied, recommended (final) and unit
CREATE OR REPLACE FUNCTION compute_user_vitamin_requirement(p_user_id INT, p_vitamin_id INT)
RETURNS TABLE(base NUMERIC, multiplier NUMERIC, recommended NUMERIC, unit TEXT) AS $$
DECLARE
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_tdee NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
BEGIN
    -- prefer age/sex-specific RDA if available in VitaminRDA, otherwise fall back to Vitamin.recommended_daily
    SELECT r.rda_value, r.unit INTO v_base, v_unit
    FROM VitaminRDA r
    WHERE r.vitamin_id = p_vitamin_id
      AND (r.sex IS NULL OR lower(r.sex) = lower((SELECT COALESCE(u.gender,'') FROM "User" u WHERE u.user_id = p_user_id)))
      AND ( (r.age_min IS NULL AND r.age_max IS NULL) OR (
            (SELECT COALESCE(u.age,0) FROM "User" u WHERE u.user_id = p_user_id) BETWEEN COALESCE(r.age_min, -9999) AND COALESCE(r.age_max, 99999)
          ) )
    LIMIT 1;

    IF v_base IS NULL THEN
        SELECT v2.recommended_daily, v2.unit INTO v_base, v_unit FROM Vitamin v2 WHERE v2.vitamin_id = p_vitamin_id;
    END IF;
    IF v_base IS NULL THEN
        RETURN; -- vitamin not found
    END IF;

    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, COALESCE(up.tdee,0), u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_tdee, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;

    -- activity adjustment: small increase for more active users (scaled, capped)
    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.25, 0.20 );
    END IF;

    -- goal adjustment: slight changes for weight goals
    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN
            v_mult := v_mult + 0.05; -- modest increase for dieting demands
        ELSIF lower(v_goal) = 'gain_weight' THEN
            v_mult := v_mult - 0.02; -- small decrease
        END IF;
    END IF;

    -- gender example tweak (optional): small increase for males on average
    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN
        v_mult := v_mult + 0.02;
    END IF;

    -- clamp sensible multiplier bounds
    IF v_mult < 0.5 THEN v_mult := 0.5; END IF;
    IF v_mult > 2.0 THEN v_mult := 2.0; END IF;

    RETURN QUERY SELECT v_base, v_mult, ROUND(v_base * v_mult, 3), v_unit;
END;
$$ LANGUAGE plpgsql;

-- Unit conversion helper: convert simple units between IU, µg (ug), mg
CREATE OR REPLACE FUNCTION convert_rda_unit(p_value NUMERIC, p_from_unit TEXT, p_to_unit TEXT, p_vitamin_code TEXT) RETURNS NUMERIC AS $$
DECLARE
    f TEXT := upper(coalesce(p_from_unit,''));
    t TEXT := upper(coalesce(p_to_unit,''));
    code TEXT := upper(coalesce(p_vitamin_code,''));
BEGIN
    IF p_value IS NULL OR f = '' OR t = '' OR f = t THEN RETURN p_value; END IF;
    -- mg <-> µg
    IF f = 'MG' AND t IN ('UG','UG/ML','MCG') THEN
        RETURN p_value * 1000;
    ELSIF (f = 'UG' OR f = 'MCG') AND t = 'MG' THEN
        RETURN p_value / 1000;
    END IF;
    -- IU conversions (limited support for common vitamins)
    IF f = 'IU' AND t IN ('UG','MCG') THEN
        -- Vitamin D: 1 IU = 0.025 µg
        IF code = 'VITD' THEN
            RETURN p_value * 0.025;
        END IF;
        -- Vitamin A (retinol): 1 IU = 0.3 µg retinol
        IF code = 'VITA' THEN
            RETURN p_value * 0.3;
        END IF;
        -- Vitamin E (alpha-tocopherol): approximate 1 IU ≈ 0.67 mg -> convert to µg
        IF code = 'VITE' AND t IN ('MG') THEN
            RETURN p_value * 0.67;
        END IF;
    END IF;
    -- fallback: no conversion known
    RETURN p_value;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Per-user cached vitamin requirements and refresh triggers
--  - stores computed recommended amounts per user so the client can read fast
--  - automatically refresh when user/profile fields change
-- ============================================================

CREATE TABLE IF NOT EXISTS UserVitaminRequirement (
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    vitamin_id INT REFERENCES Vitamin(vitamin_id) ON DELETE CASCADE,
    base NUMERIC,
    multiplier NUMERIC,
    recommended NUMERIC,
    unit TEXT,
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, vitamin_id)
);

-- Refresh all vitamin requirements for a single user (upsert into UserVitaminRequirement)
CREATE OR REPLACE FUNCTION refresh_user_vitamin_requirements(p_user_id INT) RETURNS VOID AS $$
DECLARE
    v RECORD;
    v_base NUMERIC;
    v_mult NUMERIC;
    v_rec NUMERIC;
    v_unit TEXT;
BEGIN
    IF p_user_id IS NULL THEN
        RETURN;
    END IF;

    FOR v IN SELECT vitamin_id FROM Vitamin LOOP
        -- compute using existing helper
        SELECT base, multiplier, recommended, unit INTO v_base, v_mult, v_rec, v_unit FROM compute_user_vitamin_requirement(p_user_id, v.vitamin_id);
        -- upsert into cache table
        INSERT INTO UserVitaminRequirement(user_id, vitamin_id, base, multiplier, recommended, unit, updated_at)
        VALUES (p_user_id, v.vitamin_id, v_base, v_mult, v_rec, v_unit, NOW())
        ON CONFLICT (user_id, vitamin_id) DO UPDATE
        SET base = EXCLUDED.base, multiplier = EXCLUDED.multiplier, recommended = EXCLUDED.recommended, unit = EXCLUDED.unit, updated_at = EXCLUDED.updated_at;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Trigger wrapper called when UserProfile changes
CREATE OR REPLACE FUNCTION trg_refresh_user_vitamins_from_userprofile() RETURNS trigger AS $$
BEGIN
    -- refresh for the affected user
    PERFORM refresh_user_vitamin_requirements(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger wrapper called when User changes (weight or gender)
CREATE OR REPLACE FUNCTION trg_refresh_user_vitamins_from_user() RETURNS trigger AS $$
BEGIN
    PERFORM refresh_user_vitamin_requirements(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach triggers: when UserProfile relevant columns change, refresh; when User weight/gender changes, refresh
DROP TRIGGER IF EXISTS trg_userprofile_vitamin_refresh ON UserProfile;
CREATE TRIGGER trg_userprofile_vitamin_refresh
AFTER INSERT OR UPDATE OF activity_factor, tdee, goal_type ON UserProfile
FOR EACH ROW EXECUTE FUNCTION trg_refresh_user_vitamins_from_userprofile();

DROP TRIGGER IF EXISTS trg_user_vitamin_refresh ON "User";
CREATE TRIGGER trg_user_vitamin_refresh
AFTER UPDATE OF weight_kg, gender ON "User"
FOR EACH ROW WHEN (OLD.weight_kg IS DISTINCT FROM NEW.weight_kg OR OLD.gender IS DISTINCT FROM NEW.gender)
EXECUTE FUNCTION trg_refresh_user_vitamins_from_user();

-- ============================================================
-- Convenience seed function: insert core vitamins listed by user
-- Usage: SELECT seed_core_vitamins();
-- ============================================================

CREATE OR REPLACE FUNCTION seed_core_vitamins() RETURNS INT AS $$
DECLARE
    v_count INT := 0;
BEGIN
    -- List provided: Vitamin A, D, E, K, C, B1, B2, B3, B5, B6, B7, B9, B12
    PERFORM upsert_vitamin('VITA','Vitamin A','Retinol and provitamin A compounds','µg',700);
    PERFORM upsert_vitamin('VITD','Vitamin D','Supports calcium metabolism and bone health','IU',600);
    PERFORM upsert_vitamin('VITE','Vitamin E','Antioxidant (tocopherols)','mg',15);
    PERFORM upsert_vitamin('VITK','Vitamin K','Needed for blood clotting (K1/K2)','µg',120);
    PERFORM upsert_vitamin('VITC','Vitamin C','Ascorbic acid, antioxidant','mg',75);
    PERFORM upsert_vitamin('VITB1','Vitamin B1 (Thiamine)','Supports energy metabolism','mg',1.2);
    PERFORM upsert_vitamin('VITB2','Vitamin B2 (Riboflavin)','Important for energy production','mg',1.3);
    PERFORM upsert_vitamin('VITB3','Vitamin B3 (Niacin)','Supports metabolism and skin health','mg',16);
    PERFORM upsert_vitamin('VITB5','Vitamin B5 (Pantothenic acid)','Component of coenzyme A','mg',5);
    PERFORM upsert_vitamin('VITB6','Vitamin B6 (Pyridoxine)','Supports metabolism and brain health','mg',1.3);
    PERFORM upsert_vitamin('VITB7','Vitamin B7 (Biotin)','Plays a role in macronutrient metabolism','µg',30);
    PERFORM upsert_vitamin('VITB9','Vitamin B9 (Folate)','Key for cell division and DNA synthesis','µg',400);
    PERFORM upsert_vitamin('VITB12','Vitamin B12 (Cobalamin)','Important for nerve function and blood formation','µg',2.4);

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

    -- Vitamin RDA table (age/sex specific values)
    CREATE TABLE IF NOT EXISTS VitaminRDA (
        vitamin_rda_id SERIAL PRIMARY KEY,
        vitamin_id INT REFERENCES Vitamin(vitamin_id) ON DELETE CASCADE,
        sex VARCHAR(10), -- 'male','female',NULL=both
        age_min INT,
        age_max INT,
        rda_value NUMERIC(10,3),
        unit VARCHAR(20),
        notes TEXT
    );

-- ============================================================
-- X. MINERALS TABLE (KHOÁNG CHẤT)
--  - store canonical mineral definitions and recommended daily amounts
--  - mirror the Vitamins design: Mineral, MineralRDA, per-user cached requirements
-- ============================================================

CREATE TABLE IF NOT EXISTS Mineral (
    mineral_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    unit VARCHAR(20) DEFAULT 'mg',
    recommended_daily NUMERIC(10,3),
    created_at TIMESTAMP DEFAULT NOW(),
    created_by_admin INT REFERENCES Admin(admin_id) ON DELETE SET NULL
);

-- Insert core minerals (only if not present)
-- Seed core minerals moved to `backend/migrations/2025_seed_minerals.sql`
-- Run that migration separately after applying the structural schema.

-- Mineral RDA table (age/sex specific values)
CREATE TABLE IF NOT EXISTS MineralRDA (
    mineral_rda_id SERIAL PRIMARY KEY,
    mineral_id INT REFERENCES Mineral(mineral_id) ON DELETE CASCADE,
    sex VARCHAR(10), -- 'male','female',NULL=both
    age_min INT,
    age_max INT,
    rda_value NUMERIC(10,3),
    unit VARCHAR(20),
    notes TEXT
);

-- upsert helper for minerals
CREATE OR REPLACE FUNCTION upsert_mineral(p_code TEXT, p_name TEXT, p_description TEXT, p_unit TEXT, p_recommended NUMERIC) RETURNS INT AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO Mineral(code,name,description,unit,recommended_daily,created_by_admin)
    VALUES (p_code, p_name, p_description, p_unit, p_recommended, NULL)
    ON CONFLICT (code) DO UPDATE
    SET name = EXCLUDED.name,
        description = EXCLUDED.description,
        unit = EXCLUDED.unit,
        recommended_daily = EXCLUDED.recommended_daily
    RETURNING mineral_id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION upsert_mineral_by_name(p_name TEXT, p_unit TEXT, p_recommended NUMERIC) RETURNS INT AS $$
DECLARE
    v_code TEXT := 'MIN' || regexp_replace(upper(coalesce(p_name,'')), '[^A-Z0-9]', '', 'g');
BEGIN
    RETURN upsert_mineral(v_code, p_name, NULL, p_unit, p_recommended);
END;
$$ LANGUAGE plpgsql;

-- Compute per-user mineral requirement (similar heuristics to vitamins)
CREATE OR REPLACE FUNCTION compute_user_mineral_requirement(p_user_id INT, p_mineral_id INT)
RETURNS TABLE(base NUMERIC, multiplier NUMERIC, recommended NUMERIC, unit TEXT) AS $$
DECLARE
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_tdee NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
BEGIN
    SELECT r.rda_value, r.unit INTO v_base, v_unit
    FROM MineralRDA r
    WHERE r.mineral_id = p_mineral_id
      AND (r.sex IS NULL OR lower(r.sex) = lower((SELECT COALESCE(u.gender,'') FROM "User" u WHERE u.user_id = p_user_id)))
      AND ( (r.age_min IS NULL AND r.age_max IS NULL) OR (
            (SELECT COALESCE(u.age,0) FROM "User" u WHERE u.user_id = p_user_id) BETWEEN COALESCE(r.age_min, -9999) AND COALESCE(r.age_max, 99999)
          ) )
    LIMIT 1;

    IF v_base IS NULL THEN
        SELECT m2.recommended_daily, m2.unit INTO v_base, v_unit FROM Mineral m2 WHERE m2.mineral_id = p_mineral_id;
    END IF;
    IF v_base IS NULL THEN
        RETURN;
    END IF;

    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, COALESCE(up.tdee,0), u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_tdee, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;

    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.15, 0.15 );
    END IF;

    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN
            v_mult := v_mult + 0.03;
        ELSIF lower(v_goal) = 'gain_weight' THEN
            v_mult := v_mult - 0.01;
        END IF;
    END IF;

    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN
        v_mult := v_mult + 0.02;
    END IF;

    IF v_mult < 0.5 THEN v_mult := 0.5; END IF;
    IF v_mult > 2.0 THEN v_mult := 2.0; END IF;

    RETURN QUERY SELECT v_base, v_mult, ROUND(v_base * v_mult, 3), v_unit;
END;
$$ LANGUAGE plpgsql;

-- Per-user cached mineral requirements
CREATE TABLE IF NOT EXISTS UserMineralRequirement (
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    mineral_id INT REFERENCES Mineral(mineral_id) ON DELETE CASCADE,
    base NUMERIC,
    multiplier NUMERIC,
    recommended NUMERIC,
    unit TEXT,
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, mineral_id)
);

-- Refresh function
CREATE OR REPLACE FUNCTION refresh_user_mineral_requirements(p_user_id INT) RETURNS VOID AS $$
DECLARE
    v RECORD;
    v_base NUMERIC;
    v_mult NUMERIC;
    v_rec NUMERIC;
    v_unit TEXT;
BEGIN
    IF p_user_id IS NULL THEN RETURN; END IF;
    FOR v IN SELECT mineral_id FROM Mineral LOOP
        SELECT base, multiplier, recommended, unit INTO v_base, v_mult, v_rec, v_unit FROM compute_user_mineral_requirement(p_user_id, v.mineral_id);
        INSERT INTO UserMineralRequirement(user_id, mineral_id, base, multiplier, recommended, unit, updated_at)
        VALUES (p_user_id, v.mineral_id, v_base, v_mult, v_rec, v_unit, NOW())
        ON CONFLICT (user_id, mineral_id) DO UPDATE
        SET base = EXCLUDED.base, multiplier = EXCLUDED.multiplier, recommended = EXCLUDED.recommended, unit = EXCLUDED.unit, updated_at = EXCLUDED.updated_at;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_refresh_user_minerals_from_userprofile() RETURNS trigger AS $$
BEGIN
    PERFORM refresh_user_mineral_requirements(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_refresh_user_minerals_from_user() RETURNS trigger AS $$
BEGIN
    PERFORM refresh_user_mineral_requirements(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_userprofile_mineral_refresh ON UserProfile;
CREATE TRIGGER trg_userprofile_mineral_refresh
AFTER INSERT OR UPDATE OF activity_factor, tdee, goal_type ON UserProfile
FOR EACH ROW EXECUTE FUNCTION trg_refresh_user_minerals_from_userprofile();

DROP TRIGGER IF EXISTS trg_user_mineral_refresh ON "User";
CREATE TRIGGER trg_user_mineral_refresh
AFTER UPDATE OF weight_kg, gender ON "User"
FOR EACH ROW WHEN (OLD.weight_kg IS DISTINCT FROM NEW.weight_kg OR OLD.gender IS DISTINCT FROM NEW.gender)
EXECUTE FUNCTION trg_refresh_user_minerals_from_user();

-- Convenience seed
CREATE OR REPLACE FUNCTION seed_core_minerals() RETURNS INT AS $$
DECLARE v_count INT := 0;
BEGIN
    PERFORM upsert_mineral('MIN_CA','Calcium (Ca)','Calcium for bones and teeth','mg',1000);
    PERFORM upsert_mineral('MIN_P','Phosphorus (P)','Phosphorus for bone and energy metabolism','mg',700);
    PERFORM upsert_mineral('MIN_MG','Magnesium (Mg)','Magnesium for muscle and nerve function','mg',310);
    PERFORM upsert_mineral('MIN_K','Potassium (K)','Potassium electrolyte','mg',4700);
    PERFORM upsert_mineral('MIN_NA','Sodium (Na)','Sodium electrolyte','mg',1500);
    PERFORM upsert_mineral('MIN_FE','Iron (Fe)','Iron for hemoglobin','mg',18);
    PERFORM upsert_mineral('MIN_ZN','Zinc (Zn)','Zinc for immune function','mg',11);
    PERFORM upsert_mineral('MIN_CU','Copper (Cu)','Copper cofactor','mg',0.9);
    PERFORM upsert_mineral('MIN_MN','Manganese (Mn)','Manganese cofactor','mg',2.3);
    PERFORM upsert_mineral('MIN_I','Iodine (I)','Iodine for thyroid','µg',150);
    PERFORM upsert_mineral('MIN_SE','Selenium (Se)','Selenium antioxidant','µg',55);
    PERFORM upsert_mineral('MIN_CR','Chromium (Cr)','Chromium for metabolism','µg',35);
    PERFORM upsert_mineral('MIN_MO','Molybdenum (Mo)','Molybdenum enzyme cofactor','µg',45);
    PERFORM upsert_mineral('MIN_F','Fluoride (F)','Fluoride for dental health','mg',3.0);
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- XI. FIBER & FATTY ACIDS (CANONICAL + INTAKE ATTRIBUTION)
--  - canonical Fiber/FattyAcid tables (non-editable by users by default)
--  - mapping table from dataset Nutrient -> canonical Fiber/FattyAcid
--  - per-user daily intake aggregates (UserFiberIntake, UserFattyAcidIntake)
--  - safe upsert helpers and a MealItem trigger to attribute FoodNutrient rows
-- ============================================================

-- Data and convenience migrations have been extracted to separate files.
-- Available migration files:
-- - backend/migrations/2025_trim_food_and_translate.sql
-- - backend/migrations/2025_nutrient_mapping_fiber_fatty.sql
-- - backend/migrations/2025_seed_vitamins.sql
-- - backend/migrations/2025_seed_minerals.sql
-- - backend/migrations/2025_seed_fiber_fatty.sql
-- - backend/migrations/2025_backfill_userprofile_water_target.sql
-- Run those in order after applying the structural DDL in this schema.

-- NutrientMapping seeds moved to `backend/migrations/2025_nutrient_mapping_fiber_fatty.sql`
-- Run that migration separately after applying the structural schema.
-- ============================================================
-- XI.a: Canonical Fiber & FattyAcid tables (merged from fiber/fatty migration)
-- ============================================================
CREATE TABLE IF NOT EXISTS Fiber (
    fiber_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    unit VARCHAR(20) DEFAULT 'g',
    hex_color VARCHAR(7),
    home_display BOOLEAN DEFAULT FALSE,
    is_user_editable BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS FattyAcid (
    fatty_acid_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    unit VARCHAR(20) DEFAULT 'g',
    hex_color VARCHAR(7),
    home_display BOOLEAN DEFAULT FALSE,
    is_user_editable BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS FiberRequirement (
    fiber_req_id SERIAL PRIMARY KEY,
    fiber_id INT REFERENCES Fiber(fiber_id) ON DELETE CASCADE,
    sex VARCHAR(10),
    age_min INT,
    age_max INT,
    base_value NUMERIC(10,6),
    unit VARCHAR(20) DEFAULT 'g',
    is_per_kg BOOLEAN DEFAULT FALSE,
    is_energy_pct BOOLEAN DEFAULT FALSE,
    energy_pct NUMERIC(6,4),
    notes TEXT
);

CREATE TABLE IF NOT EXISTS FattyAcidRequirement (
    fa_req_id SERIAL PRIMARY KEY,
    fatty_acid_id INT REFERENCES FattyAcid(fatty_acid_id) ON DELETE CASCADE,
    sex VARCHAR(10),
    age_min INT,
    age_max INT,
    base_value NUMERIC(12,6),
    unit VARCHAR(20) DEFAULT 'g',
    is_per_kg BOOLEAN DEFAULT FALSE,
    is_energy_pct BOOLEAN DEFAULT FALSE,
    energy_pct NUMERIC(6,4),
    notes TEXT
);

CREATE TABLE IF NOT EXISTS UserFiberRequirement (
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    fiber_id INT REFERENCES Fiber(fiber_id) ON DELETE CASCADE,
    base NUMERIC,
    multiplier NUMERIC,
    recommended NUMERIC,
    unit TEXT,
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, fiber_id)
);

CREATE TABLE IF NOT EXISTS UserFattyAcidRequirement (
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    fatty_acid_id INT REFERENCES FattyAcid(fatty_acid_id) ON DELETE CASCADE,
    base NUMERIC,
    multiplier NUMERIC,
    recommended NUMERIC,
    unit TEXT,
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, fatty_acid_id)
);

CREATE TABLE IF NOT EXISTS UserFiberIntake (
    intake_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    fiber_id INT REFERENCES Fiber(fiber_id) ON DELETE CASCADE,
    amount NUMERIC(12,4) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS UserFattyAcidIntake (
    intake_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    fatty_acid_id INT REFERENCES FattyAcid(fatty_acid_id) ON DELETE CASCADE,
    amount NUMERIC(12,4) DEFAULT 0
);

-- ============================================================
-- XI.b: NutrientMapping table (maps FoodNutrient.nutrient_id -> canonical Fiber/FattyAcid)
-- ============================================================
CREATE TABLE IF NOT EXISTS NutrientMapping (
    mapping_id SERIAL PRIMARY KEY,
    nutrient_id INT REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
    fiber_id INT REFERENCES Fiber(fiber_id) ON DELETE CASCADE,
    fatty_acid_id INT REFERENCES FattyAcid(fatty_acid_id) ON DELETE CASCADE,
    factor NUMERIC(10,6) DEFAULT 1.0,
    notes TEXT,
    UNIQUE(nutrient_id)
);

-- Note: mapping seeds, mapping-driven compute functions and trigger implementations remain in
-- `backend/migrations/2025_nutrient_mapping_fiber_fatty.sql` and `2025_add_fiber_fatty_acids.sql`.


-- ============================================================
-- XII: ESSENTIAL AMINO ACIDS
-- ============================================================
CREATE TABLE IF NOT EXISTS AminoAcid (
    amino_acid_id SERIAL PRIMARY KEY,
    code VARCHAR(32) UNIQUE NOT NULL,
    name VARCHAR(128) NOT NULL,
    hex_color VARCHAR(7) NOT NULL,
    home_display BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS AminoRequirement (
    amino_requirement_id SERIAL PRIMARY KEY,
    amino_acid_id INT NOT NULL REFERENCES AminoAcid(amino_acid_id) ON DELETE CASCADE,
    sex VARCHAR(16) DEFAULT 'both',
    age_min INT,
    age_max INT,
    per_kg BOOLEAN NOT NULL DEFAULT FALSE,
    amount NUMERIC NOT NULL,
    unit VARCHAR(16) DEFAULT 'mg',
    notes TEXT
);

CREATE TABLE IF NOT EXISTS UserAminoRequirement (
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    amino_acid_id INT REFERENCES AminoAcid(amino_acid_id) ON DELETE CASCADE,
    base NUMERIC,
    multiplier NUMERIC,
    recommended NUMERIC,
    unit TEXT,
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, amino_acid_id)
);

CREATE TABLE IF NOT EXISTS UserAminoIntake (
    intake_id BIGSERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    amino_acid_id INT REFERENCES AminoAcid(amino_acid_id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL,
    unit VARCHAR(16) DEFAULT 'mg',
    source TEXT,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- End of merged table-level DDL for Fiber/Fatty/NutrientMapping and AminoAcid

-- Migration: create tables to store per-user, per-day, per-meal targets and entries
-- 2025_create_user_meal_tables.sql

-- Table: user_meal_targets
-- Purpose: store the target amounts the user aims to consume for each meal (breakfast/lunch/snack/dinner)
-- This allows the app to load "target per meal" values (initially 0 or computed from daily targets)
CREATE TABLE IF NOT EXISTS user_meal_targets (
  id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  target_date DATE NOT NULL DEFAULT CURRENT_DATE,
  meal_type VARCHAR(16) NOT NULL,
  target_kcal NUMERIC(10,2) DEFAULT 0,
  target_carbs NUMERIC(10,2) DEFAULT 0,
  target_protein NUMERIC(10,2) DEFAULT 0,
  target_fat NUMERIC(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_user_meal_targets_user_date_meal ON user_meal_targets(user_id, target_date, meal_type);

-- Table: meal_entries
-- Purpose: store detailed additions the user makes with the '+' action (food items, weight, computed macros)
-- Each time the user uses + to add a food/item, insert into this table. The app/backend can then recalc summaries.
CREATE TABLE IF NOT EXISTS meal_entries (
  id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  meal_type VARCHAR(16) NOT NULL,
  food_id INTEGER,
  weight_g NUMERIC(10,2),
  kcal NUMERIC(10,2) DEFAULT 0,
  carbs NUMERIC(10,2) DEFAULT 0,
  protein NUMERIC(10,2) DEFAULT 0,
  fat NUMERIC(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table: user_meal_summaries
-- Purpose: keep a quick aggregate of consumed totals per user/date/meal so the app can load totals quickly
CREATE TABLE IF NOT EXISTS user_meal_summaries (
  id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
  summary_date DATE NOT NULL DEFAULT CURRENT_DATE,
  meal_type VARCHAR(16) NOT NULL,
  consumed_kcal NUMERIC(12,2) DEFAULT 0,
  consumed_carbs NUMERIC(12,2) DEFAULT 0,
  consumed_protein NUMERIC(12,2) DEFAULT 0,
  consumed_fat NUMERIC(12,2) DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, summary_date, meal_type)
);

-- Trigger tips (not implemented here):
-- - When inserting into meal_entries, update/insert corresponding user_meal_summaries row by summing the macros.
-- - When deleting/updating meal_entries, adjust the summary accordingly.
-- Alternatively the backend can recalc summaries on demand and store them here.




