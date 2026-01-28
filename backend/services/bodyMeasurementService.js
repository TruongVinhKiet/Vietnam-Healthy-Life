const db = require("../db");

const bodyMeasurementService = {
  /**
   * Get latest body measurement for user
   */
  async getLatestMeasurement(userId) {
    const result = await db.query(
      `
      SELECT 
        measurement_id,
        user_id,
        measurement_date,
        weight_kg,
        height_cm,
        bmi,
        bmi_score,
        bmi_category,
        source
      FROM bodymeasurement
      WHERE user_id = $1
      ORDER BY measurement_date DESC
      LIMIT 1
    `,
      [userId]
    );

    return result.rows[0] || null;
  },

  /**
   * Get measurement history for user
   */
  async getMeasurementHistory(userId, limit = 30) {
    const result = await db.query(
      `
      SELECT 
        measurement_id,
        measurement_date,
        weight_kg,
        height_cm,
        bmi,
        bmi_score,
        bmi_category,
        source
      FROM BodyMeasurement
      WHERE user_id = $1
      ORDER BY measurement_date DESC
      LIMIT $2
    `,
      [userId, limit]
    );

    return result.rows;
  },

  /**
   * Add new measurement
   */
  async addMeasurement(userId, data) {
    const { weight_kg, height_cm, source = "manual", notes = null } = data;

    const result = await db.query(
      `
      INSERT INTO BodyMeasurement (user_id, weight_kg, height_cm, source, notes)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `,
      [userId, weight_kg, height_cm, source, notes]
    );

    return result.rows[0];
  },

  /**
   * Get BMI statistics and trends
   */
  async getBMIStatistics(userId) {
    const result = await db.query(
      `
      SELECT 
        COUNT(*) as total_measurements,
        AVG(bmi) as avg_bmi,
        MIN(bmi) as min_bmi,
        MAX(bmi) as max_bmi,
        AVG(bmi_score) as avg_score,
        AVG(weight_kg) as avg_weight,
        
        -- Latest values
        (SELECT bmi FROM BodyMeasurement WHERE user_id = $1 ORDER BY measurement_date DESC LIMIT 1) as current_bmi,
        (SELECT bmi_score FROM BodyMeasurement WHERE user_id = $1 ORDER BY measurement_date DESC LIMIT 1) as current_score,
        (SELECT weight_kg FROM BodyMeasurement WHERE user_id = $1 ORDER BY measurement_date DESC LIMIT 1) as current_weight,
        
        -- 30 days ago
        (SELECT bmi FROM BodyMeasurement WHERE user_id = $1 AND measurement_date >= NOW() - INTERVAL '30 days' ORDER BY measurement_date ASC LIMIT 1) as bmi_30_days_ago,
        (SELECT weight_kg FROM BodyMeasurement WHERE user_id = $1 AND measurement_date >= NOW() - INTERVAL '30 days' ORDER BY measurement_date ASC LIMIT 1) as weight_30_days_ago
        
      FROM BodyMeasurement
      WHERE user_id = $1
    `,
      [userId]
    );

    return result.rows[0];
  },
};

module.exports = bodyMeasurementService;
