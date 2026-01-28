const db = require('../db');

/**
 * Get community messages with pagination
 */
exports.getCommunityMessages = async (req, res) => {
  try {
    const userId = req.user?.user_id;
    const { page = 1, limit = 50 } = req.query;
    const offset = (page - 1) * limit;

    const result = await db.query(
      `SELECT 
        cm.message_id,
        cm.user_id,
        u.full_name AS username,
        u.avatar_url,
        u.gender,
        cm.message_text,
        cm.image_url,
        cm.created_at AT TIME ZONE 'UTC' AS created_at,
        (
          SELECT COUNT(*)
          FROM MessageReaction mr
          WHERE mr.message_type = 'community'
            AND mr.message_id = cm.message_id
        ) AS reaction_count,
        (
          SELECT json_agg(json_build_object(
            'reaction_type', mr.reaction_type,
            'user_id', mr.user_id,
            'username', u2.full_name
          ))
          FROM MessageReaction mr
          JOIN "User" u2 ON u2.user_id = mr.user_id
          WHERE mr.message_type = 'community'
            AND mr.message_id = cm.message_id
        ) AS reactions
      FROM CommunityMessage cm
      JOIN "User" u ON u.user_id = cm.user_id
      WHERE cm.is_deleted = FALSE
      ORDER BY cm.created_at ASC
      LIMIT $1 OFFSET $2`,
      [limit, offset]
    );

    res.json({ messages: result.rows });
  } catch (error) {
    console.error('Error getting community messages:', error);
    res.status(500).json({ error: 'Failed to get community messages' });
  }
};

/**
 * Post a community message
 */
exports.postCommunityMessage = async (req, res) => {
  try {
    const userId = req.user?.user_id;
    if (!userId) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { message_text, image_url } = req.body;

    if (!message_text && !image_url) {
      return res.status(400).json({ error: 'Message text or image is required' });
    }

    const result = await db.query(
      `INSERT INTO CommunityMessage (user_id, message_text, image_url)
       VALUES ($1, $2, $3)
       RETURNING 
         message_id, 
         user_id, 
         message_text, 
         image_url, 
         created_at AT TIME ZONE 'UTC' AS created_at`,
      [userId, message_text || null, image_url || null]
    );

    // Get user info
    const userResult = await db.query(
      'SELECT full_name, avatar_url, gender FROM "User" WHERE user_id = $1',
      [userId]
    );

    res.json({
      message: {
        ...result.rows[0],
        username: userResult.rows[0]?.full_name,
        avatar_url: userResult.rows[0]?.avatar_url,
        gender: userResult.rows[0]?.gender,
        reaction_count: 0,
        reactions: []
      }
    });
  } catch (error) {
    console.error('Error posting community message:', error);
    res.status(500).json({ error: 'Failed to post message' });
  }
};

/**
 * React to a message
 */
exports.reactToMessage = async (req, res) => {
  try {
    const userId = req.user?.user_id;
    if (!userId) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { message_type, message_id, reaction_type = 'like' } = req.body;

    if (!['community', 'private', 'chatbot', 'admin'].includes(message_type)) {
      return res.status(400).json({ error: 'Invalid message type' });
    }

    if (!['like', 'love', 'laugh', 'wow', 'sad', 'angry'].includes(reaction_type)) {
      return res.status(400).json({ error: 'Invalid reaction type' });
    }

    // Check if reaction already exists
    const existing = await db.query(
      `SELECT reaction_id FROM MessageReaction
       WHERE message_type = $1 AND message_id = $2 AND user_id = $3 AND reaction_type = $4`,
      [message_type, message_id, userId, reaction_type]
    );

    if (existing.rows.length > 0) {
      // Remove reaction (toggle off)
      await db.query(
        'DELETE FROM MessageReaction WHERE reaction_id = $1',
        [existing.rows[0].reaction_id]
      );
      return res.json({ success: true, removed: true });
    }

    // Add reaction
    const result = await db.query(
      `INSERT INTO MessageReaction (message_type, message_id, user_id, reaction_type)
       VALUES ($1, $2, $3, $4)
       RETURNING reaction_id`,
      [message_type, message_id, userId, reaction_type]
    );

    res.json({ success: true, reaction_id: result.rows[0].reaction_id });
  } catch (error) {
    console.error('Error reacting to message:', error);
    res.status(500).json({ error: 'Failed to react to message' });
  }
};

