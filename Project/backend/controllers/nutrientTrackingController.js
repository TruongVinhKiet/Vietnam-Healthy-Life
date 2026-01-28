const nutrientTrackingService = require('../services/nutrientTrackingService');
const manualNutritionService = require('../services/manualNutritionService');
const { getVietnamDate } = require('../utils/dateHelper');

/**
 * GET /nutrients/tracking/daily
 * Get daily nutrient intake tracking
 */
async function getDailyTracking(req, res) {
  try {
    const userId = req.user.user_id;
    const date = req.query.date; // Optional: YYYY-MM-DD format
    
    console.log('[NutrientTracking] getDailyTracking called for user:', userId, 'date:', date || 'today');
    
    const intake = await nutrientTrackingService.calculateDailyNutrientIntake(userId, date);
    
    console.log('[NutrientTracking] Got', intake.length, 'nutrients from service');
    if (intake.length > 0) {
      const withValue = intake.filter(n => parseFloat(n.current_amount || 0) > 0);
      console.log('[NutrientTracking]', withValue.length, 'nutrients have consumption > 0');
      if (withValue.length > 0) {
        console.log('[NutrientTracking] Sample:', withValue[0].nutrient_name, '=', withValue[0].percentage, '%');
      }
    }
    
    res.json({
      success: true,
      date: date || getVietnamDate(),
      nutrients: intake
    });
  } catch (error) {
    console.error('Error in getDailyTracking:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin theo dõi dinh dưỡng',
      error: error.message
    });
  }
}

/**
 * GET /nutrients/tracking/breakdown
 * Get detailed nutrient breakdown with food sources
 */
async function getNutrientBreakdown(req, res) {
  try {
    const userId = req.user.user_id;
    const date = req.query.date;
    
    const breakdown = await nutrientTrackingService.getNutrientBreakdownWithSources(userId, date);
    
    res.json({
      success: true,
      date: date || getVietnamDate(),
      sources: breakdown
    });
  } catch (error) {
    console.error('Error in getNutrientBreakdown:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy chi tiết nguồn dinh dưỡng',
      error: error.message
    });
  }
}

/**
 * POST /nutrients/tracking/check-deficiencies
 * Check for deficiencies and create notifications
 */
async function checkDeficiencies(req, res) {
  try {
    const userId = req.user.user_id;
    const date = req.body.date;
    
    const notificationCount = await nutrientTrackingService.checkAndNotifyDeficiencies(userId, date);
    
    res.json({
      success: true,
      message: `Đã tạo ${notificationCount} thông báo thiếu hụt dinh dưỡng`,
      notification_count: notificationCount
    });
  } catch (error) {
    console.error('Error in checkDeficiencies:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi kiểm tra thiếu hụt dinh dưỡng',
      error: error.message
    });
  }
}

/**
 * GET /nutrients/tracking/notifications
 * Get all nutrient notifications
 */
async function getNotifications(req, res) {
  try {
    const userId = req.user.user_id;
    const limit = parseInt(req.query.limit) || 20;
    
    const notifications = await nutrientTrackingService.getNutrientNotifications(userId, limit);
    const unreadCount = await nutrientTrackingService.getUnreadNotificationCount(userId);
    
    res.json({
      success: true,
      notifications,
      unread_count: unreadCount
    });
  } catch (error) {
    console.error('Error in getNotifications:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông báo dinh dưỡng',
      error: error.message
    });
  }
}

/**
 * PUT /nutrients/tracking/notifications/:id/read
 * Mark notification as read
 */
async function markNotificationRead(req, res) {
  try {
    const userId = req.user.user_id;
    const notificationId = parseInt(req.params.id);
    
    const notification = await nutrientTrackingService.markNotificationAsRead(notificationId, userId);
    
    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thông báo'
      });
    }
    
    res.json({
      success: true,
      notification
    });
  } catch (error) {
    console.error('Error in markNotificationRead:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi đánh dấu thông báo đã đọc',
      error: error.message
    });
  }
}

/**
 * PUT /nutrients/tracking/notifications/read-all
 * Mark all notifications as read
 */
async function markAllNotificationsRead(req, res) {
  try {
    const userId = req.user.user_id;
    
    await nutrientTrackingService.markAllNotificationsAsRead(userId);
    
    res.json({
      success: true,
      message: `Đã đánh dấu ${count} thông báo đã đọc`,
      count
    });
  } catch (error) {
    console.error('Error in markAllNotificationsRead:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi đánh dấu tất cả thông báo đã đọc',
      error: error.message
    });
  }
}

/**
 * GET /nutrients/tracking/summary
 * Get nutrient summary for home screen
 */
async function getSummary(req, res) {
  try {
    const userId = req.user.user_id;
    const date = req.query.date;
    
    const summary = await nutrientTrackingService.getNutrientSummary(userId, date);
    
    res.json({
      success: true,
      date: date || getVietnamDate(),
      summary
    });
  } catch (error) {
    console.error('Error in getSummary:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy tóm tắt dinh dưỡng',
      error: error.message
    });
  }
}

/**
 * GET /nutrients/tracking/report
 * Get comprehensive nutrient report
 */
async function getComprehensiveReport(req, res) {
  try {
    const userId = req.user.user_id;
    const date = req.query.date;
    
    const report = await nutrientTrackingService.getComprehensiveNutrientReport(userId, date);
    
    res.json({
      success: true,
      report
    });
  } catch (error) {
    console.error('Error in getComprehensiveReport:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy báo cáo dinh dưỡng',
      error: error.message
    });
  }
}

/**
 * POST /nutrients/tracking/update
 * Manually trigger nutrient tracking update (called after meal changes)
 */
async function updateTracking(req, res) {
  try {
    const userId = req.user.user_id;
    const date = req.body.date;
    
    const count = await nutrientTrackingService.updateNutrientTracking(userId, date);
    
    res.json({
      success: true,
      message: `Đã cập nhật ${count} chất dinh dưỡng`,
      updated_count: count
    });
  } catch (error) {
    console.error('Error in updateTracking:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật theo dõi dinh dưỡng',
      error: error.message
    });
  }
}

/**
 * POST /nutrients/approve-scan
 * Approve nutrition scan and add to daily tracking
 */
async function approveScanNutrition(req, res) {
  try {
    const userId = req.user.user_id;
    const { food_name, nutrients } = req.body;
    const today = getVietnamDate();
    
    console.log(`[approveScanNutrition] User ${userId} approving ${nutrients?.length || 0} nutrients`);
    
    const manualResult = await manualNutritionService.saveManualIntake({
      userId,
      nutrients,
      foodName: food_name,
      source: 'scan',
      date: today
    });
    
    res.json({
      success: true,
      message: `Đã lưu thông tin dinh dưỡng của ${food_name}`,
      date: today,
      today: manualResult.todayTotals
    });
  } catch (error) {
    console.error('Error in approveScanNutrition:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lưu thông tin dinh dưỡng',
      error: error.message
    });
  }
}

module.exports = {
  getDailyTracking,
  getNutrientBreakdown,
  checkDeficiencies,
  getNotifications,
  markNotificationRead,
  markAllNotificationsRead,
  getSummary,
  getComprehensiveReport,
  updateTracking,
  approveScanNutrition
};
