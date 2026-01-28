const db = require('../db');

async function list(limit) {
  if (limit && Number.isInteger(limit)) {
    const r = await db.query('SELECT vitamin_id, code, name, description, unit, recommended_daily FROM Vitamin ORDER BY name LIMIT $1', [limit]);
    return r.rows;
  }
  const r = await db.query('SELECT vitamin_id, code, name, description, unit, recommended_daily FROM Vitamin ORDER BY name');
  return r.rows;
}

async function getById(id) {
  const r = await db.query('SELECT vitamin_id, code, name, description, unit, recommended_daily FROM Vitamin WHERE vitamin_id = $1', [id]);
  return r.rows[0];
}

// Compute recommended amount for a specific user profile.
// Assumptions:
//  - Vitamin.recommended_daily is a baseline adult RDA.
//  - Adjustments are heuristic: activity_factor slightly increases needs; weight only used when activity scales.
//  - goal_type may increase needs slightly for 'lose_weight' (+5%), keep for 'maintain', and decrease slightly for 'gain_weight' (-2%).
// These are conservative heuristics and should be replaced with authoritative rules if available.
function recommendForUser(vitaminRow, user) {
  const base = Number(vitaminRow.recommended_daily) || 0;
  let multiplier = 1.0;
  const activity = Number(user.activity_factor) || 1.2;
  const goal = (user.goal_type || '').toLowerCase();
  // activity adjustment: for activity above 1.2, add up to 20% (scaled)
  if (activity > 1.2) {
    multiplier += Math.min((activity - 1.2) * 0.25, 0.20);
  }
  // goal adjustment
  if (goal === 'lose_weight') multiplier += 0.05;
  else if (goal === 'gain_weight') multiplier -= 0.02;

  // gender-specific tweaks could be applied here; keep neutral unless more data
  const recommended = +(base * multiplier).toFixed(3);
  return { value: recommended, unit: vitaminRow.unit };
}

module.exports = { list, getById, recommendForUser };
