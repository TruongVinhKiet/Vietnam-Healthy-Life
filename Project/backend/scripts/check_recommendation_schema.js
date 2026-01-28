const { Pool } = require('pg');

new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
}).query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_name='conditionfoodrecommendation' ORDER BY ordinal_position`)
  .then(r => {
    console.log('conditionfoodrecommendation table structure:');
    r.rows.forEach(c => console.log(`- ${c.column_name}: ${c.data_type}`));
    process.exit(0);
  })
  .catch(e => {
    console.error(e);
    process.exit(1);
  });
