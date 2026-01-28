const db = require("../db");
const { getVietnamDate } = require("../utils/dateHelper");

// Clean medication controller: consolidated exports for medication endpoints

// GET /api/medications/conditions/:conditionId/drugs - Get drugs for a condition
exports.getDrugsForCondition = async (req, res) => {
  try {
    const { conditionId } = req.params;
    const userId = req.user.user_id;

    const conditionCheck = await db.query(
      `SELECT uhc.user_condition_id, uhc.status
       FROM userhealthcondition uhc
       WHERE uhc.user_id = $1 AND uhc.condition_id = $2 AND uhc.status = 'active'`,
      [userId, conditionId]
    );

    if (conditionCheck.rows.length === 0) {
      return res.status(404).json({ error: "Condition not found or not active" });
    }

    const drugsResult = await db.query(
      `SELECT 
        d.drug_id,
        d.name_vi,
        d.name_en,
        d.generic_name,
        d.drug_class,
        d.image_url,
        MAX(dhc.is_primary::int) > 0 as is_primary,
        COALESCE(
          json_agg(
            DISTINCT jsonb_build_object(
              'condition_id', hc.condition_id,
              'name_vi', hc.name_vi,
              'name_en', hc.name_en,
              'is_primary', dhc.is_primary
            )
          ) FILTER (WHERE hc.condition_id IS NOT NULL),
          '[]'::json
        ) as conditions
      FROM drug d
      JOIN drughealthcondition dhc ON dhc.drug_id = d.drug_id
      LEFT JOIN healthcondition hc ON hc.condition_id = dhc.condition_id
      WHERE dhc.condition_id = $1
        AND d.is_active = TRUE
      GROUP BY d.drug_id
      ORDER BY MAX(dhc.is_primary::int) DESC, d.name_vi`,
      [conditionId]
    );

    return res.json({ success: true, drugs: drugsResult.rows });
  } catch (error) {
    console.error("Error getting drugs for condition:", error);
    return res.status(500).json({ error: "Failed to get drugs" });
  }
};

// POST /api/medications/log - Log medication taken
exports.logMedication = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { drug_id, user_condition_id, medication_date, medication_time } = req.body;

    if (!drug_id || !user_condition_id || !medication_date || !medication_time) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const conditionCheck = await db.query(
      `SELECT user_id FROM userhealthcondition WHERE user_condition_id = $1 AND user_id = $2`,
      [user_condition_id, userId]
    );

    if (conditionCheck.rows.length === 0) {
      return res.status(403).json({ error: "Unauthorized" });
    }

    const result = await db.query(
      `INSERT INTO medicationlog (
        user_condition_id, user_id, drug_id, medication_date, medication_time, taken_at, status
      ) VALUES ($1, $2, $3, $4, $5, NOW(), 'taken')
      ON CONFLICT (user_condition_id, medication_date, medication_time)
      DO UPDATE SET drug_id = EXCLUDED.drug_id, taken_at = NOW(), status = 'taken'
      RETURNING *`,
      [user_condition_id, userId, drug_id, medication_date, medication_time]
    );

    return res.json({ success: true, medication: result.rows[0] });
  } catch (error) {
    console.error("Error logging medication:", error);
    return res.status(500).json({ error: "Failed to log medication" });
  }
};

// GET /api/medications/check-interaction - Check drug-nutrient interaction
exports.checkInteraction = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { meal_time, food_ids, drink_id } = req.query;

    if (!meal_time) return res.status(400).json({ error: "meal_time is required" });

    const mealTimestamp = new Date(meal_time);
    const foodIdsArray = food_ids ? food_ids.split(",").map((id) => parseInt(id)) : null;
    const drinkIdInt = drink_id ? parseInt(drink_id) : null;

    const interactionsResult = await db.query(
      `SELECT * FROM check_drug_nutrient_interaction($1, $2, $3, $4)`,
      [userId, mealTimestamp, foodIdsArray, drinkIdInt]
    );

    return res.json({ success: true, has_interaction: interactionsResult.rows.length > 0, interactions: interactionsResult.rows });
  } catch (error) {
    console.error("Error checking interaction:", error);
    return res.status(500).json({ error: "Failed to check interaction" });
  }
};

