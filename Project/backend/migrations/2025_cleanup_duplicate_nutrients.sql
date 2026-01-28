-- Consolidate duplicate Nutrient rows by name (case-insensitive)
-- Keep the lowest nutrient_id per lower(name) and remap references
DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT LOWER(name) AS lname,
           MIN(nutrient_id) AS keep_id,
           ARRAY_AGG(nutrient_id ORDER BY nutrient_id) AS all_ids
    FROM Nutrient
    GROUP BY LOWER(name)
    HAVING COUNT(*) > 1
  LOOP
    -- Repoint references to the kept nutrient_id
    UPDATE FoodNutrient SET nutrient_id = r.keep_id
      WHERE nutrient_id = ANY(r.all_ids) AND nutrient_id <> r.keep_id;

    -- Tables may not exist in older schemas; wrap in exception blocks
    BEGIN
      UPDATE NutrientContraindication SET nutrient_id = r.keep_id
        WHERE nutrient_id = ANY(r.all_ids) AND nutrient_id <> r.keep_id;
    EXCEPTION WHEN undefined_table THEN
      -- ignore
    END;

    BEGIN
      UPDATE ConditionNutrientEffect SET nutrient_id = r.keep_id
        WHERE nutrient_id = ANY(r.all_ids) AND nutrient_id <> r.keep_id;
    EXCEPTION WHEN undefined_table THEN
      -- ignore
    END;

    BEGIN
      UPDATE NutrientMapping SET nutrient_id = r.keep_id
        WHERE nutrient_id = ANY(r.all_ids) AND nutrient_id <> r.keep_id;
    EXCEPTION WHEN undefined_table THEN
      -- ignore
    END;

    -- Delete duplicates (except the keeper)
    DELETE FROM Nutrient WHERE nutrient_id = ANY(r.all_ids) AND nutrient_id <> r.keep_id;
  END LOOP;
END $$;