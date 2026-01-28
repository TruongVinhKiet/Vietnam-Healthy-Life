const db = require('../db');
const { toVietnamDate } = require('../utils/dateHelper');

/**
 * GET /admin/users/:userId/activity
 * Get activity logs for a specific user with filtering and pagination
 */
async function getUserActivityLogs(req, res) {
  try {
    const { userId } = req.params;
    const { 
      startDate, 
      endDate, 
      action, 
      limit = 50, 
      offset = 0 
    } = req.query;

    let query = `
      SELECT 
        ual.log_id,
        ual.action,
        ual.log_time,
        u.full_name,
        u.email
      FROM UserActivityLog ual
      JOIN "User" u ON u.user_id = ual.user_id
      WHERE ual.user_id = $1
    `;
    
    const params = [userId];
    let paramCount = 1;

    if (startDate) {
      paramCount++;
      query += ` AND ual.log_time >= $${paramCount}`;
      params.push(startDate);
    }

    if (endDate) {
      paramCount++;
      query += ` AND ual.log_time <= $${paramCount}`;
      params.push(endDate);
    }

    if (action) {
      paramCount++;
      query += ` AND ual.action ILIKE $${paramCount}`;
      params.push(`%${action}%`);
    }

    query += ` ORDER BY ual.log_time DESC LIMIT $${paramCount + 1} OFFSET $${paramCount + 2}`;
    params.push(limit, offset);

    const result = await db.query(query, params);

    // Get total count
    let countQuery = `SELECT COUNT(*) FROM UserActivityLog WHERE user_id = $1`;
    const countParams = [userId];
    if (startDate) countQuery += ` AND log_time >= $2`;
    if (endDate) countQuery += ` AND log_time <= $${countParams.length + 1}`;
    
    const countResult = await db.query(countQuery, countParams.concat(startDate ? [startDate] : []).concat(endDate ? [endDate] : []));
    
    res.json({
      success: true,
      data: result.rows,
      total: parseInt(countResult.rows[0].count),
      limit: parseInt(limit),
      offset: parseInt(offset)
    });
  } catch (error) {
    console.error('Error getting user activity logs:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get activity logs',
      error: error.message
    });
  }
}

/**
 * GET /admin/users/:userId/activity/analytics
 * Get analytics and statistics for user activity
 */
async function getUserActivityAnalytics(req, res) {
  try {
    const { userId } = req.params;
    const { period = '7d' } = req.query;

    // Calculate date range based on period
    const now = new Date();
    let startDate;
    switch (period) {
      case '24h':
        startDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        break;
      case '7d':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case '30d':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      case '90d':
        startDate = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    }

    // Format startDate as ISO string for PostgreSQL
    const startDateStr = startDate.toISOString();

    // Get activity by action type
    const actionStats = await db.query(`
      SELECT 
        action,
        COUNT(*) as count,
        MIN(log_time) as first_occurrence,
        MAX(log_time) as last_occurrence
      FROM UserActivityLog
      WHERE user_id = $1 AND log_time >= $2
      GROUP BY action
      ORDER BY count DESC
    `, [userId, startDateStr]);

    // Get activity timeline (hourly for 24h, daily for others)
    const timelineInterval = period === '24h' ? '1 hour' : '1 day';
    const timeline = await db.query(`
      SELECT 
        date_trunc('${period === '24h' ? 'hour' : 'day'}', log_time) as time_bucket,
        COUNT(*) as count,
        array_agg(DISTINCT action) as actions
      FROM UserActivityLog
      WHERE user_id = $1 AND log_time >= $2
      GROUP BY time_bucket
      ORDER BY time_bucket ASC
    `, [userId, startDateStr]);

    // Get most active hours of day
    const hourlyActivity = await db.query(`
      SELECT 
        EXTRACT(HOUR FROM log_time)::INTEGER as hour,
        COUNT(*)::INTEGER as count
      FROM UserActivityLog
      WHERE user_id = $1 AND log_time >= $2
      GROUP BY hour
      ORDER BY hour ASC
    `, [userId, startDateStr]);

    // Get most active days of week
    const dailyActivity = await db.query(`
      SELECT 
        EXTRACT(DOW FROM log_time)::INTEGER as day_of_week,
        COUNT(*)::INTEGER as count
      FROM UserActivityLog
      WHERE user_id = $1 AND log_time >= $2
      GROUP BY day_of_week
      ORDER BY day_of_week ASC
    `, [userId, startDateStr]);

    // Get total activity count
    const totalActivity = await db.query(`
      SELECT COUNT(*)::INTEGER as total
      FROM UserActivityLog
      WHERE user_id = $1 AND log_time >= $2
    `, [userId, startDateStr]);

    // Get recent meals logged from meal_entries (more accurate)
    const startDateOnly = toVietnamDate(startDate); // YYYY-MM-DD format in Vietnam timezone
    const recentMeals = await db.query(`
      SELECT 
        entry_date as meal_date,
        meal_type,
        COUNT(*)::INTEGER as items_count,
        COALESCE(SUM(kcal), 0)::NUMERIC(10,2) as total_calories
      FROM meal_entries
      WHERE user_id = $1 AND entry_date >= $2
      GROUP BY entry_date, meal_type
      ORDER BY entry_date DESC, meal_type
      LIMIT 10
    `, [userId, startDateOnly]);

    // Get user engagement score (0-100)
    const engagementScore = calculateEngagementScore(
      parseInt(totalActivity.rows[0].total),
      period,
      recentMeals.rows.length
    );

    res.json({
      success: true,
      period,
      startDate: startDateStr,
      endDate: now.toISOString(),
      analytics: {
        totalActivities: parseInt(totalActivity.rows[0]?.total || 0),
        engagementScore,
        actionBreakdown: actionStats.rows.map(row => ({
          action: row.action,
          count: parseInt(row.count || 0),
          first_occurrence: row.first_occurrence,
          last_occurrence: row.last_occurrence
        })),
        timeline: timeline.rows.map(row => ({
          time_bucket: row.time_bucket,
          count: parseInt(row.count || 0),
          actions: row.actions || []
        })),
        hourlyPattern: hourlyActivity.rows.map(row => ({
          hour: parseInt(row.hour || 0),
          count: parseInt(row.count || 0)
        })),
        weeklyPattern: dailyActivity.rows.map(row => ({
          day: ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'][parseInt(row.day_of_week || 0)],
          count: parseInt(row.count || 0)
        })),
        recentMeals: recentMeals.rows.map(row => ({
          meal_date: row.meal_date,
          meal_type: row.meal_type,
          items_count: parseInt(row.items_count || 0),
          total_calories: parseFloat(row.total_calories || 0)
        }))
      }
    });
  } catch (error) {
    console.error('Error getting user activity analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get activity analytics',
      error: error.message
    });
  }
}

