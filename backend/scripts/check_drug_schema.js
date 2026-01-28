require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

async function checkDrugSchema() {
  const client = await pool.connect();
  
  try {
    console.log('📋 DRUG TABLE COLUMNS:');
    const columns = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'drug'
      ORDER BY ordinal_position
    `);
    console.table(columns.rows);

    console.log('\n📊 SAMPLE DRUG DATA:');
    const sample = await client.query('SELECT * FROM drug LIMIT 2');
    console.log('Sample drugs:', sample.rows.length);
    if (sample.rows.length > 0) {
      console.log('Columns:', Object.keys(sample.rows[0]).join(', '));
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    client.release();
    await pool.end();
    process.exit(0);
  }
}

checkDrugSchema();
