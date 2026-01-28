-- Migration: Fix log_user_activity function ambiguity
-- Issue: Multiple overloads of log_user_activity cause "function is not unique" errors
-- Solution: Drop old 2-parameter function and keep only the 5-parameter version with defaults

BEGIN;

-- Drop the old 2-parameter function
DROP FUNCTION IF EXISTS log_user_activity(INT, TEXT);

-- Ensure the 5-parameter function exists with proper defaults
CREATE OR REPLACE FUNCTION log_user_activity(
    p_user_id INT,
    p_action TEXT,
    p_object_type TEXT DEFAULT NULL,
    p_object_id INT DEFAULT NULL,
    p_detail JSONB DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    IF p_user_id IS NULL OR p_action IS NULL THEN RETURN; END IF;
    INSERT INTO UserActivityLog (user_id, action, object_type, object_id, detail, log_time)
    VALUES (p_user_id, p_action, p_object_type, p_object_id, p_detail, NOW())
    ON CONFLICT DO NOTHING;
EXCEPTION
    WHEN OTHERS THEN
        -- Silently ignore errors to not break main operations
        NULL;
END;
$$ LANGUAGE plpgsql;

-- Update all triggers that call log_user_activity with 2 parameters to use explicit casts
-- This ensures PostgreSQL knows which function to call

-- Fix trg_log_meal_created
CREATE OR REPLACE FUNCTION trg_log_meal_created() RETURNS trigger AS $$
DECLARE
    v_user_id INT;
BEGIN
    SELECT user_id INTO v_user_id FROM Meal WHERE meal_id = NEW.meal_id;
    IF v_user_id IS NOT NULL THEN
        PERFORM log_user_activity(v_user_id, 'meal_created'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_meal_entry_updated
CREATE OR REPLACE FUNCTION trg_log_meal_entry_updated() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'meal_entry_updated'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_meal_entry_deleted
CREATE OR REPLACE FUNCTION trg_log_meal_entry_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.user_id IS NOT NULL THEN
        PERFORM log_user_activity(OLD.user_id, 'meal_entry_deleted'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_meal_item_deleted
CREATE OR REPLACE FUNCTION trg_log_meal_item_deleted() RETURNS trigger AS $$
DECLARE
    v_user_id INT;
BEGIN
    SELECT user_id INTO v_user_id FROM Meal WHERE meal_id = OLD.meal_id;
    IF v_user_id IS NOT NULL THEN
        PERFORM log_user_activity(v_user_id, 'meal_item_deleted'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_dish_updated
CREATE OR REPLACE FUNCTION trg_log_dish_updated() RETURNS trigger AS $$
BEGIN
    IF NEW.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(NEW.created_by_user, 'dish_updated'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_dish_deleted
CREATE OR REPLACE FUNCTION trg_log_dish_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(OLD.created_by_user, 'dish_deleted'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_drink_updated
CREATE OR REPLACE FUNCTION trg_log_drink_updated() RETURNS trigger AS $$
BEGIN
    IF NEW.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(NEW.created_by_user, 'drink_updated'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_drink_deleted
CREATE OR REPLACE FUNCTION trg_log_drink_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(OLD.created_by_user, 'drink_deleted'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_water_deleted
CREATE OR REPLACE FUNCTION trg_log_water_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.user_id IS NOT NULL THEN
        PERFORM log_user_activity(OLD.user_id, 'water_deleted'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_medication_deleted
CREATE OR REPLACE FUNCTION trg_log_medication_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.user_id IS NOT NULL THEN
        PERFORM log_user_activity(OLD.user_id, 'medication_deleted'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_body_measurement_updated
CREATE OR REPLACE FUNCTION trg_log_body_measurement_updated() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'body_measurement_updated'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_body_measurement_deleted
CREATE OR REPLACE FUNCTION trg_log_body_measurement_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.user_id IS NOT NULL THEN
        PERFORM log_user_activity(OLD.user_id, 'body_measurement_deleted'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Fix trg_log_health_condition_removed
CREATE OR REPLACE FUNCTION trg_log_health_condition_removed() RETURNS trigger AS $$
BEGIN
    IF OLD.user_id IS NOT NULL THEN
        PERFORM log_user_activity(OLD.user_id, 'health_condition_removed'::TEXT, NULL::TEXT, NULL::INT, NULL::JSONB);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

COMMIT;

