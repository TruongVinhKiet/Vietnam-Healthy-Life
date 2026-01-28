require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'Health',
});

async function checkTables() {
  try {
    console.log('\n=== HEALTHCONDITION TABLE ===');
    const hcColumns = await pool.query(`
      SELECT column_name, data_type, character_maximum_length, is_nullable 
      FROM information_schema.columns 
      WHERE table_name = 'healthcondition' 
      ORDER BY ordinal_position
    `);
    console.log(JSON.stringify(hcColumns.rows, null, 2));

    console.log('\n=== HEALTHCONDITION DATA COUNT ===');
    const hcCount = await pool.query('SELECT COUNT(*) FROM HealthCondition');
    console.log('Total conditions:', hcCount.rows[0].count);

    console.log('\n=== HEALTHCONDITION SAMPLE DATA ===');
    const hcData = await pool.query('SELECT condition_id, name_vi, name_en, category, image_url FROM HealthCondition LIMIT 5');
    console.log(JSON.stringify(hcData.rows, null, 2));

    console.log('\n=== CONDITIONFOODRECOMMENDATION TABLE ===');
    const cfrColumns = await pool.query(`
      SELECT column_name, data_type, is_nullable 
      FROM information_schema.columns 
      WHERE table_name = 'conditionfoodrecommendation' 
      ORDER BY ordinal_position
    `);
    console.log(JSON.stringify(cfrColumns.rows, null, 2));

    console.log('\n=== CONDITIONFOODRECOMMENDATION DATA COUNT ===');
    const cfrCount = await pool.query('SELECT COUNT(*) FROM ConditionFoodRecommendation');
    console.log('Total recommendations:', cfrCount.rows[0].count);

    console.log('\n=== DRUGHEALTHCONDITION TABLE ===');
    const dhcColumns = await pool.query(`
      SELECT column_name, data_type, is_nullable 
      FROM information_schema.columns 
      WHERE table_name = 'drughealthcondition' 
      ORDER BY ordinal_position
    `);
    console.log(JSON.stringify(dhcColumns.rows, null, 2));

    console.log('\n=== DRUGHEALTHCONDITION DATA COUNT ===');
    const dhcCount = await pool.query('SELECT COUNT(*) FROM DrugHealthCondition');
    console.log('Total drug treatments:', dhcCount.rows[0].count);

  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkTables();
