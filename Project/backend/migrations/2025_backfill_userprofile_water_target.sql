-- 2025_backfill_userprofile_water_target.sql
-- Backfill UserProfile.daily_water_target using existing User and UserProfile data

UPDATE UserProfile up
SET daily_water_target = sub.calculated_ml
FROM (
    SELECT up2.user_id,
        ROUND( (COALESCE(up2.tdee,0) * 1.0) + (COALESCE(u.weight_kg,0) * 5 * (COALESCE(up2.activity_factor,1.2) - 1.2)), 2) AS calculated_ml
    FROM UserProfile up2
    JOIN "User" u ON u.user_id = up2.user_id
    WHERE up2.tdee IS NOT NULL AND u.weight_kg IS NOT NULL AND up2.activity_factor IS NOT NULL
) sub
WHERE up.user_id = sub.user_id
  AND (up.daily_water_target IS NULL OR up.daily_water_target = 0);
