-- Migration: Add Community Chat, Friends, Avatar, and Social Features
-- Features:
-- 1. Community chat where users can share experiences and images
-- 2. Friend system (send/accept/reject friend requests)
-- 3. Avatar support for users
-- 4. Message reactions
-- 5. Private messaging between friends

BEGIN;

-- ============================================================
-- I. AVATAR SUPPORT
-- ============================================================

-- Add avatar_url column to User table
ALTER TABLE "User" 
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Add index for avatar lookups
CREATE INDEX IF NOT EXISTS idx_user_avatar ON "User"(avatar_url) WHERE avatar_url IS NOT NULL;

COMMENT ON COLUMN "User".avatar_url IS 'URL to user profile avatar image';

-- ============================================================
-- II. FRIEND SYSTEM
-- ============================================================

-- Table: FriendRequest
-- Purpose: Store friend requests between users
CREATE TABLE IF NOT EXISTS FriendRequest (
    request_id SERIAL PRIMARY KEY,
    sender_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    receiver_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'cancelled')),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(sender_id, receiver_id)
);

CREATE INDEX IF NOT EXISTS idx_friend_request_sender ON FriendRequest(sender_id);
CREATE INDEX IF NOT EXISTS idx_friend_request_receiver ON FriendRequest(receiver_id);
CREATE INDEX IF NOT EXISTS idx_friend_request_status ON FriendRequest(status);

-- Table: Friendship
-- Purpose: Store confirmed friendships (bidirectional)
CREATE TABLE IF NOT EXISTS Friendship (
    friendship_id SERIAL PRIMARY KEY,
    user1_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    user2_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user1_id, user2_id),
    CHECK (user1_id < user2_id) -- Ensure user1_id < user2_id to prevent duplicates
);

CREATE INDEX IF NOT EXISTS idx_friendship_user1 ON Friendship(user1_id);
CREATE INDEX IF NOT EXISTS idx_friendship_user2 ON Friendship(user2_id);

-- Function to create bidirectional friendship
CREATE OR REPLACE FUNCTION create_friendship(p_user1_id INT, p_user2_id INT) RETURNS void AS $$
DECLARE
    v_user1_id INT;
    v_user2_id INT;
BEGIN
    -- Ensure user1_id < user2_id
    IF p_user1_id < p_user2_id THEN
        v_user1_id := p_user1_id;
        v_user2_id := p_user2_id;
    ELSE
        v_user1_id := p_user2_id;
        v_user2_id := p_user1_id;
    END IF;
    
    -- Insert friendship
    INSERT INTO Friendship (user1_id, user2_id)
    VALUES (v_user1_id, v_user2_id)
    ON CONFLICT (user1_id, user2_id) DO NOTHING;
    
    -- Update friend request status
    UPDATE FriendRequest
    SET status = 'accepted',
        updated_at = NOW()
    WHERE ((sender_id = p_user1_id AND receiver_id = p_user2_id) OR
           (sender_id = p_user2_id AND receiver_id = p_user1_id))
      AND status = 'pending';
END;
$$ LANGUAGE plpgsql;

-- Trigger to update FriendRequest updated_at
CREATE OR REPLACE FUNCTION update_friend_request_timestamp() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_friend_request_timestamp ON FriendRequest;
CREATE TRIGGER trg_update_friend_request_timestamp
BEFORE UPDATE ON FriendRequest
FOR EACH ROW
EXECUTE FUNCTION update_friend_request_timestamp();

-- ============================================================
-- III. COMMUNITY CHAT
-- ============================================================

