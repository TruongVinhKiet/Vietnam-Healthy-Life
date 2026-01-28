-- Ensure expires_at has a sensible default (00:00 Vietnam next day)
-- Date: 2025-12-19
BEGIN;

-- Set default to midnight (00:00) of the next Vietnam date (UTC+7)
ALTER TABLE public.user_pinned_suggestions
  ALTER COLUMN expires_at SET DEFAULT ((get_vietnam_date() + 1)::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh');

-- Backfill existing NULL expires_at rows
UPDATE public.user_pinned_suggestions
SET expires_at = ((get_vietnam_date() + 1)::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh')
WHERE expires_at IS NULL;

COMMIT;
