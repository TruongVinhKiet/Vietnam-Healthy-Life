const db = require('../db');

async function list(limit) {
  if (limit && Number.isInteger(limit)) {
    const r = await db.query('SELECT fiber_id, code, name, description, unit, hex_color, home_display FROM Fiber ORDER BY name LIMIT $1', [limit]);
    return r.rows;
  }
  const r = await db.query('SELECT fiber_id, code, name, description, unit, hex_color, home_display FROM Fiber ORDER BY name');
  return r.rows;
}

async function getById(id) {
  const r = await db.query('SELECT fiber_id, code, name, description, unit, hex_color, home_display FROM Fiber WHERE fiber_id = $1', [id]);
  return r.rows[0];
}

// Try to get the cached per-user recommended row, otherwise call the compute SQL function
async function recommendForUser(fiberRow, user) {
  try {
    const r = await db.query('SELECT recommended, unit FROM UserFiberRequirement WHERE user_id = $1 AND fiber_id = $2 LIMIT 1', [user.user_id, fiberRow.fiber_id]);
    if (r.rows.length > 0) return { value: Number(r.rows[0].recommended || 0), unit: r.rows[0].unit };
    // fallback: call compute_user_fiber_requirement
    const cr = await db.query(
      'SELECT base, multiplier, recommended, unit FROM compute_user_fiber_requirement($1::int,$2::int)',
      [user.user_id, fiberRow.fiber_id]
    );
    if (cr.rows.length > 0) return { value: Number(cr.rows[0].recommended || 0), unit: cr.rows[0].unit };
  } catch (e) {
    console.error('recommendForUser fiber error', e);
  }
  return null;
}

module.exports = { list, getById, recommendForUser };
