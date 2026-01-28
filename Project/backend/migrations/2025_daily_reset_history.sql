-- Migration: Daily Reset History System
-- Creates history table to archive daily nutrient tracking data
-- Ensures data is preserved before daily reset at 00:00 UTC+7

BEGIN;

-- Create history table for DailySummary
CREATE TABLE IF NOT EXISTS DailySummaryHistory (
    history_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    total_calories NUMERIC(10,2) DEFAULT 0,
    total_protein NUMERIC(10,2) DEFAULT 0,
    total_fat NUMERIC(10,2) DEFAULT 0,
    total_carbs NUMERIC(10,2) DEFAULT 0,
    total_fiber NUMERIC(10,2) DEFAULT 0,
    total_water NUMERIC(10,2) DEFAULT 0,
    archived_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, date)
);

CREATE INDEX IF NOT EXISTS idx_daily_summary_history_user_date 
ON DailySummaryHistory(user_id, date DESC);

CREATE INDEX IF NOT EXISTS idx_daily_summary_history_archived 
ON DailySummaryHistory(archived_at DESC);

-- Comment
COMMENT ON TABLE DailySummaryHistory IS 'Archives daily nutrient tracking data at 00:00 UTC+7 (Vietnam time) before daily reset';
COMMENT ON COLUMN DailySummaryHistory.archived_at IS 'Timestamp when data was archived (in UTC)';

COMMIT;
