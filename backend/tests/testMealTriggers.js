const db = require('../db');

async function run() {
  console.log('Running MealItem trigger integration test via JS runner...');
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');

    // Create nutrient definitions if not exist with codes
    await client.query("INSERT INTO Nutrient(name, nutrient_code, unit) SELECT 'Energy','ENERC_KCAL','kcal' WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE nutrient_code='ENERC_KCAL')");
    await client.query("INSERT INTO Nutrient(name, nutrient_code, unit) SELECT 'Protein','PROCNT','g' WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE nutrient_code='PROCNT')");
    await client.query("INSERT INTO Nutrient(name, nutrient_code, unit) SELECT 'Fat','FAT','g' WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE nutrient_code='FAT')");
    await client.query("INSERT INTO Nutrient(name, nutrient_code, unit) SELECT 'Carbohydrate','CHOCDF','g' WHERE NOT EXISTS (SELECT 1 FROM Nutrient WHERE nutrient_code='CHOCDF')");

    // Create food
    const foodRes = await client.query("INSERT INTO Food(name, category) VALUES('TEST_Rice_JS','grain') RETURNING food_id");
    const foodId = foodRes.rows[0].food_id;

    // Add FoodNutrient rows
    // 130 kcal/100g, 2.7g protein/100g, 0.3g fat/100g, 28g carbs/100g
    const qNutr = `INSERT INTO FoodNutrient(food_id, nutrient_id, amount_per_100g)
      SELECT $1, n.nutrient_id, $2 FROM Nutrient n WHERE n.nutrient_code = $3 RETURNING food_nutrient_id`;
    await client.query(qNutr, [foodId, 130.0, 'ENERC_KCAL']);
    await client.query(qNutr, [foodId, 2.7, 'PROCNT']);
    await client.query(qNutr, [foodId, 0.3, 'FAT']);
    await client.query(qNutr, [foodId, 28.0, 'CHOCDF']);

    // Ensure test user exists (id=1) or create one
    let userId = 1;
    const userCheck = await client.query('SELECT user_id FROM "User" WHERE user_id = $1', [userId]);
    if (userCheck.rows.length === 0) {
      const ures = await client.query("INSERT INTO \"User\"(full_name,email,password_hash,age,gender,height_cm,weight_kg) VALUES('JS Test','jstest@example.com','x',30,'male',170,70) RETURNING user_id");
      userId = ures.rows[0].user_id;
    }

    // Create meal
    const mealRes = await client.query('INSERT INTO Meal(user_id, meal_type, meal_date) VALUES($1,$2,CURRENT_DATE) RETURNING meal_id', [userId, 'lunch']);
    const mealId = mealRes.rows[0].meal_id;

    // Insert MealItem weight 150g
    await client.query('INSERT INTO MealItem(meal_id, food_id, weight_g) VALUES($1,$2,$3)', [mealId, foodId, 150.0]);

    // Read computed MealItem
    const mi = await client.query('SELECT calories, protein, fat, carbs FROM MealItem WHERE meal_id = $1 LIMIT 1', [mealId]);
    const row = mi.rows[0];
    console.log('Computed MealItem row:', row);

    // Expected
    const expected = { calories: 195.0, protein: 4.05, fat: 0.45, carbs: 42.0 };
    const eps = 0.01;
    if (Math.abs(Number(row.calories) - expected.calories) > eps) throw new Error(`Calories mismatch: expected ${expected.calories} got ${row.calories}`);
    if (Math.abs(Number(row.protein) - expected.protein) > eps) throw new Error(`Protein mismatch: expected ${expected.protein} got ${row.protein}`);
    if (Math.abs(Number(row.fat) - expected.fat) > eps) throw new Error(`Fat mismatch: expected ${expected.fat} got ${row.fat}`);
    if (Math.abs(Number(row.carbs) - expected.carbs) > eps) throw new Error(`Carbs mismatch: expected ${expected.carbs} got ${row.carbs}`);

    // Check DailySummary
    const ds = await client.query('SELECT total_calories, total_protein, total_fat, total_carbs FROM DailySummary WHERE user_id = $1 AND date = CURRENT_DATE LIMIT 1', [userId]);
    if (ds.rows.length === 0) throw new Error('DailySummary not found');
    const s = ds.rows[0];
    if (Math.abs(Number(s.total_calories) - expected.calories) > eps) throw new Error(`Daily calories mismatch: expected ${expected.calories} got ${s.total_calories}`);

    console.log('All assertions passed');

    await client.query('ROLLBACK');
    console.log('Rolled back test changes (clean)');
    process.exit(0);
  } catch (err) {
    try { await client.query('ROLLBACK'); } catch(e){}
    console.error('TEST FAILED:', err.message || err);
    process.exit(2);
  } finally {
    client.release();
  }
}

run();
