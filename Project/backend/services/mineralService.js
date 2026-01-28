const db = require('../db');

async function list(limit) {
  if (limit && Number.isInteger(limit)) {
    const r = await db.query('SELECT mineral_id, code, name, description, unit, recommended_daily FROM Mineral ORDER BY name LIMIT $1', [limit]);
    return r.rows;
  }
  const r = await db.query('SELECT mineral_id, code, name, description, unit, recommended_daily FROM Mineral ORDER BY name');
  return r.rows;
}

async function getById(id) {
  const r = await db.query('SELECT mineral_id, code, name, description, unit, recommended_daily FROM Mineral WHERE mineral_id = $1', [id]);
  return r.rows[0];
}

function recommendForUser(mineralRow, user) {
  const base = Number(mineralRow.recommended_daily) || 0;
  let multiplier = 1.0;
  const activity = Number(user.activity_factor) || 1.2;
  const goal = (user.goal_type || '').toLowerCase();
  if (activity > 1.2) {
    multiplier += Math.min((activity - 1.2) * 0.15, 0.15);
  }
  if (goal === 'lose_weight') multiplier += 0.03;
  else if (goal === 'gain_weight') multiplier -= 0.01;
  if ((user.gender || '').toLowerCase() === 'male') multiplier += 0.02;
  const recommended = +(base * multiplier).toFixed(3);
  return { value: recommended, unit: mineralRow.unit };
}

module.exports = { list, getById, recommendForUser };
