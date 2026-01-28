/* Quick helper to print Nutrient group_name counts */
require('dotenv').config();
const { Pool } = require('pg');

(async () => {
  const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined,
    user: process.env.DB_USER != null ? String(process.env.DB_USER) : undefined,
    password: process.env.DB_PASSWORD != null ? String(process.env.DB_PASSWORD) : undefined,
    database: process.env.DB_NAME || process.env.DB_DATABASE,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
  });
  try {
    const { rows } = await pool.query(
      'select group_name, count(*) as count from Nutrient where group_name is not null group by group_name order by 1'
    );
    console.table(rows);
  } catch (e) {
    console.error(e);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
})();
