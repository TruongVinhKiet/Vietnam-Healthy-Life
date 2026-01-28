const db = require('../db');

async function createMealWithItems(userId, mealType, mealDate, items = []) {
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    const mealRes = await client.query(
      `INSERT INTO Meal(user_id, meal_type, meal_date) VALUES ($1,$2,$3) RETURNING meal_id`,
      [userId, mealType || null, mealDate || new Date()]
    );
    const mealId = mealRes.rows[0].meal_id;

    // Insert items; triggers on MealItem will compute calories/protein/fat/carbs
    for (const it of items) {
      const foodId = it.food_id || null;
      const weight = Number(it.weight_g) || 0;
      if (!foodId || weight <= 0) continue; // skip invalid
      await client.query(`INSERT INTO MealItem(meal_id, food_id, weight_g) VALUES ($1,$2,$3)`, [mealId, foodId, weight]);
    }

    // get daily summary for the meal_date (calories/protein/fat/carbs)
    const ds = await client.query(`SELECT total_calories, total_protein, total_fat, total_carbs FROM DailySummary WHERE user_id = $1 AND date = $2 LIMIT 1`, [userId, mealDate]);
    let summary = ds.rows[0];
    if (!summary) {
      // compute from Meal/MealItem join as fallback
      const agg = await client.query(`SELECT COALESCE(SUM(mi.calories),0) AS total_calories, COALESCE(SUM(mi.protein),0) AS total_protein, COALESCE(SUM(mi.fat),0) AS total_fat, COALESCE(SUM(mi.carbs),0) AS total_carbs FROM Meal m JOIN MealItem mi ON mi.meal_id = m.meal_id WHERE m.user_id = $1 AND m.meal_date = $2`, [userId, mealDate]);
      summary = agg.rows[0];
    }

    // fetch fiber total from UserFiberIntake (prefer aggregated intake table populated by triggers)
    let totalFiber = 0;
    try {
      const rf = await client.query(`SELECT COALESCE(SUM(amount),0) AS total_fiber FROM UserFiberIntake WHERE user_id = $1 AND date = $2`, [userId, mealDate]);
      totalFiber = Number((rf.rows[0] && rf.rows[0].total_fiber) ? rf.rows[0].total_fiber : 0);
    } catch (e) {
      // ignore errors; default to 0
      totalFiber = 0;
    }

    // fetch fatty acid total (TOTAL_FAT) if available
    let totalFatty = 0;
    try {
      const rf2 = await client.query(`SELECT fa.fatty_acid_id FROM FattyAcid fa WHERE fa.code = 'TOTAL_FAT' LIMIT 1`);
      if (rf2.rows.length > 0) {
        const faId = rf2.rows[0].fatty_acid_id;
        const rf3 = await client.query(`SELECT COALESCE(SUM(amount),0) AS total_fatty FROM UserFattyAcidIntake WHERE user_id = $1 AND date = $2 AND fatty_acid_id = $3`, [userId, mealDate, faId]);
        totalFatty = Number((rf3.rows[0] && rf3.rows[0].total_fatty) ? rf3.rows[0].total_fatty : 0);
      }
    } catch (e) {
      totalFatty = 0;
    }

    await client.query('COMMIT');
    
    // Update UserNutrientTracking after successful meal creation
    try {
      await updateNutrientTracking(userId, mealDate);
    } catch (trackingErr) {
      console.error('Error updating nutrient tracking:', trackingErr);
      // Don't fail the meal creation if tracking update fails
    }
    
    return { meal_id: mealId, today: { today_calories: Number(summary.total_calories || 0), today_protein: Number(summary.total_protein || 0), today_fat: Number(summary.total_fat || 0), today_carbs: Number(summary.total_carbs || 0), total_fiber: totalFiber, total_fatty: totalFatty } };
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {});
    throw err;
  } finally {
    client.release();
  }
}

/**
 * Update UserNutrientTracking table for a specific user and date
 * This syncs the tracking table with actual meal intake
 */
async function updateNutrientTracking(userId, date) {
  try {
    // Get all nutrients from calculate_daily_nutrient_intake function
    const nutrients = await db.query(
      'SELECT * FROM calculate_daily_nutrient_intake($1, $2)',
      [userId, date]
    );
    
    // Upsert into UserNutrientTracking
    for (const nutrient of nutrients.rows) {
      await db.query(`
        INSERT INTO UserNutrientTracking (
          user_id, date, nutrient_type, nutrient_id, 
          target_amount, current_amount, unit, last_updated
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
        ON CONFLICT (user_id, date, nutrient_type, nutrient_id) 
        DO UPDATE SET 
          current_amount = EXCLUDED.current_amount,
          target_amount = EXCLUDED.target_amount,
          last_updated = NOW()
      `, [
        userId, 
        date, 
        nutrient.nutrient_type,
        nutrient.nutrient_id,
        nutrient.target_amount,
        nutrient.current_amount,
        nutrient.unit
      ]);
    }
    
    console.log(`[NutrientTracking] Updated ${nutrients.rows.length} nutrients for user ${userId} on ${date}`);
  } catch (error) {
    console.error('Error in updateNutrientTracking:', error);
    throw error;
  }
}

module.exports = { createMealWithItems, updateNutrientTracking };
