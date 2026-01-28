-- Migration: Chuẩn hóa hệ thống log hoạt động user cho analytic
-- Tạo bảng UserActivityLog chuẩn hóa

BEGIN;

CREATE TABLE IF NOT EXISTS UserActivityLog (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    action TEXT NOT NULL,
    object_type TEXT,
    object_id INT,
    detail JSONB,
    log_time TIMESTAMP DEFAULT NOW()
);

-- Hàm log_user_activity chuẩn hóa
CREATE OR REPLACE FUNCTION log_user_activity(
    p_user_id INT,
    p_action TEXT,
    p_object_type TEXT DEFAULT NULL,
    p_object_id INT DEFAULT NULL,
    p_detail JSONB DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    IF p_user_id IS NULL OR p_action IS NULL THEN RETURN; END IF;
    INSERT INTO UserActivityLog (user_id, action, object_type, object_id, detail, log_time)
    VALUES (p_user_id, p_action, p_object_type, p_object_id, p_detail, NOW());
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

COMMIT;
