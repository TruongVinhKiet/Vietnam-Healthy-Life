-- Refresh all nutrient requirements for user 9 (hello@gmail.com)
BEGIN;

-- Refresh vitamin requirements
SELECT refresh_user_vitamin_requirements(9);

-- Refresh mineral requirements  
SELECT refresh_user_mineral_requirements(9);

-- Refresh amino acid requirements
SELECT refresh_user_amino_requirements(9);

-- Refresh fiber requirements
SELECT refresh_user_fiber_requirements(9);

-- Refresh fatty acid requirements
SELECT refresh_user_fatty_requirements(9);

COMMIT;

-- Verify requirements were created
SELECT 'Vitamin Requirements:' as info, COUNT(*) as count FROM UserVitaminRequirement WHERE user_id = 9
UNION ALL
SELECT 'Mineral Requirements:', COUNT(*) FROM UserMineralRequirement WHERE user_id = 9
UNION ALL
SELECT 'Amino Acid Requirements:', COUNT(*) FROM UserAminoRequirement WHERE user_id = 9
UNION ALL
SELECT 'Fiber Requirements:', COUNT(*) FROM UserFiberRequirement WHERE user_id = 9
UNION ALL
SELECT 'Fatty Acid Requirements:', COUNT(*) FROM UserFattyAcidRequirement WHERE user_id = 9;
