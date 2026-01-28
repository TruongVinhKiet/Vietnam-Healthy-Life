const db = require('../db');

// Ensure security-related tables exist (idempotent)
async function ensureSchema() {
  try {
    await db.query(`
      CREATE TABLE IF NOT EXISTS UserSecurity (
        user_id INT PRIMARY KEY REFERENCES "User"(user_id) ON DELETE CASCADE,
        twofa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
        twofa_secret TEXT,
        lock_threshold INT NOT NULL DEFAULT 5,
        failed_attempts INT NOT NULL DEFAULT 0,
        last_failed_at TIMESTAMPTZ
      );
    `);
    await db.query(`
      CREATE TABLE IF NOT EXISTS AccountUnlockCode (
        code_id SERIAL PRIMARY KEY,
        user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
        code VARCHAR(10) NOT NULL,
        expires_at TIMESTAMPTZ NOT NULL,
        used_at TIMESTAMPTZ,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now()
      );
    `);
    await db.query(`
      CREATE TABLE IF NOT EXISTS PasswordChangeCode (
        code_id SERIAL PRIMARY KEY,
        user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
        code VARCHAR(10) NOT NULL,
        expires_at TIMESTAMPTZ NOT NULL,
        consumed BOOLEAN NOT NULL DEFAULT FALSE,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now()
      );
    `);
    await db.query('CREATE INDEX IF NOT EXISTS idx_pwcode_user ON PasswordChangeCode(user_id)');
    await db.query('CREATE INDEX IF NOT EXISTS idx_pwcode_code ON PasswordChangeCode(code)');
  } catch (e) {
    console.error('ensureSchema(UserSecurity/PasswordChangeCode) failed', e && e.message);
  }
}

async function ensureUserSecurity(user_id) {
  await ensureSchema();
  await db.query('INSERT INTO UserSecurity(user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING', [user_id]);
}

async function getUserSecurity(user_id) {
  await ensureUserSecurity(user_id);
  const res = await db.query('SELECT * FROM UserSecurity WHERE user_id = $1', [user_id]);
  return res.rows[0];
}

async function setTwoFaSecret(user_id, secret) {
  await ensureUserSecurity(user_id);
  await db.query('UPDATE UserSecurity SET twofa_secret = $1, twofa_enabled = FALSE WHERE user_id = $2', [secret, user_id]);
}

async function enableTwoFa(user_id) {
  await ensureUserSecurity(user_id);
  await db.query('UPDATE UserSecurity SET twofa_enabled = TRUE WHERE user_id = $1 AND twofa_secret IS NOT NULL', [user_id]);
}

async function disableTwoFa(user_id) {
  await ensureUserSecurity(user_id);
  await db.query('UPDATE UserSecurity SET twofa_enabled = FALSE, twofa_secret = NULL WHERE user_id = $1', [user_id]);
}

async function setLockThreshold(user_id, threshold) {
  await ensureUserSecurity(user_id);
  await db.query('UPDATE UserSecurity SET lock_threshold = $1 WHERE user_id = $2', [threshold, user_id]);
}

async function getLockThreshold(user_id) {
  const sec = await getUserSecurity(user_id);
  return Number(sec.lock_threshold || 5);
}

async function incrementFailedAttempt(user_id) {
  await ensureUserSecurity(user_id);
  const res = await db.query('UPDATE UserSecurity SET failed_attempts = failed_attempts + 1, last_failed_at = now() WHERE user_id = $1 RETURNING failed_attempts', [user_id]);
  return Number(res.rows[0] && res.rows[0].failed_attempts || 0);
}

async function resetFailedAttempts(user_id) {
  await ensureUserSecurity(user_id);
  await db.query('UPDATE UserSecurity SET failed_attempts = 0 WHERE user_id = $1', [user_id]);
}

async function unblockUser(user_id) {
  await ensureUserSecurity(user_id);
  await db.query('UPDATE user_account_status SET is_blocked = FALSE, blocked_reason = NULL, updated_at = now() WHERE user_id = $1', [user_id]);
  await db.query('INSERT INTO user_block_event(user_id, event_type, reason) VALUES ($1, $2, $3)', [user_id, 'unblock', 'unlock_code']);
  await resetFailedAttempts(user_id);
}

function _rand6() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

async function createUnlockCode(user_id, ttlSeconds = 900) {
  await ensureSchema();
  const code = _rand6();
  const expiresAt = new Date(Date.now() + ttlSeconds * 1000);
  await db.query(
    'INSERT INTO AccountUnlockCode(user_id, code, expires_at) VALUES ($1,$2,$3)',
    [user_id, code, expiresAt]
  );
  return { code, expires_at: expiresAt };
}

async function verifyUnlockCode(user_id, code) {
  await ensureSchema();
  const res = await db.query(
    'SELECT created_at, expires_at, used_at FROM AccountUnlockCode WHERE user_id = $1 AND code = $2 ORDER BY created_at DESC LIMIT 1',
    [user_id, code]
  );
  const row = res.rows[0];
  if (!row) return { ok: false, reason: 'not_found' };
  if (row.used_at) return { ok: false, reason: 'consumed' };
  if (new Date(row.expires_at).getTime() < Date.now())
    return { ok: false, reason: 'expired' };
  await db.query(
    'UPDATE AccountUnlockCode SET used_at = now() WHERE user_id = $1 AND code = $2 AND created_at = $3',
    [user_id, code, row.created_at]
  );
  return { ok: true };
}

