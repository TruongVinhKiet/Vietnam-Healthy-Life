-- Test Critical API Queries Against Database Schema
-- Date: November 18, 2025
-- Purpose: Simulate actual API queries to verify schema compatibility

BEGIN;

-- ============================================
-- TEST 1: Nutrient Tracking calculate_daily_nutrient_intake
-- ============================================
DO $$
DECLARE
    v_result RECORD;
BEGIN
    -- Test the function exists and can be called
    SELECT * INTO v_result FROM calculate_daily_nutrient_intake(1, CURRENT_DATE) LIMIT 1;
    RAISE NOTICE 'TEST 1 PASSED: calculate_daily_nutrient_intake function works';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 1 FAILED: calculate_daily_nutrient_intake - %', SQLERRM;
END $$;

-- ============================================
-- TEST 2: UserNutrientNotification table query
-- ============================================
DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM UserNutrientNotification
    WHERE user_id = 1 AND is_read = FALSE;
    
    RAISE NOTICE 'TEST 2 PASSED: UserNutrientNotification query works (% notifications)', v_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 2 FAILED: UserNutrientNotification - %', SQLERRM;
END $$;

-- ============================================
-- TEST 3: Medication Schedule with medication_details
-- ============================================
DO $$
DECLARE
    v_result RECORD;
BEGIN
    SELECT 
        ms.medication_id,
        ms.medication_details,
        unnest(ms.medication_times) as med_time
    INTO v_result
    FROM medicationschedule ms
    LIMIT 1;
    
    RAISE NOTICE 'TEST 3 PASSED: MedicationSchedule with medication_details works';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 3 FAILED: MedicationSchedule - %', SQLERRM;
END $$;

-- ============================================
-- TEST 4: Dish with is_deleted filter
-- ============================================
DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM dish
    WHERE is_deleted = FALSE;
    
    RAISE NOTICE 'TEST 4 PASSED: Dish is_deleted filter works (% active dishes)', v_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 4 FAILED: Dish is_deleted - %', SQLERRM;
END $$;

-- ============================================
-- TEST 5: user_account_status table
-- ============================================
DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_account_status;
    
    RAISE NOTICE 'TEST 5 PASSED: user_account_status table accessible (% records)', v_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 5 FAILED: user_account_status - %', SQLERRM;
END $$;

-- ============================================
-- TEST 6: MealItem with dish_id and quick_add_count
-- ============================================
DO $$
DECLARE
    v_result RECORD;
BEGIN
    SELECT 
        meal_item_id,
        dish_id,
        quick_add_count,
        last_eaten_at
    INTO v_result
    FROM mealitem
    LIMIT 1;
    
    RAISE NOTICE 'TEST 6 PASSED: MealItem with dish_id and quick_add_count works';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 6 FAILED: MealItem columns - %', SQLERRM;
END $$;

-- ============================================
-- TEST 7: UserSetting with seasonal/weather columns
-- ============================================
DO $$
DECLARE
    v_result RECORD;
BEGIN
    SELECT 
        seasonal_ui_enabled,
        weather_enabled,
        weather_city,
        weather_last_data,
        macro_protein_pct,
        macro_fat_pct,
        macro_carb_pct,
        meal_pct_breakfast,
        effect_intensity
    INTO v_result
    FROM usersetting
    LIMIT 1;
    
    RAISE NOTICE 'TEST 7 PASSED: UserSetting with all feature columns works';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 7 FAILED: UserSetting columns - %', SQLERRM;
END $$;

-- ============================================
-- TEST 8: FattyAcid and Fiber requirements
-- ============================================
DO $$
DECLARE
    v_fatty_count INT;
    v_fiber_count INT;
BEGIN
    SELECT COUNT(*) INTO v_fatty_count FROM fattyacid;
    SELECT COUNT(*) INTO v_fiber_count FROM fiber;
    
    IF v_fatty_count >= 13 AND v_fiber_count >= 5 THEN
        RAISE NOTICE 'TEST 8 PASSED: FattyAcid (%) and Fiber (%) tables populated', v_fatty_count, v_fiber_count;
    ELSE
        RAISE WARNING 'TEST 8 WARNING: FattyAcid (%) or Fiber (%) may be incomplete', v_fatty_count, v_fiber_count;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 8 FAILED: FattyAcid/Fiber - %', SQLERRM;
END $$;

-- ============================================
-- TEST 9: Admin Dashboard Stats Query
-- ============================================
DO $$
DECLARE
    v_dish_count INT;
    v_user_count INT;
