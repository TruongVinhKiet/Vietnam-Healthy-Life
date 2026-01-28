-- ============================================================
-- Migration: Body Measurement Tracking System
-- Purpose: Store user body measurements with history tracking
-- ============================================================

-- Create BodyMeasurement table
CREATE TABLE IF NOT EXISTS BodyMeasurement (
    measurement_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    measurement_date TIMESTAMP DEFAULT NOW(),
    weight_kg NUMERIC(5,2) CHECK (weight_kg > 0),
    height_cm NUMERIC(5,2) CHECK (height_cm > 0),
    bmi NUMERIC(4,2),
    bmi_score INT CHECK (bmi_score >= 1 AND bmi_score <= 10), -- Health score 1-10
    bmi_category VARCHAR(20), -- underweight, normal, overweight, obese
    source VARCHAR(50) DEFAULT 'manual', -- manual, smart_scale, app_calculated
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_body_measurement_user_date 
ON BodyMeasurement(user_id, measurement_date DESC);

-- Create function to calculate BMI automatically
CREATE OR REPLACE FUNCTION calculate_bmi_and_score()
RETURNS TRIGGER AS $$
DECLARE
    calculated_bmi NUMERIC(4,2);
    score INT;
    category VARCHAR(20);
BEGIN
    -- Calculate BMI
    IF NEW.weight_kg IS NOT NULL AND NEW.height_cm IS NOT NULL AND NEW.height_cm > 0 THEN
        calculated_bmi := NEW.weight_kg / ((NEW.height_cm / 100.0) * (NEW.height_cm / 100.0));
        NEW.bmi := calculated_bmi;
        
        -- Calculate BMI score (1-10) and category
        -- WHO BMI categories with scoring
        IF calculated_bmi < 16.0 THEN
            score := 2; category := 'severely_underweight';
        ELSIF calculated_bmi < 17.0 THEN
            score := 3; category := 'underweight';
        ELSIF calculated_bmi < 18.5 THEN
            score := 5; category := 'mild_underweight';
        ELSIF calculated_bmi >= 18.5 AND calculated_bmi < 21.0 THEN
            score := 9; category := 'normal';
        ELSIF calculated_bmi >= 21.0 AND calculated_bmi < 25.0 THEN
            score := 10; category := 'optimal'; -- Peak score
        ELSIF calculated_bmi >= 25.0 AND calculated_bmi < 27.0 THEN
            score := 8; category := 'normal_high';
        ELSIF calculated_bmi >= 27.0 AND calculated_bmi < 30.0 THEN
            score := 6; category := 'overweight';
        ELSIF calculated_bmi >= 30.0 AND calculated_bmi < 35.0 THEN
            score := 4; category := 'obese_class_1';
        ELSIF calculated_bmi >= 35.0 AND calculated_bmi < 40.0 THEN
            score := 2; category := 'obese_class_2';
        ELSE
            score := 1; category := 'obese_class_3';
        END IF;
        
        NEW.bmi_score := score;
        NEW.bmi_category := category;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-calculate BMI
CREATE TRIGGER trigger_calculate_bmi
BEFORE INSERT OR UPDATE ON BodyMeasurement
FOR EACH ROW
EXECUTE FUNCTION calculate_bmi_and_score();

-- Sync latest measurement to User table
CREATE OR REPLACE FUNCTION sync_latest_measurement_to_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Update User table with latest measurement
    UPDATE "User"
    SET 
        weight_kg = NEW.weight_kg,
        height_cm = NEW.height_cm
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sync_to_user
AFTER INSERT ON BodyMeasurement
FOR EACH ROW
EXECUTE FUNCTION sync_latest_measurement_to_user();

-- Insert sample data from existing User table
INSERT INTO BodyMeasurement (user_id, weight_kg, height_cm, source, measurement_date)
SELECT 
    user_id, 
    weight_kg, 
    height_cm,
    'initial_import',
    created_at
FROM "User"
WHERE weight_kg IS NOT NULL AND height_cm IS NOT NULL
ON CONFLICT DO NOTHING;

COMMENT ON TABLE BodyMeasurement IS 'Stores historical body measurements with automatic BMI calculation and health scoring';
COMMENT ON COLUMN BodyMeasurement.bmi_score IS 'Health score 1-10 where 10 is optimal BMI (21-25)';
COMMENT ON COLUMN BodyMeasurement.bmi_category IS 'WHO BMI classification category';
