/**
 * Script to ensure AI_Analyzed_Meals promotion columns exist
 * Run: node scripts/ensure_ai_promotion_columns.js
 */

require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
});

async function checkAndAddColumns() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Check which columns exist
    const checkRes = await client.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'ai_analyzed_meals'
      AND column_name IN ('promoted', 'promoted_at', 'promoted_by_admin', 'linked_dish_id', 'linked_drink_id')
    `);

    const existingColumns = checkRes.rows.map(r => r.column_name);
    console.log('Existing promotion columns:', existingColumns);

    // Add missing columns
    if (!existingColumns.includes('promoted')) {
      await client.query('ALTER TABLE AI_Analyzed_Meals ADD COLUMN promoted BOOLEAN DEFAULT FALSE');
      console.log('✓ Added column: promoted');
    }

    if (!existingColumns.includes('promoted_at')) {
      await client.query('ALTER TABLE AI_Analyzed_Meals ADD COLUMN promoted_at TIMESTAMPTZ');
      console.log('✓ Added column: promoted_at');
    }

    if (!existingColumns.includes('promoted_by_admin')) {
      await client.query('ALTER TABLE AI_Analyzed_Meals ADD COLUMN promoted_by_admin INT');
      console.log('✓ Added column: promoted_by_admin');
    }

    if (!existingColumns.includes('linked_dish_id')) {
      await client.query('ALTER TABLE AI_Analyzed_Meals ADD COLUMN linked_dish_id INT');
      console.log('✓ Added column: linked_dish_id');
    }

    if (!existingColumns.includes('linked_drink_id')) {
      await client.query('ALTER TABLE AI_Analyzed_Meals ADD COLUMN linked_drink_id INT');
      console.log('✓ Added column: linked_drink_id');
    }

    await client.query('COMMIT');
    console.log('\n✅ All promotion columns are ready!');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', err.message);
    throw err;
  } finally {
    client.release();
  }
}

checkAndAddColumns()
  .then(() => {
    console.log('Done.');
    process.exit(0);
  })
  .catch((err) => {
    console.error('Failed:', err);
    process.exit(1);
  })
  .finally(() => {
    pool.end();
  });

