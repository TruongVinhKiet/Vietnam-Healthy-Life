const db = require("../db");
const { getVietnamDate } = require("../utils/dateHelper");

// Get all health conditions
async function getAllConditions() {
  const result = await db.query(`
    SELECT condition_id, 
           COALESCE(condition_name, '') as condition_name,
           name_vi, 
           description, 
           description_vi, 
           category, 
           created_at
    FROM healthcondition
    ORDER BY category, COALESCE(condition_name, '')
  `);
  return result.rows;
}

// Get condition by ID with nutrient effects and food restrictions
async function getConditionById(conditionId) {
  const condition = await db.query(
    `
    SELECT * FROM HealthCondition WHERE condition_id = $1
  `,
    [conditionId]
  );

  if (condition.rows.length === 0) return null;

  // Get nutrient effects
  const effects = await db.query(
    `
    SELECT cne.*, n.name as nutrient_name, n.nutrient_code, n.unit
    FROM ConditionNutrientEffect cne
    JOIN Nutrient n ON cne.nutrient_id = n.nutrient_id
    WHERE cne.condition_id = $1
    ORDER BY cne.effect_type, n.name
  `,
    [conditionId]
  );

  // Get food recommendations
  const foods = await db.query(
    `
    SELECT cfr.*, f.name as food_name
    FROM ConditionFoodRecommendation cfr
    JOIN Food f ON cfr.food_id = f.food_id
    WHERE cfr.condition_id = $1
    ORDER BY cfr.recommendation_type, f.name
  `,
    [conditionId]
  );

  const foodsToAvoid = foods.rows.filter(
    (row) => (row.recommendation_type || "").toLowerCase() === "avoid"
  );
  const foodsRecommended = foods.rows.filter(
    (row) => (row.recommendation_type || "").toLowerCase() !== "avoid"
  );

  return {
    ...condition.rows[0],
    nutrient_effects: effects.rows,
    food_restrictions: foods.rows,
    foods_to_avoid: foodsToAvoid,
    food_recommendations: foodsRecommended,
  };
}

// Create new condition
async function createCondition(data) {
  const {
    name_vi,
    name_en,
    category,
    description,
    causes,
    image_url,
    treatment_duration_reference,
  } = data;

  const result = await db.query(
    `
    INSERT INTO HealthCondition 
    (name_vi, name_en, category, description, causes, image_url, treatment_duration_reference)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *
  `,
    [
      name_vi,
      name_en,
      category,
      description,
      causes,
      image_url,
      treatment_duration_reference,
    ]
  );

  return result.rows[0];
}

// Update condition
async function updateCondition(conditionId, data) {
  const {
    name_vi,
    name_en,
    category,
    description,
    causes,
    image_url,
    treatment_duration_reference,
  } = data;

  const result = await db.query(
    `
    UPDATE HealthCondition
    SET name_vi = COALESCE($2, name_vi),
        name_en = COALESCE($3, name_en),
        category = COALESCE($4, category),
        description = COALESCE($5, description),
        causes = COALESCE($6, causes),
        image_url = COALESCE($7, image_url),
        treatment_duration_reference = COALESCE($8, treatment_duration_reference),
        updated_at = NOW()
    WHERE condition_id = $1
    RETURNING *
  `,
    [
      conditionId,
      name_vi,
      name_en,
      category,
      description,
      causes,
      image_url,
      treatment_duration_reference,
    ]
  );

  return result.rows[0];
}

// Delete condition
async function deleteCondition(conditionId) {
  await db.query("DELETE FROM HealthCondition WHERE condition_id = $1", [
    conditionId,
  ]);
}

// Add nutrient effect
async function addNutrientEffect(
  conditionId,
  nutrientId,
  effectType,
  adjustmentPercent,
  notes
) {
  const result = await db.query(
    `
    INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent, notes)
    VALUES ($1, $2, $3, $4, $5)
    ON CONFLICT (condition_id, nutrient_id) 
    DO UPDATE SET effect_type = $3, adjustment_percent = $4, notes = $5
    RETURNING *
  `,
    [conditionId, nutrientId, effectType, adjustmentPercent, notes]
  );

  return result.rows[0];
}

// Add food restriction
async function addFoodRestriction(
  conditionId,
  foodId,
  recommendationType,
  notes
) {
  const result = await db.query(
    `
    INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
    VALUES ($1, $2, $3, $4)
    ON CONFLICT (condition_id, food_id)
    DO UPDATE SET recommendation_type = $3, notes = $4
    RETURNING *
  `,
    [conditionId, foodId, recommendationType, notes]
  );

  return result.rows[0];
}

