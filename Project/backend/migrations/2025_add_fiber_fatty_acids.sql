-- Migration: add Dietary Fiber and Fatty Acids support
-- Creates canonical Fiber and FattyAcid tables, requirement rows, per-user cached requirement tables,
-- intake tables that will be populated from MealItem / FoodNutrient lookups, compute and refresh functions,
-- and triggers to refresh per-user caches when user/profile changes or when MealItem changes occur.

-- ============================================================
-- I. Canonical definitions
-- ============================================================
-- Table DDL for Fiber/FattyAcid (Fiber, FattyAcid, Requirement and Intake tables)
-- has been moved to `schema.sql` to serve as the single source of truth.
-- Functions, triggers and seeds remain in this migration file.

-- ============================================================
-- V. Compute per-user requirement helpers
-- - Fiber: similar heuristics to vitamin/mineral; supports per-kg rules
-- - Fatty acids: supports base grams or energy-% rows (convert using TDEE or fallback daily_calorie_target)
-- ============================================================

CREATE OR REPLACE FUNCTION compute_user_fiber_requirement(p_user_id INT, p_fiber_id INT)
RETURNS TABLE(base NUMERIC, multiplier NUMERIC, recommended NUMERIC, unit TEXT) AS $$
DECLARE
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_tdee NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
    v_req RECORD;
    v_rec NUMERIC;
BEGIN
    SELECT * INTO v_req FROM FiberRequirement r
    WHERE r.fiber_id = p_fiber_id
      AND (r.sex IS NULL OR lower(r.sex) = lower((SELECT COALESCE(u.gender,'') FROM "User" u WHERE u.user_id = p_user_id)))
      AND ( (r.age_min IS NULL AND r.age_max IS NULL) OR (
            (SELECT COALESCE(u.age,0) FROM "User" u WHERE u.user_id = p_user_id) BETWEEN COALESCE(r.age_min, -9999) AND COALESCE(r.age_max, 99999)
          ) )
    LIMIT 1;

    IF v_req IS NULL THEN
        -- nothing found
        RETURN;
    END IF;

    v_base := v_req.base_value;
    v_unit := COALESCE(v_req.unit, 'g');

    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, COALESCE(up.tdee,0), u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_tdee, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;

    -- small activity/goal/gender multipliers to adjust fiber needs
    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.10, 0.10 );
    END IF;
    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN v_mult := v_mult + 0.05;
        ELSIF lower(v_goal) = 'gain_weight' THEN v_mult := v_mult - 0.02; END IF;
    END IF;
    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN v_mult := v_mult + 0.02; END IF;

    -- per-kg: multiply base_value by weight if required
    IF v_req.is_per_kg THEN
        IF v_weight IS NOT NULL THEN
            v_rec := ROUND(COALESCE(v_base,0) * v_weight * v_mult, 3);
        ELSE
            v_rec := NULL;
        END IF;
    ELSE
        v_rec := ROUND(COALESCE(v_base,0) * v_mult, 3);
    END IF;

    RETURN QUERY SELECT v_base, v_mult, v_rec, v_unit;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION compute_user_fattyacid_requirement(p_user_id INT, p_fa_id INT)
RETURNS TABLE(base NUMERIC, multiplier NUMERIC, recommended NUMERIC, unit TEXT) AS $$
DECLARE
    v_req RECORD;
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_tdee NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
    v_rec NUMERIC;
    v_energy_kcal NUMERIC;
    v_code TEXT;
    v_base_pct NUMERIC;
