-- Migration: Add trigger to update DailySummary when meal_entries are inserted/updated/deleted
-- This ensures Mediterranean diet progress bars update correctly when adding dishes (which use meal_entries)

BEGIN;

-- Function to adjust DailySummary when meal_entries change
CREATE OR REPLACE FUNCTION adjust_daily_summary_on_meal_entry_change() RETURNS trigger AS $$
DECLARE
    v_user INT;
    v_date DATE;
    v_cal NUMERIC;
    v_prot NUMERIC;
    v_fat NUMERIC;
    v_carb NUMERIC;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_user := NEW.user_id;
        v_date := NEW.entry_date;
        v_cal := COALESCE(NEW.kcal, 0);
        v_prot := COALESCE(NEW.protein, 0);
        v_fat := COALESCE(NEW.fat, 0);
        v_carb := COALESCE(NEW.carbs, 0);
        
        -- Upsert DailySummary
        INSERT INTO DailySummary(user_id, date, total_calories, total_protein, total_fat, total_carbs)
        VALUES (v_user, v_date, v_cal, v_prot, v_fat, v_carb)
        ON CONFLICT (user_id, date) DO UPDATE
        SET total_calories = DailySummary.total_calories + EXCLUDED.total_calories,
            total_protein = DailySummary.total_protein + EXCLUDED.total_protein,
            total_fat = DailySummary.total_fat + EXCLUDED.total_fat,
            total_carbs = DailySummary.total_carbs + EXCLUDED.total_carbs;
        
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Decrement old values
        v_user := OLD.user_id;
        v_date := OLD.entry_date;
        v_cal := COALESCE(OLD.kcal, 0);
        v_prot := COALESCE(OLD.protein, 0);
        v_fat := COALESCE(OLD.fat, 0);
        v_carb := COALESCE(OLD.carbs, 0);
        
        UPDATE DailySummary SET
            total_calories = GREATEST(total_calories - v_cal, 0),
            total_protein = GREATEST(total_protein - v_prot, 0),
            total_fat = GREATEST(total_fat - v_fat, 0),
            total_carbs = GREATEST(total_carbs - v_carb, 0)
        WHERE user_id = v_user AND date = v_date;
        
        -- Increment new values
        v_user := NEW.user_id;
        v_date := NEW.entry_date;
        v_cal := COALESCE(NEW.kcal, 0);
        v_prot := COALESCE(NEW.protein, 0);
        v_fat := COALESCE(NEW.fat, 0);
        v_carb := COALESCE(NEW.carbs, 0);
        
        INSERT INTO DailySummary(user_id, date, total_calories, total_protein, total_fat, total_carbs)
        VALUES (v_user, v_date, v_cal, v_prot, v_fat, v_carb)
        ON CONFLICT (user_id, date) DO UPDATE
        SET total_calories = DailySummary.total_calories + EXCLUDED.total_calories,
            total_protein = DailySummary.total_protein + EXCLUDED.total_protein,
            total_fat = DailySummary.total_fat + EXCLUDED.total_fat,
            total_carbs = DailySummary.total_carbs + EXCLUDED.total_carbs;
        
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        v_user := OLD.user_id;
        v_date := OLD.entry_date;
        v_cal := COALESCE(OLD.kcal, 0);
        v_prot := COALESCE(OLD.protein, 0);
        v_fat := COALESCE(OLD.fat, 0);
        v_carb := COALESCE(OLD.carbs, 0);
        
        UPDATE DailySummary SET
            total_calories = GREATEST(total_calories - v_cal, 0),
            total_protein = GREATEST(total_protein - v_prot, 0),
            total_fat = GREATEST(total_fat - v_fat, 0),
            total_carbs = GREATEST(total_carbs - v_carb, 0)
        WHERE user_id = v_user AND date = v_date;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on meal_entries table
DROP TRIGGER IF EXISTS trg_adjust_daily_summary_meal_entries ON meal_entries;
CREATE TRIGGER trg_adjust_daily_summary_meal_entries
AFTER INSERT OR UPDATE OR DELETE ON meal_entries
FOR EACH ROW EXECUTE FUNCTION adjust_daily_summary_on_meal_entry_change();

COMMIT;

