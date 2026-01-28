require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

async function check() {
  const client = await pool.connect();
  
  try {
    // Check conditionfoodrecommendation columns
    const cfr = await client.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'conditionfoodrecommendation' 
      AND column_name LIKE '%notes%'
    `);
    console.log('📋 conditionfoodrecommendation notes columns:', cfr.rows.map(r => r.column_name));

    // Check drughealthcondition columns
    const dhc = await client.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'drughealthcondition' 
      AND column_name LIKE '%notes%'
    `);
    console.log('📋 drughealthcondition notes columns:', dhc.rows.map(r => r.column_name));

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    client.release();
    await pool.end();
    process.exit(0);
  }
}

check();
