-- ============================================================
-- SMART SUGGESTIONS SYSTEM - Database Schema
-- Created: 2025-12-06
-- Purpose: Phễu lọc 4 lớp - AI-powered meal/drink suggestions
-- ============================================================

-- ============================================================
-- 1. USER PINNED SUGGESTIONS
-- Purpose: Lưu món user đã ghim (1 dish + 1 drink max)
-- Auto-expire: Khi add meal/drink HOẶC 00:00 UTC+7
-- ============================================================
CREATE TABLE IF NOT EXISTS user_pinned_suggestions (
    pin_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    item_type VARCHAR(10) NOT NULL CHECK (item_type IN ('dish', 'drink')),
    item_id INTEGER NOT NULL,
    pinned_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    meal_period VARCHAR(20), -- breakfast, lunch, snack, dinner
    UNIQUE(user_id, item_type) -- Chỉ 1 dish + 1 drink
);

CREATE INDEX idx_pinned_user_expires ON user_pinned_suggestions(user_id, expires_at);
CREATE INDEX idx_pinned_item ON user_pinned_suggestions(item_type, item_id);

COMMENT ON TABLE user_pinned_suggestions IS 'User pinned dish/drink suggestions (max 1 each type)';
COMMENT ON COLUMN user_pinned_suggestions.expires_at IS 'Auto-expire at 00:00 UTC+7 or when added to meal';

-- ============================================================
-- 2. USER FOOD PREFERENCES
-- Purpose: Lưu sở thích/dị ứng/yêu thích của user
-- Types: allergy (filter 100%), dislike (giảm 50%), favorite (tăng 30%)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_food_preferences (
    preference_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    food_id INTEGER NOT NULL REFERENCES food(food_id) ON DELETE CASCADE,
    preference_type VARCHAR(20) NOT NULL CHECK (preference_type IN ('allergy', 'dislike', 'favorite')),
    intensity INTEGER DEFAULT 3 CHECK (intensity BETWEEN 1 AND 5), -- 1=mild, 5=severe
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (user_id, food_id)
);

CREATE INDEX IF NOT EXISTS idx_user_preferences ON user_food_preferences(user_id, preference_type);

COMMENT ON TABLE user_food_preferences IS 'User food allergies, dislikes, and favorites';
COMMENT ON COLUMN user_food_preferences.intensity IS '1=mild, 5=severe (affects filtering/scoring)';

-- ============================================================
-- 3. USER EATING HISTORY
-- Purpose: Track món ăn đã ăn gần đây (cho diversity penalty)
-- Penalty: 2 days = -20%, 3 days = -50%, 4 days = -70%, 5+ days = filter
-- ============================================================
CREATE TABLE IF NOT EXISTS user_eating_history (
    history_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    eaten_date DATE NOT NULL,
    item_type VARCHAR(10) NOT NULL CHECK (item_type IN ('dish', 'drink', 'food')),
    item_id INTEGER NOT NULL,
    meal_period VARCHAR(20), -- breakfast, lunch, snack, dinner
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_eating_history_user_date ON user_eating_history(user_id, eaten_date DESC);
CREATE INDEX idx_eating_history_item ON user_eating_history(item_type, item_id, eaten_date DESC);

COMMENT ON TABLE user_eating_history IS 'Track eating history for diversity scoring';

-- ============================================================
-- 4. SUGGESTION HISTORY
-- Purpose: Log mọi lần gợi ý để phân tích và improve
-- ============================================================
CREATE TABLE IF NOT EXISTS suggestion_history (
    history_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    suggested_at TIMESTAMPTZ DEFAULT NOW(),
    suggestion_type VARCHAR(20) NOT NULL CHECK (suggestion_type IN ('dish', 'drink', 'both')),
    limit_count INTEGER, -- 5, 10, or NULL (all)
    context_snapshot JSONB, -- {weather, gaps, conditions, meal_period}
    suggestions JSONB, -- [{item_id, item_type, score, rank}]
    user_action VARCHAR(20) CHECK (user_action IN ('pinned', 'added', 'ignored', 'viewed')),
    action_item_id INTEGER,
    action_item_type VARCHAR(10)
);

CREATE INDEX idx_suggestion_history_user ON suggestion_history(user_id, suggested_at DESC);
CREATE INDEX idx_suggestion_context ON suggestion_history USING gin(context_snapshot);

COMMENT ON TABLE suggestion_history IS 'Log all suggestion requests for analytics and improvement';

-- ============================================================
-- 5. DRINK NUTRIENT DATA (Already exists with different column names!)
-- Purpose: drinknutrient table already exists with column 'amount_per_100ml'
-- No need to recreate, just add comment
-- ============================================================

COMMENT ON TABLE drinknutrient IS 'Nutritional content of drinks (amount_per_100ml)';

-- ============================================================
-- 6. ADD MEAL TIME COLUMNS TO USERSETTING
-- Purpose: Detect current meal period (breakfast, lunch, snack, dinner)
-- ============================================================
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'usersetting' AND column_name = 'breakfast_time') THEN
        ALTER TABLE usersetting ADD COLUMN breakfast_time TIME DEFAULT '07:00';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'usersetting' AND column_name = 'lunch_time') THEN
        ALTER TABLE usersetting ADD COLUMN lunch_time TIME DEFAULT '12:00';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'usersetting' AND column_name = 'dinner_time') THEN
        ALTER TABLE usersetting ADD COLUMN dinner_time TIME DEFAULT '18:00';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'usersetting' AND column_name = 'snack_time') THEN
        ALTER TABLE usersetting ADD COLUMN snack_time TIME DEFAULT '15:00';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'usersetting' AND column_name = 'lightbulb_x') THEN
        ALTER TABLE usersetting ADD COLUMN lightbulb_x DECIMAL(5,2) DEFAULT 0.85; -- 85% from left
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'usersetting' AND column_name = 'lightbulb_y') THEN
        ALTER TABLE usersetting ADD COLUMN lightbulb_y DECIMAL(5,2) DEFAULT 0.15; -- 15% from top
    END IF;
