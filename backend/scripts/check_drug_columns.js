require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

pool.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'drug' ORDER BY ordinal_position")
  .then(r => {
    console.log('Drug table columns:', r.rows.map(x => x.column_name).join(', '));
    return pool.end();
  })
  .catch(e => {
    console.error(e);
    pool.end();
  });
