-- Migration: Add triggers to log UPDATE and DELETE operations for user activities
-- This extends the existing activity logging to track all CRUD operations

BEGIN;

-- ============================================================
-- MEAL UPDATE/DELETE ACTIVITIES
-- ============================================================

-- Trigger: Log when meal entry is updated
CREATE OR REPLACE FUNCTION trg_log_meal_entry_updated() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'meal_entry_updated');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_meal_entry_updated ON meal_entries;
CREATE TRIGGER trg_log_meal_entry_updated
AFTER UPDATE ON meal_entries
FOR EACH ROW EXECUTE FUNCTION trg_log_meal_entry_updated();

-- Trigger: Log when meal entry is deleted
CREATE OR REPLACE FUNCTION trg_log_meal_entry_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.user_id IS NOT NULL THEN
        PERFORM log_user_activity(OLD.user_id, 'meal_entry_deleted');
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_meal_entry_deleted ON meal_entries;
CREATE TRIGGER trg_log_meal_entry_deleted
AFTER DELETE ON meal_entries
FOR EACH ROW EXECUTE FUNCTION trg_log_meal_entry_deleted();

-- Trigger: Log when meal item is deleted
CREATE OR REPLACE FUNCTION trg_log_meal_item_deleted() RETURNS trigger AS $$
DECLARE
    v_user_id INT;
BEGIN
    SELECT user_id INTO v_user_id FROM Meal WHERE meal_id = OLD.meal_id;
    IF v_user_id IS NOT NULL THEN
        PERFORM log_user_activity(v_user_id, 'meal_item_deleted');
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_meal_item_deleted ON MealItem;
CREATE TRIGGER trg_log_meal_item_deleted
AFTER DELETE ON MealItem
FOR EACH ROW EXECUTE FUNCTION trg_log_meal_item_deleted();

-- ============================================================
-- DISH UPDATE/DELETE ACTIVITIES
-- ============================================================

-- Trigger: Log when dish is updated
CREATE OR REPLACE FUNCTION trg_log_dish_updated() RETURNS trigger AS $$
BEGIN
    IF NEW.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(NEW.created_by_user, 'dish_updated');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_dish_updated ON Dish;
CREATE TRIGGER trg_log_dish_updated
AFTER UPDATE ON Dish
FOR EACH ROW WHEN (NEW.created_by_user IS NOT NULL)
EXECUTE FUNCTION trg_log_dish_updated();

-- Trigger: Log when dish is deleted
CREATE OR REPLACE FUNCTION trg_log_dish_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(OLD.created_by_user, 'dish_deleted');
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_dish_deleted ON Dish;
CREATE TRIGGER trg_log_dish_deleted
AFTER DELETE ON Dish
FOR EACH ROW WHEN (OLD.created_by_user IS NOT NULL)
EXECUTE FUNCTION trg_log_dish_deleted();

-- ============================================================
-- DRINK UPDATE/DELETE ACTIVITIES
-- ============================================================

-- Trigger: Log when drink is updated
CREATE OR REPLACE FUNCTION trg_log_drink_updated() RETURNS trigger AS $$
BEGIN
    IF NEW.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(NEW.created_by_user, 'drink_updated');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_drink_updated ON Drink;
CREATE TRIGGER trg_log_drink_updated
AFTER UPDATE ON Drink
FOR EACH ROW WHEN (NEW.created_by_user IS NOT NULL)
EXECUTE FUNCTION trg_log_drink_updated();

-- Trigger: Log when drink is deleted
CREATE OR REPLACE FUNCTION trg_log_drink_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(OLD.created_by_user, 'drink_deleted');
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_drink_deleted ON Drink;
CREATE TRIGGER trg_log_drink_deleted
AFTER DELETE ON Drink
FOR EACH ROW WHEN (OLD.created_by_user IS NOT NULL)
EXECUTE FUNCTION trg_log_drink_deleted();

-- ============================================================
-- WATER DELETE ACTIVITIES
-- ============================================================

-- Trigger: Log when water log is deleted
CREATE OR REPLACE FUNCTION trg_log_water_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.user_id IS NOT NULL THEN
        PERFORM log_user_activity(OLD.user_id, 'water_deleted');
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_water_deleted ON WaterLog;
CREATE TRIGGER trg_log_water_deleted
AFTER DELETE ON WaterLog
FOR EACH ROW EXECUTE FUNCTION trg_log_water_deleted();

-- ============================================================
-- MEDICATION DELETE ACTIVITIES
-- ============================================================

-- Trigger: Log when medication log is deleted
CREATE OR REPLACE FUNCTION trg_log_medication_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.user_id IS NOT NULL THEN
        PERFORM log_user_activity(OLD.user_id, 'medication_deleted');
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_medication_deleted ON MedicationLog;
CREATE TRIGGER trg_log_medication_deleted
AFTER DELETE ON MedicationLog
FOR EACH ROW EXECUTE FUNCTION trg_log_medication_deleted();

-- ============================================================
-- BODY MEASUREMENT UPDATE/DELETE ACTIVITIES
-- ============================================================

-- Trigger: Log when body measurement is updated
CREATE OR REPLACE FUNCTION trg_log_body_measurement_updated() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'body_measurement_updated');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_body_measurement_updated ON BodyMeasurement;
CREATE TRIGGER trg_log_body_measurement_updated
AFTER UPDATE ON BodyMeasurement
FOR EACH ROW EXECUTE FUNCTION trg_log_body_measurement_updated();

-- Trigger: Log when body measurement is deleted
CREATE OR REPLACE FUNCTION trg_log_body_measurement_deleted() RETURNS trigger AS $$
BEGIN
    IF OLD.user_id IS NOT NULL THEN
        PERFORM log_user_activity(OLD.user_id, 'body_measurement_deleted');
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_body_measurement_deleted ON BodyMeasurement;
CREATE TRIGGER trg_log_body_measurement_deleted
AFTER DELETE ON BodyMeasurement
FOR EACH ROW EXECUTE FUNCTION trg_log_body_measurement_deleted();

-- ============================================================
-- HEALTH CONDITION DELETE ACTIVITIES
-- ============================================================

-- Trigger: Log when health condition is removed
CREATE OR REPLACE FUNCTION trg_log_health_condition_removed() RETURNS trigger AS $$
BEGIN
    IF OLD.user_id IS NOT NULL THEN
        PERFORM log_user_activity(OLD.user_id, 'health_condition_removed');
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_health_condition_removed ON UserHealthCondition;
CREATE TRIGGER trg_log_health_condition_removed
AFTER DELETE ON UserHealthCondition
FOR EACH ROW EXECUTE FUNCTION trg_log_health_condition_removed();

COMMIT;

