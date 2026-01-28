const { Pool } = require('pg');

new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
}).query(`SELECT column_name FROM information_schema.columns WHERE table_name='healthcondition'`)
  .then(r => {
    console.log('healthcondition table columns:');
    r.rows.forEach(c => console.log(`- ${c.column_name}`));
    process.exit(0);
  })
  .catch(e => {
    console.error(e);
    process.exit(1);
  });
