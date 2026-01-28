SELECT nutrient_type, COUNT(*) as count 
FROM calculate_daily_nutrient_intake(9, CURRENT_DATE) 
GROUP BY nutrient_type 
ORDER BY nutrient_type;
