const db = require('../db');

async function main() {
  try {
    const users = await db.query('SELECT user_id FROM "User"');
    console.log('Found', users.rows.length, 'users');
    for (const u of users.rows) {
      try {
        await db.query('SELECT refresh_user_amino_requirements($1)', [u.user_id]);
        console.log('Refreshed user', u.user_id);
      } catch (e) {
        console.error('Failed refresh for', u.user_id, e && e.message);
      }
    }
    console.log('Done');
    process.exit(0);
  } catch (e) {
    console.error('Error enumerating users', e && e.message);
    process.exit(1);
  }
}

main();
