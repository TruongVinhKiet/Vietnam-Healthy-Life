const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function checkAndFixIsDeletedColumn() {
  const client = await pool.connect();
  
  try {
    console.log('🔍 Checking is_deleted column in User table...\n');
    
    // Check if is_deleted column exists
    const checkColumn = await client.query(`
      SELECT column_name, data_type, column_default, is_nullable
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'User'
        AND column_name = 'is_deleted';
    `);
    
    if (checkColumn.rows.length > 0) {
      console.log('✅ Column is_deleted already exists:');
      console.table(checkColumn.rows);
    } else {
      console.log('❌ Column is_deleted does NOT exist. Adding it now...\n');
      
      await client.query('BEGIN');
      
      // Add is_deleted column
      await client.query(`
        ALTER TABLE "User"
        ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
      `);
      
      console.log('✅ Added is_deleted column to User table');
      
      // Update existing users to is_deleted = false
      const updateResult = await client.query(`
        UPDATE "User"
        SET is_deleted = FALSE
        WHERE is_deleted IS NULL;
      `);
      
      console.log(`✅ Updated ${updateResult.rowCount} existing users to is_deleted = false\n`);
      
      await client.query('COMMIT');
    }
    
    // Verify all User columns
    console.log('📋 All User table columns:\n');
    const allColumns = await client.query(`
      SELECT column_name, data_type, column_default, is_nullable
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'User'
      ORDER BY ordinal_position;
    `);
    
    console.table(allColumns.rows);
    
    // Check if there are other missing columns commonly used
    const requiredColumns = [
      { name: 'is_deleted', type: 'boolean', default: 'false' },
      { name: 'created_at', type: 'timestamp', default: 'CURRENT_TIMESTAMP' },
      { name: 'updated_at', type: 'timestamp', default: 'CURRENT_TIMESTAMP' }
    ];
    
    console.log('\n📋 Checking required columns:\n');
    
    const existingCols = allColumns.rows.map(r => r.column_name.toLowerCase());
    const missingCols = [];
    
    for (const col of requiredColumns) {
      if (existingCols.includes(col.name)) {
        console.log(`✅ ${col.name} exists`);
      } else {
        console.log(`❌ ${col.name} missing`);
        missingCols.push(col);
      }
    }
    
    if (missingCols.length > 0) {
      console.log('\n⚠️  Adding missing columns...\n');
      
      await client.query('BEGIN');
      
      for (const col of missingCols) {
        const alterQuery = `
          ALTER TABLE "User"
          ADD COLUMN ${col.name} ${col.type} DEFAULT ${col.default};
        `;
        
        await client.query(alterQuery);
        console.log(`✅ Added ${col.name} column`);
      }
      
      await client.query('COMMIT');
    }
    
    console.log('\n✅ All required columns verified!\n');
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

checkAndFixIsDeletedColumn();