BEGIN
    SELECT * INTO v_req FROM FattyAcidRequirement r
    WHERE r.fatty_acid_id = p_fa_id
      AND (r.sex IS NULL OR lower(r.sex) = lower((SELECT COALESCE(u.gender,'') FROM "User" u WHERE u.user_id = p_user_id)))
      AND ( (r.age_min IS NULL AND r.age_max IS NULL) OR (
            (SELECT COALESCE(u.age,0) FROM "User" u WHERE u.user_id = p_user_id) BETWEEN COALESCE(r.age_min, -9999) AND COALESCE(r.age_max, 99999)
          ) )
    LIMIT 1;

    IF v_req IS NULL THEN RETURN; END IF;

    v_base := v_req.base_value;
    v_unit := COALESCE(v_req.unit, 'g');

    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, COALESCE(up.tdee,0), COALESCE(up.daily_calorie_target,0), u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_tdee, v_energy_kcal, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;

    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.10, 0.10 );
    END IF;
    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN v_mult := v_mult + 0.03;
        ELSIF lower(v_goal) = 'gain_weight' THEN v_mult := v_mult - 0.02; END IF;
    END IF;
    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN v_mult := v_mult + 0.02; END IF;

    -- Determine a sensible energy baseline (TDEE > daily_calorie_target > fallback 2000)
    IF v_tdee IS NULL OR v_tdee = 0 THEN
        v_tdee := v_energy_kcal;
    END IF;
    IF v_tdee IS NULL OR v_tdee = 0 THEN
        v_tdee := 2000; -- fallback kcal/day
    END IF;

    -- fetch canonical code for special-case nutrients (EPA/DHA/CHOLESTEROL)
    SELECT code INTO v_code FROM FattyAcid WHERE fatty_acid_id = p_fa_id LIMIT 1;

    IF v_req.is_energy_pct THEN
        -- convert energy percent (0-100) into grams of fat: grams = (pct/100 * kcal) / 9
        -- start with configured pct or base_value if stored as pct
        v_base_pct := COALESCE(v_req.energy_pct, v_req.base_value, 0);

        -- Apply demographic/activity adjustments for total fat group as requested:
        -- Male: +10% total fat
        -- Age 51-70: -5% total energy from fat
        -- Activity >= 1.725: +5% total energy from fat
        IF v_gender IS NOT NULL AND lower(v_gender) LIKE 'm%' THEN
            v_base_pct := v_base_pct * 1.10; -- +10%
        END IF;
        IF v_age IS NOT NULL AND v_age BETWEEN 51 AND 70 THEN
            v_base_pct := v_base_pct * 0.95; -- -5%
        END IF;
        IF v_activity IS NOT NULL AND v_activity >= 1.725 THEN
            v_base_pct := v_base_pct * 1.05; -- +5%
        END IF;

        -- final recommended grams from energy percent
        v_rec := ROUND( (COALESCE(v_base_pct,0) / 100.0) * v_tdee / 9.0 * v_mult, 3);
        v_base := v_base_pct; -- report base as pct
        v_unit := 'g';
    ELSE
        -- handle special mg-based nutrients (EPA/DHA combined and Cholesterol)
        IF v_code IS NOT NULL AND (upper(v_code) = 'EPA' OR upper(v_code) = 'DHA' OR upper(v_code) = 'EPA_DHA' OR upper(v_code) = 'EPA+DHA') THEN
            -- EPA+DHA baseline: 250 mg; males +100 mg
            v_rec := ROUND( (COALESCE(v_req.base_value,250) + CASE WHEN lower(v_gender) LIKE 'm%' THEN 100 ELSE 0 END) * v_mult , 0);
            v_base := COALESCE(v_req.base_value,250);
            v_unit := 'mg';
        ELSIF v_code IS NOT NULL AND upper(v_code) = 'CHOLESTEROL' THEN
            -- Cholesterol mg: default 300 mg, reduce to 200 mg for age 51-70
            v_rec := COALESCE(v_req.base_value,300);
            IF v_age IS NOT NULL AND v_age BETWEEN 51 AND 70 THEN
                v_rec := v_rec - 100;
            END IF;
            v_rec := ROUND(v_rec * v_mult, 0);
            v_base := COALESCE(v_req.base_value,300);
            v_unit := 'mg';
        ELSE
            -- standard gram-based or per-kg rules
            IF v_req.is_per_kg THEN
                IF v_weight IS NOT NULL THEN
                    v_rec := ROUND( COALESCE(v_base,0) * v_weight * v_mult, 3);
                ELSE
                    v_rec := NULL;
                END IF;
            ELSE
                v_rec := ROUND( COALESCE(v_base,0) * v_mult, 3);
            END IF;
        END IF;
    END IF;

    RETURN QUERY SELECT v_base, v_mult, v_rec, v_unit;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- VI. Refresh functions to upsert per-user required rows
