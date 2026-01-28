-- ============================================================
-- Add promotion columns to AI_Analyzed_Meals if not exist
-- ============================================================

BEGIN;

-- Add promotion columns if they don't exist
DO $$
BEGIN
    -- promoted
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_analyzed_meals' AND column_name = 'promoted'
    ) THEN
        ALTER TABLE AI_Analyzed_Meals ADD COLUMN promoted BOOLEAN DEFAULT FALSE;
    END IF;

    -- promoted_at
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_analyzed_meals' AND column_name = 'promoted_at'
    ) THEN
        ALTER TABLE AI_Analyzed_Meals ADD COLUMN promoted_at TIMESTAMPTZ;
    END IF;

    -- promoted_by_admin
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_analyzed_meals' AND column_name = 'promoted_by_admin'
    ) THEN
        ALTER TABLE AI_Analyzed_Meals ADD COLUMN promoted_by_admin INT;
    END IF;

    -- linked_dish_id
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_analyzed_meals' AND column_name = 'linked_dish_id'
    ) THEN
        ALTER TABLE AI_Analyzed_Meals ADD COLUMN linked_dish_id INT;
    END IF;

    -- linked_drink_id
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_analyzed_meals' AND column_name = 'linked_drink_id'
    ) THEN
        ALTER TABLE AI_Analyzed_Meals ADD COLUMN linked_drink_id INT;
    END IF;
END $$;

COMMIT;

