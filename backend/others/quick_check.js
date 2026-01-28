const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function quickCheck() {
  const client = await pool.connect();
  
  try {
    // Get Food table columns
    console.log('FOOD TABLE COLUMNS:');
    const foodCols = await client.query(`
      SELECT column_name FROM information_schema.columns 
      WHERE table_name='food' ORDER BY ordinal_position
    `);
    console.table(foodCols.rows);
    
    // Get ingredients with proper column names
    console.log('\nINGREDIENTS FOR DISH #47:');
    const ingredients = await client.query(`
      SELECT di.*, f.name as food_name
      FROM dishingredient di
      LEFT JOIN food f ON di.food_id = f.food_id
      WHERE di.dish_id = 47;
    `);
    console.table(ingredients.rows);
    
    // Check nutrients for each food
    console.log('\nNUTRIENT COUNTS:');
    for (const ing of ingredients.rows) {
      const count = await client.query(`
        SELECT COUNT(*) as count FROM foodnutrient WHERE food_id = $1
      `, [ing.food_id]);
      console.log(`${ing.food_name} (food_id ${ing.food_id}): ${count.rows[0].count} nutrients`);
    }
    
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

quickCheck();
