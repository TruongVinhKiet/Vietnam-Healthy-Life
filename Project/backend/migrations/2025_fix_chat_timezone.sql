-- ================================================================
-- FIX CHAT SYSTEM TIMEZONE - CONVERT TO UTC+7 (VIETNAM TIME)
-- ================================================================
-- Chat messages đang dùng NOW() trả về UTC, cần convert sang VN timezone
-- Date: 2025-12-13
-- ================================================================

BEGIN;

-- 1. Create helper function to get current timestamp in Vietnam timezone
CREATE OR REPLACE FUNCTION get_vietnam_timestamp()
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
  RETURN CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh';
END;
$$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION get_vietnam_timestamp() IS 'Returns current timestamp in Vietnam timezone (UTC+7) - VOLATILE';

-- 2. Create helper function to convert timestamp to Vietnam timezone
CREATE OR REPLACE FUNCTION to_vietnam_timestamp(ts TIMESTAMP WITH TIME ZONE)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
  RETURN ts AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh';
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION to_vietnam_timestamp(TIMESTAMP WITH TIME ZONE) IS 'Converts timestamp to Vietnam timezone - STABLE';

-- 3. Create helper function to format timestamp as ISO string with VN timezone
CREATE OR REPLACE FUNCTION format_vietnam_timestamp_iso(ts TIMESTAMP WITH TIME ZONE)
RETURNS TEXT AS $$
BEGIN
  -- Convert to VN timezone and format with timezone indicator
  RETURN to_char(ts AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh', 'YYYY-MM-DD"T"HH24:MI:SS.MS"+07:00"');
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION format_vietnam_timestamp_iso(TIMESTAMP WITH TIME ZONE) IS 'Formats timestamp as ISO string with +07:00 timezone for client parsing';

-- 3. Fix update_conversation_timestamp() to use VN timezone
CREATE OR REPLACE FUNCTION update_conversation_timestamp() RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME = 'ChatbotMessage' THEN
        UPDATE ChatbotConversation 
        SET updated_at = get_vietnam_timestamp() 
        WHERE conversation_id = NEW.conversation_id;
    ELSIF TG_TABLE_NAME = 'AdminMessage' THEN
        UPDATE AdminConversation 
        SET updated_at = get_vietnam_timestamp() 
        WHERE admin_conversation_id = NEW.admin_conversation_id;
    ELSIF TG_TABLE_NAME = 'PrivateMessage' THEN
        UPDATE PrivateConversation 
        SET updated_at = get_vietnam_timestamp() 
        WHERE conversation_id = NEW.conversation_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_conversation_timestamp() IS 'Updates conversation timestamps using Vietnam timezone';

-- 4. Fix update_friend_request_timestamp() to use VN timezone
CREATE OR REPLACE FUNCTION update_friend_request_timestamp() RETURNS trigger AS $$
BEGIN
    NEW.updated_at := get_vietnam_timestamp();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_friend_request_timestamp() IS 'Updates friend request timestamp using Vietnam timezone';

-- 5. Fix update_private_conversation_timestamp() to use VN timezone  
CREATE OR REPLACE FUNCTION update_private_conversation_timestamp() RETURNS trigger AS $$
BEGIN
    UPDATE PrivateConversation
    SET updated_at = get_vietnam_timestamp()
    WHERE conversation_id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_private_conversation_timestamp() IS 'Updates private conversation timestamp using Vietnam timezone';

-- 6. Create views with VN timezone converted timestamps for easy querying

-- View: chatbot_messages_vietnam - with VN timezone
CREATE OR REPLACE VIEW chatbot_messages_vietnam AS
SELECT 
    message_id,
    conversation_id,
    sender,
    message_text,
    image_url,
    nutrition_data,
    is_approved,
    created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh' AS created_at_vn
FROM ChatbotMessage;

COMMENT ON VIEW chatbot_messages_vietnam IS 'Chatbot messages with timestamps converted to Vietnam timezone';

-- View: admin_messages_vietnam - with VN timezone
CREATE OR REPLACE VIEW admin_messages_vietnam AS
SELECT 
    admin_message_id,
    admin_conversation_id,
    sender_type,
    sender_id,
    message_text,
    image_url,
    is_read,
    created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh' AS created_at_vn
FROM AdminMessage;

COMMENT ON VIEW admin_messages_vietnam IS 'Admin messages with timestamps converted to Vietnam timezone';

-- View: community_messages_vietnam - with VN timezone
CREATE OR REPLACE VIEW community_messages_vietnam AS
SELECT 
    message_id,
    user_id,
    message_text,
    image_url,
    created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh' AS created_at_vn,
    updated_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh' AS updated_at_vn,
    is_deleted,
    deleted_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh' AS deleted_at_vn
FROM CommunityMessage
WHERE is_deleted = FALSE;

COMMENT ON VIEW community_messages_vietnam IS 'Community messages with timestamps converted to Vietnam timezone';

-- View: private_messages_vietnam - with VN timezone
CREATE OR REPLACE VIEW private_messages_vietnam AS
SELECT 
    message_id,
    conversation_id,
    sender_id,
    message_text,
    image_url,
    is_read,
    created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh' AS created_at_vn,
    read_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh' AS read_at_vn
FROM PrivateMessage;

COMMENT ON VIEW private_messages_vietnam IS 'Private messages with timestamps converted to Vietnam timezone';

COMMIT;

-- ================================================================
-- VERIFICATION
-- ================================================================
-- Run these to verify:
-- SELECT get_vietnam_timestamp() as vn_time, CURRENT_TIMESTAMP as utc_time;
-- SELECT * FROM chatbot_messages_vietnam LIMIT 5;
-- ================================================================