// Get user's active conditions
async function getUserConditions(userId) {
  const result = await db.query(
    `
    SELECT 
      uhc.user_condition_id,
      uhc.user_id,
      uhc.condition_id,
      uhc.diagnosed_date as diagnosis_date,
      uhc.treatment_start_date,
      uhc.treatment_end_date,
      uhc.treatment_duration_days,
      uhc.medication_times,
      uhc.status,
      uhc.notes,
      uhc.created_at,
      hc.condition_name, 
      hc.name_vi, 
      hc.description_vi,
      hc.description,
      hc.category
    FROM userhealthcondition uhc
    JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
    WHERE uhc.user_id = $1 AND uhc.status = 'active'
    ORDER BY uhc.created_at DESC
  `,
    [userId]
  );

  return result.rows;
}

// Add condition to user with medication schedule
async function addUserCondition(
  userId,
  conditionId,
  treatmentStartDate,
  treatmentEndDate,
  medicationTimes,
  medicationDetails
) {
  console.log('[addUserCondition] Input params:', {
    userId,
    conditionId,
    treatmentStartDate,
    treatmentEndDate,
    medicationTimes,
    medicationDetails
  });

  // Insert user condition with medication_times
  const conditionResult = await db.query(
    `
    INSERT INTO userhealthcondition 
    (user_id, condition_id, treatment_start_date, treatment_end_date, medication_times)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *
  `,
    [
      userId,
      conditionId,
      treatmentStartDate || getVietnamDate(),
      treatmentEndDate || null,
      medicationTimes || [], // Save medication times array
    ]
  );

  const userCondition = conditionResult.rows[0];
  
  console.log(`[addUserCondition] Created condition ${userCondition.user_condition_id} with medication_times:`, userCondition.medication_times);

  return userCondition;
}

// Update user condition status
async function updateUserConditionStatus(userConditionId, status) {
  const result = await db.query(
    `
    UPDATE userhealthcondition
    SET status = $2, updated_at = NOW()
    WHERE user_condition_id = $1
    RETURNING *
  `,
    [userConditionId, status]
  );

  return result.rows[0];
}

// Get adjusted RDA for user based on their conditions
async function getAdjustedRDA(userId) {
  const result = await db.query(
    `
    SELECT 
      n.nutrient_id,
      n.name as nutrient_name,
      n.nutrient_code,
      n.unit,
      COALESCE(SUM(cne.adjustment_percent), 0) as total_adjustment
    FROM UserHealthCondition uhc
    JOIN ConditionNutrientEffect cne ON uhc.condition_id = cne.condition_id
    JOIN Nutrient n ON cne.nutrient_id = n.nutrient_id
    WHERE uhc.user_id = $1 AND uhc.status = 'active'
    GROUP BY n.nutrient_id, n.name, n.nutrient_code, n.unit
  `,
    [userId]
  );

  return result.rows;
}

// Get restricted foods for user
async function getRestrictedFoods(userId) {
  const result = await db.query(
    `
    SELECT DISTINCT 
      f.food_id, 
      f.name as food_name,
      cfr.notes, 
      hc.name_vi as condition_name
    FROM UserHealthCondition uhc
    JOIN ConditionFoodRecommendation cfr ON uhc.condition_id = cfr.condition_id
    JOIN Food f ON cfr.food_id = f.food_id
    JOIN HealthCondition hc ON uhc.condition_id = hc.condition_id
    WHERE uhc.user_id = $1 
      AND uhc.status = 'active'
      AND cfr.recommendation_type = 'avoid'
  `,
    [userId]
  );

  return result.rows;
}

async function extendTreatment(userId, userConditionId, newEndDate) {
  const result = await db.query(
    `
    UPDATE UserHealthCondition
    SET treatment_end_date = $1
    WHERE user_condition_id = $2 AND user_id = $3
    RETURNING *
  `,
    [newEndDate, userConditionId, userId]
  );

  return result.rows[0];
}

async function markRecovered(userId, userConditionId) {
  const { getVietnamDate } = require('../utils/dateHelper');
  const result = await db.query(
    `
    UPDATE UserHealthCondition
    SET status = 'recovered', 
        treatment_end_date = $3
    WHERE user_condition_id = $1 AND user_id = $2
    RETURNING *
  `,
    [userConditionId, userId, getVietnamDate()]
  );

  return result.rows[0];
}

module.exports = {
  getAllConditions,
  getConditionById,
  createCondition,
  updateCondition,
  deleteCondition,
  addNutrientEffect,
  addFoodRestriction,
  getUserConditions,
  addUserCondition,
  updateUserConditionStatus,
  getAdjustedRDA,
  getRestrictedFoods,
  extendTreatment,
  markRecovered,
};
