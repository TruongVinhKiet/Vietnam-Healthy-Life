const db = require("../db");

/**
 * Get or create admin conversation for user
 */
exports.getOrCreateConversation = async (req, res) => {
  try {
    const userId = req.user.user_id;

    // Try to get most recent active conversation
    let result = await db.query(
      `SELECT 
         admin_conversation_id, 
         status, 
         subject, 
         created_at AT TIME ZONE 'UTC' AS created_at,
         updated_at AT TIME ZONE 'UTC' AS updated_at
       FROM AdminConversation 
       WHERE user_id = $1 AND status = 'active'
       ORDER BY updated_at DESC 
       LIMIT 1`,
      [userId]
    );

    if (result.rows.length === 0) {
      // Create new conversation
      result = await db.query(
        `INSERT INTO AdminConversation (user_id, subject, status) 
         VALUES ($1, 'Hỗ trợ khách hàng', 'active') 
         RETURNING 
           admin_conversation_id, 
           status, 
           subject, 
           created_at AT TIME ZONE 'UTC' AS created_at,
           updated_at AT TIME ZONE 'UTC' AS updated_at`,
        [userId]
      );
    }

    res.json({ conversation: result.rows[0] });
  } catch (error) {
    console.error("Error getting/creating admin conversation:", error);
    res.status(500).json({ error: "Failed to get conversation" });
  }
};

/**
 * Get messages for admin conversation
 */
exports.getMessages = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user.user_id;

    // Verify conversation belongs to user
    const convCheck = await db.query(
      "SELECT 1 FROM AdminConversation WHERE admin_conversation_id = $1 AND user_id = $2",
      [conversationId, userId]
    );

    if (convCheck.rows.length === 0) {
      return res.status(403).json({ error: "Access denied" });
    }

    // Mark messages as read
    await db.query(
      `UPDATE AdminMessage 
       SET is_read = TRUE 
       WHERE admin_conversation_id = $1 AND sender_type = 'admin' AND is_read = FALSE`,
      [conversationId]
    );

    const result = await db.query(
      `SELECT 
         admin_message_id, 
         sender_type, 
         sender_id, 
         message_text, 
         image_url, 
         is_read, 
         created_at AT TIME ZONE 'UTC' AS created_at
       FROM AdminMessage
       WHERE admin_conversation_id = $1
       ORDER BY created_at ASC`,
      [conversationId]
    );

    res.json({ messages: result.rows });
  } catch (error) {
    console.error("Error getting admin messages:", error);
    res.status(500).json({ error: "Failed to get messages" });
  }
};

/**
 * Send message to admin
 */
exports.sendMessage = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { message, imageUrl } = req.body;
    const userId = req.user.user_id;

    // Verify conversation belongs to user
    const convCheck = await db.query(
      "SELECT 1 FROM AdminConversation WHERE admin_conversation_id = $1 AND user_id = $2",
      [conversationId, userId]
    );

    if (convCheck.rows.length === 0) {
      return res.status(403).json({ error: "Access denied" });
    }

    // Save user message
    const result = await db.query(
      `INSERT INTO AdminMessage (admin_conversation_id, sender_type, sender_id, message_text, image_url)
       VALUES ($1, 'user', $2, $3, $4)
       RETURNING 
         admin_message_id, 
         sender_type, 
         sender_id, 
         message_text, 
         image_url, 
         is_read, 
         created_at AT TIME ZONE 'UTC' AS created_at`,
      [conversationId, userId, message, imageUrl]
    );

    res.json({ message: result.rows[0] });
  } catch (error) {
    console.error("Error sending admin message:", error);
    res.status(500).json({ error: "Failed to send message" });
  }
};

/**
 * Get unread message count
 */
exports.getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.user_id;

    const result = await db.query(
      `SELECT COUNT(*) as unread_count
       FROM adminmessage am
       WHERE am.admin_conversation_id IN (
         SELECT admin_conversation_id 
         FROM adminconversation 
         WHERE user_id = $1
       )
       AND am.sender_type = 'admin' 
       AND am.is_read = FALSE`,
      [userId]
    );

    res.json({ unreadCount: parseInt(result.rows[0].unread_count) });
  } catch (error) {
    console.error("Error getting unread count:", error);
    res.status(500).json({ error: "Failed to get unread count" });
  }
};
