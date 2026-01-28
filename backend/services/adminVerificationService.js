const db = require('../db');

async function createPending({ username, password_hash, code, expires_at }) {
  const q = `INSERT INTO admin_verification (username, password_hash, code, expires_at) VALUES ($1,$2,$3,$4) RETURNING *`;
  const res = await db.query(q, [username, password_hash, code, expires_at]);
  return res.rows[0];
}

async function findByUsernameAndCode(username, code) {
  const q = 'SELECT * FROM admin_verification WHERE username = $1 AND code = $2 LIMIT 1';
  const res = await db.query(q, [username, code]);
  return res.rows[0];
}

async function deleteById(id) {
  const q = 'DELETE FROM admin_verification WHERE verification_id = $1';
  await db.query(q, [id]);
}

async function deleteByUsername(username) {
  const q = 'DELETE FROM admin_verification WHERE username = $1';
  await db.query(q, [username]);
}

module.exports = { createPending, findByUsernameAndCode, deleteById, deleteByUsername };
