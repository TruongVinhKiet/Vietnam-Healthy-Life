const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function fixOrphanedRecords() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    console.log('🔍 Finding orphaned ConditionNutrientEffect records...\n');
    
    // Find orphaned records
    const orphaned = await client.query(`
      SELECT cne.*, hc.condition_id as hc_id, n.nutrient_id as n_id
      FROM ConditionNutrientEffect cne
      LEFT JOIN HealthCondition hc ON cne.condition_id = hc.condition_id
      LEFT JOIN Nutrient n ON cne.nutrient_id = n.nutrient_id
      WHERE hc.condition_id IS NULL OR n.nutrient_id IS NULL
    `);
    
    console.log(`Found ${orphaned.rows.length} orphaned records:\n`);
    
    if (orphaned.rows.length > 0) {
      console.table(orphaned.rows.slice(0, 10)); // Show first 10
      
      // Option 1: Delete orphaned records
      console.log('\n🗑️  Deleting orphaned records...');
      
      const deleteResult = await client.query(`
        DELETE FROM ConditionNutrientEffect cne
        WHERE NOT EXISTS (SELECT 1 FROM HealthCondition hc WHERE hc.condition_id = cne.condition_id)
           OR NOT EXISTS (SELECT 1 FROM Nutrient n WHERE n.nutrient_id = cne.nutrient_id)
        RETURNING effect_id
      `);
      
      console.log(`✅ Deleted ${deleteResult.rows.length} orphaned records\n`);
      
      await client.query('COMMIT');
      
      // Verify
      console.log('📊 Verification:\n');
      const remaining = await client.query(`
        SELECT COUNT(*) as count
        FROM ConditionNutrientEffect cne
        LEFT JOIN HealthCondition hc ON cne.condition_id = hc.condition_id
        LEFT JOIN Nutrient n ON cne.nutrient_id = n.nutrient_id
        WHERE hc.condition_id IS NULL OR n.nutrient_id IS NULL
      `);
      
      console.log(`  Remaining orphaned records: ${remaining.rows[0].count}`);
      
      const total = await client.query('SELECT COUNT(*) as count FROM ConditionNutrientEffect');
      console.log(`  Total valid records: ${total.rows[0].count}\n`);
      
      if (parseInt(remaining.rows[0].count) === 0) {
        console.log('✅ All orphaned records fixed!\n');
      }
    } else {
      console.log('✅ No orphaned records found!\n');
      await client.query('ROLLBACK');
    }
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

fixOrphanedRecords();
