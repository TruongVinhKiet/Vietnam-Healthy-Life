-- Migration: Create UserNutrientNotification and related tables (UTF-8 safe)

BEGIN;

CREATE TABLE IF NOT EXISTS UserNutrientTracking (
    tracking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    nutrient_type VARCHAR(20) NOT NULL,
    nutrient_id INT NOT NULL,
    target_amount NUMERIC(10,3),
    current_amount NUMERIC(10,3) DEFAULT 0,
    unit VARCHAR(20),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date, nutrient_type, nutrient_id)
);

CREATE INDEX IF NOT EXISTS idx_user_nutrient_tracking_user_date 
ON UserNutrientTracking(user_id, date);

CREATE TABLE IF NOT EXISTS UserNutrientNotification (
    notification_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    nutrient_type VARCHAR(20) NOT NULL,
    nutrient_id INT NOT NULL,
    nutrient_name VARCHAR(100),
    notification_type VARCHAR(50) NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_nutrient_notification_user 
ON UserNutrientNotification(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_nutrient_notification_unread 
ON UserNutrientNotification(user_id, is_read) WHERE is_read = FALSE;

CREATE OR REPLACE FUNCTION calculate_daily_nutrient_intake(
    p_user_id INT,
    p_date DATE
) RETURNS TABLE(
    nutrient_type VARCHAR(20),
    nutrient_id INT,
    nutrient_name VARCHAR(100),
    total_amount NUMERIC(10,3),
    target_amount NUMERIC(10,3),
    unit VARCHAR(20),
    percent_of_target NUMERIC(5,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'vitamin'::VARCHAR(20) as nutrient_type,
        v.vitamin_id as nutrient_id,
        v.name::VARCHAR(100) as nutrient_name,
        COALESCE(SUM(vn.amount), 0)::NUMERIC(10,3) as total_amount,
        COALESCE(rda.base_value, 0)::NUMERIC(10,3) as target_amount,
        COALESCE(rda.unit, 'mg')::VARCHAR(20) as unit,
        CASE 
            WHEN COALESCE(rda.base_value, 0) > 0 THEN 
                (COALESCE(SUM(vn.amount), 0) / rda.base_value * 100)::NUMERIC(5,2)
            ELSE 0::NUMERIC(5,2)
        END as percent_of_target
    FROM Vitamin v
    LEFT JOIN VitaminNutrient vn ON v.vitamin_id = vn.vitamin_id
    LEFT JOIN FoodNutrient fn ON vn.nutrient_id = fn.nutrient_id
    LEFT JOIN MealItem mi ON fn.food_id = mi.food_id
    LEFT JOIN Meal m ON mi.meal_id = m.meal_id AND m.user_id = p_user_id AND m.meal_date = p_date
    LEFT JOIN VitaminRDA rda ON v.vitamin_id = rda.vitamin_id
    GROUP BY v.vitamin_id, v.name, rda.base_value, rda.unit
    
    UNION ALL
    
    SELECT 
        'mineral'::VARCHAR(20),
        min.mineral_id,
        min.name::VARCHAR(100),
        COALESCE(SUM(mn.amount), 0)::NUMERIC(10,3),
        COALESCE(rda.base_value, 0)::NUMERIC(10,3),
        COALESCE(rda.unit, 'mg')::VARCHAR(20),
        CASE 
            WHEN COALESCE(rda.base_value, 0) > 0 THEN 
                (COALESCE(SUM(mn.amount), 0) / rda.base_value * 100)::NUMERIC(5,2)
            ELSE 0::NUMERIC(5,2)
        END
    FROM Mineral min
    LEFT JOIN MineralNutrient mn ON min.mineral_id = mn.mineral_id
    LEFT JOIN FoodNutrient fn ON mn.nutrient_id = fn.nutrient_id
    LEFT JOIN MealItem mi ON fn.food_id = mi.food_id
    LEFT JOIN Meal m ON mi.meal_id = m.meal_id AND m.user_id = p_user_id AND m.meal_date = p_date
    LEFT JOIN MineralRDA rda ON min.mineral_id = rda.mineral_id
    GROUP BY min.mineral_id, min.name, rda.base_value, rda.unit;
END;
$$ LANGUAGE plpgsql;

COMMIT;
