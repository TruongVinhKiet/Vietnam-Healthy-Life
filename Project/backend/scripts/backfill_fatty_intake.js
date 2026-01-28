// Backfill script: aggregate historical MealItem -> UserFattyAcidIntake using NutrientMapping and helper upsert
// Usage: set DB env vars (DB_HOST, DB_USER, DB_PASSWORD, DB_NAME) then run:
// node backfill_fatty_intake.js

const db = require('../db');

async function main() {
  console.log('Starting fatty intake backfill. This will process MealItem rows and call the DB helper upsert function.');
  try {
    // iterate distinct meal items with food_id and weight
    const res = await db.query(`SELECT mi.meal_item_id, m.user_id, m.meal_date::date AS date, mi.food_id, mi.weight_g
                                 FROM MealItem mi JOIN Meal m ON m.meal_id = mi.meal_id
                                 WHERE mi.food_id IS NOT NULL`);
    console.log('Found', res.rows.length, 'meal items to process');
    let count = 0;
    for (const r of res.rows) {
      const userId = r.user_id;
      const date = r.date;
      const foodId = r.food_id;
      const weightG = Number(r.weight_g) || 0;
      if (!foodId || !userId) continue;
      // For each nutrient mapping for this food, compute amount and upsert
      const fn = await db.query('SELECT fn.amount_per_100g, nm.fatty_acid_id, COALESCE(nm.factor,1.0) as factor FROM FoodNutrient fn JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id WHERE fn.food_id = $1', [foodId]);
      for (const n of fn.rows) {
        if (!n.fatty_acid_id) continue;
        const amountPer100 = Number(n.amount_per_100g) || 0;
        const factor = Number(n.factor) || 1.0;
        const amount = amountPer100 * factor * (weightG / 100.0);
        // call DB helper to upsert (aggregates per day)
        await db.query('SELECT upsert_user_fatty_intake_specific($1, $2, $3, $4)', [userId, date, n.fatty_acid_id, amount]);
      }
      count++;
      if (count % 100 === 0) console.log('Processed', count);
    }
    console.log('Backfill completed, processed', count, 'items');
    process.exit(0);
  } catch (e) {
    console.error('Backfill error', e && e.message);
    process.exit(1);
  }
}

main();
