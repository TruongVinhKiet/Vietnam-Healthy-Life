
SET client_encoding = 'UTF8';

BEGIN;

-- Update the calculate_drink_nutrients function to preserve manually entered nutrients
CREATE OR REPLACE FUNCTION calculate_drink_nutrients(p_drink_id INT)
RETURNS void AS $$
DECLARE
    v_total_volume_ml NUMERIC;
    v_total_weight_g NUMERIC;
BEGIN
    SELECT COALESCE(default_volume_ml, 250) 
    INTO v_total_volume_ml
    FROM drink 
    WHERE drink_id = p_drink_id;
    
    SELECT COALESCE(SUM(amount_g), 0)
    INTO v_total_weight_g
    FROM drinkingredient
    WHERE drink_id = p_drink_id;
    
    IF v_total_weight_g = 0 THEN
        RAISE NOTICE 'Drink ID % không có nguyên liệu nào, giữ nguyên nutrients hiện có', p_drink_id;
        RETURN;
    END IF;
    
    -- Only delete nutrients that can be recalculated from ingredients
    -- This preserves manually entered nutrients that aren't in FoodNutrient
    DELETE FROM drinknutrient 
    WHERE drink_id = p_drink_id 
    AND nutrient_id IN (
        SELECT DISTINCT fn.nutrient_id
        FROM drinkingredient di
        JOIN foodnutrient fn ON fn.food_id = di.food_id
        WHERE di.drink_id = p_drink_id
    );
    
    INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml)
    SELECT 
        di.drink_id,
        fn.nutrient_id,
        ROUND(
            (SUM(fn.amount_per_100g * di.amount_g / 100.0) / v_total_volume_ml * 100)::numeric,
            6
        ) AS amount_per_100ml
    FROM drinkingredient di
    INNER JOIN foodnutrient fn ON di.food_id = fn.food_id
    WHERE di.drink_id = p_drink_id
    GROUP BY di.drink_id, fn.nutrient_id
    HAVING SUM(fn.amount_per_100g * di.amount_g / 100.0) > 0
    ON CONFLICT (drink_id, nutrient_id)
    DO UPDATE SET amount_per_100ml = EXCLUDED.amount_per_100ml;
    
    RAISE NOTICE 'Đã tính toán dinh dưỡng cho Drink ID %: % nutrients', 
                 p_drink_id, 
                 (SELECT COUNT(*) FROM drinknutrient WHERE drink_id = p_drink_id);
END;
$$ LANGUAGE plpgsql;

COMMIT;

