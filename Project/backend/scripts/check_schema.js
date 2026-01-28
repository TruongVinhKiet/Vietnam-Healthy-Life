const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
});

async function checkSchema() {
  try {
    const dishCols = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name='dishingredient'
      ORDER BY ordinal_position
    `);
    console.log('dishingredient columns:');
    dishCols.rows.forEach(c => console.log(`  ${c.column_name}: ${c.data_type}`));

    const drugCols = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name='drug'
      ORDER BY ordinal_position
    `);
    console.log('\ndrug columns:');
    drugCols.rows.forEach(c => console.log(`  ${c.column_name}: ${c.data_type}`));

    const hcCols = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name='healthcondition'
      ORDER BY ordinal_position
    `);
    console.log('\nhealthcondition columns:');
    hcCols.rows.forEach(c => console.log(`  ${c.column_name}: ${c.data_type}`));

    const dncCols = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name='drugnutrientcontraindication'
      ORDER BY ordinal_position
    `);
    console.log('\ndrugnutrientcontraindication columns:');
    dncCols.rows.forEach(c => console.log(`  ${c.column_name}: ${c.data_type}`));
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkSchema();
