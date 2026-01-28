-- Fix unique constraints for UserFiberIntake and UserFattyAcidIntake
-- This migration adds unique constraints to support ON CONFLICT clauses

BEGIN;

-- Drop existing unique constraint if it exists (to avoid errors on re-run)
DO $$ 
BEGIN
    -- Check and drop unique constraint on UserFiberIntake if exists
    IF EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'userfiberintake_user_date_fiber_unique'
    ) THEN
        ALTER TABLE UserFiberIntake 
        DROP CONSTRAINT userfiberintake_user_date_fiber_unique;
    END IF;
    
    -- Check and drop unique constraint on UserFattyAcidIntake if exists
    IF EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'userfattyacidintake_user_date_fatty_unique'
    ) THEN
        ALTER TABLE UserFattyAcidIntake 
        DROP CONSTRAINT userfattyacidintake_user_date_fatty_unique;
    END IF;
END $$;

-- Add unique constraint on UserFiberIntake
ALTER TABLE UserFiberIntake
ADD CONSTRAINT userfiberintake_user_date_fiber_unique 
UNIQUE (user_id, date, fiber_id);

-- Add unique constraint on UserFattyAcidIntake
ALTER TABLE UserFattyAcidIntake
ADD CONSTRAINT userfattyacidintake_user_date_fatty_unique 
UNIQUE (user_id, date, fatty_acid_id);

COMMIT;

