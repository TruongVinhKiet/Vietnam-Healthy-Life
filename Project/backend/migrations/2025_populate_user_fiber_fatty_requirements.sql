-- Migration: Populate UserFiberRequirement and UserFattyAcidRequirement for all existing users
-- This script will calculate and insert fiber and fatty acid requirements for all users
-- based on their profile data (age, gender, weight, activity level, etc.)

BEGIN;

-- ============================================================
-- Populate UserFiberRequirement for all existing users
-- ============================================================
DO $$
DECLARE
    v_user RECORD;
    v_count INT := 0;
BEGIN
    RAISE NOTICE 'Starting to populate UserFiberRequirement for all users...';
    
    FOR v_user IN SELECT user_id FROM "User" LOOP
        BEGIN
            PERFORM refresh_user_fiber_requirements(v_user.user_id);
            v_count := v_count + 1;
            
            IF v_count % 10 = 0 THEN
                RAISE NOTICE 'Processed % users...', v_count;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Error processing user %: %', v_user.user_id, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Completed populating UserFiberRequirement for % users', v_count;
END $$;

-- ============================================================
-- Populate UserFattyAcidRequirement for all existing users
-- ============================================================
DO $$
DECLARE
    v_user RECORD;
    v_count INT := 0;
BEGIN
    RAISE NOTICE 'Starting to populate UserFattyAcidRequirement for all users...';
    
    FOR v_user IN SELECT user_id FROM "User" LOOP
        BEGIN
            PERFORM refresh_user_fatty_requirements(v_user.user_id);
            v_count := v_count + 1;
            
            IF v_count % 10 = 0 THEN
                RAISE NOTICE 'Processed % users...', v_count;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Error processing user %: %', v_user.user_id, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Completed populating UserFattyAcidRequirement for % users', v_count;
END $$;

-- ============================================================
-- Verify the data was populated
-- ============================================================
DO $$
DECLARE
    v_fiber_count INT;
    v_fatty_count INT;
    v_user_count INT;
BEGIN
    SELECT COUNT(*) INTO v_user_count FROM "User";
    SELECT COUNT(*) INTO v_fiber_count FROM UserFiberRequirement;
    SELECT COUNT(*) INTO v_fatty_count FROM UserFattyAcidRequirement;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE 'Total users: %', v_user_count;
    RAISE NOTICE 'UserFiberRequirement records: %', v_fiber_count;
    RAISE NOTICE 'UserFattyAcidRequirement records: %', v_fatty_count;
    RAISE NOTICE '========================================';
END $$;

COMMIT;

