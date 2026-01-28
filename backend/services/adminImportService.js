const db = require('../db');

/**
 * Bulk import foods and associated nutrients.
 * Expected payload: [{ name, category, nutrients: [{ nutrient_code, name (optional), unit (optional), amount_per_100g }] }]
 */
async function bulkImportFoods(payload = []) {
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    for (const food of payload) {
      const { name, category, nutrients } = food;
      if (!name) continue;
      // create or get food
      const fRes = await client.query('INSERT INTO Food(name, category) VALUES($1,$2) ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name RETURNING food_id', [name, category || null]);
      const foodId = fRes.rows[0].food_id;
      if (Array.isArray(nutrients)) {
        for (const n of nutrients) {
          const code = n.nutrient_code || null;
          const nname = n.name || code || 'unknown';
          const unit = n.unit || 'g';
          // upsert nutrient
          let nutRes;
          if (code) {
            nutRes = await client.query('INSERT INTO Nutrient(name, nutrient_code, unit) VALUES($1,$2,$3) ON CONFLICT (nutrient_code) DO UPDATE SET name = EXCLUDED.name RETURNING nutrient_id', [nname, code, unit]);
          } else {
            nutRes = await client.query('INSERT INTO Nutrient(name, unit) VALUES($1,$2) RETURNING nutrient_id', [nname, unit]);
          }
          const nutrientId = nutRes.rows[0].nutrient_id;
          // upsert food nutrient
          await client.query('INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g) VALUES($1,$2,$3) ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g', [foodId, nutrientId, Number(n.amount_per_100g) || 0]);
        }
      }
    }
    await client.query('COMMIT');
    return { success: true };
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {});
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { bulkImportFoods };