async function blockUser(user_id, reason) {
  // mark status
  await db.query('INSERT INTO user_account_status(user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING', [user_id]);
  await db.query('UPDATE user_account_status SET is_blocked = TRUE, blocked_reason = $1, blocked_at = now(), updated_at = now() WHERE user_id = $2', [reason || null, user_id]);
  await db.query('INSERT INTO user_block_event(user_id, event_type, reason) VALUES ($1, $2, $3)', [user_id, 'block', reason || null]);
}

async function lastUnblockedAt(user_id) {
  const res = await db.query("SELECT created_at FROM user_block_event WHERE user_id = $1 AND event_type = 'unblock' ORDER BY created_at DESC LIMIT 1", [user_id]);
  return res.rows[0] ? res.rows[0].created_at : null;
}

// Create a password change code, expires in ttlSeconds (default 10 minutes)
async function createPasswordChangeCodeJS(user_id, ttlSeconds = 600) {
  await ensureSchema();
  const code = _rand6();
  const expiresAt = new Date(Date.now() + ttlSeconds * 1000);
  await db.query('INSERT INTO PasswordChangeCode(user_id, code, expires_at) VALUES ($1,$2,$3)', [user_id, code, expiresAt]);
  return { code, expires_at: expiresAt };
}

async function verifyPasswordChangeCode(user_id, code) {
  await ensureSchema();
  // Compatible with migration that uses used_at (TIMESTAMPTZ) instead of consumed boolean
  const res = await db.query(
    'SELECT created_at, expires_at, used_at FROM PasswordChangeCode WHERE user_id = $1 AND code = $2 ORDER BY created_at DESC LIMIT 1',
    [user_id, code]
  );
  const row = res.rows[0];
  if (!row) return { ok: false, reason: 'not_found' };
  if (row.used_at) return { ok: false, reason: 'consumed' };
  if (new Date(row.expires_at).getTime() < Date.now()) return { ok: false, reason: 'expired' };
  // Mark as used; target the exact row by user_id, code, created_at
  await db.query(
    'UPDATE PasswordChangeCode SET used_at = now() WHERE user_id = $1 AND code = $2 AND created_at = $3',
    [user_id, code, row.created_at]
  );
  // Best-effort: if a legacy schema had a consumed boolean, try to set it too, but ignore errors
  try {
    await db.query(
      'UPDATE PasswordChangeCode SET consumed = TRUE WHERE user_id = $1 AND code = $2 AND created_at = $3',
      [user_id, code, row.created_at]
    );
  } catch (e) { /* ignore if column does not exist */ }
  return { ok: true };
}

async function getNotifications(user_id) {
  const out = [];
  // last login
  try {
    const u = await db.query('SELECT last_login FROM "User" WHERE user_id = $1', [user_id]);
    const last_login = u.rows[0] ? u.rows[0].last_login : null;
    if (last_login) out.push({ type: 'last_login', at: last_login, message: 'Lần đăng nhập gần nhất' });
  } catch (e) {}
  // last unblocked
  try {
    const un = await db.query("SELECT created_at FROM user_block_event WHERE user_id = $1 AND event_type = 'unblock' ORDER BY created_at DESC LIMIT 1", [user_id]);
    const t = un.rows[0] && un.rows[0].created_at;
    if (t) out.push({ type: 'account_unblocked', at: t, message: 'Tài khoản đã được mở khóa' });
  } catch (e) {}
  // last metrics-related action from UserActivityLog
  try {
    const a = await db.query("SELECT action, log_time FROM UserActivityLog WHERE user_id = $1 AND action IN ('profile_updated','bmr_tdee_recomputed','daily_targets_recomputed') ORDER BY log_time DESC LIMIT 1", [user_id]);
    const row = a.rows[0];
    if (row) {
      let msg = 'Chỉ số cơ thể đã được cập nhật';
      if (row.action === 'bmr_tdee_recomputed') msg = 'BMR/TDEE đã được tính lại';
      if (row.action === 'daily_targets_recomputed') msg = 'Mục tiêu hàng ngày đã được tính lại';
      out.push({ type: 'metrics_updated', at: row.log_time, message: msg });
    }
  } catch (e) {}
  // sort by time desc
  out.sort((a, b) => new Date(b.at) - new Date(a.at));
  return out;
}

module.exports = {
  ensureSchema,
  ensureUserSecurity,
  getUserSecurity,
  setTwoFaSecret,
  enableTwoFa,
  disableTwoFa,
  setLockThreshold,
  getLockThreshold,
  incrementFailedAttempt,
  resetFailedAttempts,
  unblockUser,
  createUnlockCode,
  verifyUnlockCode,
  blockUser,
  lastUnblockedAt,
  createPasswordChangeCodeJS,
  verifyPasswordChangeCode,
  getNotifications,
};
