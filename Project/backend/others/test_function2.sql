SET client_encoding = 'UTF8';

SELECT 
    nutrient_type, 
    COUNT(*) as count,
    SUM(CASE WHEN current_amount > 0 THEN 1 ELSE 0 END) as with_consumption
FROM calculate_daily_nutrient_intake(9, CURRENT_DATE) 
GROUP BY nutrient_type 
ORDER BY nutrient_type;

SELECT 
    nutrient_type,
    nutrient_code,
    ROUND(current_amount::numeric, 2) as current_amt,
    ROUND(target_amount::numeric, 2) as target_amt,
    ROUND(percentage::numeric, 1) as pct
FROM calculate_daily_nutrient_intake(9, CURRENT_DATE)
WHERE nutrient_type IN ('amino_acid', 'fiber', 'fatty_acid')
ORDER BY nutrient_type, nutrient_code
LIMIT 20;
