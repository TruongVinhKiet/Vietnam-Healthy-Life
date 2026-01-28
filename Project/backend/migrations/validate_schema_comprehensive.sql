-- Comprehensive Database Schema Validation for My Diary Backend API
-- Date: November 18, 2025
-- Purpose: Verify all tables, columns, functions, and triggers match API requirements

BEGIN;

-- ============================================
-- SECTION 1: TABLE EXISTENCE VALIDATION
-- ============================================
DO $$
DECLARE
    v_missing_tables TEXT[] := ARRAY[]::TEXT[];
    v_required_tables TEXT[] := ARRAY[
        'User', 'admin', 'admin_verification', 'adminconversation', 'adminmessage', 
        'adminrole', 'aminoacid', 'aminorequirement', 'bodymeasurement',
        'chatbotconversation', 'chatbotmessage', 'conditionfoodrecommendation',
        'conditionnutrienteffect', 'dailysummary', 'dish', 'dishingredient',
        'dishnotification', 'dishnutrient', 'dishstatistics', 'fattyacid',
        'fattyacidrequirement', 'fiber', 'fiberrequirement', 'food', 'foodnutrient',
        'healthcondition', 'meal', 'meal_entries', 'mealitem', 'medicationschedule',
        'medicationlog', 'mineral', 'mineralrda', 'nutrient', 'role',
        'user_account_status', 'user_block_event', 'user_meal_summaries',
        'user_meal_targets', 'user_unblock_request', 'useractivitylog',
        'useraminointake', 'useraminorequirement', 'userfattyacidintake',
        'userfattyacidrequirement', 'userfiberintake', 'userfiberrequirement',
        'usergoal', 'userhealthcondition', 'usermineralrequirement',
        'usernutrientnotification', 'usernutrienttracking', 'userprofile',
        'usersecurity', 'usersetting', 'uservitaminrequirement', 'vitamin',
        'vitaminrda', 'waterlog', 'passwordchangecode', 'mealtemplate',
        'mealtemplateitem', 'portionsize', 'recipe', 'recipeingredient'
    ];
    v_table TEXT;
BEGIN
    FOREACH v_table IN ARRAY v_required_tables
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE LOWER(table_name) = LOWER(v_table) AND table_schema = 'public'
        ) THEN
            v_missing_tables := array_append(v_missing_tables, v_table);
        END IF;
    END LOOP;
    
    IF array_length(v_missing_tables, 1) > 0 THEN
        RAISE WARNING 'Missing tables: %', array_to_string(v_missing_tables, ', ');
    ELSE
        RAISE NOTICE '✓ All required tables exist (%)', array_length(v_required_tables, 1);
    END IF;
END $$;

-- ============================================
-- SECTION 2: CRITICAL COLUMN VALIDATION
-- ============================================
DO $$
DECLARE
    v_issues TEXT[] := ARRAY[]::TEXT[];
BEGIN
    -- Check medication_details column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'medicationschedule' AND column_name = 'medication_details'
    ) THEN
        v_issues := array_append(v_issues, 'medicationschedule.medication_details missing');
    END IF;
    
    -- Check dish.is_deleted column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'dish' AND column_name = 'is_deleted'
    ) THEN
        v_issues := array_append(v_issues, 'dish.is_deleted missing');
    END IF;
    
    -- Check User.last_login column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'User' AND column_name = 'last_login'
    ) THEN
        v_issues := array_append(v_issues, 'User.last_login missing');
    END IF;
    
    -- Check mealitem columns for meal history feature
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'mealitem' AND column_name = 'dish_id'
    ) THEN
        v_issues := array_append(v_issues, 'mealitem.dish_id missing');
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'mealitem' AND column_name = 'quick_add_count'
    ) THEN
        v_issues := array_append(v_issues, 'mealitem.quick_add_count missing');
    END IF;
    
    -- Check usersetting columns for seasonal/weather features
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'usersetting' AND column_name = 'seasonal_ui_enabled'
    ) THEN
        v_issues := array_append(v_issues, 'usersetting.seasonal_ui_enabled missing');
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'usersetting' AND column_name = 'weather_enabled'
    ) THEN
        v_issues := array_append(v_issues, 'usersetting.weather_enabled missing');
    END IF;
    
    -- Check macro tracking columns
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'usersetting' AND column_name = 'macro_protein_pct'
    ) THEN
        v_issues := array_append(v_issues, 'usersetting.macro_protein_pct missing');
    END IF;
    
    IF array_length(v_issues, 1) > 0 THEN
        RAISE WARNING 'Column issues found: %', array_to_string(v_issues, ', ');
    ELSE
        RAISE NOTICE '✓ All critical columns exist';
    END IF;
END $$;

-- ============================================
-- SECTION 3: FUNCTION EXISTENCE VALIDATION
-- ============================================
DO $$
DECLARE
    v_missing_functions TEXT[] := ARRAY[]::TEXT[];
    v_required_functions TEXT[] := ARRAY[
        'calculate_daily_nutrient_intake',
        'calculate_dish_nutrients',
        'compute_user_fattyacid_requirement',
        'compute_user_fiber_requirement'
    ];
    v_func TEXT;
