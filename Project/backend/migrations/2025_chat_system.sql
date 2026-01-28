-- ============================================================
-- CHAT SYSTEM - MIGRATION
-- Purpose: Enable chatbot and admin messaging features
-- Author: System
-- Date: 2025-11-18
-- ============================================================

BEGIN;

-- ============================================================
-- I. CHATBOT CONVERSATIONS
-- ============================================================

-- Table: ChatbotConversation
-- Purpose: Store chatbot conversation threads for each user
CREATE TABLE IF NOT EXISTS ChatbotConversation (
    conversation_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    title VARCHAR(200) DEFAULT 'New conversation',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chatbot_conversation_user ON ChatbotConversation(user_id);
CREATE INDEX IF NOT EXISTS idx_chatbot_conversation_updated ON ChatbotConversation(updated_at DESC);

-- Table: ChatbotMessage
-- Purpose: Store individual messages in chatbot conversations
CREATE TABLE IF NOT EXISTS ChatbotMessage (
    message_id SERIAL PRIMARY KEY,
    conversation_id INT NOT NULL REFERENCES ChatbotConversation(conversation_id) ON DELETE CASCADE,
    sender VARCHAR(20) NOT NULL CHECK (sender IN ('user', 'bot')),
    message_text TEXT,
    image_url TEXT,
    nutrition_data JSONB, -- Stores analyzed nutrition data from food images
    is_approved BOOLEAN DEFAULT NULL, -- NULL=pending, TRUE=approved, FALSE=rejected
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chatbot_message_conversation ON ChatbotMessage(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chatbot_message_created ON ChatbotMessage(created_at);

-- ============================================================
-- II. ADMIN MESSAGING SYSTEM
-- ============================================================

-- Table: AdminConversation
-- Purpose: Store conversation threads between users and admins
CREATE TABLE IF NOT EXISTS AdminConversation (
    admin_conversation_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'resolved', 'archived')),
    subject VARCHAR(200),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_conversation_user ON AdminConversation(user_id);
CREATE INDEX IF NOT EXISTS idx_admin_conversation_status ON AdminConversation(status);
CREATE INDEX IF NOT EXISTS idx_admin_conversation_updated ON AdminConversation(updated_at DESC);

-- Table: AdminMessage
-- Purpose: Store individual messages between users and admins
CREATE TABLE IF NOT EXISTS AdminMessage (
    admin_message_id SERIAL PRIMARY KEY,
    admin_conversation_id INT NOT NULL REFERENCES AdminConversation(admin_conversation_id) ON DELETE CASCADE,
    sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('user', 'admin')),
    sender_id INT NOT NULL, -- user_id or admin_id depending on sender_type
    message_text TEXT,
    image_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_message_conversation ON AdminMessage(admin_conversation_id);
CREATE INDEX IF NOT EXISTS idx_admin_message_created ON AdminMessage(created_at);
CREATE INDEX IF NOT EXISTS idx_admin_message_read ON AdminMessage(is_read);

-- ============================================================
-- III. NUTRITION ANALYSIS CACHE
-- ============================================================

-- Table: NutritionAnalysis
-- Purpose: Cache nutrition analysis results from AI for food images
CREATE TABLE IF NOT EXISTS NutritionAnalysis (
    analysis_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    food_name VARCHAR(200),
    confidence_score NUMERIC(3,2), -- 0.00 to 1.00
    nutrients JSONB NOT NULL, -- Array of {nutrient_id, nutrient_name, amount, unit}
    is_approved BOOLEAN DEFAULT NULL,
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_nutrition_analysis_user ON NutritionAnalysis(user_id);
CREATE INDEX IF NOT EXISTS idx_nutrition_analysis_created ON NutritionAnalysis(created_at);
CREATE INDEX IF NOT EXISTS idx_nutrition_analysis_approved ON NutritionAnalysis(is_approved);

-- ============================================================
-- IV. HELPER FUNCTIONS
-- ============================================================

-- Function: update_conversation_timestamp
-- Purpose: Update the updated_at field when new messages are added
CREATE OR REPLACE FUNCTION update_conversation_timestamp() RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME = 'ChatbotMessage' THEN
        UPDATE ChatbotConversation 
        SET updated_at = NOW() 
        WHERE conversation_id = NEW.conversation_id;
    ELSIF TG_TABLE_NAME = 'AdminMessage' THEN
        UPDATE AdminConversation 
        SET updated_at = NOW() 
        WHERE admin_conversation_id = NEW.admin_conversation_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to update conversation timestamps
DROP TRIGGER IF EXISTS trg_update_chatbot_conversation_timestamp ON ChatbotMessage;
CREATE TRIGGER trg_update_chatbot_conversation_timestamp
AFTER INSERT ON ChatbotMessage
FOR EACH ROW EXECUTE FUNCTION update_conversation_timestamp();

DROP TRIGGER IF EXISTS trg_update_admin_conversation_timestamp ON AdminMessage;
CREATE TRIGGER trg_update_admin_conversation_timestamp
AFTER INSERT ON AdminMessage
FOR EACH ROW EXECUTE FUNCTION update_conversation_timestamp();

-- ============================================================
-- V. VIEWS FOR EASY QUERYING
-- ============================================================

-- View: recent_chatbot_conversations
-- Purpose: Get recent chatbot conversations with last message preview
CREATE OR REPLACE VIEW recent_chatbot_conversations AS
SELECT 
    c.conversation_id,
    c.user_id,
    c.title,
    c.created_at,
    c.updated_at,
    (
        SELECT message_text 
        FROM ChatbotMessage 
        WHERE conversation_id = c.conversation_id 
        ORDER BY created_at DESC 
        LIMIT 1
    ) AS last_message,
    (
        SELECT COUNT(*) 
        FROM ChatbotMessage 
        WHERE conversation_id = c.conversation_id
    ) AS message_count
FROM ChatbotConversation c
ORDER BY c.updated_at DESC;

-- View: active_admin_conversations
-- Purpose: Get active admin conversations with unread count
CREATE OR REPLACE VIEW active_admin_conversations AS
SELECT 
    ac.admin_conversation_id,
    ac.user_id,
    ac.status,
    ac.subject,
    ac.created_at,
    ac.updated_at,
    (
        SELECT COUNT(*) 
        FROM AdminMessage 
        WHERE admin_conversation_id = ac.admin_conversation_id 
          AND sender_type = 'user' 
          AND is_read = FALSE
    ) AS unread_count,
    (
        SELECT message_text 
        FROM AdminMessage 
        WHERE admin_conversation_id = ac.admin_conversation_id 
        ORDER BY created_at DESC 
        LIMIT 1
    ) AS last_message
FROM AdminConversation ac
WHERE ac.status = 'active'
ORDER BY ac.updated_at DESC;

-- ============================================================
-- VI. COMMENTS FOR DOCUMENTATION
-- ============================================================

COMMENT ON TABLE ChatbotConversation IS 'Stores chatbot conversation threads for each user';
COMMENT ON TABLE ChatbotMessage IS 'Individual messages in chatbot conversations, supports text and images';
COMMENT ON TABLE AdminConversation IS 'Conversation threads between users and admin support';
COMMENT ON TABLE AdminMessage IS 'Messages in admin conversations, bidirectional user-admin chat';
COMMENT ON TABLE NutritionAnalysis IS 'AI-analyzed nutrition data from food images with approval workflow';

COMMENT ON COLUMN ChatbotMessage.nutrition_data IS 'JSONB array of analyzed nutrients with IDs, names, amounts, units';
COMMENT ON COLUMN ChatbotMessage.is_approved IS 'NULL=pending approval, TRUE=saved to daily totals, FALSE=rejected';
COMMENT ON COLUMN NutritionAnalysis.confidence_score IS 'AI confidence level (0.00-1.00) for food recognition';

COMMIT;

-- ============================================================
-- END OF CHAT SYSTEM MIGRATION
-- ============================================================
