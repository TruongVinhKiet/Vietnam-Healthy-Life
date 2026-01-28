const dailyMealSuggestionService = require('../services/dailyMealSuggestionService');
const smartSuggestionService = require('../services/smartSuggestionService');
const { toVietnamDate } = require('../utils/dateHelper');

/**
 * Daily Meal Suggestion Controller
 * Handles API endpoints for meal suggestions
 */

class DailyMealSuggestionController {

  /**
   * POST /api/suggestions/daily-meals
   * Generate daily meal suggestions for current user
   */
  async generateSuggestions(req, res) {
    try {
      const userId = req.user.user_id; // From auth middleware
      const { 
        date,
        breakfastDishCount,
        breakfastDrinkCount,
        lunchDishCount,
        lunchDrinkCount,
        dinnerDishCount,
        dinnerDrinkCount,
        snackDishCount,
        snackDrinkCount
      } = req.body;

      const targetDate = date ? new Date(date) : new Date();

      // Pass meal counts to service
      const result = await dailyMealSuggestionService.generateDailySuggestions(
        userId, 
        targetDate,
        {
          breakfastDishCount,
          breakfastDrinkCount,
          lunchDishCount,
          lunchDrinkCount,
          dinnerDishCount,
          dinnerDrinkCount,
          snackDishCount,
          snackDrinkCount
        }
      );

      const nutrientSummary = await dailyMealSuggestionService.calculateNutrientSummary(
        userId,
        targetDate,
        result.suggestions
      );

      const missing = await smartSuggestionService.getMissingNutrients(
        userId,
        toVietnamDate(targetDate)
      );

      res.status(201).json({
        success: true,
        message: 'Đã tạo gợi ý bữa ăn thành công',
        data: {
          ...result,
          nutrientSummary,
          missing
        }
      });

    } catch (error) {
      console.error('Error generating daily suggestions:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi tạo gợi ý bữa ăn',
        error: error.message
      });
    }
  }

  /**
   * GET /api/suggestions/daily-meals
   * Get current user's daily meal suggestions with nutrient summary
   */
  async getSuggestions(req, res) {
    try {
      const userId = req.user.user_id;
      const { date } = req.query; // Optional: specific date

      const targetDate = date ? new Date(date) : new Date();

      const suggestions = await dailyMealSuggestionService.getSuggestions(userId, targetDate);
      
      // Calculate nutrient summary for all suggestions
      const nutrientSummary = await dailyMealSuggestionService.calculateNutrientSummary(userId, targetDate, suggestions);

      const missing = await smartSuggestionService.getMissingNutrients(
        userId,
        toVietnamDate(targetDate)
      );

      res.status(200).json({
        success: true,
        data: {
          suggestions,
          nutrientSummary,
          missing
        }
      });

    } catch (error) {
      console.error('Error getting daily suggestions:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi lấy gợi ý bữa ăn',
        error: error.message
      });
    }
  }
  async consumeSuggestion(req, res) {
    try {
      const userId = req.user.user_id;
      const { date, mealType, dishId, drinkId } = req.body || {};

      if (!dishId && !drinkId) {
        return res.status(400).json({
          success: false,
          message: 'Thiếu dishId hoặc drinkId'
        });
      }

      const targetDate = date ? new Date(date) : new Date();
      const result = await dailyMealSuggestionService.consumeAcceptedSuggestion({
        userId,
        date: toVietnamDate(targetDate),
        mealType: mealType || null,
        dishId: dishId ? parseInt(dishId, 10) : null,
        drinkId: drinkId ? parseInt(drinkId, 10) : null
      });

      if (!result) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy gợi ý đã chấp nhận để xóa'
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Đã xóa gợi ý đã chấp nhận',
        data: result
      });
    } catch (error) {
      console.error('Error consuming suggestion:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi xóa gợi ý đã chấp nhận',
        error: error.message
      });
    }
  }

  /**
   * PUT /api/suggestions/daily-meals/:id/accept
   * Accept a meal suggestion
   */
  async acceptSuggestion(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.user_id;

      // Verify ownership (security check)
      const result = await dailyMealSuggestionService.acceptSuggestion(id);

      if (!result) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy gợi ý'
        });
      }

      // Verify user owns this suggestion
      if (result.user_id !== userId) {
        return res.status(403).json({
          success: false,
          message: 'Không có quyền thực hiện hành động này'
        });
      }

      res.status(200).json({
        success: true,
        message: 'Đã chấp nhận gợi ý',
        data: result
      });

    } catch (error) {
      console.error('Error accepting suggestion:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi chấp nhận gợi ý',
        error: error.message
      });
    }
  }

  /**
   * PUT /api/suggestions/daily-meals/:id/reject
   * Reject a suggestion and get a new one
   */
  async rejectSuggestion(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.user_id;

      // Note: Service will verify ownership during rejection
      const result = await dailyMealSuggestionService.rejectSuggestion(id);

      res.status(200).json({
        success: true,
        message: 'Đã từ chối gợi ý và tạo gợi ý mới',
        data: result
      });

    } catch (error) {
      console.error('Error rejecting suggestion:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi từ chối gợi ý',
        error: error.message
      });
    }
  }

  /**
   * DELETE /api/suggestions/daily-meals/:id
   * Delete a suggestion
   */
  async deleteSuggestion(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.user_id;

      const result = await dailyMealSuggestionService.deleteSuggestion(id);

      if (!result) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy gợi ý'
        });
      }

      // Verify ownership
      if (result.user_id !== userId) {
        return res.status(403).json({
          success: false,
          message: 'Không có quyền thực hiện hành động này'
        });
      }

      res.status(200).json({
        success: true,
        message: 'Đã xóa gợi ý'
      });

    } catch (error) {
      console.error('Error deleting suggestion:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi xóa gợi ý',
        error: error.message
      });
    }
  }

  /**
   * POST /api/suggestions/daily-meals/cleanup
   * Manual cleanup of old suggestions (admin only)
   */
  async cleanupOldSuggestions(req, res) {
    try {
      // Check if user is admin
      if (req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Chỉ admin mới có quyền thực hiện'
        });
      }

      const result = await dailyMealSuggestionService.cleanupOldSuggestions();

      res.status(200).json({
        success: true,
        message: 'Đã dọn dẹp gợi ý cũ',
        data: result
      });

    } catch (error) {
      console.error('Error cleaning up suggestions:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi dọn dẹp gợi ý',
        error: error.message
      });
    }
  }

  /**
   * POST /api/suggestions/daily-meals/cleanup-passed
   * Cleanup passed meal suggestions for current user
   */
  async cleanupPassedMeals(req, res) {
    try {
      const userId = req.user.user_id;

      const result = await dailyMealSuggestionService.cleanupPassedMeals(userId);

      res.status(200).json({
        success: true,
        message: 'Đã dọn dẹp gợi ý đã qua giờ',
        data: result
      });

    } catch (error) {
      console.error('Error cleaning up passed meals:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi dọn dẹp gợi ý',
        error: error.message
      });
    }
  }

  /**
   * GET /api/suggestions/daily-meals/stats
   * Get statistics about suggestions (acceptance rate, etc.)
   */
  async getStats(req, res) {
    try {
      const userId = req.user.user_id;
      const { startDate, endDate } = req.query;

      // Query for stats
      const pool = require('../db');
      const result = await pool.query(`
        SELECT 
          COUNT(*) as total_suggestions,
          COUNT(*) FILTER (WHERE is_accepted = true) as accepted_count,
          COUNT(*) FILTER (WHERE is_rejected = true) as rejected_count,
          ROUND(AVG(suggestion_score), 2) as avg_score,
          meal_type,
          COUNT(DISTINCT date) as days_with_suggestions
        FROM user_daily_meal_suggestions
        WHERE user_id = $1
          AND ($2::date IS NULL OR date >= $2)
          AND ($3::date IS NULL OR date <= $3)
        GROUP BY meal_type
      `, [userId, startDate || null, endDate || null]);

      res.status(200).json({
        success: true,
        data: result.rows
      });

    } catch (error) {
      console.error('Error getting suggestion stats:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi lấy thống kê',
        error: error.message
      });
    }
  }
}

module.exports = new DailyMealSuggestionController();