BEGIN
    SELECT COUNT(*) INTO v_dish_count FROM dish WHERE is_deleted = FALSE;
    SELECT COUNT(*) INTO v_user_count FROM "User";
    
    RAISE NOTICE 'TEST 9 PASSED: Admin dashboard queries work (% dishes, % users)', v_dish_count, v_user_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 9 FAILED: Admin dashboard - %', SQLERRM;
END $$;

-- ============================================
-- TEST 10: Meal Entries and Summaries
-- ============================================
DO $$
DECLARE
    v_entry_count INT;
    v_summary_count INT;
BEGIN
    SELECT COUNT(*) INTO v_entry_count FROM meal_entries;
    SELECT COUNT(*) INTO v_summary_count FROM user_meal_summaries;
    
    RAISE NOTICE 'TEST 10 PASSED: Meal entries (%) and summaries (%) tables work', v_entry_count, v_summary_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 10 FAILED: Meal entries/summaries - %', SQLERRM;
END $$;

-- ============================================
-- TEST 11: Vitamin and Mineral RDA tables
-- ============================================
DO $$
DECLARE
    v_vitamin_count INT;
    v_mineral_count INT;
    v_vitamin_rda INT;
    v_mineral_rda INT;
BEGIN
    SELECT COUNT(*) INTO v_vitamin_count FROM vitamin;
    SELECT COUNT(*) INTO v_mineral_count FROM mineral;
    SELECT COUNT(*) INTO v_vitamin_rda FROM vitaminrda;
    SELECT COUNT(*) INTO v_mineral_rda FROM mineralrda;
    
    RAISE NOTICE 'TEST 11 PASSED: Vitamins (%), Minerals (%), VitaminRDA (%), MineralRDA (%)', 
        v_vitamin_count, v_mineral_count, v_vitamin_rda, v_mineral_rda;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 11 FAILED: Vitamin/Mineral - %', SQLERRM;
END $$;

-- ============================================
-- TEST 12: Dish Nutrients and Statistics
-- ============================================
DO $$
DECLARE
    v_dish_nutrient INT;
    v_dish_stats INT;
BEGIN
    SELECT COUNT(*) INTO v_dish_nutrient FROM dishnutrient;
    SELECT COUNT(*) INTO v_dish_stats FROM dishstatistics;
    
    RAISE NOTICE 'TEST 12 PASSED: DishNutrient (%) and DishStatistics (%) tables work', v_dish_nutrient, v_dish_stats;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 12 FAILED: Dish nutrients/stats - %', SQLERRM;
END $$;

-- ============================================
-- TEST 13: Chatbot Conversation Tables
-- ============================================
DO $$
DECLARE
    v_chatbot_conv INT;
    v_admin_conv INT;
BEGIN
    SELECT COUNT(*) INTO v_chatbot_conv FROM chatbotconversation;
    SELECT COUNT(*) INTO v_admin_conv FROM adminconversation;
    
    RAISE NOTICE 'TEST 13 PASSED: ChatbotConversation (%) and AdminConversation (%) tables work', v_chatbot_conv, v_admin_conv;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 13 FAILED: Conversation tables - %', SQLERRM;
END $$;

-- ============================================
-- TEST 14: Water Log and Daily Summary
-- ============================================
DO $$
DECLARE
    v_water INT;
    v_daily INT;
BEGIN
    SELECT COUNT(*) INTO v_water FROM waterlog;
    SELECT COUNT(*) INTO v_daily FROM dailysummary;
    
    RAISE NOTICE 'TEST 14 PASSED: WaterLog (%) and DailySummary (%) tables work', v_water, v_daily;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 14 FAILED: Water/Daily summary - %', SQLERRM;
END $$;

-- ============================================
-- TEST 15: User Profile and Settings Join
-- ============================================
DO $$
DECLARE
    v_result RECORD;
BEGIN
    SELECT 
        u.user_id,
        u.full_name,
        up.activity_level,
        up.diet_type,
        us.theme,
        us.language
    INTO v_result
    FROM "User" u
    LEFT JOIN userprofile up ON u.user_id = up.user_id
    LEFT JOIN usersetting us ON u.user_id = us.user_id
    LIMIT 1;
    
    RAISE NOTICE 'TEST 15 PASSED: User-Profile-Setting JOIN query works';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'TEST 15 FAILED: User joins - %', SQLERRM;
END $$;

COMMIT;

-- Print final summary
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE '  API QUERY COMPATIBILITY TESTS COMPLETE';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Review PASSED/FAILED messages above';
    RAISE NOTICE 'All PASSED tests indicate endpoints will work correctly';
END $$;