/**
 * Send friend request
 */
exports.sendFriendRequest = async (req, res) => {
  try {
    const userId = req.user?.user_id;
    if (!userId) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { receiver_id } = req.body;

    if (!receiver_id || receiver_id === userId) {
      return res.status(400).json({ error: 'Invalid receiver ID' });
    }

    // Check if already friends
    const friendshipCheck = await db.query(
      `SELECT 1 FROM Friendship
       WHERE (user1_id = $1 AND user2_id = $2) OR (user1_id = $2 AND user2_id = $1)`,
      [userId, receiver_id]
    );

    if (friendshipCheck.rows.length > 0) {
      return res.status(400).json({ error: 'Already friends' });
    }

    // Check if request already exists
    const existingRequest = await db.query(
      `SELECT request_id, status FROM FriendRequest
       WHERE (sender_id = $1 AND receiver_id = $2) OR (sender_id = $2 AND receiver_id = $1)`,
      [userId, receiver_id]
    );

    if (existingRequest.rows.length > 0) {
      const request = existingRequest.rows[0];
      if (request.status === 'pending') {
        return res.status(400).json({ error: 'Friend request already pending' });
      }
      // If rejected/cancelled, create new request
    }

    const result = await db.query(
      `INSERT INTO FriendRequest (sender_id, receiver_id, status)
       VALUES ($1, $2, 'pending')
       ON CONFLICT (sender_id, receiver_id) DO UPDATE
       SET status = 'pending', updated_at = NOW()
         RETURNING 
         request_id, 
         sender_id, 
         receiver_id, 
         status, 
         created_at AT TIME ZONE 'UTC' AS created_at`,
      [userId, receiver_id]
    );

    res.json({ friend_request: result.rows[0] });
  } catch (error) {
    console.error('Error sending friend request:', error);
    res.status(500).json({ error: 'Failed to send friend request' });
  }
};

/**
 * Accept/reject friend request
 */
