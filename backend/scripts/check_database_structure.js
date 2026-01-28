require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

async function checkTables() {
  const client = await pool.connect();
  
  try {
    console.log('='.repeat(80));
    console.log('CHECKING DATABASE STRUCTURE');
    console.log('='.repeat(80));

    // Check food table structure
    console.log('\n📋 FOOD TABLE COLUMNS:');
    const foodColumns = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'food'
      ORDER BY ordinal_position
    `);
    console.table(foodColumns.rows);

    // Check conditionfoodrecommendation table
    console.log('\n📋 CONDITIONFOODRECOMMENDATION TABLE COLUMNS:');
    const cfrColumns = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'conditionfoodrecommendation'
      ORDER BY ordinal_position
    `);
    console.table(cfrColumns.rows);

    // Check nutrient table
    console.log('\n📋 NUTRIENT TABLE COLUMNS:');
    const nutrientColumns = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'nutrient'
      ORDER BY ordinal_position
    `);
    console.table(nutrientColumns.rows);

    // Check nutrienteffect table
    console.log('\n📋 NUTRIENTEFFECT TABLE COLUMNS:');
    const neColumns = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'nutrienteffect'
      ORDER BY ordinal_position
    `);
    console.table(neColumns.rows);

    // Sample data check
    console.log('\n📊 SAMPLE DATA FROM CONDITIONFOODRECOMMENDATION:');
    const sampleData = await client.query(`
      SELECT cfr.*, f.* 
      FROM conditionfoodrecommendation cfr
      LEFT JOIN food f ON cfr.food_id = f.food_id
      LIMIT 3
    `);
    console.log('Total recommendations:', sampleData.rows.length);
    if (sampleData.rows.length > 0) {
      console.log('First row keys:', Object.keys(sampleData.rows[0]).join(', '));
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    client.release();
    await pool.end();
    process.exit(0);
  }
}

checkTables();