-- Table: CommunityMessage
-- Purpose: Store messages in community chat (public chat)
CREATE TABLE IF NOT EXISTS CommunityMessage (
    message_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    message_text TEXT,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_community_message_user ON CommunityMessage(user_id);
CREATE INDEX IF NOT EXISTS idx_community_message_created ON CommunityMessage(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_message_not_deleted ON CommunityMessage(is_deleted) WHERE is_deleted = FALSE;

-- ============================================================
-- IV. MESSAGE REACTIONS
-- ============================================================

-- Table: MessageReaction
-- Purpose: Store reactions to messages (community and private)
CREATE TABLE IF NOT EXISTS MessageReaction (
    reaction_id SERIAL PRIMARY KEY,
    message_type VARCHAR(20) NOT NULL CHECK (message_type IN ('community', 'private', 'chatbot', 'admin')),
    message_id INT NOT NULL,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    reaction_type VARCHAR(20) NOT NULL DEFAULT 'like' CHECK (reaction_type IN ('like', 'love', 'laugh', 'wow', 'sad', 'angry')),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(message_type, message_id, user_id, reaction_type)
);

CREATE INDEX IF NOT EXISTS idx_message_reaction_message ON MessageReaction(message_type, message_id);
CREATE INDEX IF NOT EXISTS idx_message_reaction_user ON MessageReaction(user_id);

-- ============================================================
-- V. PRIVATE MESSAGING BETWEEN FRIENDS
-- ============================================================

-- Table: PrivateConversation
-- Purpose: Store private conversations between friends
CREATE TABLE IF NOT EXISTS PrivateConversation (
    conversation_id SERIAL PRIMARY KEY,
    user1_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    user2_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user1_id, user2_id),
    CHECK (user1_id < user2_id) -- Ensure user1_id < user2_id
);

CREATE INDEX IF NOT EXISTS idx_private_conversation_user1 ON PrivateConversation(user1_id);
CREATE INDEX IF NOT EXISTS idx_private_conversation_user2 ON PrivateConversation(user2_id);

-- Table: PrivateMessage
-- Purpose: Store messages in private conversations
CREATE TABLE IF NOT EXISTS PrivateMessage (
    message_id SERIAL PRIMARY KEY,
    conversation_id INT NOT NULL REFERENCES PrivateConversation(conversation_id) ON DELETE CASCADE,
    sender_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    message_text TEXT,
    image_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_private_message_conversation ON PrivateMessage(conversation_id);
CREATE INDEX IF NOT EXISTS idx_private_message_sender ON PrivateMessage(sender_id);
CREATE INDEX IF NOT EXISTS idx_private_message_created ON PrivateMessage(created_at);
CREATE INDEX IF NOT EXISTS idx_private_message_read ON PrivateMessage(is_read) WHERE is_read = FALSE;

-- Function to get or create private conversation
CREATE OR REPLACE FUNCTION get_or_create_private_conversation(p_user1_id INT, p_user2_id INT) 
RETURNS INT AS $$
DECLARE
    v_user1_id INT;
    v_user2_id INT;
    v_conversation_id INT;
    v_friendship_exists BOOLEAN;
BEGIN
    -- Check if users are friends
    IF p_user1_id < p_user2_id THEN
        v_user1_id := p_user1_id;
        v_user2_id := p_user2_id;
    ELSE
        v_user1_id := p_user2_id;
        v_user2_id := p_user1_id;
    END IF;
    
    -- Check if friendship exists
    SELECT EXISTS(
        SELECT 1 FROM Friendship 
        WHERE user1_id = v_user1_id AND user2_id = v_user2_id
    ) INTO v_friendship_exists;
    
    IF NOT v_friendship_exists THEN
        RAISE EXCEPTION 'Users must be friends to start a private conversation';
    END IF;
    
    -- Get or create conversation
    SELECT conversation_id INTO v_conversation_id
    FROM PrivateConversation
    WHERE user1_id = v_user1_id AND user2_id = v_user2_id;
    
    IF v_conversation_id IS NULL THEN
        INSERT INTO PrivateConversation (user1_id, user2_id)
        VALUES (v_user1_id, v_user2_id)
        RETURNING conversation_id INTO v_conversation_id;
    END IF;
    
    RETURN v_conversation_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update conversation timestamps
CREATE OR REPLACE FUNCTION update_private_conversation_timestamp() RETURNS TRIGGER AS $$
BEGIN
    UPDATE PrivateConversation
    SET updated_at = NOW()
    WHERE conversation_id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_private_conversation_timestamp ON PrivateMessage;
CREATE TRIGGER trg_update_private_conversation_timestamp
AFTER INSERT ON PrivateMessage
FOR EACH ROW
EXECUTE FUNCTION update_private_conversation_timestamp();

-- ============================================================
-- VI. HELPER VIEWS
-- ============================================================

-- Function: get_user_friends
-- Purpose: Get all friends for a user (bidirectional)
CREATE OR REPLACE FUNCTION get_user_friends(p_user_id INT)
RETURNS TABLE(
    friendship_id INT,
    friend_id INT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.friendship_id,
        CASE 
            WHEN f.user1_id = p_user_id THEN f.user2_id
            ELSE f.user1_id
        END AS friend_id,
        f.created_at
    FROM Friendship f
    WHERE f.user1_id = p_user_id OR f.user2_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- View: community_messages_with_user_info
-- Purpose: Get community messages with user information
CREATE OR REPLACE VIEW community_messages_with_user_info AS
SELECT 
    cm.message_id,
    cm.user_id,
    u.full_name AS username,
    u.avatar_url,
    u.gender,
    cm.message_text,
    cm.image_url,
    cm.created_at,
    cm.updated_at,
    (
        SELECT COUNT(*)
        FROM MessageReaction mr
        WHERE mr.message_type = 'community'
          AND mr.message_id = cm.message_id
    ) AS reaction_count
FROM CommunityMessage cm
JOIN "User" u ON u.user_id = cm.user_id
WHERE cm.is_deleted = FALSE
ORDER BY cm.created_at DESC;

-- ============================================================
-- VII. COMMENTS FOR DOCUMENTATION
-- ============================================================

COMMENT ON TABLE FriendRequest IS 'Friend requests between users with status tracking';
COMMENT ON TABLE Friendship IS 'Confirmed friendships (bidirectional, user1_id < user2_id)';
COMMENT ON TABLE CommunityMessage IS 'Public community chat messages where users share experiences';
COMMENT ON TABLE MessageReaction IS 'Reactions to messages (community, private, chatbot, admin)';
COMMENT ON TABLE PrivateConversation IS 'Private conversations between friends';
COMMENT ON TABLE PrivateMessage IS 'Messages in private conversations between friends';

COMMENT ON COLUMN "User".avatar_url IS 'URL to user profile avatar image';
COMMENT ON COLUMN FriendRequest.status IS 'pending, accepted, rejected, or cancelled';
COMMENT ON COLUMN MessageReaction.reaction_type IS 'like, love, laugh, wow, sad, or angry';
COMMENT ON COLUMN MessageReaction.message_type IS 'community, private, chatbot, or admin';

COMMIT;

