const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
});

async function checkSchema() {
  const client = await pool.connect();
  try {
    const result = await client.query(`
      SELECT column_name, data_type, column_default
      FROM information_schema.columns
      WHERE table_name = 'food'
      ORDER BY ordinal_position
    `);
    
    console.log('Food table structure:');
    result.rows.forEach(col => {
      console.log(`- ${col.column_name}: ${col.data_type} ${col.column_default ? `(default: ${col.column_default})` : ''}`);
    });

    const dishResult = await client.query(`
      SELECT column_name, data_type, column_default
      FROM information_schema.columns
      WHERE table_name = 'dish'
      ORDER BY ordinal_position
    `);
    
    console.log('\nDish table structure:');
    dishResult.rows.forEach(col => {
      console.log(`- ${col.column_name}: ${col.data_type} ${col.column_default ? `(default: ${col.column_default})` : ''}`);
    });

  } finally {
    client.release();
    await pool.end();
  }
}

checkSchema().catch(console.error);
