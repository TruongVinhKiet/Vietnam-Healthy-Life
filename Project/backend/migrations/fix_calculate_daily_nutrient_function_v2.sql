-- Fix calculate_daily_nutrient_intake function to use correct tables
-- Corrects the vitamin/mineral nutrient tracking to use nutrientmapping

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
    -- Vitamins from meals
    WITH user_meals AS (
        SELECT 
            mi.food_id,
            mi.weight_g
        FROM Meal m
        JOIN MealItem mi ON m.meal_id = mi.meal_id
        WHERE m.user_id = p_user_id 
        AND m.meal_date = p_date
    ),
    vitamin_intake AS (
        SELECT 
            v.vitamin_id,
            v.name,
            v.unit,
            COALESCE(SUM(
                (fn.amount_per_100g * um.weight_g / 100.0)
            ), 0) as total_consumed
        FROM Vitamin v
        LEFT JOIN nutrientmapping nm ON v.code = nm.nutrient_code AND nm.nutrient_type = 'vitamin'
        LEFT JOIN FoodNutrient fn ON nm.nutrient_id = fn.nutrient_id
        LEFT JOIN user_meals um ON fn.food_id = um.food_id
        GROUP BY v.vitamin_id, v.name, v.unit
    )
    SELECT 
        'vitamin'::VARCHAR(20),
        vi.vitamin_id,
        vi.name::VARCHAR(100),
        vi.total_consumed::NUMERIC(10,3),
        COALESCE(vrda.base_value, 0)::NUMERIC(10,3),
        COALESCE(vrda.unit, vi.unit, 'mg')::VARCHAR(20),
        CASE 
            WHEN COALESCE(vrda.base_value, 0) > 0 THEN 
                (vi.total_consumed / vrda.base_value * 100)::NUMERIC(5,2)
            ELSE 0::NUMERIC(5,2)
        END
    FROM vitamin_intake vi
    LEFT JOIN VitaminRDA vrda ON vi.vitamin_id = vrda.vitamin_id
    
    UNION ALL
    
    -- Minerals from meals
    SELECT 
        'mineral'::VARCHAR(20),
        mi.mineral_id,
        mi.name::VARCHAR(100),
        mi.total_consumed::NUMERIC(10,3),
        COALESCE(mrda.base_value, 0)::NUMERIC(10,3),
        COALESCE(mrda.unit, mi.unit, 'mg')::VARCHAR(20),
        CASE 
            WHEN COALESCE(mrda.base_value, 0) > 0 THEN 
                (mi.total_consumed / mrda.base_value * 100)::NUMERIC(5,2)
            ELSE 0::NUMERIC(5,2)
        END
    FROM (
        SELECT 
            min.mineral_id,
            min.name,
            min.unit,
            COALESCE(SUM(
                (fn.amount_per_100g * um2.weight_g / 100.0)
            ), 0) as total_consumed
        FROM Mineral min
        LEFT JOIN nutrientmapping nm2 ON min.code = nm2.nutrient_code AND nm2.nutrient_type = 'mineral'
        LEFT JOIN FoodNutrient fn ON nm2.nutrient_id = fn.nutrient_id
        LEFT JOIN (
            SELECT 
                mi2.food_id,
                mi2.weight_g
            FROM Meal m2
            JOIN MealItem mi2 ON m2.meal_id = mi2.meal_id
            WHERE m2.user_id = p_user_id 
            AND m2.meal_date = p_date
        ) um2 ON fn.food_id = um2.food_id
        GROUP BY min.mineral_id, min.name, min.unit
    ) mi
    LEFT JOIN MineralRDA mrda ON mi.mineral_id = mrda.mineral_id;
END;
$$ LANGUAGE plpgsql;
