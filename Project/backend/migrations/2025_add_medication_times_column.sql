-- Migration: Add medication_times column to UserHealthCondition
-- Date: 2025-12-04
-- Purpose: Store medication schedule times as array for each health condition

-- Add medication_times column if not exists
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'userhealthcondition' 
        AND column_name = 'medication_times'
    ) THEN
        ALTER TABLE UserHealthCondition 
        ADD COLUMN medication_times TEXT[] DEFAULT '{}';
        
        RAISE NOTICE 'Added medication_times column to UserHealthCondition';
    ELSE
        RAISE NOTICE 'medication_times column already exists';
    END IF;
END $$;

-- Add comment
COMMENT ON COLUMN UserHealthCondition.medication_times IS 'Array of medication times in HH:MM format, e.g. {07:00, 12:00, 19:00}';

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_uhc_medication_times 
ON UserHealthCondition USING GIN (medication_times);

RAISE NOTICE 'Migration completed: medication_times column added';
