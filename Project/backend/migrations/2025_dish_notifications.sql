-- ============================================================
-- DISH NOTIFICATIONS SYSTEM
-- Tạo bảng thông báo cho món ăn (dish notifications)
-- Date: 2025-11-15
-- ============================================================

BEGIN;

-- Create DishNotification table
CREATE TABLE IF NOT EXISTS dishnotification (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES userprofile(user_id) ON DELETE CASCADE,
    dish_id INTEGER REFERENCES dish(dish_id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL, -- 'dish_created', 'dish_approved', 'dish_rejected', 'dish_popular'
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_dishnotification_user ON dishnotification(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_dishnotification_created ON dishnotification(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_dishnotification_dish ON dishnotification(dish_id);

-- Function to create notification when dish is created
CREATE OR REPLACE FUNCTION notify_dish_created()
RETURNS TRIGGER AS $$
BEGIN
    -- Notify the creator
    IF NEW.created_by_user IS NOT NULL THEN
        INSERT INTO dishnotification (
            user_id,
            dish_id,
            notification_type,
            title,
            message
        ) VALUES (
            NEW.created_by_user,
            NEW.dish_id,
            'dish_created',
            'Món ăn đã được tạo thành công',
            FORMAT('Món "%s" của bạn đã được tạo thành công! Món ăn đang chờ phê duyệt từ quản trị viên.', COALESCE(NEW.vietnamese_name, NEW.name))
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to notify when dish is approved (made public)
CREATE OR REPLACE FUNCTION notify_dish_approved()
RETURNS TRIGGER AS $$
BEGIN
    -- When dish becomes public (approved)
    IF NEW.is_public = TRUE AND OLD.is_public = FALSE AND NEW.created_by_user IS NOT NULL THEN
        INSERT INTO dishnotification (
            user_id,
            dish_id,
            notification_type,
            title,
            message
        ) VALUES (
            NEW.created_by_user,
            NEW.dish_id,
            'dish_approved',
            'Món ăn đã được phê duyệt! 🎉',
            FORMAT('Chúc mừng! Món "%s" của bạn đã được phê duyệt và hiện đã công khai cho mọi người sử dụng.', COALESCE(NEW.vietnamese_name, NEW.name))
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to notify when dish becomes popular
CREATE OR REPLACE FUNCTION notify_dish_popular()
RETURNS TRIGGER AS $$
DECLARE
    v_dish_name VARCHAR(200);
    v_user_id INTEGER;
BEGIN
    -- When dish reaches 10 times logged
    IF NEW.total_times_logged >= 10 AND OLD.total_times_logged < 10 THEN
        SELECT COALESCE(vietnamese_name, name), created_by_user INTO v_dish_name, v_user_id
        FROM dish WHERE dish_id = NEW.dish_id;
        
        IF v_user_id IS NOT NULL THEN
            INSERT INTO dishnotification (
                user_id,
                dish_id,
                notification_type,
                title,
                message
            ) VALUES (
                v_user_id,
                NEW.dish_id,
                'dish_popular',
                'Món ăn của bạn đang được yêu thích! ⭐',
                FORMAT('Món "%s" của bạn đã được ghi nhận %s lần! Cảm ơn bạn đã chia sẻ công thức tuyệt vời.', 
                       v_dish_name, NEW.total_times_logged)
            );
        END IF;
    END IF;
    
    -- Milestone notifications: 50, 100, 500 times
    IF NEW.total_times_logged >= 50 AND OLD.total_times_logged < 50 THEN
        SELECT COALESCE(vietnamese_name, name), created_by_user INTO v_dish_name, v_user_id
        FROM dish WHERE dish_id = NEW.dish_id;
        
        IF v_user_id IS NOT NULL THEN
            INSERT INTO dishnotification (
                user_id,
                dish_id,
                notification_type,
                title,
                message
            ) VALUES (
                v_user_id,
                NEW.dish_id,
                'dish_popular',
                'Món ăn siêu phổ biến! 🌟',
                FORMAT('Wow! Món "%s" đã đạt %s lần ghi nhận. Bạn thật tuyệt vời!', 
                       v_dish_name, NEW.total_times_logged)
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
DROP TRIGGER IF EXISTS trg_notify_dish_created ON dish;
CREATE TRIGGER trg_notify_dish_created
    AFTER INSERT ON dish
    FOR EACH ROW
    WHEN (NEW.created_by_user IS NOT NULL AND NEW.is_template = FALSE)
    EXECUTE FUNCTION notify_dish_created();

DROP TRIGGER IF EXISTS trg_notify_dish_approved ON dish;
CREATE TRIGGER trg_notify_dish_approved
    AFTER UPDATE ON dish
    FOR EACH ROW
    WHEN (NEW.created_by_user IS NOT NULL)
    EXECUTE FUNCTION notify_dish_approved();

DROP TRIGGER IF EXISTS trg_notify_dish_popular ON dishstatistics;
CREATE TRIGGER trg_notify_dish_popular
    AFTER UPDATE ON dishstatistics
    FOR EACH ROW
    EXECUTE FUNCTION notify_dish_popular();

COMMIT;

-- Verify
SELECT 'DishNotification system installed successfully!' as status;
SELECT COUNT(*) as trigger_count FROM information_schema.triggers 
WHERE trigger_name LIKE '%dish%' AND event_object_table IN ('dish', 'dishstatistics');