exports.respondToFriendRequest = async (req, res) => {
  try {
    const userId = req.user?.user_id;
    if (!userId) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { request_id } = req.params;
    const { action } = req.body; // 'accept' or 'reject'

    // Get request
    const requestResult = await db.query(
      'SELECT * FROM FriendRequest WHERE request_id = $1',
      [request_id]
    );

    if (requestResult.rows.length === 0) {
      return res.status(404).json({ error: 'Friend request not found' });
    }

    const request = requestResult.rows[0];

    // Verify user is the receiver
    if (request.receiver_id !== userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    if (action === 'accept') {
      // Create friendship
      await db.query('SELECT create_friendship($1, $2)', [
        request.sender_id,
        request.receiver_id
      ]);

      res.json({ success: true, message: 'Friend request accepted' });
    } else if (action === 'reject') {
      // Update request status
      await db.query(
        'UPDATE FriendRequest SET status = $1, updated_at = NOW() WHERE request_id = $2',
        ['rejected', request_id]
      );

      res.json({ success: true, message: 'Friend request rejected' });
    } else {
      return res.status(400).json({ error: 'Invalid action' });
    }
  } catch (error) {
    console.error('Error responding to friend request:', error);
    res.status(500).json({ error: 'Failed to respond to friend request' });
  }
};

/**
 * Get friend requests (sent and received)
 */
exports.getFriendRequests = async (req, res) => {
  try {
    const userId = req.user?.user_id;
    if (!userId) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { type = 'received' } = req.query; // 'sent' or 'received'

    let query;
    if (type === 'sent') {
      query = `
        SELECT 
          fr.request_id,
          fr.sender_id,
          fr.receiver_id,
          fr.status,
          fr.created_at AT TIME ZONE 'UTC' AS created_at,
          u.user_id,
          u.full_name AS username,
          u.avatar_url,
          u.gender
        FROM FriendRequest fr
        JOIN "User" u ON u.user_id = fr.receiver_id
        WHERE fr.sender_id = $1
        ORDER BY fr.created_at ASC
      `;
    } else {
      query = `
        SELECT 
          fr.request_id,
          fr.sender_id,
          fr.receiver_id,
          fr.status,
          fr.created_at AT TIME ZONE 'UTC' AS created_at,
          u.user_id,
          u.full_name AS username,
          u.avatar_url,
          u.gender
        FROM FriendRequest fr
        JOIN "User" u ON u.user_id = fr.sender_id
        WHERE fr.receiver_id = $1 AND fr.status = 'pending'
        ORDER BY fr.created_at ASC
      `;
    }

    const result = await db.query(query, [userId]);

    res.json({ friend_requests: result.rows });
  } catch (error) {
    console.error('Error getting friend requests:', error);
    res.status(500).json({ error: 'Failed to get friend requests' });
  }
};

/**
 * Get user's friends
 */
exports.getFriends = async (req, res) => {
  try {
    const userId = req.user?.user_id;
    if (!userId) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const result = await db.query(
      `SELECT 
        f.friendship_id,
        CASE 
          WHEN f.user1_id = $1 THEN f.user2_id
          ELSE f.user1_id
        END AS friend_id,
        u.full_name AS username,
        u.avatar_url,
        u.gender,
        f.created_at AT TIME ZONE 'UTC' AS created_at
      FROM Friendship f
      JOIN "User" u ON u.user_id = CASE 
        WHEN f.user1_id = $1 THEN f.user2_id
        ELSE f.user1_id
      END
      WHERE f.user1_id = $1 OR f.user2_id = $1
      ORDER BY f.created_at DESC`,
      [userId]
    );

    res.json({ friends: result.rows });
  } catch (error) {
    console.error('Error getting friends:', error);
    res.status(500).json({ error: 'Failed to get friends' });
  }
};

/**
 * Get or create private conversation
 */
exports.getOrCreatePrivateConversation = async (req, res) => {
  try {
    const userId = req.user?.user_id;
    if (!userId) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { friend_id } = req.params;
    const friendId = parseInt(friend_id, 10);

    if (Number.isNaN(friendId)) {
      return res.status(400).json({ error: 'Invalid friend id' });
    }

    // Check if users are friends
    const friendshipCheck = await db.query(
      `SELECT 1 FROM Friendship
       WHERE (user1_id = $1 AND user2_id = $2) OR (user1_id = $2 AND user2_id = $1)`,
      [userId, friendId]
    );

    if (friendshipCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Users must be friends to start a conversation' });
    }

    const parsedUserId = parseInt(userId, 10);
    if (Number.isNaN(parsedUserId)) {
      return res.status(400).json({ error: 'Invalid user id' });
    }

    const result = await db.query(
      'SELECT get_or_create_private_conversation($1::INT, $2::INT) AS conversation_id',
      [parsedUserId, friendId]
    );

    const conversationId = parseInt(result.rows[0].conversation_id, 10);

    // Get conversation details
    const convResult = await db.query(
      `SELECT 
        pc.conversation_id,
        pc.user1_id,
        pc.user2_id,
        pc.created_at AT TIME ZONE 'UTC' AS created_at,
        pc.updated_at AT TIME ZONE 'UTC' AS updated_at,
        CASE 
          WHEN pc.user1_id = $1 THEN u2.user_id
          ELSE u1.user_id
        END AS friend_id,
        CASE 
          WHEN pc.user1_id = $1 THEN u2.full_name
          ELSE u1.full_name
        END AS friend_username,
        CASE 
          WHEN pc.user1_id = $1 THEN u2.avatar_url
          ELSE u1.avatar_url
        END AS friend_avatar_url
      FROM PrivateConversation pc
      JOIN "User" u1 ON u1.user_id = pc.user1_id
      JOIN "User" u2 ON u2.user_id = pc.user2_id
      WHERE pc.conversation_id = $2`,
      [parsedUserId, conversationId]
    );

    res.json({ conversation: convResult.rows[0] });
  } catch (error) {
    console.error('Error getting/creating private conversation:', error);
    res.status(500).json({ error: 'Failed to get conversation' });
  }
};

/**
 * Get private messages
 */
exports.getPrivateMessages = async (req, res) => {
  try {
    const userId = req.user?.user_id;
    if (!userId) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { conversation_id } = req.params;

    // Verify user is part of conversation
    const convCheck = await db.query(
      `SELECT 1 FROM PrivateConversation
       WHERE conversation_id = $1 AND (user1_id = $2 OR user2_id = $2)`,
      [conversation_id, userId]
    );

    if (convCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const result = await db.query(
      `SELECT 
        pm.message_id,
        pm.conversation_id,
        pm.sender_id,
        pm.message_text,
        pm.image_url,
        pm.is_read,
        pm.read_at AT TIME ZONE 'UTC' AS read_at,
        pm.created_at AT TIME ZONE 'UTC' AS created_at,
        u.full_name AS username,
        u.avatar_url,
        u.gender
      FROM PrivateMessage pm
      JOIN "User" u ON u.user_id = pm.sender_id
      WHERE pm.conversation_id = $1
      ORDER BY pm.created_at ASC`,
      [conversation_id]
    );

    // Mark messages as read
    await db.query(
      `UPDATE PrivateMessage
       SET is_read = TRUE, read_at = CURRENT_TIMESTAMP
       WHERE conversation_id = $1 AND sender_id != $2 AND is_read = FALSE`,
      [conversation_id, userId]
    );

    res.json({ messages: result.rows });
  } catch (error) {
    console.error('Error getting private messages:', error);
    res.status(500).json({ error: 'Failed to get messages' });
  }
};

/**
 * Send private message
 */
exports.sendPrivateMessage = async (req, res) => {
  try {
    const userId = req.user?.user_id;
    if (!userId) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { conversation_id } = req.params;
    const { message_text, image_url } = req.body;

    if (!message_text && !image_url) {
      return res.status(400).json({ error: 'Message text or image is required' });
    }

    // Verify user is part of conversation
    const convCheck = await db.query(
      `SELECT 1 FROM PrivateConversation
       WHERE conversation_id = $1 AND (user1_id = $2 OR user2_id = $2)`,
      [conversation_id, userId]
    );

    if (convCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const result = await db.query(
      `INSERT INTO PrivateMessage (conversation_id, sender_id, message_text, image_url)
       VALUES ($1, $2, $3, $4)
       RETURNING 
         message_id, 
         conversation_id, 
         sender_id, 
         message_text, 
         image_url, 
         created_at AT TIME ZONE 'UTC' AS created_at`,
      [conversation_id, userId, message_text || null, image_url || null]
    );

    // Get user info
    const userResult = await db.query(
      'SELECT full_name, avatar_url, gender FROM "User" WHERE user_id = $1',
      [userId]
    );

    res.json({
      message: {
        ...result.rows[0],
        username: userResult.rows[0]?.full_name,
        avatar_url: userResult.rows[0]?.avatar_url,
        gender: userResult.rows[0]?.gender
      }
    });
  } catch (error) {
    console.error('Error sending private message:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
};

/**
 * Get user body measurements (for viewing friend's profile)
 */
exports.getUserBodyMeasurements = async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await db.query(
      `SELECT 
        measurement_id,
        measurement_date,
        weight_kg,
        height_cm,
        bmi,
        bmi_score,
        bmi_category,
        source,
        notes,
        created_at
      FROM BodyMeasurement
      WHERE user_id = $1
      ORDER BY measurement_date DESC, created_at DESC
      LIMIT 10`,
      [user_id]
    );

    res.json({ measurements: result.rows });
  } catch (error) {
    console.error('Error getting body measurements:', error);
    res.status(500).json({ error: 'Failed to get body measurements' });
  }
};

