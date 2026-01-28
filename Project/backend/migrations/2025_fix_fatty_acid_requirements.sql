-- Migration: Fix FattyAcidRequirement for ALA, EPA, DHA
-- These fatty acids need recommended values based on WHO guidelines

BEGIN;

-- Add/Update FattyAcidRequirement for ALA (Alpha-Linolenic Acid)
-- WHO recommends 0.5-2% of energy from ALA (~1.1-1.6g/day for adults)
INSERT INTO FattyAcidRequirement (fatty_acid_id, sex, age_min, age_max, amount, unit, energy_percentage, notes)
SELECT fa.fatty_acid_id, NULL, 19, 120, 1.6, 'g', 0.5, 'WHO: 0.5-2% energy from ALA'
FROM FattyAcid fa
WHERE fa.code = 'ALA'
ON CONFLICT DO NOTHING;

-- Add/Update FattyAcidRequirement for EPA
-- WHO recommends 250mg EPA+DHA combined, so ~125mg each
INSERT INTO FattyAcidRequirement (fatty_acid_id, sex, age_min, age_max, amount, unit, notes)
SELECT fa.fatty_acid_id, NULL, 19, 120, 0.125, 'g', 'WHO: Part of 250mg EPA+DHA combined'
FROM FattyAcid fa
WHERE fa.code = 'EPA'
ON CONFLICT DO NOTHING;

-- Add/Update FattyAcidRequirement for DHA
-- WHO recommends 250mg EPA+DHA combined, so ~125mg each
INSERT INTO FattyAcidRequirement (fatty_acid_id, sex, age_min, age_max, amount, unit, notes)
SELECT fa.fatty_acid_id, NULL, 19, 120, 0.125, 'g', 'WHO: Part of 250mg EPA+DHA combined'
FROM FattyAcid fa
WHERE fa.code = 'DHA'
ON CONFLICT DO NOTHING;

-- Refresh UserFattyAcidRequirement for all users
-- This will recalculate based on the new FattyAcidRequirement data
DO $$
DECLARE
    u RECORD;
    fa RECORD;
    v_recommended NUMERIC;
BEGIN
    FOR u IN SELECT user_id FROM "User" LOOP
        FOR fa IN SELECT fatty_acid_id, code FROM FattyAcid WHERE code IN ('ALA', 'EPA', 'DHA') LOOP
            -- Get requirement from FattyAcidRequirement
            SELECT amount INTO v_recommended
            FROM FattyAcidRequirement
            WHERE fatty_acid_id = fa.fatty_acid_id
            LIMIT 1;
            
            IF v_recommended IS NOT NULL THEN
                UPDATE UserFattyAcidRequirement 
                SET recommended = v_recommended
                WHERE user_id = u.user_id AND fatty_acid_id = fa.fatty_acid_id;
                
                IF NOT FOUND THEN
                    INSERT INTO UserFattyAcidRequirement (user_id, fatty_acid_id, recommended)
                    VALUES (u.user_id, fa.fatty_acid_id, v_recommended);
                END IF;
            END IF;
        END LOOP;
    END LOOP;
END $$;

COMMIT;

-- Verify
SELECT ufar.user_id, fa.code, ufar.recommended 
FROM UserFattyAcidRequirement ufar 
JOIN FattyAcid fa ON fa.fatty_acid_id = ufar.fatty_acid_id 
WHERE ufar.user_id = 1
ORDER BY fa.code;

