const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
});

async function checkNullFoods() {
  try {
    // Find foods with null name_vi in recommendations
    const nullFoods = await pool.query(`
      SELECT DISTINCT f.food_id, f.name, f.name_vi, f.category
      FROM food f
      JOIN conditionfoodrecommendation cfr ON f.food_id = cfr.food_id
      WHERE f.name_vi IS NULL
      ORDER BY f.food_id
    `);

    console.log(`Foods with NULL name_vi in recommendations (${nullFoods.rows.length}):\n`);
    nullFoods.rows.forEach(f => {
      console.log(`  ID ${f.food_id}: ${f.name} (${f.category || 'no category'})`);
    });

    // Also check all foods with null name_vi
    const allNull = await pool.query(`
      SELECT food_id, name, category
      FROM food
      WHERE name_vi IS NULL
      ORDER BY food_id
      LIMIT 50
    `);

    console.log(`\n\nAll foods with NULL name_vi (showing first 50 of ${allNull.rows.length}):\n`);
    allNull.rows.forEach(f => {
      console.log(`  ${f.food_id}: ${f.name} | ${f.category || 'N/A'}`);
    });

  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkNullFoods();
