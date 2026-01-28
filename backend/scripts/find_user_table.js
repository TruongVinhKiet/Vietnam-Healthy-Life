const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Health',
  password: 'Kiet2004',
  port: 5432,
});

async function findUserTable() {
  const result = await pool.query(`
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
      AND (table_name LIKE '%user%' OR table_name LIKE '%account%')
    ORDER BY table_name
  `);
  
  console.log('User-related tables:');
  result.rows.forEach(t => console.log('- ' + t.table_name));
  
  // Get userprofile columns
  const cols = await pool.query(`
    SELECT column_name 
    FROM information_schema.columns 
    WHERE table_name = 'userprofile'
    ORDER BY ordinal_position
  `);
  
  console.log('\nUserprofile columns:');
  cols.rows.forEach(c => console.log('- ' + c.column_name));
  
  await pool.end();
}

findUserTable();
