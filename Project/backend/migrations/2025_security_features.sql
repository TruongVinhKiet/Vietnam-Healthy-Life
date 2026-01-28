-- Security features: 2FA, password reset code, login lock threshold

-- UserSecurity table stores per-user security settings
CREATE TABLE IF NOT EXISTS UserSecurity (
  user_id INT PRIMARY KEY REFERENCES "User"(user_id) ON DELETE CASCADE,
  twofa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  twofa_secret TEXT,
  lock_threshold INT NOT NULL DEFAULT 5,
  failed_attempts INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Table for password change codes
CREATE TABLE IF NOT EXISTS PasswordChangeCode (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
  code VARCHAR(12) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  used_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_pwcode_user ON PasswordChangeCode(user_id);
CREATE INDEX IF NOT EXISTS idx_pwcode_code ON PasswordChangeCode(code);
