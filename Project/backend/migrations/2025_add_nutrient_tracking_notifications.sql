-- Migration: Add UserNutrientNotification table for RDA tracking and notifications

BEGIN;

-- Table to track daily nutrient intake and trigger notifications
CREATE TABLE IF NOT EXISTS UserNutrientTracking (
    tracking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    nutrient_type VARCHAR(20) NOT NULL, -- 'vitamin', 'mineral', 'fiber', 'fatty_acid'
    nutrient_id INT NOT NULL, -- ID from respective table
    target_amount NUMERIC(10,3),
    current_amount NUMERIC(10,3) DEFAULT 0,
    unit VARCHAR(20),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date, nutrient_type, nutrient_id)
);

CREATE INDEX IF NOT EXISTS idx_user_nutrient_tracking_user_date 
ON UserNutrientTracking(user_id, date);

-- Table to store nutrient-related notifications
CREATE TABLE IF NOT EXISTS UserNutrientNotification (
    notification_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    nutrient_type VARCHAR(20) NOT NULL,
    nutrient_id INT NOT NULL,
    nutrient_name VARCHAR(100),
    notification_type VARCHAR(50) NOT NULL, -- 'deficiency_warning', 'daily_reminder', 'goal_achieved'
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'info', -- 'info', 'warning', 'critical'
    is_read BOOLEAN DEFAULT FALSE,
    metadata JSONB, -- Store additional data like percentage, amounts, etc.
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_nutrient_notification_user 
ON UserNutrientNotification(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_nutrient_notification_unread 
ON UserNutrientNotification(user_id, is_read) WHERE is_read = FALSE;

-- Function to calculate daily nutrient progress from meals
CREATE OR REPLACE FUNCTION calculate_daily_nutrient_intake(
    p_user_id INT,
    p_date DATE
) RETURNS TABLE(
    nutrient_type VARCHAR(20),
    nutrient_id INT,
    nutrient_code VARCHAR(50),
    nutrient_name VARCHAR(100),
    current_amount NUMERIC,
    target_amount NUMERIC,
    unit VARCHAR(20),
    percentage NUMERIC
) AS $$
BEGIN
    -- Calculate vitamin intake from meals
    RETURN QUERY
    WITH meal_items_today AS (
        SELECT mi.food_id, mi.weight_g
        FROM MealItem mi
        JOIN Meal m ON m.meal_id = mi.meal_id
        WHERE m.user_id = p_user_id AND m.meal_date = p_date
    ),
    vitamin_intake AS (
        SELECT 
            'vitamin'::VARCHAR(20) as nutrient_type,
            v.vitamin_id::INT as nutrient_id,
            v.code as nutrient_code,
            v.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(uvr.recommended, v.recommended_daily::NUMERIC, 0) as target_amount,
            v.unit,
            CASE 
                WHEN COALESCE(uvr.recommended, v.recommended_daily::NUMERIC, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(uvr.recommended, v.recommended_daily::NUMERIC, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Vitamin v
        LEFT JOIN UserVitaminRequirement uvr ON uvr.vitamin_id = v.vitamin_id AND uvr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY v.vitamin_id, v.code, v.name, v.unit, v.recommended_daily, uvr.recommended
    ),
    mineral_intake AS (
        SELECT 
            'mineral'::VARCHAR(20) as nutrient_type,
            m.mineral_id::INT as nutrient_id,
            m.code as nutrient_code,
            m.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(umr.recommended, m.recommended_daily::NUMERIC, 0) as target_amount,
            m.unit,
            CASE 
                WHEN COALESCE(umr.recommended, m.recommended_daily::NUMERIC, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(umr.recommended, m.recommended_daily::NUMERIC, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Mineral m
        LEFT JOIN UserMineralRequirement umr ON umr.mineral_id = m.mineral_id AND umr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(REPLACE(m.code, 'MIN_', ''))
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY m.mineral_id, m.code, m.name, m.unit, m.recommended_daily, umr.recommended
    ),
    amino_acid_intake AS (
        SELECT 
            'amino_acid'::VARCHAR(20) as nutrient_type,
            aa.amino_acid_id::INT as nutrient_id,
            aa.code as nutrient_code,
            aa.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(uar.recommended, 0) as target_amount,
            'mg'::VARCHAR(20) as unit,
            CASE 
                WHEN COALESCE(uar.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(uar.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM AminoAcid aa
        LEFT JOIN UserAminoRequirement uar ON uar.amino_acid_id = aa.amino_acid_id AND uar.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER('AMINO_' || aa.code)
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY aa.amino_acid_id, aa.code, aa.name, uar.recommended
    ),
    fiber_intake AS (
        SELECT 
            'fiber'::VARCHAR(20) as nutrient_type,
            f.fiber_id::INT as nutrient_id,
            f.code as nutrient_code,
            f.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(ufr.recommended, 0) as target_amount,
            f.unit,
            CASE 
                WHEN COALESCE(ufr.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(ufr.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Fiber f
        LEFT JOIN UserFiberRequirement ufr ON ufr.fiber_id = f.fiber_id AND ufr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(
            CASE f.code
                WHEN 'TOTAL_FIBER' THEN 'FIBTG'
                WHEN 'SOLUBLE_FIBER' THEN 'FIB_SOL'
                WHEN 'INSOLUBLE_FIBER' THEN 'FIB_INSOL'
                WHEN 'RESISTANT_STARCH' THEN 'FIB_RS'
                WHEN 'BETA_GLUCAN' THEN 'FIB_BGLU'
                ELSE f.code
            END
        )
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY f.fiber_id, f.code, f.name, f.unit, ufr.recommended
    ),
    fatty_acid_intake AS (
        SELECT 
            'fatty_acid'::VARCHAR(20) as nutrient_type,
            fa.fatty_acid_id::INT as nutrient_id,
            fa.code as nutrient_code,
            fa.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(ufar.recommended, 0) as target_amount,
            fa.unit,
            CASE 
                WHEN COALESCE(ufar.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(ufar.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM FattyAcid fa
        LEFT JOIN UserFattyAcidRequirement ufar ON ufar.fatty_acid_id = fa.fatty_acid_id AND ufar.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(
            CASE fa.code
                WHEN 'TOTAL_FAT' THEN 'FAT'
                WHEN 'SFA' THEN 'FASAT'
                WHEN 'MUFA' THEN 'FAMS'
                WHEN 'PUFA' THEN 'FAPU'
                WHEN 'ALA' THEN 'FA18_3N3'
                WHEN 'EPA' THEN 'FAEPA'
                WHEN 'DHA' THEN 'FADHA'
                WHEN 'EPA_DHA' THEN 'FAEPA_DHA'
                WHEN 'LA' THEN 'FA18_2N6C'
                WHEN 'TRANS_FAT' THEN 'FATRN'
                ELSE fa.code
            END
        )
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY fa.fatty_acid_id, fa.code, fa.name, fa.unit, ufar.recommended
    )
    SELECT * FROM vitamin_intake
    UNION ALL
    SELECT * FROM mineral_intake
    UNION ALL
    SELECT * FROM amino_acid_intake
    UNION ALL
    SELECT * FROM fiber_intake
    UNION ALL
    SELECT * FROM fatty_acid_intake;
END;
$$ LANGUAGE plpgsql;

-- Function to create notifications for nutrient deficiencies
CREATE OR REPLACE FUNCTION check_and_notify_nutrient_deficiencies(
    p_user_id INT,
    p_date DATE DEFAULT CURRENT_DATE
) RETURNS INT AS $$
DECLARE
    v_nutrient RECORD;
    v_notification_count INT := 0;
    v_title TEXT;
    v_message TEXT;
    v_severity VARCHAR(20);
BEGIN
    -- Check nutrients at end of day (e.g., 8pm or later)
    FOR v_nutrient IN 
        SELECT * FROM calculate_daily_nutrient_intake(p_user_id, p_date)
        WHERE percentage < 50 -- Less than 50% of target
    LOOP
        -- Determine severity based on percentage
        IF v_nutrient.percentage < 25 THEN
            v_severity := 'critical';
            v_title := '⚠️ Thiếu hụt nghiêm trọng: ' || v_nutrient.nutrient_name;
            v_message := 'Bạn chỉ đạt ' || ROUND(v_nutrient.percentage, 0) || '% nhu cầu ' || v_nutrient.nutrient_name || 
                        ' (' || ROUND(v_nutrient.current_amount, 1) || '/' || ROUND(v_nutrient.target_amount, 1) || ' ' || v_nutrient.unit || 
                        '). Hãy bổ sung ngay!';
        ELSIF v_nutrient.percentage < 50 THEN
            v_severity := 'warning';
            v_title := '⚡ Cần bổ sung: ' || v_nutrient.nutrient_name;
            v_message := 'Bạn đã đạt ' || ROUND(v_nutrient.percentage, 0) || '% nhu cầu ' || v_nutrient.nutrient_name || 
                        ' (' || ROUND(v_nutrient.current_amount, 1) || '/' || ROUND(v_nutrient.target_amount, 1) || ' ' || v_nutrient.unit || 
                        '). Còn ' || ROUND(v_nutrient.target_amount - v_nutrient.current_amount, 1) || ' ' || v_nutrient.unit || ' nữa.';
        ELSE
            CONTINUE; -- Skip if not deficient
        END IF;

        -- Insert notification if not already exists today
        INSERT INTO UserNutrientNotification(
            user_id, nutrient_type, nutrient_id, nutrient_name,
            notification_type, title, message, severity, is_read,
            metadata
        )
        SELECT 
            p_user_id, 
            v_nutrient.nutrient_type, 
            v_nutrient.nutrient_id, 
            v_nutrient.nutrient_name,
            'deficiency_warning',
            v_title,
            v_message,
            v_severity,
            FALSE,
            jsonb_build_object(
                'date', p_date,
                'current_amount', v_nutrient.current_amount,
                'target_amount', v_nutrient.target_amount,
                'unit', v_nutrient.unit,
                'percentage', v_nutrient.percentage,
                'nutrient_code', v_nutrient.nutrient_code
            )
        WHERE NOT EXISTS (
            SELECT 1 FROM UserNutrientNotification
            WHERE user_id = p_user_id 
            AND nutrient_type = v_nutrient.nutrient_type
            AND nutrient_id = v_nutrient.nutrient_id
            AND notification_type = 'deficiency_warning'
            AND DATE(created_at) = p_date
        );

        IF FOUND THEN
            v_notification_count := v_notification_count + 1;
        END IF;
    END LOOP;

    RETURN v_notification_count;
END;
$$ LANGUAGE plpgsql;

-- Function to track nutrient intake in real-time
CREATE OR REPLACE FUNCTION update_nutrient_tracking() RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_meal_date DATE;
BEGIN
    -- Get user_id and meal_date from the meal
    SELECT m.user_id, m.meal_date INTO v_user_id, v_meal_date
    FROM Meal m WHERE m.meal_id = COALESCE(NEW.meal_id, OLD.meal_id);

    -- Refresh tracking for this user and date
    -- This will be done via backend API call after meal operations
    -- But we can insert a placeholder here
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger to update tracking when meals change
DROP TRIGGER IF EXISTS trg_update_nutrient_tracking ON MealItem;
CREATE TRIGGER trg_update_nutrient_tracking
AFTER INSERT OR UPDATE OR DELETE ON MealItem
FOR EACH ROW EXECUTE FUNCTION update_nutrient_tracking();

-- View for easy nutrient notification access
CREATE OR REPLACE VIEW vw_user_nutrient_notifications AS
SELECT 
    unn.*,
    CASE 
        WHEN unn.created_at > NOW() - INTERVAL '1 hour' THEN 'new'
        WHEN unn.created_at > NOW() - INTERVAL '24 hours' THEN 'recent'
        ELSE 'old'
    END as freshness
FROM UserNutrientNotification unn
ORDER BY unn.created_at DESC;

COMMIT;
