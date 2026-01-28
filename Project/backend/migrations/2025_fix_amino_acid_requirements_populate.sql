-- Migration: Populate UserAminoRequirement for all existing users
-- This ensures amino acid progress bars work correctly
-- Issue: UserAminoRequirement may not be populated for existing users

BEGIN;

-- Populate UserAminoRequirement for all existing users
DO $$
DECLARE
    u RECORD;
BEGIN
    FOR u IN SELECT user_id FROM "User" LOOP
        PERFORM refresh_user_amino_requirements(u.user_id);
    END LOOP;
    
    RAISE NOTICE 'Populated UserAminoRequirement for all users';
END $$;

COMMIT;

