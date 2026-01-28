const db = require('../db');
const { getVietnamDate } = require('../utils/dateHelper');

// Create medication schedule
async function createMedicationSchedule(userConditionId, userId, medicationTimes, notes) {
  const result = await db.query(`
    INSERT INTO MedicationSchedule (user_condition_id, user_id, medication_times, notes)
    VALUES ($1, $2, $3, $4)
    RETURNING *
  `, [userConditionId, userId, medicationTimes, notes]);
  
  return result.rows[0];
}

// Get medication schedules for user
async function getUserMedicationSchedules(userId) {
  const result = await db.query(`
    SELECT ms.*, uhc.condition_id, hc.name_vi as condition_name
    FROM MedicationSchedule ms
    JOIN UserHealthCondition uhc ON ms.user_condition_id = uhc.user_condition_id
    JOIN HealthCondition hc ON uhc.condition_id = hc.condition_id
    WHERE ms.user_id = $1 AND uhc.status = 'active'
    ORDER BY ms.created_at DESC
  `, [userId]);
  
  return result.rows;
}

// Log medication taken
async function logMedicationTaken(userConditionId, userId, medicationDate, medicationTime) {
  const result = await db.query(`
    INSERT INTO MedicationLog 
    (user_condition_id, user_id, medication_date, medication_time, taken_at, status)
    VALUES ($1, $2, $3, $4, NOW(), 'taken')
    ON CONFLICT (user_condition_id, medication_date, medication_time)
    DO UPDATE SET taken_at = NOW(), status = 'taken'
    RETURNING *
  `, [userConditionId, userId, medicationDate, medicationTime]);
  
  return result.rows[0];
}

// Get medication logs for date range
async function getMedicationLogs(userId, startDate, endDate) {
  const result = await db.query(`
    SELECT ml.*, uhc.condition_id, hc.name_vi as condition_name
    FROM MedicationLog ml
    JOIN UserHealthCondition uhc ON ml.user_condition_id = uhc.user_condition_id
    JOIN HealthCondition hc ON uhc.condition_id = hc.condition_id
    WHERE ml.user_id = $1 
      AND ml.medication_date BETWEEN $2 AND $3
    ORDER BY ml.medication_date DESC, ml.medication_time DESC
  `, [userId, startDate, endDate]);
  
  return result.rows;
}

// Get today's medication schedule with status
async function getTodayMedication(userId) {
  const today = getVietnamDate();
  
  const result = await db.query(`
    WITH medication_times_expanded AS (
      SELECT 
        ms.medication_id,
        ms.user_condition_id,
        ms.medication_times,
        ms.medication_details,
        hc.name_vi as condition_name,
        unnest(ms.medication_times) as medication_time
      FROM MedicationSchedule ms
      JOIN UserHealthCondition uhc ON ms.user_condition_id = uhc.user_condition_id
      JOIN HealthCondition hc ON uhc.condition_id = hc.condition_id
      WHERE ms.user_id = $1 AND uhc.status = 'active'
    )
    SELECT 
      mte.medication_id,
      mte.user_condition_id,
      mte.condition_name,
      mte.medication_time,
      COALESCE(
        (mte.medication_details->mte.medication_time->>'notes')::text, 
        ''
      ) as notes,
      COALESCE(ml.status, 'pending') as status,
      ml.taken_at
    FROM medication_times_expanded mte
    LEFT JOIN MedicationLog ml ON 
      ml.user_condition_id = mte.user_condition_id 
      AND ml.medication_date = $2
      AND to_char(ml.medication_time::time, 'HH24:MI') = mte.medication_time
    ORDER BY mte.medication_time
  `, [userId, today]);
  
  return result.rows;
}

// Get medication dates for calendar (dates with active treatment)
async function getMedicationDates(userId, startDate, endDate) {
  const result = await db.query(`
    SELECT DISTINCT
      generate_series(
        GREATEST(uhc.treatment_start_date, $2::date),
        LEAST(COALESCE(uhc.treatment_end_date, $3::date), $3::date),
        '1 day'::interval
      )::date as medication_date,
      hc.name_vi as condition_name
    FROM UserHealthCondition uhc
    JOIN HealthCondition hc ON uhc.condition_id = hc.condition_id
    WHERE uhc.user_id = $1 
      AND uhc.status = 'active'
      AND uhc.treatment_start_date <= $3
      AND (uhc.treatment_end_date IS NULL OR uhc.treatment_end_date >= $2)
  `, [userId, startDate, endDate]);
  
  return result.rows;
}

module.exports = {
  createMedicationSchedule,
  getUserMedicationSchedules,
  logMedicationTaken,
  getMedicationLogs,
  getTodayMedication,
  getMedicationDates
};
