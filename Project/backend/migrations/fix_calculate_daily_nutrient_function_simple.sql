-- Simplified calculate_daily_nutrient_intake function
-- Returns vitamin/mineral targets without needing historical meal data

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
    -- Vitamins with RDA targets
    SELECT 
        'vitamin'::VARCHAR(20),
        v.vitamin_id,
        v.name::VARCHAR(100),
        0::NUMERIC(10,3) as total_amount,
        COALESCE(vrda.base_value, v.recommended_daily, 0)::NUMERIC(10,3),
        COALESCE(vrda.unit, v.unit, 'mg')::VARCHAR(20),
        0::NUMERIC(5,2) as percent_of_target
    FROM Vitamin v
    LEFT JOIN VitaminRDA vrda ON v.vitamin_id = vrda.vitamin_id
    
    UNION ALL
    
    -- Minerals with RDA targets
    SELECT 
        'mineral'::VARCHAR(20),
        m.mineral_id,
        m.name::VARCHAR(100),
        0::NUMERIC(10,3),
        COALESCE(mrda.base_value, m.recommended_daily, 0)::NUMERIC(10,3),
        COALESCE(mrda.unit, m.unit, 'mg')::VARCHAR(20),
        0::NUMERIC(5,2)
    FROM Mineral m
    LEFT JOIN MineralRDA mrda ON m.mineral_id = mrda.mineral_id;
END;
$$ LANGUAGE plpgsql;
