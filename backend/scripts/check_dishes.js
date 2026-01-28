const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
});

async function checkDishes() {
  try {
    // Check recent dishes
    const dishResult = await pool.query(
      'SELECT dish_id, name FROM dish ORDER BY dish_id DESC LIMIT 30'
    );
    
    console.log(`\n📋 Recent dishes (${dishResult.rows.length}):`);
    dishResult.rows.forEach(d => {
      console.log(`  ${d.dish_id}: ${d.name}`);
    });

    // Check if any dishes have ingredients
    const ingredientResult = await pool.query(
      'SELECT COUNT(*) FROM dishingredient'
    );
    console.log(`\n🍲 Total dishingredient entries: ${ingredientResult.rows[0].count}`);

    // Check sample dish with ingredients
    const sampleDish = await pool.query(`
      SELECT d.dish_id, d.name, di.food_id, f.name_vi as food_name, di.quantity_grams
      FROM dish d
      LEFT JOIN dishingredient di ON d.dish_id = di.dish_id
      LEFT JOIN food f ON di.food_id = f.food_id
      WHERE d.dish_id IN (SELECT dish_id FROM dish ORDER BY dish_id DESC LIMIT 5)
      ORDER BY d.dish_id, di.food_id
      LIMIT 20
    `);

    console.log(`\n🔍 Sample dish ingredients:`);
    sampleDish.rows.forEach(r => {
      console.log(`  ${r.dish_id} ${r.name}: ${r.food_name || '(no ingredients)'} - ${r.quantity_grams || 0}g`);
    });

  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkDishes();