END $$;

COMMENT ON COLUMN usersetting.breakfast_time IS 'User breakfast time (default 07:00)';
COMMENT ON COLUMN usersetting.lunch_time IS 'User lunch time (default 12:00)';
COMMENT ON COLUMN usersetting.dinner_time IS 'User dinner time (default 18:00)';
COMMENT ON COLUMN usersetting.snack_time IS 'User snack time (default 15:00)';
COMMENT ON COLUMN usersetting.lightbulb_x IS 'Lightbulb button X position (0-1, relative to screen width)';
COMMENT ON COLUMN usersetting.lightbulb_y IS 'Lightbulb button Y position (0-1, relative to screen height)';

-- ============================================================
-- 7. FUNCTIONS FOR SMART SUGGESTIONS
-- ============================================================

-- Function: Get current meal period for user
CREATE OR REPLACE FUNCTION get_current_meal_period(p_user_id INTEGER) 
RETURNS VARCHAR(20) AS $$
DECLARE
    v_current_time TIME;
    v_breakfast TIME;
    v_lunch TIME;
    v_dinner TIME;
    v_snack TIME;
    v_next_breakfast TIME;
BEGIN
    -- Get current time in Vietnam timezone
    SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::TIME INTO v_current_time;
    
    -- Get user meal times
    SELECT breakfast_time, lunch_time, dinner_time, snack_time 
    INTO v_breakfast, v_lunch, v_dinner, v_snack
    FROM usersetting 
    WHERE user_id = p_user_id;
    
    -- Default times if not set
    v_breakfast := COALESCE(v_breakfast, '07:00'::TIME);
    v_lunch := COALESCE(v_lunch, '12:00'::TIME);
    v_dinner := COALESCE(v_dinner, '18:00'::TIME);
    v_snack := COALESCE(v_snack, '15:00'::TIME);
    
    -- Calculate next breakfast (for dinner period that crosses midnight)
    v_next_breakfast := v_breakfast;
    
    -- Determine current meal period
    -- Order: breakfast, lunch, snack, dinner
    IF v_current_time >= v_breakfast AND v_current_time < v_lunch THEN
        RETURN 'breakfast';
    ELSIF v_current_time >= v_lunch AND v_current_time < v_snack THEN
        RETURN 'lunch';
    ELSIF v_current_time >= v_snack AND v_current_time < v_dinner THEN
        RETURN 'snack';
    ELSE
        -- dinner period (from dinner_time until next breakfast)
        RETURN 'dinner';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function: Auto-expire pins at 00:00 UTC+7
CREATE OR REPLACE FUNCTION auto_expire_pins() RETURNS TRIGGER AS $$
BEGIN
    -- Set expires_at to next 00:00 UTC+7
    NEW.expires_at := (
        (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE + INTERVAL '1 day'
    )::TIMESTAMPTZ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_expire_pins ON user_pinned_suggestions;
CREATE TRIGGER trg_auto_expire_pins
BEFORE INSERT ON user_pinned_suggestions
FOR EACH ROW EXECUTE FUNCTION auto_expire_pins();

-- Function: Clean expired pins
CREATE OR REPLACE FUNCTION clean_expired_pins() RETURNS INTEGER AS $$
DECLARE
    v_deleted INTEGER;
BEGIN
    DELETE FROM user_pinned_suggestions 
    WHERE expires_at < NOW();
    
    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    RETURN v_deleted;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 8. INITIAL DATA FOR DRINKNUTRIENT
-- drinknutrient table already exists with data
-- No need to insert, admin can manage via existing UI
-- ============================================================

-- Note: drinknutrient uses 'amount_per_100ml' column, not 'amount'
-- Admin imports via existing interface

-- ============================================================
-- COMPLETE! Ready for backend API implementation
-- ============================================================
