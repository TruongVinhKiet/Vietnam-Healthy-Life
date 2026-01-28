-- Script to recalculate BMI scores for existing data
-- Run this after fixing the API to ensure all measurements have proper scores

-- First, let's see current data
SELECT 
    measurement_id,
    user_id,
    weight_kg,
    height_cm,
    bmi,
    bmi_score,
    bmi_category
FROM BodyMeasurement
ORDER BY measurement_date DESC
LIMIT 10;

-- Recalculate BMI and scores for all existing records
-- This triggers the calculate_bmi_and_score() function
UPDATE BodyMeasurement
SET 
    weight_kg = weight_kg  -- Dummy update to trigger the BEFORE UPDATE trigger
WHERE bmi_score IS NULL OR bmi_category IS NULL;

-- Verify the update
SELECT 
    COUNT(*) as total_measurements,
    COUNT(bmi_score) as with_score,
    COUNT(bmi_category) as with_category,
    AVG(bmi_score) as avg_score
FROM BodyMeasurement;

-- Show sample results
SELECT 
    user_id,
    measurement_date,
    weight_kg,
    height_cm,
    bmi,
    bmi_score,
    bmi_category
FROM BodyMeasurement
ORDER BY measurement_date DESC
LIMIT 20;