/**
 * GET /admin/activity/overview
 * Get overview of all user activities across the platform
 */
async function getAllUsersActivityOverview(req, res) {
  try {
    const { period = '7d' } = req.query;

    const now = new Date();
    let startDate;
    switch (period) {
      case '24h':
        startDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        break;
      case '7d':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case '30d':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    }

    // Total activities
    const totalActivities = await db.query(`
      SELECT COUNT(*) as count
      FROM UserActivityLog
      WHERE log_time >= $1
    `, [startDate]);

    // Active users count
    const activeUsers = await db.query(`
      SELECT COUNT(DISTINCT user_id) as count
      FROM UserActivityLog
      WHERE log_time >= $1
    `, [startDate]);

    // Most active users
    const topUsers = await db.query(`
      SELECT 
        u.user_id,
        u.full_name,
        u.email,
        COUNT(*) as activity_count,
        MAX(ual.log_time) as last_activity
      FROM UserActivityLog ual
      JOIN "User" u ON u.user_id = ual.user_id
      WHERE ual.log_time >= $1
      GROUP BY u.user_id, u.full_name, u.email
      ORDER BY activity_count DESC
      LIMIT 10
    `, [startDate]);

    // Activity by type
    const activityByType = await db.query(`
      SELECT 
        action,
        COUNT(*) as count
      FROM UserActivityLog
      WHERE log_time >= $1
      GROUP BY action
      ORDER BY count DESC
    `, [startDate]);

    // Timeline
    const timeline = await db.query(`
      SELECT 
        date_trunc('${period === '24h' ? 'hour' : 'day'}', log_time) as time_bucket,
        COUNT(*) as count,
        COUNT(DISTINCT user_id) as unique_users
      FROM UserActivityLog
      WHERE log_time >= $1
      GROUP BY time_bucket
      ORDER BY time_bucket ASC
    `, [startDate]);

    res.json({
      success: true,
      period,
      overview: {
        totalActivities: parseInt(totalActivities.rows[0].count),
        activeUsers: parseInt(activeUsers.rows[0].count),
        topUsers: topUsers.rows,
        activityBreakdown: activityByType.rows,
        timeline: timeline.rows
      }
    });
  } catch (error) {
    console.error('Error getting activity overview:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get activity overview',
      error: error.message
    });
  }
}

/**
 * POST /admin/users/:userId/activity
 * Manually log an activity for a user (admin use)
 */
async function logUserActivity(req, res) {
  try {
    const { userId } = req.params;
    const { action } = req.body;

    if (!action) {
      return res.status(400).json({
        success: false,
        message: 'Action is required'
      });
    }

    const result = await db.query(`
      INSERT INTO UserActivityLog (user_id, action, log_time)
      VALUES ($1, $2, NOW())
      RETURNING *
    `, [userId, action]);

    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error logging user activity:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log activity',
      error: error.message
    });
  }
}

// Helper function to calculate engagement score
function calculateEngagementScore(totalActivities, period, mealsLogged) {
  let expectedActivities;
  switch (period) {
    case '24h':
      expectedActivities = 10; // Expect ~10 activities per day
      break;
    case '7d':
      expectedActivities = 50; // ~7 per day
      break;
    case '30d':
      expectedActivities = 150; // ~5 per day
      break;
    case '90d':
      expectedActivities = 300; // ~3 per day
      break;
    default:
      expectedActivities = 50;
  }

  // Base score from activity frequency
  let score = Math.min((totalActivities / expectedActivities) * 60, 60);

  // Bonus for meal logging consistency
  const mealBonus = Math.min((mealsLogged / (period === '24h' ? 3 : 21)) * 40, 40);

  return Math.round(score + mealBonus);
}

module.exports = {
  getUserActivityLogs,
  getUserActivityAnalytics,
  getAllUsersActivityOverview,
  logUserActivity
};
