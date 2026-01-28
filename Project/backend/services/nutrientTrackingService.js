const db = require("../db");
const healthConditionService = require("./healthConditionService");
const { getVietnamDate } = require("../utils/dateHelper");

/**
 * Calculate daily nutrient intake from meals for a specific user and date
 * Returns vitamins and minerals with current/target amounts and percentages
 * APPLIES HEALTH CONDITION ADJUSTMENTS to target amounts
 */
async function calculateDailyNutrientIntake(userId, date = null) {
  const targetDate = date || getVietnamDate();

  try {
    // Get base nutrient intake from database function
    const result = await db.query(
      "SELECT * FROM calculate_daily_nutrient_intake($1, $2)",
      [userId, targetDate]
    );

    const manualIntake = await db.query(
      `SELECT nutrient_id, nutrient_type, SUM(amount) as total_amount
       FROM UserNutrientManualLog
       WHERE user_id = $1 AND log_date = $2
       GROUP BY nutrient_id, nutrient_type`,
      [userId, targetDate]
    );

    const manualMap = new Map();
    manualIntake.rows.forEach((row) => {
      const key = `${row.nutrient_type}:${row.nutrient_id}`;
      manualMap.set(key, parseFloat(row.total_amount) || 0);
    });

    const mergedNutrients = result.rows.map((nutrient) => {
      const key = `${nutrient.nutrient_type}:${nutrient.nutrient_id}`;
      const manualAddition = manualMap.get(key) || 0;
      const currentAmount =
        (parseFloat(nutrient.current_amount) || 0) + manualAddition;
      if (manualMap.has(key)) manualMap.delete(key);
      return {
        ...nutrient,
        current_amount: currentAmount,
      };
    });

    // Get health condition adjustments
    const adjustments = await healthConditionService.getAdjustedRDA(userId);

    // Create adjustment map for quick lookup
    const adjustmentMap = new Map();
    adjustments.forEach((adj) => {
      adjustmentMap.set(adj.nutrient_code, adj.total_adjustment);
    });

    // Apply adjustments to target amounts
    const adjustedNutrients = mergedNutrients.map((nutrient) => {
      const adjustment = adjustmentMap.get(nutrient.nutrient_code) || 0;
      const currentAmount = parseFloat(nutrient.current_amount) || 0;
      const baseTarget = parseFloat(nutrient.target_amount) || 0;

      if (adjustment !== 0 && baseTarget > 0) {
        const adjustedTarget = baseTarget * (1 + adjustment / 100);
        const adjustedPercentage =
          currentAmount > 0 ? (currentAmount / adjustedTarget) * 100 : 0;

        return {
          ...nutrient,
          original_target_amount: baseTarget,
          target_amount: adjustedTarget,
          percentage: adjustedPercentage,
          adjustment_percent: adjustment,
          has_adjustment: true,
        };
      }

      const percentage =
        baseTarget > 0 ? (currentAmount / baseTarget) * 100 : 0;

      return {
        ...nutrient,
        current_amount: currentAmount,
        target_amount: baseTarget,
        percentage,
        adjustment_percent: 0,
        has_adjustment: false,
      };
    });

    return adjustedNutrients;
  } catch (error) {
    console.error("Error calculating daily nutrient intake:", error);
    throw error;
  }
}

/**
 * Get detailed nutrient breakdown with food sources
 */
async function getNutrientBreakdownWithSources(userId, date = null) {
  const targetDate = date || getVietnamDate();

  try {
    const query = `
      WITH meal_items_today AS (
        SELECT mi.food_id, mi.weight_g, f.description as food_name, m.meal_type
        FROM MealItem mi
        JOIN Meal m ON m.meal_id = mi.meal_id
        JOIN Food f ON f.food_id = mi.food_id
        WHERE m.user_id = $1 AND m.meal_date = $2
      ),
      vitamin_sources AS (
        SELECT 
          v.vitamin_id,
          v.code,
          v.name,
          v.unit,
          mit.food_name,
          mit.meal_type,
          mit.weight_g,
          fn.amount_per_100g * mit.weight_g / 100.0 as contributed_amount
        FROM Vitamin v
        JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
        JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        JOIN meal_items_today mit ON mit.food_id = fn.food_id
        WHERE fn.amount_per_100g > 0
      ),
      mineral_sources AS (
        SELECT 
          m.mineral_id,
          m.code,
          m.name,
          m.unit,
          mit.food_name,
          mit.meal_type,
          mit.weight_g,
          fn.amount_per_100g * mit.weight_g / 100.0 as contributed_amount
        FROM Mineral m
        JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(REPLACE(m.code, 'MIN_', ''))
        JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        JOIN meal_items_today mit ON mit.food_id = fn.food_id
        WHERE fn.amount_per_100g > 0
      )
      SELECT 'vitamin' as nutrient_type, * FROM vitamin_sources
      UNION ALL
      SELECT 'mineral' as nutrient_type, * FROM mineral_sources
      ORDER BY code, contributed_amount DESC
    `;

    const result = await db.query(query, [userId, targetDate]);
    return result.rows;
  } catch (error) {
    console.error("Error getting nutrient breakdown with sources:", error);
    throw error;
  }
}

/**
 * Check for nutrient deficiencies and create notifications
 * Returns number of notifications created
 */
async function checkAndNotifyDeficiencies(userId, date = null) {
  const targetDate = date || getVietnamDate();

  try {
    const result = await db.query(
      "SELECT check_and_notify_nutrient_deficiencies($1, $2) as notification_count",
      [userId, targetDate]
    );

    return result.rows[0].notification_count;
  } catch (error) {
    console.error("Error checking/notifying deficiencies:", error);
    throw error;
  }
}

