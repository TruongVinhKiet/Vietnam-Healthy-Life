const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

async function getAllConditions() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_DATABASE || 'Health',
  });

  const client = await pool.connect();

  try {
    const conditions = await client.query(`
      SELECT condition_id, name_vi, name_en, category 
      FROM healthcondition 
      ORDER BY condition_id
    `);
    
    console.log('='.repeat(80));
    console.log('TẤT CẢ 39 BỆNH TRONG HỆ THỐNG:\n');
    
    conditions.rows.forEach(c => {
      console.log(`[${c.condition_id}] ${c.name_vi}`);
      if (c.name_en && c.name_en !== c.name_vi) {
        console.log(`    EN: ${c.name_en}`);
      }
      if (c.category) {
        console.log(`    Category: ${c.category}`);
      }
      console.log();
    });
    
    console.log('='.repeat(80));
    console.log(`\nTổng: ${conditions.rows.length} bệnh cần food recommendations`);

  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    client.release();
    await pool.end();
  }
}

getAllConditions();
