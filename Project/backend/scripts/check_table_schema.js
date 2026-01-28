const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
});

async function checkSchema() {
  const client = await pool.connect();
  
  try {
    // Check Food table columns
    const foodCols = await client.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'food' 
      ORDER BY ordinal_position;
    `);
    
    console.log('Food table columns:');
    console.table(foodCols.rows);

    // Check related tables
    const tables = ['mealitem', 'foodnutrient', 'dishingredient', 'conditionfoodrecommendation', 'drugnutrientcontraindication'];
    
    for (const table of tables) {
      const cols = await client.query(`
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = $1
        ORDER BY ordinal_position;
      `, [table]);
      
      console.log(`\n${table} columns:`);
      console.table(cols.rows);
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

checkSchema();