/**
 * Get all nutrient notifications for a user
 */
async function getNutrientNotifications(userId, limit = 50) {
  try {
    const query = `
      SELECT 
        notification_id,
        nutrient_type,
        nutrient_id,
        notification_type,
        message,
        severity,
        is_read,
        created_at,
        CASE 
          WHEN created_at > NOW() - INTERVAL '1 hour' THEN 'new'
          WHEN created_at > NOW() - INTERVAL '24 hours' THEN 'recent'
          ELSE 'old'
        END as freshness
      FROM usernutrientnotification
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT $2
    `;

    const result = await db.query(query, [userId, limit]);
    return result.rows;
  } catch (error) {
    console.error("Error getting nutrient notifications:", error);
    throw error;
  }
}

/**
 * Mark nutrient notification as read
 */
async function markNotificationAsRead(notificationId, userId) {
  try {
    const result = await db.query(
      "UPDATE UserNutrientNotification SET is_read = TRUE WHERE notification_id = $1 AND user_id = $2 RETURNING *",
      [notificationId, userId]
    );

    return result.rows[0];
  } catch (error) {
    console.error("Error marking notification as read:", error);
    throw error;
  }
}

/**
 * Mark all nutrient notifications as read for a user
 */
async function markAllNotificationsAsRead(userId) {
  try {
    const result = await db.query(
      "UPDATE UserNutrientNotification SET is_read = TRUE WHERE user_id = $1 AND is_read = FALSE RETURNING COUNT(*)",
      [userId]
    );

    return result.rowCount;
  } catch (error) {
    console.error("Error marking all notifications as read:", error);
    throw error;
  }
}

/**
 * Get unread notification count
 */
async function getUnreadNotificationCount(userId) {
  try {
    const result = await db.query(
      "SELECT COUNT(*) as count FROM UserNutrientNotification WHERE user_id = $1 AND is_read = FALSE",
      [userId]
    );

    return parseInt(result.rows[0].count);
  } catch (error) {
    console.error("Error getting unread notification count:", error);
    throw error;
  }
}

/**
 * Get nutrient summary for home screen RDA cards
 */
async function getNutrientSummary(userId, date = null) {
  const intake = await calculateDailyNutrientIntake(userId, date);

  // Group by nutrient type and calculate averages
  const summary = {
    vitamins: {
      total: 0,
      achieved: 0,
      average_percentage: 0,
      top_deficient: [],
    },
    minerals: {
      total: 0,
      achieved: 0,
      average_percentage: 0,
      top_deficient: [],
    },
  };

  intake.forEach((nutrient) => {
    const category = summary[nutrient.nutrient_type + "s"];
    if (!category) return;

    category.total++;
    if (nutrient.percentage >= 100) category.achieved++;
    category.average_percentage += parseFloat(nutrient.percentage);

    // Track top 3 deficient nutrients
    if (nutrient.percentage < 100) {
      category.top_deficient.push({
        name: nutrient.nutrient_name,
        percentage: parseFloat(nutrient.percentage),
        current: parseFloat(nutrient.current_amount),
        target: parseFloat(nutrient.target_amount),
        unit: nutrient.unit,
      });
    }
  });

  // Calculate averages and sort deficiencies
  ["vitamins", "minerals"].forEach((type) => {
    if (summary[type].total > 0) {
      summary[type].average_percentage =
        summary[type].average_percentage / summary[type].total;
    }
    summary[type].top_deficient.sort((a, b) => a.percentage - b.percentage);
    summary[type].top_deficient = summary[type].top_deficient.slice(0, 3);
  });

  return summary;
}

/**
 * Update nutrient tracking table (called after meal operations)
 */
async function updateNutrientTracking(userId, date = null) {
  const targetDate = date || getVietnamDate();

  try {
    const intake = await calculateDailyNutrientIntake(userId, targetDate);

    // Upsert tracking records
    for (const nutrient of intake) {
      await db.query(
        `
        INSERT INTO UserNutrientTracking(
          user_id, date, nutrient_type, nutrient_id, 
          target_amount, current_amount, unit, last_updated
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
        ON CONFLICT (user_id, date, nutrient_type, nutrient_id)
        DO UPDATE SET
          current_amount = EXCLUDED.current_amount,
          last_updated = NOW()
      `,
        [
          userId,
          targetDate,
          nutrient.nutrient_type,
          nutrient.nutrient_id,
          nutrient.target_amount,
          nutrient.current_amount,
          nutrient.unit,
        ]
      );
    }

    return intake.length;
  } catch (error) {
    console.error("Error updating nutrient tracking:", error);
    throw error;
  }
}

/**
 * Get comprehensive nutrient report with all details
 */
async function getComprehensiveNutrientReport(userId, date = null) {
  const [intake, sources, notifications, summary] = await Promise.all([
    calculateDailyNutrientIntake(userId, date),
    getNutrientBreakdownWithSources(userId, date),
    getNutrientNotifications(userId, 10),
    getNutrientSummary(userId, date),
  ]);

  const { getVietnamDate } = require('../utils/dateHelper');
  return {
    date: date || getVietnamDate(),
    intake,
    sources,
    notifications,
    summary,
  };
}

module.exports = {
  calculateDailyNutrientIntake,
  getNutrientBreakdownWithSources,
  checkAndNotifyDeficiencies,
  getNutrientNotifications,
  markNotificationAsRead,
  markAllNotificationsAsRead,
  getUnreadNotificationCount,
  getNutrientSummary,
  updateNutrientTracking,
  getComprehensiveNutrientReport,
};