-- ============================================================

CREATE OR REPLACE FUNCTION refresh_user_fiber_requirements(p_user_id INT) RETURNS VOID AS $$
DECLARE
    v RECORD;
    v_base NUMERIC;
    v_mult NUMERIC;
    v_rec NUMERIC;
    v_unit TEXT;
BEGIN
    IF p_user_id IS NULL THEN RETURN; END IF;
    FOR v IN SELECT fiber_id FROM Fiber LOOP
        SELECT base, multiplier, recommended, unit INTO v_base, v_mult, v_rec, v_unit FROM compute_user_fiber_requirement(p_user_id, v.fiber_id);
        INSERT INTO UserFiberRequirement(user_id, fiber_id, base, multiplier, recommended, unit, updated_at)
        VALUES (p_user_id, v.fiber_id, v_base, v_mult, v_rec, v_unit, NOW())
        ON CONFLICT (user_id, fiber_id) DO UPDATE
        SET base = EXCLUDED.base, multiplier = EXCLUDED.multiplier, recommended = EXCLUDED.recommended, unit = EXCLUDED.unit, updated_at = EXCLUDED.updated_at;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION refresh_user_fatty_requirements(p_user_id INT) RETURNS VOID AS $$
DECLARE
    v RECORD;
    v_base NUMERIC;
    v_mult NUMERIC;
    v_rec NUMERIC;
    v_unit TEXT;
BEGIN
    IF p_user_id IS NULL THEN RETURN; END IF;
    FOR v IN SELECT fatty_acid_id FROM FattyAcid LOOP
        SELECT base, multiplier, recommended, unit INTO v_base, v_mult, v_rec, v_unit FROM compute_user_fattyacid_requirement(p_user_id, v.fatty_acid_id);
        INSERT INTO UserFattyAcidRequirement(user_id, fatty_acid_id, base, multiplier, recommended, unit, updated_at)
        VALUES (p_user_id, v.fatty_acid_id, v_base, v_mult, v_rec, v_unit, NOW())
        ON CONFLICT (user_id, fatty_acid_id) DO UPDATE
        SET base = EXCLUDED.base, multiplier = EXCLUDED.multiplier, recommended = EXCLUDED.recommended, unit = EXCLUDED.unit, updated_at = EXCLUDED.updated_at;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- VII. Triggers to refresh when User or UserProfile changes
-- ============================================================

