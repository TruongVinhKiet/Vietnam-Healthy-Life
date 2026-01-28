require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE
});

async function checkDrugs() {
  try {
    const result = await pool.query(`
      SELECT drug_id, name_vi, name_en, generic_name, drug_class 
      FROM drug 
      ORDER BY drug_id
    `);
    
    console.log('=== DANH SÁCH THUỐC HIỆN CÓ ===\n');
    result.rows.forEach(r => {
      console.log(`${r.drug_id}. ${r.name_vi} (${r.name_en || 'N/A'})`);
      console.log(`   Generic: ${r.generic_name || 'N/A'}`);
      console.log(`   Class: ${r.drug_class || 'N/A'}\n`);
    });
    
    console.log(`Tổng: ${result.rows.length} thuốc`);
  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    await pool.end();
  }
}

checkDrugs();
