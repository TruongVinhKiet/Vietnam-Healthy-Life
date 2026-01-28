-- Migration: Add Essential Amino Acids
-- Adjusted to match project schema: uses "User" (user_id INT) and naming conventions similar to Vitamin/Mineral

BEGIN;

-- Core amino acid definitions
-- Amino acid table DDL moved to `schema.sql` (AminoAcid, AminoRequirement, UserAminoRequirement, UserAminoIntake).
-- This migration retains compute/refresh functions, triggers and seed inserts only.

-- Compute per-user amino requirement helper
-- Returns: base, multiplier, recommended, unit
CREATE OR REPLACE FUNCTION compute_user_amino_requirement(p_user_id INT, p_amino_id INT)
RETURNS TABLE(base NUMERIC, multiplier NUMERIC, recommended NUMERIC, unit TEXT) AS $$
DECLARE
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
    v_per_kg BOOLEAN;
BEGIN
    -- pick the most specific AminoRequirement row matching sex/age if present
    SELECT ar.amount, ar.unit, ar.per_kg INTO v_base, v_unit, v_per_kg
    FROM AminoRequirement ar
    WHERE ar.amino_acid_id = p_amino_id
      AND (ar.sex IS NULL OR lower(ar.sex) = lower( (SELECT COALESCE(u.gender,'') FROM "User" u WHERE u.user_id = p_user_id) ) OR lower(ar.sex) = 'both')
      AND ( (ar.age_min IS NULL AND ar.age_max IS NULL) OR (
            (SELECT COALESCE(u.age,0) FROM "User" u WHERE u.user_id = p_user_id) BETWEEN COALESCE(ar.age_min, -9999) AND COALESCE(ar.age_max, 99999)
          ) )
    ORDER BY (ar.age_min IS NOT NULL) DESC, (ar.age_max IS NOT NULL) DESC
    LIMIT 1;

    IF v_base IS NULL THEN
        RETURN; -- no recommendation available
    END IF;

    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;

    -- activity and goal heuristics (light): scale multiplier similar to vitamins/minerals
    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.2, 0.20 );
    END IF;
    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN v_mult := v_mult + 0.03; ELSIF lower(v_goal) = 'gain_weight' THEN v_mult := v_mult - 0.01; END IF;
    END IF;
    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN v_mult := v_mult + 0.02; END IF;

    -- compute final recommended number, handling per-kg
    IF v_per_kg = TRUE THEN
        IF v_weight IS NULL THEN
            RETURN; -- can't compute per-kg without weight
        END IF;
        RETURN QUERY SELECT v_base, v_mult, ROUND(v_base * v_weight * v_mult, 3), v_unit;
    ELSE
        RETURN QUERY SELECT v_base, v_mult, ROUND(v_base * v_mult, 3), v_unit;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Refresh function to upsert all amino requirements for a user
CREATE OR REPLACE FUNCTION refresh_user_amino_requirements(p_user_id INT) RETURNS VOID AS $$
DECLARE
    a RECORD;
    v_base NUMERIC;
    v_mult NUMERIC;
    v_rec NUMERIC;
    v_unit TEXT;
BEGIN
    IF p_user_id IS NULL THEN RETURN; END IF;
    FOR a IN SELECT amino_acid_id FROM AminoAcid LOOP
        SELECT base, multiplier, recommended, unit INTO v_base, v_mult, v_rec, v_unit FROM compute_user_amino_requirement(p_user_id, a.amino_acid_id);
        -- upsert if computed (v_rec may be NULL if cannot compute)
        IF v_rec IS NOT NULL THEN
            INSERT INTO UserAminoRequirement(user_id, amino_acid_id, base, multiplier, recommended, unit, updated_at)
            VALUES (p_user_id, a.amino_acid_id, v_base, v_mult, v_rec, v_unit, NOW())
            ON CONFLICT (user_id, amino_acid_id) DO UPDATE
            SET base = EXCLUDED.base, multiplier = EXCLUDED.multiplier, recommended = EXCLUDED.recommended, unit = EXCLUDED.unit, updated_at = EXCLUDED.updated_at;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Trigger wrappers
CREATE OR REPLACE FUNCTION trg_refresh_user_amino_from_userprofile() RETURNS trigger AS $$
BEGIN
    PERFORM refresh_user_amino_requirements(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_refresh_user_amino_from_user() RETURNS trigger AS $$
BEGIN
    PERFORM refresh_user_amino_requirements(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach triggers: when UserProfile or User changes relevant fields, refresh cached requirements
DROP TRIGGER IF EXISTS trg_userprofile_amino_refresh ON UserProfile;
CREATE TRIGGER trg_userprofile_amino_refresh
AFTER INSERT OR UPDATE OF activity_factor, tdee, goal_type ON UserProfile
FOR EACH ROW EXECUTE FUNCTION trg_refresh_user_amino_from_userprofile();

DROP TRIGGER IF EXISTS trg_user_amino_refresh ON "User";
CREATE TRIGGER trg_user_amino_refresh
AFTER UPDATE OF weight_kg, gender, age ON "User"
FOR EACH ROW WHEN (OLD.weight_kg IS DISTINCT FROM NEW.weight_kg OR OLD.gender IS DISTINCT FROM NEW.gender OR OLD.age IS DISTINCT FROM NEW.age)
EXECUTE FUNCTION trg_refresh_user_amino_from_user();

-- Seed core amino acids and mark homepage ones
INSERT INTO AminoAcid(code, name, hex_color, home_display)
SELECT * FROM (VALUES
  ('HIS','Histidine','#B58ED9', FALSE),
  ('ILE','Isoleucine','#A8E6A3', TRUE),
  ('LEU','Leucine','#E76F51', TRUE),
  ('LYS','Lysine','#4CC9F0', TRUE),
  ('MET','Methionine','#F6D55C', TRUE),
  ('PHE','Phenylalanine','#F4A7B9', FALSE),
  ('THR','Threonine','#76D7C4', FALSE),
  ('TRP','Tryptophan','#6A5ACD', TRUE),
  ('VAL','Valine','#FFB570', TRUE)
) AS a(code,name,hex_color,home_display)
WHERE NOT EXISTS (SELECT 1 FROM AminoAcid aa WHERE aa.code = a.code);

COMMIT;

-- End of migration