const db = require('./db');

(async () => {
  try {
    await db.query("CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_summary_user_date ON DailySummary(user_id, date)");
    console.log('created index');
    process.exit(0);
  } catch (e) {
    console.error('error creating index', e);
    process.exit(1);
  }
})();