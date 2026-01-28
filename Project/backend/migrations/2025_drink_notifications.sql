BEGIN;

CREATE TABLE IF NOT EXISTS drinknotification (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES userprofile(user_id) ON DELETE CASCADE,
    drink_id INTEGER REFERENCES drink(drink_id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_drinknotification_user ON drinknotification(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_drinknotification_created ON drinknotification(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_drinknotification_drink ON drinknotification(drink_id);

CREATE OR REPLACE FUNCTION notify_drink_created()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_by_user IS NOT NULL THEN
        INSERT INTO drinknotification (
            user_id,
            drink_id,
            notification_type,
            title,
            message
        ) VALUES (
            NEW.created_by_user,
            NEW.drink_id,
            'drink_created',
            'Đồ uống đã được tạo thành công',
            FORMAT('Đồ uống "%s" của bạn đã được tạo thành công! Đồ uống đang chờ phê duyệt từ quản trị viên.', COALESCE(NEW.vietnamese_name, NEW.name))
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_drink_approved()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_public = TRUE AND OLD.is_public = FALSE AND NEW.created_by_user IS NOT NULL THEN
        INSERT INTO drinknotification (
            user_id,
            drink_id,
            notification_type,
            title,
            message
        ) VALUES (
            NEW.created_by_user,
            NEW.drink_id,
            'drink_approved',
            'Đồ uống đã được phê duyệt!',
            FORMAT('Chúc mừng! Đồ uống "%s" của bạn đã được phê duyệt và hiện đã công khai cho mọi người sử dụng.', COALESCE(NEW.vietnamese_name, NEW.name))
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_drink_created ON drink;
CREATE TRIGGER trg_notify_drink_created
    AFTER INSERT ON drink
    FOR EACH ROW
    WHEN (NEW.created_by_user IS NOT NULL AND NEW.is_template = FALSE)
    EXECUTE FUNCTION notify_drink_created();

DROP TRIGGER IF EXISTS trg_notify_drink_approved ON drink;
CREATE TRIGGER trg_notify_drink_approved
    AFTER UPDATE ON drink
    FOR EACH ROW
    WHEN (NEW.created_by_user IS NOT NULL)
    EXECUTE FUNCTION notify_drink_approved();

COMMIT;
