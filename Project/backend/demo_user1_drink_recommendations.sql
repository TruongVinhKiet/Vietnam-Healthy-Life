-- Demo: Drink Recommendations for User ID 1
-- User 1 has conditions: 1 (Diabetes), 4 (Obesity), 5 (Gout), 20 (Cholera)

-- ========================================
-- PART 1: User's Health Conditions
-- ========================================
SELECT 
    'USER HEALTH CONDITIONS' as section,
    uhc.user_id,
    uhc.condition_id,
    hc.name_en as condition_name
FROM userhealthcondition uhc
JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
WHERE uhc.user_id = 1
ORDER BY uhc.condition_id;

-- ========================================
-- PART 2: Drinks to AVOID
-- ========================================
SELECT 
    'DRINKS TO AVOID' as section,
    d.drink_id,
    d.name as drink_name,
    d.vietnamese_name,
    cdr.reason,
    cdr.severity,
    hc.name_en as because_of_condition
FROM conditiondrinkrecommendation cdr
JOIN drink d ON cdr.drink_id = d.drink_id
JOIN healthcondition hc ON cdr.condition_id = hc.condition_id
WHERE cdr.recommendation_type = 'avoid'
  AND cdr.condition_id IN (1, 4, 5, 20)
ORDER BY 
    CASE cdr.severity 
        WHEN 'high' THEN 1 
        WHEN 'medium' THEN 2 
        ELSE 3 
    END,
    d.drink_id;

-- ========================================
-- PART 3: Drinks RECOMMENDED
-- ========================================
SELECT 
    'DRINKS RECOMMENDED' as section,
    d.drink_id,
    d.name as drink_name,
    d.vietnamese_name,
    cdr.reason,
    cdr.severity,
    hc.name_en as good_for_condition
FROM conditiondrinkrecommendation cdr
JOIN drink d ON cdr.drink_id = d.drink_id
JOIN healthcondition hc ON cdr.condition_id = hc.condition_id
WHERE cdr.recommendation_type = 'recommend'
  AND cdr.condition_id IN (1, 4, 5, 20)
ORDER BY 
    CASE cdr.severity 
        WHEN 'high' THEN 1 
        WHEN 'medium' THEN 2 
        ELSE 3 
    END,
    d.drink_id;

-- ========================================
-- PART 4: Summary Statistics
-- ========================================
SELECT 
    'SUMMARY' as section,
    'Drinks to Avoid' as metric,
    COUNT(DISTINCT d.drink_id)::text as count
FROM conditiondrinkrecommendation cdr
JOIN drink d ON cdr.drink_id = d.drink_id
WHERE cdr.recommendation_type = 'avoid'
  AND cdr.condition_id IN (1, 4, 5, 20)
UNION ALL
SELECT 
    'SUMMARY',
    'Drinks Recommended',
    COUNT(DISTINCT d.drink_id)::text
FROM conditiondrinkrecommendation cdr
JOIN drink d ON cdr.drink_id = d.drink_id
WHERE cdr.recommendation_type = 'recommend'
  AND cdr.condition_id IN (1, 4, 5, 20)
UNION ALL
SELECT 
    'SUMMARY',
    'Total Recommendations',
    COUNT(*)::text
FROM conditiondrinkrecommendation
WHERE condition_id IN (1, 4, 5, 20);

-- ========================================
-- PART 5: Example Visual in UI
-- ========================================
-- This shows how drinks would appear in the Water Quick Add Sheet:
-- 
-- ❌ AVOID (opacity 0.4, red warning icon):
--    - Vietnamese Black Coffee (HIGH severity - Diabetes, Obesity, Gout)
--    - Vietnamese Milk Coffee (HIGH severity - Diabetes, Gout)
--    - Bubble Milk Tea (HIGH severity - Diabetes, Obesity)
--    - Sugarcane Juice (HIGH severity - Diabetes)
--    - Fresh Orange Juice (HIGH severity - Obesity)
--
-- ✅ RECOMMEND (green background, check icon):
--    - Coconut Water (HIGH - Gout, Cholera)
--    - Green Tea (HIGH - Diabetes)
--    - Pennywort Juice (HIGH - Diabetes, Obesity)
--    - Plain Water (HIGH - Diabetes)
--    - Passion Fruit Juice (HIGH - Gout)
--    - Ginger Honey Tea (MEDIUM - Diabetes, Obesity, Cholera)

SELECT 
    '==== UI PREVIEW ====' as info,
    'User opens Water Quick Add Sheet' as action,
    'Restricted drinks shown with 40% opacity + red warning icon' as visual_avoid,
    'Recommended drinks shown with green background + check icon' as visual_recommend,
    'Warning dialog appears if user selects restricted drink' as interaction;