// GET /api/medications/history/stats - Get medication history statistics
exports.getMedicationHistoryStats = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { start_date, end_date } = req.query;

    const statsResult = await db.query(`SELECT * FROM get_medication_history_stats($1, $2, $3)`, [userId, start_date || null, end_date || null]);

    return res.json({ success: true, stats: statsResult.rows });
  } catch (error) {
    console.error("Error getting medication history stats:", error);
    return res.status(500).json({ error: "Failed to get medication history stats" });
  }
};

// GET /api/medications/drugs - Get all drugs (for user selection)
exports.getAllDrugs = async (req, res) => {
  try {
    const { search } = req.query;
    const userId = req.user.user_id;

    const conditionsResult = await db.query(`SELECT condition_id FROM userhealthcondition WHERE user_id = $1 AND status = 'active'`, [userId]);
    const userConditionIds = conditionsResult.rows.map((r) => r.condition_id);

    const params = [];
    let paramCount = 0;
    let searchClause = '';
    if (search) {
      paramCount++;
      searchClause = ` AND (d.name_vi ILIKE $${paramCount} OR d.name_en ILIKE $${paramCount} OR d.generic_name ILIKE $${paramCount})`;
      params.push(`%${search}%`);
    }

    const query = `
      SELECT 
        d.drug_id,
        d.name_vi,
        d.name_en,
        d.generic_name,
        d.drug_class,
        d.description,
        d.image_url,
        d.dosage_form,
        d.is_active,
        COALESCE(
          json_agg(
            DISTINCT jsonb_build_object(
              'condition_id', hc.condition_id,
              'name_vi', hc.name_vi,
              'name_en', hc.name_en,
              'is_primary', dhc.is_primary
            )
          ) FILTER (WHERE hc.condition_id IS NOT NULL),
          '[]'::json
        ) as conditions
      FROM drug d
      LEFT JOIN drughealthcondition dhc ON dhc.drug_id = d.drug_id
      LEFT JOIN healthcondition hc ON hc.condition_id = dhc.condition_id
      WHERE d.is_active = TRUE
      ${searchClause}
      GROUP BY d.drug_id
      ORDER BY d.name_vi ASC
    `;

    const result = await db.query(query, params);

    const drugs = result.rows.map((drug) => {
      const drugConditionIds = (drug.conditions || []).map((c) => c.condition_id).filter((id) => id != null);
      const isSuitable = userConditionIds.length > 0 && drugConditionIds.some((id) => userConditionIds.includes(id));
      return { ...drug, is_suitable_for_user: isSuitable, has_any_condition: drugConditionIds.length > 0 };
    });

    return res.json({ success: true, drugs, user_condition_ids: userConditionIds });
  } catch (error) {
    console.error("Error getting all drugs:", error);
    return res.status(500).json({ error: "Failed to get drugs" });
  }
};

