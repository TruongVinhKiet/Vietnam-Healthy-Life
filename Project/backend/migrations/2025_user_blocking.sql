-- Migration: User blocking & unblock request support
-- Adds: last_login column, user_account_status, user_block_event, user_unblock_request tables

-- 1. Add last_login column to User (if not exists)
ALTER TABLE "User"
    ADD COLUMN IF NOT EXISTS last_login TIMESTAMPTZ;

-- 2. Table: user_account_status (current block state)
CREATE TABLE IF NOT EXISTS user_account_status (
    user_id INT PRIMARY KEY REFERENCES "User"(user_id) ON DELETE CASCADE,
    is_blocked BOOLEAN NOT NULL DEFAULT FALSE,
    blocked_reason TEXT,
    blocked_at TIMESTAMPTZ,
    blocked_by_admin INT REFERENCES Admin(admin_id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Table: user_block_event (history of block/unblock actions)
CREATE TABLE IF NOT EXISTS user_block_event (
    block_event_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    event_type VARCHAR(20) NOT NULL CHECK (event_type IN ('block','unblock')),
    reason TEXT,
    admin_id INT REFERENCES Admin(admin_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_user_block_event_user ON user_block_event(user_id);

-- 4. Table: user_unblock_request (user appeal to be unblocked)
CREATE TABLE IF NOT EXISTS user_unblock_request (
    request_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected','cancelled')),
    message TEXT, -- user provided reason / appeal
    admin_response TEXT, -- admin notes on decision
    decided_at TIMESTAMPTZ,
    decided_by_admin INT REFERENCES Admin(admin_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_unblock_request_user ON user_unblock_request(user_id);
CREATE INDEX IF NOT EXISTS idx_unblock_request_status ON user_unblock_request(status);

-- Helper view: simplified user moderation status (optional)
CREATE OR REPLACE VIEW vw_user_moderation AS
SELECT u.user_id,
       u.full_name,
       u.email,
       uas.is_blocked,
       uas.blocked_reason,
       uas.blocked_at,
       u.last_login,
       (SELECT status FROM user_unblock_request r WHERE r.user_id = u.user_id ORDER BY r.created_at DESC LIMIT 1) AS latest_request_status
FROM "User" u
LEFT JOIN user_account_status uas ON u.user_id = uas.user_id;

-- Seed account status rows for existing users (not blocked by default)
INSERT INTO user_account_status(user_id)
SELECT u.user_id FROM "User" u
LEFT JOIN user_account_status s ON s.user_id = u.user_id
WHERE s.user_id IS NULL;
