const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'Health',
});

async function runMigration() {
  const client = await pool.connect();
  
  try {
    console.log('Running health condition upgrade migration...');
    
    const migrationPath = path.join(__dirname, '../../../database_migrations/upgrade_healthcondition.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
    
    await client.query('BEGIN');
    await client.query(migrationSQL);
    await client.query('COMMIT');
    
    console.log('✅ Migration completed successfully!');
    
    // Check results
    const result = await client.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'healthcondition' 
      ORDER BY ordinal_position
    `);
    
    console.log('\nHealthCondition table columns:');
    result.rows.forEach(row => {
      console.log(`  - ${row.column_name}: ${row.data_type}`);
    });
    
    const countResult = await client.query('SELECT COUNT(*) FROM healthcondition');
    console.log(`\nTotal health conditions: ${countResult.rows[0].count}`);
    
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed:', err);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

runMigration()
  .then(() => {
    console.log('\n🎉 All done!');
    process.exit(0);
  })
  .catch((err) => {
    console.error('\n💥 Error:', err);
    process.exit(1);
  });
