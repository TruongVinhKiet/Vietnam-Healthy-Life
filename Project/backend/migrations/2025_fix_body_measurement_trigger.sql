-- Migration: Fix trg_log_body_measurement to use measurement_id instead of id
-- Date: 2025-12-15

BEGIN;

DROP TRIGGER IF EXISTS trg_log_body_measurement ON BodyMeasurement;
DROP FUNCTION IF EXISTS trg_log_body_measurement();

CREATE OR REPLACE FUNCTION trg_log_body_measurement() RETURNS trigger AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'body_measurement_recorded', 'bodymeasurement', NEW.measurement_id, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_body_measurement
AFTER INSERT ON BodyMeasurement
FOR EACH ROW EXECUTE FUNCTION trg_log_body_measurement();

COMMIT;
