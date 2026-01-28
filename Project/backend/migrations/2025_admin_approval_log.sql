BEGIN;

CREATE TABLE IF NOT EXISTS admin_approval_log (
    log_id SERIAL PRIMARY KEY,
    admin_id INT REFERENCES admin(admin_id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    item_type VARCHAR(20) NOT NULL,
    item_id INT NOT NULL,
    item_name TEXT,
    created_by_user INT REFERENCES "User"(user_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_approval_log_created_at
ON admin_approval_log(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_admin_approval_log_admin
ON admin_approval_log(admin_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_admin_approval_log_item
ON admin_approval_log(item_type, item_id);

COMMIT;
