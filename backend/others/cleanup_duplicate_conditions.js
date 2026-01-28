const db = require('./db');

async function cleanupDuplicates() {
  try {
    // Find duplicate conditions (same user_id + condition_id)
    const duplicates = await db.query(`
      SELECT user_id, condition_id, COUNT(*) as count
      FROM UserHealthCondition
      WHERE status = 'active'
      GROUP BY user_id, condition_id
      HAVING COUNT(*) > 1
    `);

    console.log('Found duplicates:', duplicates.rows);

    for (const dup of duplicates.rows) {
      // Keep the most recent one, delete others
      const toDelete = await db.query(`
        DELETE FROM UserHealthCondition
        WHERE user_condition_id IN (
          SELECT user_condition_id 
          FROM UserHealthCondition
          WHERE user_id = $1 AND condition_id = $2 AND status = 'active'
          ORDER BY treatment_start_date DESC, user_condition_id DESC
          OFFSET 1
        )
        RETURNING *
      `, [dup.user_id, dup.condition_id]);

      console.log(`Deleted ${toDelete.rows.length} duplicate(s) for user ${dup.user_id}, condition ${dup.condition_id}`);
    }

    console.log('Cleanup complete!');
    process.exit(0);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
}

cleanupDuplicates();
