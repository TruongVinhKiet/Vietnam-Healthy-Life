const express = require('express');
const router = express.Router();
const db = require('../db');
const adminMiddleware = require('../utils/adminMiddleware');

/**
 * GET /admin/chat/conversations
 * Get all chat conversations for admin
 */
router.get('/conversations', adminMiddleware, async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        c.admin_conversation_id as conversation_id,
        c.admin_conversation_id,
        c.user_id,
        u.email as user_email,
        u.full_name as user_name,
        u.avatar_url,
        c.status,
        c.subject,
        c.created_at AT TIME ZONE 'UTC' AS created_at,
        c.updated_at AT TIME ZONE 'UTC' AS updated_at,
        (SELECT message_text 
         FROM AdminMessage 
         WHERE admin_conversation_id = c.admin_conversation_id 
         ORDER BY created_at DESC 
         LIMIT 1) as last_message,
        (SELECT created_at AT TIME ZONE 'UTC'
         FROM AdminMessage 
         WHERE admin_conversation_id = c.admin_conversation_id 
         ORDER BY created_at DESC 
         LIMIT 1) as last_message_time,
        (SELECT COUNT(*) 
         FROM AdminMessage 
         WHERE admin_conversation_id = c.admin_conversation_id 
         AND sender_type = 'user' 
         AND is_read = false) as unread_count
      FROM AdminConversation c
      JOIN "User" u ON c.user_id = u.user_id
      WHERE c.status != 'archived'
      ORDER BY last_message_time DESC NULLS LAST, c.updated_at DESC
    `);

    res.json({ 
      success: true, 
      conversations: result.rows 
    });
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to load conversations',
      conversations: [] 
    });
  }
});

/**
 * GET /admin/chat/conversations/:id/messages
 * Get all messages in a conversation
 */
router.get('/conversations/:id/messages', adminMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query(`
      SELECT 
        admin_message_id as message_id,
        admin_conversation_id as conversation_id,
        sender_type,
        sender_id,
        message_text,
        image_url,
        created_at AT TIME ZONE 'UTC' AS created_at,
        is_read
      FROM AdminMessage
      WHERE admin_conversation_id = $1
      ORDER BY created_at ASC
    `, [id]);

    // Mark messages as read
    await db.query(`
      UPDATE AdminMessage 
      SET is_read = true 
      WHERE admin_conversation_id = $1 
      AND sender_type = 'user'
    `, [id]);

    res.json({ 
      success: true, 
      messages: result.rows 
    });
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to load messages',
      messages: [] 
    });
  }
});

/**
 * POST /admin/chat/conversations/:id/messages
 * Send a message as admin
 */
router.post('/conversations/:id/messages', adminMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { message } = req.body;
    const adminId = req.admin.admin_id;

    if (!message || !message.trim()) {
      return res.status(400).json({ 
        success: false, 
        message: 'Message cannot be empty' 
      });
    }

    const result = await db.query(`
      INSERT INTO AdminMessage (admin_conversation_id, sender_type, sender_id, message_text)
      VALUES ($1, 'admin', $2, $3)
      RETURNING 
        admin_message_id as message_id, 
        admin_conversation_id as conversation_id, 
        sender_type, 
        sender_id, 
        message_text, 
        created_at AT TIME ZONE 'UTC' AS created_at, 
        is_read
    `, [id, adminId, message.trim()]);

    // Update conversation updated_at
    await db.query(`UPDATE AdminConversation SET updated_at = NOW() WHERE admin_conversation_id = $1`, [id]);

    res.json({ 
      success: true, 
      message: result.rows[0] 
    });
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to send message' 
    });
  }
});

module.exports = router;
