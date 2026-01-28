-- Migration: Add triggers to automatically log user activities to UserActivityLog
-- This ensures all important user actions are tracked for analytics

BEGIN;

-- Function to log activity (helper function)
CREATE OR REPLACE FUNCTION log_user_activity(p_user_id INT, p_action TEXT) RETURNS VOID AS $$
BEGIN
    IF p_user_id IS NULL OR p_action IS NULL THEN RETURN; END IF;
    INSERT INTO UserActivityLog (user_id, action, log_time)
    VALUES (p_user_id, p_action, NOW())
    ON CONFLICT DO NOTHING; -- Ignore duplicates if any
EXCEPTION
    WHEN OTHERS THEN
        -- Silently ignore errors to not break main operations
        NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- MEAL ACTIVITIES
-- ============================================================

-- Trigger: Log when meal is created (via MealItem insert)
CREATE OR REPLACE FUNCTION trg_log_meal_created() RETURNS trigger AS $$
DECLARE
    v_user_id INT;
BEGIN
    SELECT user_id INTO v_user_id FROM Meal WHERE meal_id = NEW.meal_id;
    IF v_user_id IS NOT NULL THEN
        PERFORM log_user_activity(v_user_id, 'meal_created');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_meal_created ON MealItem;
CREATE TRIGGER trg_log_meal_created
AFTER INSERT ON MealItem
FOR EACH ROW EXECUTE FUNCTION trg_log_meal_created();

-- Trigger: Log when meal entry is created (via meal_entries insert)
CREATE OR REPLACE FUNCTION trg_log_meal_entry_created() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'meal_entry_created', 'meal_entries', NEW.id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_meal_entry_created ON meal_entries;
CREATE TRIGGER trg_log_meal_entry_created
AFTER INSERT ON meal_entries
FOR EACH ROW EXECUTE FUNCTION trg_log_meal_entry_created();

-- ============================================================
-- DISH ACTIVITIES
-- ============================================================

-- Trigger: Log when dish is created (via Dish insert)
CREATE OR REPLACE FUNCTION trg_log_dish_created() RETURNS trigger AS $$
BEGIN
    IF NEW.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(NEW.created_by_user, 'dish_created', 'dish', NEW.dish_id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_dish_created ON Dish;
CREATE TRIGGER trg_log_dish_created
AFTER INSERT ON Dish
FOR EACH ROW WHEN (NEW.created_by_user IS NOT NULL)
EXECUTE FUNCTION trg_log_dish_created();

-- ============================================================
-- DRINK ACTIVITIES
-- ============================================================

-- Trigger: Log when custom drink is created (via Drink insert)
CREATE OR REPLACE FUNCTION trg_log_drink_created() RETURNS trigger AS $$
BEGIN
    IF NEW.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(NEW.created_by_user, 'drink_created', 'drink', NEW.drink_id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_drink_created ON Drink;
CREATE TRIGGER trg_log_drink_created
AFTER INSERT ON Drink
FOR EACH ROW WHEN (NEW.created_by_user IS NOT NULL)
EXECUTE FUNCTION trg_log_drink_created();

-- ============================================================
-- WATER LOGGING ACTIVITIES
-- ============================================================

-- Trigger: Log when water is logged (via WaterLog insert)
CREATE OR REPLACE FUNCTION trg_log_water_logged() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'water_logged', 'waterlog', NEW.id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_water_logged ON WaterLog;
CREATE TRIGGER trg_log_water_logged
AFTER INSERT ON WaterLog
FOR EACH ROW EXECUTE FUNCTION trg_log_water_logged();

-- ============================================================
-- MEDICATION ACTIVITIES
-- ============================================================

-- Trigger: Log when medication is logged (via MedicationLog insert)
CREATE OR REPLACE FUNCTION trg_log_medication_taken() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'medication_taken', 'medicationlog', NEW.id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_medication_taken ON MedicationLog;
CREATE TRIGGER trg_log_medication_taken
AFTER INSERT ON MedicationLog
FOR EACH ROW EXECUTE FUNCTION trg_log_medication_taken();

-- ============================================================
-- BODY MEASUREMENT ACTIVITIES
-- ============================================================

-- Trigger: Log when body measurement is recorded (via BodyMeasurement insert)
CREATE OR REPLACE FUNCTION trg_log_body_measurement() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'body_measurement_recorded', 'bodymeasurement', NEW.id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_body_measurement ON BodyMeasurement;
CREATE TRIGGER trg_log_body_measurement
AFTER INSERT ON BodyMeasurement
FOR EACH ROW EXECUTE FUNCTION trg_log_body_measurement();

-- ============================================================
-- HEALTH CONDITION ACTIVITIES
-- ============================================================

-- Trigger: Log when health condition is added (via UserHealthCondition insert)
CREATE OR REPLACE FUNCTION trg_log_health_condition_added() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'health_condition_added', 'userhealthcondition', NEW.user_condition_id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_health_condition_added ON UserHealthCondition;
CREATE TRIGGER trg_log_health_condition_added
AFTER INSERT ON UserHealthCondition
FOR EACH ROW EXECUTE FUNCTION trg_log_health_condition_added();

-- ============================================================
-- FOOD SEARCH ACTIVITIES (via function call, not trigger)
-- Note: Food search should be logged in the API endpoint, not via trigger
-- ============================================================

COMMIT;

