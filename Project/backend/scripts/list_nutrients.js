const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
});

async function listNutrients() {
  try {
    const r = await pool.query('SELECT nutrient_id, name, name_vi FROM nutrient ORDER BY nutrient_id');
    console.log('Nutrients in database:');
    r.rows.forEach(n => {
      console.log(`  ${n.nutrient_id}: ${n.name || 'N/A'} | ${n.name_vi || 'N/A'}`);
    });
    console.log(`\nTotal: ${r.rows.length} nutrients`);
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

listNutrients();
