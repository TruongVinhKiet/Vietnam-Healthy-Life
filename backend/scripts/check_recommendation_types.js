const { Pool } = require('pg');

new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
}).query(`SELECT DISTINCT recommendation_type FROM conditionfoodrecommendation`)
  .then(r => {
    console.log('Existing recommendation_type values:');
    r.rows.forEach(t => console.log(`- "${t.recommendation_type}"`));
    process.exit(0);
  })
  .catch(e => {
    console.error(e);
    process.exit(1);
  });
