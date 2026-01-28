const { Pool } = require('pg');

new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Health',
  password: 'Kiet2004',
  port: 5432,
}).query(`
  SELECT column_name 
  FROM information_schema.columns 
  WHERE table_name = 'userhealthcondition'
  ORDER BY ordinal_position
`).then(r => {
  console.log('userhealthcondition columns:');
  r.rows.forEach(c => console.log('- ' + c.column_name));
  process.exit();
});
