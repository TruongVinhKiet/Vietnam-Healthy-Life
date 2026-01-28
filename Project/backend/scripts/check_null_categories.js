const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Health',
  password: 'Kiet2004',
  port: 5432,
});

async function checkNullCategories() {
  try {
    // Find foods with NULL or empty category
    const result = await pool.query(`
      SELECT food_id, name, name_vi, category 
      FROM food 
      WHERE category IS NULL OR category = '' 
      ORDER BY food_id
    `);

    console.log(`\nFound ${result.rowCount} foods with NULL/empty category:\n`);
    result.rows.forEach(food => {
      console.log(`- ID ${food.food_id}: ${food.name_vi || food.name} (category: "${food.category}")`);
    });

  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkNullCategories();
