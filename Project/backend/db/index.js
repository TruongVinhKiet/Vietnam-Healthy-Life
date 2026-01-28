require('dotenv').config();
const { Pool } = require('pg');

// Debug: print the type of DB_PASSWORD to help diagnose SASL auth errors
const _rawDbPassword = process.env.DB_PASSWORD;
try {
  const preview = _rawDbPassword === undefined ? '<undefined>' : String(_rawDbPassword).replace(/.(?=.{2})/g, '*');
  console.log('DBG: DB_PASSWORD type=', typeof _rawDbPassword, ' preview=', preview);
} catch (e) {
  console.log('DBG: Error previewing DB_PASSWORD', e && e.message);
}

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
  max: parseInt(process.env.DB_MAX || '10', 10),
  idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT || '30000', 10),
  connectionTimeoutMillis: parseInt(process.env.DB_CONN_TIMEOUT || '2000', 10),
});

pool.on('error', (err) => {
  console.error('Unexpected idle client error', err);
  process.exit(-1);
});

// Ensure certain schema columns exist (graceful if migrations not yet applied).
(async function ensureSchemaColumns() {
  try {
    // DailySummary.total_carbs used by /auth/me
    await pool.query("ALTER TABLE DailySummary ADD COLUMN IF NOT EXISTS total_carbs NUMERIC(10,2) DEFAULT 0");
    await pool.query("ALTER TABLE DailySummary ADD COLUMN IF NOT EXISTS total_water NUMERIC(10,2) DEFAULT 0");
    await pool.query("ALTER TABLE DailySummary ADD COLUMN IF NOT EXISTS total_fiber NUMERIC(10,2) DEFAULT 0");
    await pool.query("CREATE UNIQUE INDEX IF NOT EXISTS dailysummary_user_date_uniq ON DailySummary(user_id, date)");
    // MealItem nutrient columns (in case migration hasn't run)
    await pool.query("ALTER TABLE MealItem ADD COLUMN IF NOT EXISTS calories NUMERIC(10,2) DEFAULT 0");
    await pool.query("ALTER TABLE MealItem ADD COLUMN IF NOT EXISTS protein NUMERIC(10,2) DEFAULT 0");
    await pool.query("ALTER TABLE MealItem ADD COLUMN IF NOT EXISTS fat NUMERIC(10,2) DEFAULT 0");
    await pool.query("ALTER TABLE MealItem ADD COLUMN IF NOT EXISTS carbs NUMERIC(10,2) DEFAULT 0");
    console.log('Ensured DailySummary/MealItem nutrient columns exist');
  } catch (e) {
    console.error('Error ensuring schema columns at startup', e && e.message);
  }
})();

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
};