BEGIN
    FOREACH v_func IN ARRAY v_required_functions
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM pg_proc WHERE proname = v_func
        ) THEN
            v_missing_functions := array_append(v_missing_functions, v_func);
        END IF;
    END LOOP;
    
    IF array_length(v_missing_functions, 1) > 0 THEN
        RAISE WARNING 'Missing functions: %', array_to_string(v_missing_functions, ', ');
    ELSE
        RAISE NOTICE '✓ All required functions exist (%)', array_length(v_required_functions, 1);
    END IF;
END $$;

-- ============================================
-- SECTION 4: FOREIGN KEY RELATIONSHIP VALIDATION
-- ============================================
DO $$
DECLARE
    v_fk_issues TEXT[] := ARRAY[]::TEXT[];
    v_count INT;
BEGIN
    -- Check critical foreign keys
    
    -- MedicationSchedule should reference User and UserHealthCondition
    SELECT COUNT(*) INTO v_count
    FROM information_schema.table_constraints
    WHERE table_name = 'medicationschedule' 
    AND constraint_type = 'FOREIGN KEY';
    
    IF v_count < 2 THEN
        v_fk_issues := array_append(v_fk_issues, 'medicationschedule missing foreign keys');
    END IF;
    
    -- DishIngredient should reference Dish and Food
    SELECT COUNT(*) INTO v_count
    FROM information_schema.table_constraints
    WHERE table_name = 'dishingredient' 
    AND constraint_type = 'FOREIGN KEY';
    
    IF v_count < 2 THEN
        v_fk_issues := array_append(v_fk_issues, 'dishingredient missing foreign keys');
    END IF;
    
    IF array_length(v_fk_issues, 1) > 0 THEN
        RAISE WARNING 'Foreign key issues: %', array_to_string(v_fk_issues, ', ');
    ELSE
        RAISE NOTICE '✓ Critical foreign key relationships verified';
    END IF;
END $$;

-- ============================================
-- SECTION 5: DATA TYPE VALIDATION
-- ============================================
SELECT 
    '✓ Column data types' as validation_check,
    COUNT(*) as validated_columns
FROM (
    SELECT table_name, column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND (
        (table_name = 'medicationschedule' AND column_name = 'medication_details' AND data_type = 'jsonb') OR
        (table_name = 'dish' AND column_name = 'is_deleted' AND data_type = 'boolean') OR
        (table_name = 'usersetting' AND column_name = 'weather_last_data' AND data_type = 'jsonb') OR
        (table_name = 'mealitem' AND column_name = 'calories' AND data_type = 'numeric') OR
        (table_name = 'usernutrientnotification' AND column_name = 'metadata' AND data_type = 'jsonb')
    )
) dt;

-- ============================================
-- SECTION 6: INDEX EXISTENCE VALIDATION
-- ============================================
SELECT 
    '✓ Performance indexes' as validation_check,
    COUNT(*) as index_count
FROM pg_indexes
WHERE schemaname = 'public'
AND (
    indexname LIKE '%user_id%' OR
    indexname LIKE '%meal_id%' OR
    indexname LIKE '%dish_id%' OR
    indexname LIKE '%nutrient%' OR
    indexname LIKE '%date%'
);

-- ============================================
-- SECTION 7: TRIGGER VALIDATION
-- ============================================
SELECT 
    '✓ Active triggers' as validation_check,
    COUNT(DISTINCT trigger_name) as trigger_count
FROM information_schema.triggers
WHERE trigger_schema = 'public';

-- ============================================
-- SECTION 8: ROLE AND PERMISSION VALIDATION
-- ============================================
SELECT 
    '✓ Admin roles configured' as validation_check,
    COUNT(DISTINCT r.role_name) as role_count,
    COUNT(ar.admin_id) as admin_role_assignments
FROM role r
LEFT JOIN adminrole ar ON r.role_id = ar.role_id;

-- ============================================
-- SECTION 9: SUPER ADMIN VERIFICATION
-- ============================================
SELECT 
    '✓ Super admin setup' as validation_check,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM admin a
            JOIN adminrole ar ON a.admin_id = ar.admin_id
            JOIN role r ON ar.role_id = r.role_id
            WHERE a.username = 'truonghoankiet@gmail.com' 
            AND r.role_name = 'super_admin'
        ) THEN 'CONFIGURED'
        ELSE 'NOT FOUND'
    END as status;

-- ============================================
-- SECTION 10: SUMMARY STATISTICS
-- ============================================
SELECT 
    'Database Schema Summary' as category,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') as total_tables,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'public') as total_columns,
    (SELECT COUNT(*) FROM pg_proc WHERE pronamespace = 'public'::regnamespace) as total_functions,
    (SELECT COUNT(DISTINCT trigger_name) FROM information_schema.triggers WHERE trigger_schema = 'public') as total_triggers,
    (SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public') as total_indexes;

COMMIT;

-- Print final status
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE '  DATABASE SCHEMA VALIDATION COMPLETE';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'All API endpoints should now be compatible with the database schema.';
    RAISE NOTICE 'Review warnings above for any issues that need attention.';
END $$;
