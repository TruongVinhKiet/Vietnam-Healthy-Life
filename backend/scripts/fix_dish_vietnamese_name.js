const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Health',
  password: 'Kiet2004',
  port: 5432,
});

async function fixDishVietnameseName() {
  try {
    console.log('🔍 Checking dishes with NULL vietnamese_name...\n');
    
    // Find dishes with NULL vietnamese_name
    const nullCheck = await pool.query(`
      SELECT dish_id, name, vietnamese_name 
      FROM dish 
      WHERE vietnamese_name IS NULL 
      ORDER BY dish_id 
      LIMIT 20
    `);
    
    console.log(`Found ${nullCheck.rowCount} dishes with NULL vietnamese_name\n`);
    if (nullCheck.rowCount > 0) {
      console.log('Sample dishes:');
      nullCheck.rows.forEach(d => {
        console.log(`- ID ${d.dish_id}: ${d.name}`);
      });
    }
    
    // Fix: Copy name to vietnamese_name where NULL
    const result = await pool.query(`
      UPDATE dish 
      SET vietnamese_name = name 
      WHERE vietnamese_name IS NULL
    `);
    
    console.log(`\n✅ Updated ${result.rowCount} dishes with vietnamese_name from name`);
    
    // Verify
    const verify = await pool.query(`
      SELECT COUNT(*) 
      FROM dish 
      WHERE vietnamese_name IS NULL
    `);
    
    console.log(`\n📊 Remaining dishes with NULL vietnamese_name: ${verify.rows[0].count}`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

fixDishVietnameseName();