// GET /api/medications/schedule - Get medication schedule for a date
exports.getMedicationSchedule = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const date = req.query.date || getVietnamDate();

    const datesResult = await db.query(
      `SELECT
        uhc.user_condition_id,
        uhc.condition_id,
        hc.name_vi as condition_name,
        UNNEST(uhc.medication_times) as medication_time,
        uhc.treatment_start_date,
        uhc.treatment_end_date,
        uhc.followup_date
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON hc.condition_id = uhc.condition_id
      WHERE uhc.user_id = $1
        AND uhc.status = 'active'
        AND uhc.medication_times IS NOT NULL
        AND array_length(uhc.medication_times, 1) > 0
      ORDER BY medication_time`,
      [userId]
    );

    const logsResult = await db.query(
      `SELECT
        ml.log_id,
        ml.user_condition_id,
        ml.medication_date,
        to_char(ml.medication_time::time, 'HH24:MI') as medication_time,
        ml.taken_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh' as taken_at,
        ml.status,
        ml.drug_id,
        d.name_vi as drug_name_vi,
        d.name_en as drug_name_en
      FROM medicationlog ml
      LEFT JOIN drug d ON d.drug_id = ml.drug_id
      WHERE ml.user_id = $1 AND ml.medication_date = $2
      ORDER BY ml.medication_time`,
      [userId, date]
    );

    return res.json({ success: true, schedules: datesResult.rows, logs: logsResult.rows });
  } catch (error) {
    console.error("Error getting medication schedule:", error);
    return res.json({ success: true, schedules: [], logs: [] });
  }
};

// GET /api/medications/today - Get today's medication
exports.getTodayMedication = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const today = getVietnamDate();

    const scheduleResult = await db.query(
      `SELECT 
        uhc.user_condition_id,
        uhc.condition_id,
        hc.name_vi as condition_name,
        UNNEST(uhc.medication_times) as medication_time,
        uhc.notes
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON hc.condition_id = uhc.condition_id
      WHERE uhc.user_id = $1 
        AND uhc.status = 'active'
        AND uhc.medication_times IS NOT NULL
        AND array_length(uhc.medication_times, 1) > 0
        AND (uhc.treatment_end_date IS NULL OR uhc.treatment_end_date >= $2)
      ORDER BY medication_time`,
      [userId, today]
    );

    const logsResult = await db.query(
      `SELECT 
        ml.user_condition_id,
        to_char(ml.medication_time::time, 'HH24:MI') as medication_time,
        ml.status,
        ml.taken_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh' as taken_at,
        ml.drug_id,
        d.name_vi as drug_name
      FROM medicationlog ml
      LEFT JOIN drug d ON d.drug_id = ml.drug_id
      WHERE ml.user_id = $1 AND ml.medication_date = $2`,
      [userId, today]
    );

    console.log(`[getTodayMedication] Schedule: ${scheduleResult.rows.length} times, Logs: ${logsResult.rows.length} entries`);

    const medications = scheduleResult.rows.map((schedule) => {
      const log = logsResult.rows.find((l) => l.user_condition_id === schedule.user_condition_id && l.medication_time === schedule.medication_time);
      return {
        user_condition_id: schedule.user_condition_id,
        condition_id: schedule.condition_id,
        condition_name: schedule.condition_name,
        medication_time: schedule.medication_time,
        notes: schedule.notes,
        status: log ? log.status : "pending",
        taken_at: log ? log.taken_at : null,
        drug_name: log ? log.drug_name : null,
      };
    });

    return res.json({ success: true, medications });
  } catch (error) {
    console.error("Error getting today medication:", error);
    return res.json({ success: true, medications: [] });
  }
};

