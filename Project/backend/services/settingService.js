const db = require('../db');

async function getSettings(userId) {
  const q = 'SELECT * FROM UserSetting WHERE user_id = $1 LIMIT 1';
  const res = await db.query(q, [userId]);
  return res.rows[0] || null;
}

async function upsertSettings(userId, fields = {}) {
  // Build columns/values for insert and update
  const keys = Object.keys(fields);
  if (keys.length === 0) {
    // ensure a row exists
    await db.query('INSERT INTO UserSetting(user_id) VALUES ($1) ON CONFLICT DO NOTHING', [userId]);
    return getSettings(userId);
  }

  const insertCols = ['user_id', ...keys];
  const insertVals = ['$1', ...keys.map((_, i) => `$${i + 2}`)];
  const insertParams = [userId, ...keys.map(k => fields[k])];

  // Build update clause referencing EXCLUDED values
  const updateClauses = keys.map(k => `${k} = EXCLUDED.${k}`);

  const q = `INSERT INTO UserSetting (${insertCols.join(', ')}) VALUES (${insertVals.join(', ')}) ON CONFLICT (user_id) DO UPDATE SET ${updateClauses.join(', ')} RETURNING *`;
  const res = await db.query(q, insertParams);
  return res.rows[0];
}

module.exports = { getSettings, upsertSettings };
