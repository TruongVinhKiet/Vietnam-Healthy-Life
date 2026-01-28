// Script to fix medication trigger
const db = require('./db');
const fs = require('fs');
const path = require('path');

async function runMigration() {
  try {
    console.log('Reading migration file...');
    const sql = fs.readFileSync(
      path.join(__dirname, 'migrations', 'fix_medication_trigger.sql'),
      'utf8'
    );

    console.log('Executing migration...');
    await db.query(sql);

    console.log('✅ Migration completed successfully!');
    console.log('Trigger trg_log_medication_taken has been fixed.');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

runMigration();
