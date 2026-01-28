/**
 * dishNotificationController.js
 * Handle dish notification operations
 */

const db = require('../db');

/**
 * Get user's dish notifications
 */
async function getUserNotifications(req, res) {
  try {
    const userId = req.user.user_id;
    const { limit = 50, unread_only = false } = req.query;

    let query = `
      SELECT 
        dn.notification_id,
        dn.dish_id,
        dn.notification_type,
        dn.title,
        dn.message,
        dn.is_read,
        dn.created_at,
        dn.read_at,
        d.name as dish_name,
        d.vietnamese_name,
        d.image_url as dish_image
      FROM dishnotification dn
      LEFT JOIN dish d ON dn.dish_id = d.dish_id
      WHERE dn.user_id = $1
    `;

    const params = [userId];

    if (unread_only === 'true') {
      query += ' AND dn.is_read = FALSE';
    }

    query += ' ORDER BY dn.created_at DESC LIMIT $2';
    params.push(parseInt(limit));

    const result = await db.query(query, params);

    // Get unread count
    const unreadResult = await db.query(
      'SELECT COUNT(*) FROM dishnotification WHERE user_id = $1 AND is_read = FALSE',
      [userId]
    );

    res.json({
      success: true,
      notifications: result.rows,
      unread_count: parseInt(unreadResult.rows[0].count)
    });
  } catch (error) {
    console.error('Error getting dish notifications:', error);
    res.status(500).json({ error: 'Failed to get notifications' });
  }
}

/**
 * Mark notification as read
 */
async function markAsRead(req, res) {
  try {
    const userId = req.user.user_id;
    const { notificationId } = req.params;

    await db.query(
      `UPDATE dishnotification 
       SET is_read = TRUE, read_at = CURRENT_TIMESTAMP 
       WHERE notification_id = $1 AND user_id = $2`,
      [notificationId, userId]
    );

    res.json({ success: true });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ error: 'Failed to mark as read' });
  }
}

/**
 * Mark all notifications as read
 */
async function markAllAsRead(req, res) {
  try {
    const userId = req.user.user_id;

    await db.query(
      `UPDATE dishnotification 
       SET is_read = TRUE, read_at = CURRENT_TIMESTAMP 
       WHERE user_id = $1 AND is_read = FALSE`,
      [userId]
    );

    res.json({ success: true });
  } catch (error) {
    console.error('Error marking all as read:', error);
    res.status(500).json({ error: 'Failed to mark all as read' });
  }
}

/**
 * Delete notification
 */
async function deleteNotification(req, res) {
  try {
    const userId = req.user.user_id;
    const { notificationId } = req.params;

    await db.query(
      'DELETE FROM dishnotification WHERE notification_id = $1 AND user_id = $2',
      [notificationId, userId]
    );

    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({ error: 'Failed to delete notification' });
  }
}

module.exports = {
  getUserNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification
};
