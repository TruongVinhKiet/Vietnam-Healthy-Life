const { Pool } = require('pg');

new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Health',
  password: 'Kiet2004',
  port: 5432,
}).query(`
  SELECT condition_id, condition_name 
  FROM healthcondition 
  WHERE condition_id IN (1, 5, 20)
`).then(r => {
  console.log('Health conditions:');
  r.rows.forEach(c => console.log(`ID ${c.condition_id}: ${c.condition_name || 'NULL'}`));
  process.exit();
});
