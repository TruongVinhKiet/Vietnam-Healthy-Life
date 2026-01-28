-- Add missing columns for pinned suggestions
-- Date: 2025-12-19
BEGIN;

-- Only add columns if they do not already exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'user_pinned_suggestions' AND column_name = 'is_pinned'
  ) THEN
    ALTER TABLE public.user_pinned_suggestions
      ADD COLUMN is_pinned boolean DEFAULT true NOT NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'user_pinned_suggestions' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE public.user_pinned_suggestions
      ADD COLUMN updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'user_pinned_suggestions' AND column_name = 'suggestion_date'
  ) THEN
    ALTER TABLE public.user_pinned_suggestions
      ADD COLUMN suggestion_date date DEFAULT get_vietnam_date() NOT NULL;
  END IF;
END$$;

-- Backfill existing rows: set suggestion_date from pinned_at (if available) and updated_at
UPDATE public.user_pinned_suggestions
SET suggestion_date = COALESCE(suggestion_date, (pinned_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date),
    updated_at = COALESCE(updated_at, pinned_at)
WHERE suggestion_date IS NULL OR updated_at IS NULL;

COMMIT;
