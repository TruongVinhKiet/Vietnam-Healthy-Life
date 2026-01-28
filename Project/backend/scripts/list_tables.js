const { Pool } = require('pg');

new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
}).query(`SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE' ORDER BY table_name`)
  .then(r => {
    console.log('Tables in database:');
    r.rows.forEach(t => console.log(`- ${t.table_name}`));
    process.exit(0);
  })
  .catch(e => {
    console.error(e);
    process.exit(1);
  });
