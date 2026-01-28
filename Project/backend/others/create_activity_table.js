const db = require('./db');

async function createActivityTable() {
  console.log('Creating UserActivityLog table...');
  
  try {
    await db.query(`
      CREATE TABLE IF NOT EXISTS "UserActivityLog" (
        log_id SERIAL PRIMARY KEY,
        user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
        action TEXT,
        log_time TIMESTAMP DEFAULT NOW()
      )
    `);
    
    console.log('✅ UserActivityLog table created successfully');
    
    // Create index for faster queries
    await db.query(`
      CREATE INDEX IF NOT EXISTS idx_user_activity_user_time 
      ON "UserActivityLog"(user_id, log_time DESC)
    `);
    
    console.log('✅ Index created on user_id and log_time');
    
    // Create index for action filtering
    await db.query(`
      CREATE INDEX IF NOT EXISTS idx_user_activity_action 
      ON "UserActivityLog"(action)
    `);
    
    console.log('✅ Index created on action');
    
    console.log('\n🎉 UserActivityLog infrastructure ready!');
    
  } catch (error) {
    console.error('❌ Error creating table:', error.message);
  } finally {
    process.exit(0);
  }
}

createActivityTable();
