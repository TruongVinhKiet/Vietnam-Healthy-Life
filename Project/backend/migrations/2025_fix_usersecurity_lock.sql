-- Ensure UserSecurity has all columns needed for lock/unlock/last_failed_at
ALTER TABLE IF EXISTS UserSecurity
  ADD COLUMN IF NOT EXISTS lock_threshold INT NOT NULL DEFAULT 5,
  ADD COLUMN IF NOT EXISTS failed_attempts INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_failed_at TIMESTAMPTZ;

-- Create AccountUnlockCode table for unlock flow
CREATE TABLE IF NOT EXISTS AccountUnlockCode (
  code_id SERIAL PRIMARY KEY,
  user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
  code VARCHAR(10) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Optional indexes
CREATE INDEX IF NOT EXISTS idx_unlock_user ON AccountUnlockCode(user_id);
CREATE INDEX IF NOT EXISTS idx_unlock_code ON AccountUnlockCode(code);