// GET /api/medications/statistics - Get medication adherence statistics
exports.getMedicationStatistics = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { start_date, end_date } = req.query;

    const endDate = end_date || getVietnamDate();
    const thirtyDaysAgo = new Date(new Date().toLocaleString('en-US', { timeZone: 'Asia/Ho_Chi_Minh' }));
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const startDate = start_date || thirtyDaysAgo.toLocaleDateString('sv-SE', { timeZone: 'Asia/Ho_Chi_Minh' });

    const result = await db.query(
      `SELECT 
        COUNT(*) as total_doses,
        COUNT(CASE WHEN ml.status = 'taken' THEN 1 END) as taken_doses,
        COUNT(CASE WHEN ml.status = 'taken' AND ABS(EXTRACT(EPOCH FROM (ml.taken_at::time - ml.medication_time::time))) <= 3600 THEN 1 END) as on_time_doses,
        COUNT(CASE WHEN ml.status = 'taken' AND ABS(EXTRACT(EPOCH FROM (ml.taken_at::time - ml.medication_time::time))) > 3600 THEN 1 END) as late_doses,
        COUNT(CASE WHEN ml.status = 'missed' OR ml.status = 'pending' THEN 1 END) as missed_doses
      FROM medicationlog ml
      WHERE ml.user_id = $1 
        AND ml.medication_date >= $2 
        AND ml.medication_date <= $3`,
      [userId, startDate, endDate]
    );

    const stats = result.rows[0] || {};
    const total = parseInt(stats.total_doses || 0);
    const taken = parseInt(stats.taken_doses || 0);
    const onTime = parseInt(stats.on_time_doses || 0);

    const adherence_rate = total > 0 ? ((taken / total) * 100).toFixed(1) : 0;
    const on_time_rate = taken > 0 ? ((onTime / taken) * 100).toFixed(1) : 0;

    return res.json({
      success: true,
      statistics: {
        total_doses: total,
        taken_doses: taken,
        on_time_doses: onTime,
        late_doses: parseInt(stats.late_doses || 0),
        missed_doses: parseInt(stats.missed_doses || 0),
        adherence_rate: parseFloat(adherence_rate),
        on_time_rate: parseFloat(on_time_rate),
        start_date: startDate,
        end_date: endDate,
      },
    });
  } catch (error) {
    console.error("Error getting medication statistics:", error);
    return res.status(500).json({ error: "Failed to get medication statistics" });
  }
};

// GET /api/medications/logs - Get medication logs
exports.getMedicationLogs = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { start_date, end_date } = req.query;

    let query = `
      SELECT 
        ml.log_id,
        ml.medication_date,
        ml.medication_time,
        ml.taken_at,
        ml.status,
        ml.drug_id,
        d.name_vi as drug_name_vi,
        d.name_en as drug_name_en,
        uhc.condition_id,
        hc.name_vi as condition_name_vi,
        hc.name_en as condition_name_en
      FROM medicationlog ml
      JOIN userhealthcondition uhc ON uhc.user_condition_id = ml.user_condition_id
      JOIN healthcondition hc ON hc.condition_id = uhc.condition_id
      LEFT JOIN drug d ON d.drug_id = ml.drug_id
      WHERE ml.user_id = $1
    `;

    const params = [userId];
    let paramCount = 1;

    if (start_date) {
      paramCount++;
      query += ` AND ml.medication_date >= $${paramCount}`;
      params.push(start_date);
    }

    if (end_date) {
      paramCount++;
      query += ` AND ml.medication_date <= $${paramCount}`;
      params.push(end_date);
    }

    query += ` ORDER BY ml.medication_date DESC, ml.medication_time DESC`;

    const result = await db.query(query, params);

    return res.json({ success: true, logs: result.rows });
  } catch (error) {
    console.error("Error getting medication logs:", error);
    return res.status(500).json({ error: "Failed to get medication logs" });
  }
};

// POST /api/medications/taken - Mark medication as taken
exports.markMedicationTaken = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { medication_id, medication_time, drug_id } = req.body;

    if (!medication_id || !medication_time) {
      return res.status(400).json({ error: "medication_id and medication_time are required" });
    }

    const today = getVietnamDate();

    const scheduleResult = await db.query(
      `SELECT ms.user_condition_id, ms.user_id FROM medicationschedule ms WHERE ms.medication_id = $1 AND ms.user_id = $2`,
      [medication_id, userId]
    );

    if (scheduleResult.rows.length === 0) return res.status(404).json({ error: "Medication schedule not found" });

    const { user_condition_id } = scheduleResult.rows[0];

    const result = await db.query(
      `INSERT INTO medicationlog (user_condition_id, user_id, drug_id, medication_date, medication_time, taken_at, status)
       VALUES ($1, $2, $3, $4, $5, NOW(), 'taken')
       ON CONFLICT (user_condition_id, medication_date, medication_time)
       DO UPDATE SET drug_id = COALESCE(EXCLUDED.drug_id, medicationlog.drug_id), taken_at = NOW(), status = 'taken'
       RETURNING *`,
      [user_condition_id, userId, drug_id || null, today, medication_time]
    );

    return res.json({ success: true, medication: result.rows[0] });
  } catch (error) {
    console.error("Error marking medication taken:", error);
    return res.status(500).json({ error: "Failed to mark medication taken" });
  }
};

