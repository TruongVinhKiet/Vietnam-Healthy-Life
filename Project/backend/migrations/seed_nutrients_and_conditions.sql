-- Clean, single DO block version
-- This script inserts records into `nutrient` from the various source tables, but
-- it does NOT attempt to insert into source tables (to avoid NOT NULL/constraint issues).

DO $$
DECLARE
  v_table_exists boolean;
BEGIN
  SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'nutrient') INTO v_table_exists;
  IF NOT v_table_exists THEN
    RAISE NOTICE 'Target table "nutrient" not found; aborting.';
    RETURN;
  END IF;

  -- For each source type, check existence and run an INSERT ... SELECT guarded by NOT EXISTS

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vitamin') THEN
    PERFORM 1; -- no-op to keep consistent style
    EXECUTE $sql$
      INSERT INTO nutrient (name, nutrient_code, unit, created_at, created_by_admin)
      SELECT v.name, COALESCE(NULLIF(v.code, ''), 'VIT_' || v.vitamin_id::text), COALESCE(NULLIF(TRIM(v.unit), ''), 'µg'), now(), NULL
      FROM vitamin v
      WHERE NOT EXISTS (SELECT 1 FROM nutrient n WHERE n.nutrient_code = COALESCE(NULLIF(v.code, ''), 'VIT_' || v.vitamin_id::text))
      ON CONFLICT DO NOTHING;
    $sql$;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'mineral') THEN
    EXECUTE $sql$
      INSERT INTO nutrient (name, nutrient_code, unit, created_at, created_by_admin)
      SELECT m.name, COALESCE(NULLIF(m.code, ''), 'MIN_' || m.mineral_id::text), COALESCE(NULLIF(TRIM(m.unit), ''), 'mg'), now(), NULL
      FROM mineral m
      WHERE NOT EXISTS (SELECT 1 FROM nutrient n WHERE n.nutrient_code = COALESCE(NULLIF(m.code, ''), 'MIN_' || m.mineral_id::text))
      ON CONFLICT DO NOTHING;
    $sql$;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'aminoacid') THEN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'aminoacid' AND column_name = 'aminoacid_id') THEN
      EXECUTE $sql$
        INSERT INTO nutrient (name, nutrient_code, unit, created_at, created_by_admin)
        SELECT a.name, COALESCE(NULLIF(a.code, ''), 'AA_' || a.aminoacid_id::text), 'g', now(), NULL
        FROM aminoacid a
        WHERE NOT EXISTS (SELECT 1 FROM nutrient n WHERE n.nutrient_code = COALESCE(NULLIF(a.code, ''), 'AA_' || a.aminoacid_id::text))
        ON CONFLICT DO NOTHING;
      $sql$;
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'aminoacid' AND column_name = 'amino_acid_id') THEN
      EXECUTE $sql$
        INSERT INTO nutrient (name, nutrient_code, unit, created_at, created_by_admin)
        SELECT a.name, COALESCE(NULLIF(a.code, ''), 'AA_' || a.amino_acid_id::text), 'g', now(), NULL
        FROM aminoacid a
        WHERE NOT EXISTS (SELECT 1 FROM nutrient n WHERE n.nutrient_code = COALESCE(NULLIF(a.code, ''), 'AA_' || a.amino_acid_id::text))
        ON CONFLICT DO NOTHING;
      $sql$;
    END IF;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fiber') THEN
    EXECUTE $sql$
      INSERT INTO nutrient (name, nutrient_code, unit, created_at, created_by_admin)
      SELECT f.name, COALESCE(NULLIF(f.code, ''), 'FIB_' || f.fiber_id::text), COALESCE(NULLIF(TRIM(f.unit), ''), 'g'), now(), NULL
      FROM fiber f
      WHERE NOT EXISTS (SELECT 1 FROM nutrient n WHERE n.nutrient_code = COALESCE(NULLIF(f.code, ''), 'FIB_' || f.fiber_id::text))
      ON CONFLICT DO NOTHING;
    $sql$;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fattyacid') THEN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fattyacid' AND column_name = 'fattyacid_id') THEN
      EXECUTE $sql$
        INSERT INTO nutrient (name, nutrient_code, unit, created_at, created_by_admin)
        SELECT fa.name, COALESCE(NULLIF(fa.code, ''), 'FA_' || fa.fattyacid_id::text), COALESCE(NULLIF(TRIM(fa.unit), ''), 'mg'), now(), NULL
        FROM fattyacid fa
        WHERE NOT EXISTS (SELECT 1 FROM nutrient n WHERE n.nutrient_code = COALESCE(NULLIF(fa.code, ''), 'FA_' || fa.fattyacid_id::text))
        ON CONFLICT DO NOTHING;
      $sql$;
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fattyacid' AND column_name = 'fatty_acid_id') THEN
      EXECUTE $sql$
        INSERT INTO nutrient (name, nutrient_code, unit, created_at, created_by_admin)
        SELECT fa.name, COALESCE(NULLIF(fa.code, ''), 'FA_' || fa.fatty_acid_id::text), COALESCE(NULLIF(TRIM(fa.unit), ''), 'mg'), now(), NULL
        FROM fattyacid fa
        WHERE NOT EXISTS (SELECT 1 FROM nutrient n WHERE n.nutrient_code = COALESCE(NULLIF(fa.code, ''), 'FA_' || fa.fatty_acid_id::text))
        ON CONFLICT DO NOTHING;
      $sql$;
    END IF;
  END IF;

  RAISE NOTICE 'Nutrient table population complete.';
END
$$;

-- Optionally populate RDA tables if they exist (vitaminrda/mineralrda)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vitaminrda') AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vitamin') THEN
    EXECUTE $sql$
      INSERT INTO vitaminrda (vitamin_id, sex, age_min, age_max, rda_value, unit)
      SELECT v.vitamin_id, 'any', 19, 50, v.recommended_daily, v.unit
      FROM vitamin v
      ON CONFLICT DO NOTHING;
    $sql$;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'mineralrda') AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'mineral') THEN
    EXECUTE $sql$
      INSERT INTO mineralrda (mineral_id, sex, age_min, age_max, rda_value, unit)
      SELECT m.mineral_id, 'any', 19, 50, m.recommended_daily, m.unit
      FROM mineral m
      ON CONFLICT DO NOTHING;
    $sql$;
  END IF;
END
$$;

