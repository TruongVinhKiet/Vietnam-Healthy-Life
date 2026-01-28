const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
});

async function checkDishSchema() {
  try {
    // Check dish table columns
    const columns = await pool.query(`
      SELECT column_name, data_type, column_default
      FROM information_schema.columns 
      WHERE table_name='dish'
      ORDER BY ordinal_position
    `);
    
    console.log('dish table columns:');
    columns.rows.forEach(c => {
      console.log(`  ${c.column_name}: ${c.data_type} (default: ${c.column_default || 'none'})`);
    });

    // Check constraints
    const constraints = await pool.query(`
      SELECT constraint_name, check_clause
      FROM information_schema.check_constraints
      WHERE constraint_name LIKE '%dish%'
    `);
    
    console.log('\ndish constraints:');
    constraints.rows.forEach(c => {
      console.log(`  ${c.constraint_name}: ${c.check_clause}`);
    });

  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkDishSchema();
