-- ============================================================
-- Water Intake Tracking Enhancement
-- ------------------------------------------------------------
-- Daily water intake tracking table
-- Integrates with AI analysis and WaterLog
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- TABLE WATER_INTAKE (If not exists)
-- Track daily water intake
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Water_Intake (
    intake_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Water amount (ml)
    today_water_ml NUMERIC(10,2) DEFAULT 0,              -- Total water consumed today
    target_water_ml NUMERIC(10,2) DEFAULT 2000,          -- Target (from UserProfile.daily_water_target)
    
    -- Water sources
    from_drinks_ml NUMERIC(10,2) DEFAULT 0,              -- From drinks (WaterLog, AI drinks)
    from_foods_ml NUMERIC(10,2) DEFAULT 0,               -- From food (AI foods with water_ml)
    from_ai_analysis_ml NUMERIC(10,2) DEFAULT 0,         -- From AI image analysis
    
    -- Metadata
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraint: 1 record/user/day
    UNIQUE(user_id, date)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_water_intake_user ON Water_Intake(user_id);
CREATE INDEX IF NOT EXISTS idx_water_intake_date ON Water_Intake(date);
CREATE INDEX IF NOT EXISTS idx_water_intake_user_date ON Water_Intake(user_id, date);

-- ------------------------------------------------------------
-- TRIGGER: Auto Update Water Intake when WaterLog changes
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_water_intake_from_waterlog()
RETURNS TRIGGER AS $$
BEGIN
    -- When add/edit WaterLog, update Water_Intake
    INSERT INTO Water_Intake (user_id, date, today_water_ml, from_drinks_ml, last_updated)
    VALUES (
        NEW.user_id,
        DATE(NEW.logged_at),
        NEW.amount_ml,
        NEW.amount_ml,
        NOW()
    )
    ON CONFLICT (user_id, date) 
    DO UPDATE SET
        today_water_ml = Water_Intake.today_water_ml + (NEW.amount_ml - COALESCE(OLD.amount_ml, 0)),
        from_drinks_ml = Water_Intake.from_drinks_ml + (NEW.amount_ml - COALESCE(OLD.amount_ml, 0)),
        last_updated = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_waterlog_update_intake ON WaterLog;
CREATE TRIGGER trg_waterlog_update_intake
AFTER INSERT OR UPDATE ON WaterLog
FOR EACH ROW
EXECUTE FUNCTION update_water_intake_from_waterlog();

-- ------------------------------------------------------------
-- TRIGGER: Auto Update Water Intake when AI_Analyzed_Meals accepted
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_water_intake_from_ai_meals()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update when user ACCEPTS (accepted = TRUE)
    IF NEW.accepted = TRUE AND (OLD.accepted IS NULL OR OLD.accepted = FALSE) THEN
        INSERT INTO Water_Intake (user_id, date, today_water_ml, from_ai_analysis_ml, last_updated)
        VALUES (
            NEW.user_id,
            DATE(NEW.analyzed_at),
            NEW.water_ml,
            NEW.water_ml,
            NOW()
        )
        ON CONFLICT (user_id, date) 
        DO UPDATE SET
            today_water_ml = Water_Intake.today_water_ml + NEW.water_ml,
            from_ai_analysis_ml = Water_Intake.from_ai_analysis_ml + NEW.water_ml,
            last_updated = NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ai_meals_update_water_intake ON AI_Analyzed_Meals;
CREATE TRIGGER trg_ai_meals_update_water_intake
AFTER UPDATE ON AI_Analyzed_Meals
FOR EACH ROW
EXECUTE FUNCTION update_water_intake_from_ai_meals();

-- ------------------------------------------------------------
-- FUNCTION: Sync water target from UserProfile
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION sync_water_target_from_profile(p_user_id INT)
RETURNS VOID AS $$
DECLARE
    v_target NUMERIC(10,2);
BEGIN
    -- Get target from UserProfile
    SELECT COALESCE(daily_water_target, 2000) INTO v_target
    FROM UserProfile
    WHERE user_id = p_user_id;
    
    -- Update all user records
    UPDATE Water_Intake
    SET target_water_ml = v_target
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

COMMIT;

-- ============================================================
-- COMMENTS
-- ============================================================
COMMENT ON TABLE Water_Intake IS 'Track daily water intake (from drinks, foods, AI analysis)';
COMMENT ON COLUMN Water_Intake.today_water_ml IS 'Total water consumed (ml) - sum from all sources';
COMMENT ON COLUMN Water_Intake.from_drinks_ml IS 'Water from WaterLog (regular drinks)';
COMMENT ON COLUMN Water_Intake.from_foods_ml IS 'Water from food (pho, soup...) - not used yet';
COMMENT ON COLUMN Water_Intake.from_ai_analysis_ml IS 'Water from AI image analysis (both food + drink)';
