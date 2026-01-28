const db = require('../db');

// The migration created tables named AminoAcid, AminoRequirement, UserAminoRequirement (unquoted -> lowercased in PG)
// which become identifiers: aminoacid, aminorequirement, useraminorequirement

async function list(limit) {
  if (limit && Number.isInteger(limit)) {
    const r = await db.query('SELECT amino_acid_id as id, code, name, hex_color, home_display FROM aminoacid ORDER BY name LIMIT $1', [limit]);
    return r.rows;
  }
  const r = await db.query('SELECT amino_acid_id as id, code, name, hex_color, home_display FROM aminoacid ORDER BY name');
  return r.rows;
}

async function getById(id) {
  const r = await db.query('SELECT amino_acid_id as id, code, name, hex_color, home_display FROM aminoacid WHERE amino_acid_id = $1', [id]);
  return r.rows[0];
}

async function getRecommendedForUser(aminoId, user) {
  try {
    const uid = user.user_id || user.id || user.userId;
    // Check cached per-user table created by migration
    const r = await db.query('SELECT recommended, unit FROM useraminorequirement WHERE user_id = $1 AND amino_acid_id = $2', [uid, aminoId]);
    if (r.rows.length > 0) return r.rows[0];

    // Fallback: check generic recommended values
    const rr = await db.query('SELECT amount, unit, per_kg FROM aminorequirement WHERE amino_acid_id = $1 LIMIT 1', [aminoId]);
    if (rr.rows.length === 0) return null;
    const rec = rr.rows[0];
    if (rec.per_kg && user.weight_kg) {
      return { recommended: Number(rec.amount) * Number(user.weight_kg), unit: rec.unit };
    }
    return { recommended: rec.amount, unit: rec.unit };
  } catch (e) {
    console.error('getRecommendedForUser error', e && e.message);
    return null;
  }
}

module.exports = { list, getById, getRecommendedForUser };