// GET /api/medications/calendar-dates - Get medication dates for calendar
exports.getMedicationDates = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { start_date, end_date } = req.query;

    const startDate = start_date || new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0];
    const endDate = end_date || new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).toISOString().split('T')[0];

    const result = await db.query(
      `SELECT DISTINCT
        ml.medication_date as date,
        COUNT(*) as medication_count
      FROM medicationlog ml
      WHERE ml.user_id = $1 
        AND ml.medication_date >= $2 
        AND ml.medication_date <= $3
      GROUP BY ml.medication_date
      ORDER BY ml.medication_date`,
      [userId, startDate, endDate]
    );

    return res.json({ success: true, dates: result.rows });
  } catch (error) {
    console.error("Error getting medication dates:", error);
    return res.status(500).json({ error: "Failed to get medication dates" });
  }
};

// POST /api/medications/taken - Mark medication as taken
exports.markMedicationTaken = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { medication_id, medication_time, drug_id } = req.body;

    if (!medication_id || !medication_time) {
      return res
        .status(400)
        .json({ error: "medication_id and medication_time are required" });
    }

    const today = getVietnamDate();

    // Get medication schedule to verify
    const scheduleResult = await db.query(
      `SELECT ms.user_condition_id, ms.user_id
       FROM medicationschedule ms
       WHERE ms.medication_id = $1 AND ms.user_id = $2`,
      [medication_id, userId]
    );

    if (scheduleResult.rows.length === 0) {
      return res.status(404).json({ error: "Medication schedule not found" });
    }

    const { user_condition_id } = scheduleResult.rows[0];

    // Insert or update medication log
    const result = await db.query(
      `INSERT INTO medicationlog (
        user_condition_id, user_id, drug_id, medication_date, medication_time, 
        taken_at, status
      ) VALUES ($1, $2, $3, $4, $5, NOW(), 'taken')
      ON CONFLICT (user_condition_id, medication_date, medication_time)
      DO UPDATE SET 
        drug_id = COALESCE(EXCLUDED.drug_id, medicationlog.drug_id),
        taken_at = NOW(),
        status = 'taken'
      RETURNING *`,
      [user_condition_id, userId, drug_id || null, today, medication_time]
    );

    return res.json({
      success: true,
      medication: result.rows[0],
    });
  } catch (error) {
    console.error("Error marking medication taken:", error);
    return res.status(500).json({ error: "Failed to mark medication taken" });
  }
};

// GET /api/medications/calendar-dates - Get medication dates for calendar
exports.getMedicationDates = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { start_date, end_date } = req.query;

    // Default to current month if not provided
    const startDate =
      start_date ||
      new Date(new Date().getFullYear(), new Date().getMonth(), 1)
        .toISOString()
        .split("T")[0];
    const endDate =
      end_date ||
      new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0)
        .toISOString()
        .split("T")[0];

    const result = await db.query(
      `SELECT DISTINCT
        ml.medication_date as date,
        COUNT(*) as medication_count
      FROM medicationlog ml
      WHERE ml.user_id = $1 
        AND ml.medication_date >= $2 
        AND ml.medication_date <= $3
      GROUP BY ml.medication_date
      ORDER BY ml.medication_date`,
      [userId, startDate, endDate]
    );

    return res.json({
      success: true,
      dates: result.rows,
    });
  } catch (error) {
    console.error("Error getting medication dates:", error);
    return res.status(500).json({ error: "Failed to get medication dates" });
  }
};
