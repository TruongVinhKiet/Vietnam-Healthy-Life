const db = require('../db');

async function main() {
  try {
    const users = await db.query('SELECT user_id FROM "User"');
    console.log('Found', users.rows.length, 'users');
    
    let fiberCount = 0;
    let fattyCount = 0;
    
    for (const u of users.rows) {
      try {
        // Refresh fiber requirements
        await db.query('SELECT refresh_user_fiber_requirements($1)', [u.user_id]);
        fiberCount++;
        
        // Refresh fatty acid requirements
        await db.query('SELECT refresh_user_fatty_requirements($1)', [u.user_id]);
        fattyCount++;
        
        if ((fiberCount + fattyCount) % 20 === 0) {
          console.log(`Processed ${fiberCount} fiber and ${fattyCount} fatty requirements...`);
        }
      } catch (e) {
        console.error('Failed refresh for user', u.user_id, e && e.message);
      }
    }
    
    // Verify counts
    const fiberResult = await db.query('SELECT COUNT(*) as count FROM UserFiberRequirement');
    const fattyResult = await db.query('SELECT COUNT(*) as count FROM UserFattyAcidRequirement');
    
    console.log('\n========================================');
    console.log('Summary:');
    console.log('Total users processed:', users.rows.length);
    console.log('UserFiberRequirement records:', fiberResult.rows[0].count);
    console.log('UserFattyAcidRequirement records:', fattyResult.rows[0].count);
    console.log('========================================\n');
    
    console.log('Done!');
    process.exit(0);
  } catch (e) {
    console.error('Error:', e && e.message);
    process.exit(1);
  }
}

main();

