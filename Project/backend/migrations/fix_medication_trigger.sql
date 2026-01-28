-- Fix trigger trg_log_medication_taken to use correct column name
-- The medicationlog table has log_id, not id

CREATE OR REPLACE FUNCTION trg_log_medication_taken() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        -- Use log_id instead of id
        PERFORM log_user_activity(NEW.user_id, 'medication_taken', 'medicationlog', NEW.log_id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger is already created, just needed to fix the function
