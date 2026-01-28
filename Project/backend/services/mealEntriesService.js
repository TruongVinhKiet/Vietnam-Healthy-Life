const db = require('../db');

async function computeNutrientsForFood(foodId, weight) {
  // weight in grams
  const q = `SELECT n.nutrient_code, fn.amount_per_100g FROM FoodNutrient fn JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id WHERE fn.food_id = $1`;
  const res = await db.query(q, [foodId]);
  const map = {};
  for (const r of res.rows) {
    if (r.nutrient_code) map[r.nutrient_code] = Number(r.amount_per_100g || 0);
  }

  const kcalPer100 = map['ENERC_KCAL'] || 0;
  const proteinPer100 = map['PROCNT'] || 0;
  const fatPer100 = map['FAT'] || 0;
  const carbPer100 = map['CHOCDF'] || 0;

  const factor = Number(weight || 0) / 100.0;
  return {
    kcal: Math.round(kcalPer100 * factor * 100) / 100,
    protein: Math.round(proteinPer100 * factor * 100) / 100,
    fat: Math.round(fatPer100 * factor * 100) / 100,
    carbs: Math.round(carbPer100 * factor * 100) / 100,
  };
}

async function createMealEntry(userId, entryDate, mealType, foodId, weightG) {
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');

    // compute nutrients
    const nut = await computeNutrientsForFood(foodId, weightG);

    const insertQ = `INSERT INTO meal_entries (user_id, entry_date, meal_type, food_id, weight_g, kcal, carbs, protein, fat, created_at) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9, now()) RETURNING id`;
    const params = [userId, entryDate, mealType, foodId, weightG, nut.kcal, nut.carbs, nut.protein, nut.fat];
    const r = await client.query(insertQ, params);
    const entryId = r.rows[0].id;

    // upsert summary row: add consumed macros
    const upsertQ = `INSERT INTO user_meal_summaries (user_id, summary_date, meal_type, consumed_kcal, consumed_carbs, consumed_protein, consumed_fat, updated_at)
      VALUES ($1,$2,$3,$4,$5,$6,$7, now())
      ON CONFLICT (user_id, summary_date, meal_type) DO UPDATE SET
        consumed_kcal = user_meal_summaries.consumed_kcal + EXCLUDED.consumed_kcal,
        consumed_carbs = user_meal_summaries.consumed_carbs + EXCLUDED.consumed_carbs,
        consumed_protein = user_meal_summaries.consumed_protein + EXCLUDED.consumed_protein,
        consumed_fat = user_meal_summaries.consumed_fat + EXCLUDED.consumed_fat,
        updated_at = now()`;
    const upParams = [userId, entryDate, mealType, nut.kcal, nut.carbs, nut.protein, nut.fat];
    await client.query(upsertQ, upParams);

    await client.query('COMMIT');
    return { entryId, nutrients: nut };
  } catch (err) {
    await client.query('ROLLBACK').catch(()=>{});
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { createMealEntry };
