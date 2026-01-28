const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'Health',
  user: 'postgres',
  password: 'Kiet2004',
});

async function fixNullNameVi() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    console.log('🚀 Fixing NULL name_vi values...\n');

    // Get all foods with NULL name_vi
    const nullFoods = await client.query(`
      SELECT food_id, name, category
      FROM food
      WHERE name_vi IS NULL
    `);

    console.log(`Found ${nullFoods.rows.length} foods with NULL name_vi\n`);

    let updated = 0;
    for (const food of nullFoods.rows) {
      // Copy name to name_vi
      await client.query(
        'UPDATE food SET name_vi = $1 WHERE food_id = $2',
        [food.name, food.food_id]
      );
      
      updated++;
      console.log(`✅ Fixed: ${food.food_id} - ${food.name}`);
    }

    await client.query('COMMIT');

    console.log(`\n📊 Summary:`);
    console.log(`✅ Updated ${updated} foods`);

    // Verify - should be 0 now
    const remaining = await client.query(`
      SELECT COUNT(*) 
      FROM food 
      WHERE name_vi IS NULL
    `);

    console.log(`\n📈 Remaining NULL name_vi: ${remaining.rows[0].count}`);
    console.log('\n✅ name_vi fixed successfully! 🎉');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

fixNullNameVi();