CREATE OR REPLACE FUNCTION trg_refresh_user_fiber_from_userprofile() RETURNS trigger AS $$
BEGIN
    PERFORM refresh_user_fiber_requirements(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_refresh_user_fatty_from_userprofile() RETURNS trigger AS $$
BEGIN
    PERFORM refresh_user_fatty_requirements(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_refresh_user_fiber_from_user() RETURNS trigger AS $$
BEGIN
    PERFORM refresh_user_fiber_requirements(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_refresh_user_fatty_from_user() RETURNS trigger AS $$
BEGIN
    PERFORM refresh_user_fatty_requirements(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_userprofile_fiber_refresh ON UserProfile;
CREATE TRIGGER trg_userprofile_fiber_refresh
AFTER INSERT OR UPDATE OF activity_factor, tdee, goal_type ON UserProfile
FOR EACH ROW EXECUTE FUNCTION trg_refresh_user_fiber_from_userprofile();

DROP TRIGGER IF EXISTS trg_userprofile_fatty_refresh ON UserProfile;
CREATE TRIGGER trg_userprofile_fatty_refresh
AFTER INSERT OR UPDATE OF activity_factor, tdee, goal_type ON UserProfile
FOR EACH ROW EXECUTE FUNCTION trg_refresh_user_fatty_from_userprofile();

DROP TRIGGER IF EXISTS trg_user_fiber_refresh ON "User";
CREATE TRIGGER trg_user_fiber_refresh
AFTER UPDATE OF weight_kg, gender ON "User"
FOR EACH ROW WHEN (OLD.weight_kg IS DISTINCT FROM NEW.weight_kg OR OLD.gender IS DISTINCT FROM NEW.gender)
EXECUTE FUNCTION trg_refresh_user_fiber_from_user();

DROP TRIGGER IF EXISTS trg_user_fatty_refresh ON "User";
CREATE TRIGGER trg_user_fatty_refresh
AFTER UPDATE OF weight_kg, gender ON "User"
FOR EACH ROW WHEN (OLD.weight_kg IS DISTINCT FROM NEW.weight_kg OR OLD.gender IS DISTINCT FROM NEW.gender)
EXECUTE FUNCTION trg_refresh_user_fatty_from_user();

-- ============================================================
-- VIII. MealItem hooks to update intake tables
--  - on MealItem insert/update/delete, compute fiber/fatty acid amounts from FoodNutrient
--  - upsert into UserFiberIntake and UserFattyAcidIntake grouped by date/user/nutrient
-- NOTE: This implementation uses heuristic lookups by nutrient_code or nutrient name
-- ============================================================

CREATE OR REPLACE FUNCTION compute_and_upsert_fiber_fattyintake() RETURNS trigger AS $$
DECLARE
    v_user INT;
    v_date DATE;
    v_fiber_amount NUMERIC := 0;
    v_fatty_amount NUMERIC := 0;
    rec RECORD;
    v_weight_factor NUMERIC;
BEGIN
    -- find user and date for the meal
    IF TG_OP = 'DELETE' THEN
        SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = OLD.meal_id;
    ELSE
        SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = NEW.meal_id;
    END IF;

    -- determine grams for the meal item (weight_g)
    IF TG_OP = 'DELETE' THEN
        v_weight_factor := OLD.weight_g / 100.0;
    ELSE
        v_weight_factor := NEW.weight_g / 100.0;
    END IF;

    -- iterate fiber nutrients (heuristic codes: 'FIBTG' common in USDA)
    v_fiber_amount := 0;
    FOR rec IN
        SELECT fn.amount_per_100g
        FROM FoodNutrient fn JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = COALESCE(NEW.food_id, OLD.food_id)
          AND (upper(n.nutrient_code) = 'FIBTG' OR lower(n.name) LIKE '%fiber%' OR lower(n.name) LIKE '%fibre%')
    LOOP
        v_fiber_amount := v_fiber_amount + COALESCE(rec.amount_per_100g,0) * v_weight_factor;
    END LOOP;

    -- iterate fatty acid nutrient heuristics (common codes: 'FAMS'(MUFA), 'FAPU'(PUFA), 'FATRN'(trans), 'FAEPA','FADHA')
    v_fatty_amount := 0;
    FOR rec IN
        SELECT fn.amount_per_100g, n.nutrient_id, n.name, n.nutrient_code
        FROM FoodNutrient fn JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = COALESCE(NEW.food_id, OLD.food_id)
          AND (
              upper(n.nutrient_code) IN ('FAMS','FAPU','FATRN','FA18_2N6C','FA18_3N3','FAEPA','FADHA')
              OR lower(n.name) LIKE '%saturated fat%' OR lower(n.name) LIKE '%monounsaturated%' OR lower(n.name) LIKE '%polyunsat%'
              OR lower(n.name) LIKE '%epa%' OR lower(n.name) LIKE '%dha%' OR lower(n.name) LIKE '%cholesterol%'
          )
    LOOP
        v_fatty_amount := v_fatty_amount + COALESCE(rec.amount_per_100g,0) * v_weight_factor;
    END LOOP;

    -- Upsert fiber intake: we will distribute total fiber into the canonical Fiber rows by matching the primary Fiber entry 'TOTAL_FIBER' if exists
    PERFORM upsert_user_fiber_intake(v_user, v_date, v_fiber_amount);

    -- Upsert fatty intake into a generic fatty acid entry 'TOTAL_FAT' if exists
    PERFORM upsert_user_fatty_intake(v_user, v_date, v_fatty_amount);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- helpers to upsert into intake tables (aggregate per date/user/nutrient)
CREATE OR REPLACE FUNCTION upsert_user_fiber_intake(p_user INT, p_date DATE, p_amount NUMERIC) RETURNS VOID AS $$
DECLARE
    v_fiber_id INT;
BEGIN
    -- prefer a Fiber with code 'TOTAL_FIBER' else do nothing
    SELECT fiber_id INTO v_fiber_id FROM Fiber WHERE code = 'TOTAL_FIBER' LIMIT 1;
    IF v_fiber_id IS NULL THEN RETURN; END IF;

    INSERT INTO UserFiberIntake(user_id, date, fiber_id, amount)
    VALUES (p_user, p_date, v_fiber_id, COALESCE(p_amount,0))
    ON CONFLICT (user_id, date, fiber_id) DO UPDATE
    SET amount = COALESCE(UserFiberIntake.amount,0) + EXCLUDED.amount;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION upsert_user_fatty_intake(p_user INT, p_date DATE, p_amount NUMERIC) RETURNS VOID AS $$
DECLARE
    v_fa_id INT;
BEGIN
    -- prefer a FattyAcid with code 'TOTAL_FAT' else do nothing
    SELECT fatty_acid_id INTO v_fa_id FROM FattyAcid WHERE code = 'TOTAL_FAT' LIMIT 1;
    IF v_fa_id IS NULL THEN RETURN; END IF;

    INSERT INTO UserFattyAcidIntake(user_id, date, fatty_acid_id, amount)
    VALUES (p_user, p_date, v_fa_id, COALESCE(p_amount,0))
    ON CONFLICT (user_id, date, fatty_acid_id) DO UPDATE
    SET amount = COALESCE(UserFattyAcidIntake.amount,0) + EXCLUDED.amount;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to MealItem AFTER insert/update/delete to update intake aggregates
DROP TRIGGER IF EXISTS trg_compute_fiber_fattyintake ON MealItem;
CREATE TRIGGER trg_compute_fiber_fattyintake
AFTER INSERT OR UPDATE OR DELETE ON MealItem
FOR EACH ROW EXECUTE FUNCTION compute_and_upsert_fiber_fattyintake();

-- ============================================================
-- IX. Seed a few canonical entries (total fiber and total fat) with provided colors
-- ============================================================
INSERT INTO Fiber(code,name,description,unit,hex_color,home_display)
SELECT * FROM (VALUES
    ('TOTAL_FIBER','Total Dietary Fiber','Sum of soluble and insoluble fiber','g','#4CAF50',TRUE),
    ('SOLUBLE_FIBER','Soluble Fiber','Viscous fiber; aids cholesterol and glycemic control','g','#42A5F5',TRUE),
    ('INSOLUBLE_FIBER','Insoluble Fiber','Adds bulk and supports bowel regularity','g','#8D6E63',FALSE),
    ('RESISTANT_STARCH','Resistant Starch','Starch resistant to digestion; functions as prebiotic','g','#FBC02D',FALSE),
    ('BETA_GLUCAN','Beta-Glucan','Soluble fiber found in oats and barley','g','#FFA726',FALSE)
) AS f(code,name,description,unit,hex_color,home_display)
WHERE NOT EXISTS (SELECT 1 FROM Fiber WHERE code = f.code);

INSERT INTO FattyAcid(code,name,description,unit,hex_color,home_display)
SELECT * FROM (VALUES
    ('TOTAL_FAT','Total Fat','Total fat (includes SFA/MUFA/PUFA)','g','#F5B041',TRUE),
    ('SFA','Saturated Fat (SFA)','Saturated fatty acids','g','#E74C3C',FALSE),
    ('MUFA','Monounsaturated Fat (MUFA)','Monounsaturated fatty acids','g','#27AE60',FALSE),
    ('PUFA','Polyunsaturated Fat (PUFA)','Polyunsaturated fatty acids','g','#1ABC9C',FALSE),
    ('ALA','Omega-3 (ALA)','Alpha-linolenic acid (plant omega-3)','g','#3498DB',FALSE),
    ('EPA','EPA','Eicosapentaenoic acid','mg','#3498DB',FALSE),
    ('DHA','DHA','Docosahexaenoic acid','mg','#3498DB',FALSE),
    ('EPA_DHA','EPA + DHA','Combined long-chain omega-3 fatty acids','mg','#3498DB',FALSE),
    ('LA','Omega-6 (LA)','Linoleic acid (omega-6)','g','#F39C12',FALSE),
    ('TRANS_FAT','Trans Fat (total)','Trans fatty acids','g','#7F8C8D',FALSE),
    ('CHOLESTEROL','Cholesterol','Dietary cholesterol','mg','#C0392B',FALSE)
) AS fa(code,name,description,unit,hex_color,home_display)
WHERE NOT EXISTS (SELECT 1 FROM FattyAcid WHERE code = fa.code);

-- ============================================================
-- Seed FiberRequirement rows (WHO/FAO guidance basics)
-- ============================================================
INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT f.fiber_id, NULL, NULL, NULL, 25, 'g', FALSE, FALSE, NULL, 'WHO/FAO recommended total dietary fiber (general adult guidance ~25 g/day)'
FROM Fiber f
WHERE f.code = 'TOTAL_FIBER'
    AND NOT EXISTS (SELECT 1 FROM FiberRequirement fr WHERE fr.fiber_id = f.fiber_id);

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT f.fiber_id, NULL, NULL, NULL, 7, 'g', FALSE, FALSE, NULL, 'Soluble fiber guidance (approximate)'
FROM Fiber f
WHERE f.code = 'SOLUBLE_FIBER'
    AND NOT EXISTS (SELECT 1 FROM FiberRequirement fr WHERE fr.fiber_id = f.fiber_id);

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT f.fiber_id, NULL, NULL, NULL, 15, 'g', FALSE, FALSE, NULL, 'Insoluble fiber guidance (approximate)'
FROM Fiber f
WHERE f.code = 'INSOLUBLE_FIBER'
    AND NOT EXISTS (SELECT 1 FROM FiberRequirement fr WHERE fr.fiber_id = f.fiber_id);

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT f.fiber_id, NULL, NULL, NULL, 10, 'g', FALSE, FALSE, NULL, 'Resistant starch guidance (approximate)'
FROM Fiber f
WHERE f.code = 'RESISTANT_STARCH'
    AND NOT EXISTS (SELECT 1 FROM FiberRequirement fr WHERE fr.fiber_id = f.fiber_id);

INSERT INTO FiberRequirement(fiber_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT f.fiber_id, NULL, NULL, NULL, 3, 'g', FALSE, FALSE, NULL, 'Beta-glucan guidance (oats/barley soluble fiber)'
FROM Fiber f
WHERE f.code = 'BETA_GLUCAN'
    AND NOT EXISTS (SELECT 1 FROM FiberRequirement fr WHERE fr.fiber_id = f.fiber_id);

-- ============================================================
-- Fatty acid default requirement rows (energy-% based where applicable)
-- ============================================================
INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT fa.fatty_acid_id, NULL, NULL, NULL, NULL, 'g', FALSE, TRUE, 30, 'Total fat: default 30% of energy (range 25-35%)'
FROM FattyAcid fa WHERE fa.code = 'TOTAL_FAT' AND NOT EXISTS (SELECT 1 FROM FattyAcidRequirement fr WHERE fr.fatty_acid_id = fa.fatty_acid_id);

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT fa.fatty_acid_id, NULL, NULL, NULL, NULL, 'g', FALSE, TRUE, 10, 'Saturated fat: limit to <10% energy'
FROM FattyAcid fa WHERE fa.code = 'SFA' AND NOT EXISTS (SELECT 1 FROM FattyAcidRequirement fr WHERE fr.fatty_acid_id = fa.fatty_acid_id);

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT fa.fatty_acid_id, NULL, NULL, NULL, NULL, 'g', FALSE, TRUE, 12.5, 'MUFA: recommended ~10-15% energy (use 12.5%)'
FROM FattyAcid fa WHERE fa.code = 'MUFA' AND NOT EXISTS (SELECT 1 FROM FattyAcidRequirement fr WHERE fr.fatty_acid_id = fa.fatty_acid_id);

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT fa.fatty_acid_id, NULL, NULL, NULL, NULL, 'g', FALSE, TRUE, 7.5, 'PUFA: recommended ~5-10% energy (use 7.5%)'
FROM FattyAcid fa WHERE fa.code = 'PUFA' AND NOT EXISTS (SELECT 1 FROM FattyAcidRequirement fr WHERE fr.fatty_acid_id = fa.fatty_acid_id);

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT fa.fatty_acid_id, NULL, NULL, NULL, 250, 'mg', FALSE, FALSE, NULL, 'EPA+DHA baseline: 250 mg/day (adjusted by gender)'
FROM FattyAcid fa WHERE fa.code = 'EPA_DHA' AND NOT EXISTS (SELECT 1 FROM FattyAcidRequirement fr WHERE fr.fatty_acid_id = fa.fatty_acid_id);

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT fa.fatty_acid_id, NULL, NULL, NULL, NULL, 'g', FALSE, TRUE, 5, 'Omega-6 (LA): recommended ~4-6% energy (use 5%)'
FROM FattyAcid fa WHERE fa.code = 'LA' AND NOT EXISTS (SELECT 1 FROM FattyAcidRequirement fr WHERE fr.fatty_acid_id = fa.fatty_acid_id);

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT fa.fatty_acid_id, NULL, NULL, NULL, NULL, 'g', FALSE, TRUE, 1, 'Trans fat: target ≤1% energy'
FROM FattyAcid fa WHERE fa.code = 'TRANS_FAT' AND NOT EXISTS (SELECT 1 FROM FattyAcidRequirement fr WHERE fr.fatty_acid_id = fa.fatty_acid_id);

INSERT INTO FattyAcidRequirement(fatty_acid_id, sex, age_min, age_max, base_value, unit, is_per_kg, is_energy_pct, energy_pct, notes)
SELECT fa.fatty_acid_id, NULL, NULL, NULL, 300, 'mg', FALSE, FALSE, NULL, 'Cholesterol: default 300 mg/day, reduced for older adults'
FROM FattyAcid fa WHERE fa.code = 'CHOLESTEROL' AND NOT EXISTS (SELECT 1 FROM FattyAcidRequirement fr WHERE fr.fatty_acid_id = fa.fatty_acid_id);

-- ============================================================
-- Done.
-- NOTE: The MealItem intake trigger uses heuristics to find FoodNutrient rows. Depending on the
-- FoodNutrient/Nutrient dataset you may want to add more robust nutrient_code mappings and
-- possibly replace the simple total aggregation with per-nutrient detailed mapping.
-- Also consider running refresh_user_fiber_requirements(user_id) and refresh_user_fatty_requirements(user_id)
-- after seeding or bulk-importing requirement rows so User cached tables are populated.
-- ============================================================
