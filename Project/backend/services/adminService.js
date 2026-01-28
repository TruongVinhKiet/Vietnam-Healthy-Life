const db = require('../db');


// Use username column (matches migrations - unquoted admin table)
async function createAdmin({ username, password_hash }) {
  const q = `INSERT INTO admin (username, password_hash) VALUES ($1,$2) RETURNING admin_id, username, created_at`;
  const res = await db.query(q, [username, password_hash]);
  return res.rows[0];
}

async function findByUsername(username) {
  const q = 'SELECT * FROM admin WHERE username = $1 LIMIT 1';
  const res = await db.query(q, [username]);
  return res.rows[0];
}

async function findById(id) {
  const q = 'SELECT * FROM admin WHERE admin_id = $1 LIMIT 1';
  const res = await db.query(q, [id]);
  return res.rows[0];
}

module.exports = { createAdmin, findByUsername, findById };
