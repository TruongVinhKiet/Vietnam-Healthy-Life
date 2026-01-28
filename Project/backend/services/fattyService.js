const db = require('../db');

async function list(limit) {
  if (limit && Number.isInteger(limit)) {
    const r = await db.query('SELECT fatty_acid_id, code, name, description, unit, hex_color, home_display FROM FattyAcid ORDER BY name LIMIT $1', [limit]);
    return r.rows;
  }
  const r = await db.query('SELECT fatty_acid_id, code, name, description, unit, hex_color, home_display FROM FattyAcid ORDER BY name');
  return r.rows;
}

async function getById(id) {
  const r = await db.query('SELECT fatty_acid_id, code, name, description, unit, hex_color, home_display FROM FattyAcid WHERE fatty_acid_id = $1', [id]);
  return r.rows[0];
}

async function recommendForUser(faRow, user) {
  try {
    const r = await db.query('SELECT recommended, unit FROM UserFattyAcidRequirement WHERE user_id = $1 AND fatty_acid_id = $2 LIMIT 1', [user.user_id, faRow.fatty_acid_id]);
    if (r.rows.length > 0) return { value: Number(r.rows[0].recommended || 0), unit: r.rows[0].unit };
    const cr = await db.query('SELECT base, multiplier, recommended, unit FROM compute_user_fattyacid_requirement($1,$2)', [user.user_id, faRow.fatty_acid_id]);
    if (cr.rows.length > 0) return { value: Number(cr.rows[0].recommended || 0), unit: cr.rows[0].unit };
  } catch (e) {
    console.error('recommendForUser fatty error', e);
  }
  return null;
}

module.exports = { list, getById, recommendForUser };
