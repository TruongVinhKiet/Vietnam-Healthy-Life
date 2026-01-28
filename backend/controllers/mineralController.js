const mineralService = require('../services/mineralService');
const jwt = require('jsonwebtoken');

async function maybeLoadUser(req) {
  const auth = req.headers['authorization'] || req.headers['Authorization'];
  if (!auth) return null;
  const parts = auth.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') return null;
  try {
    const payload = jwt.verify(parts[1], process.env.JWT_SECRET || 'change_this_secret');
    const db = require('../db');
    const r = await db.query('SELECT u.user_id, u.gender, u.weight_kg, up.goal_type, up.activity_factor, up.tdee FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id WHERE u.user_id = $1', [payload.user_id]);
    if (r.rows.length === 0) return null;
    return r.rows[0];
  } catch (e) {
    return null;
  }
}

async function listMinerals(req, res) {
  try {
    const top = parseInt(req.query.top || '0', 10) || 0;
    const user = await maybeLoadUser(req);
    const rows = await mineralService.list(top > 0 ? top : null);
    if (user) {
      const enriched = rows.map(v => ({ ...v, recommended_for_user: mineralService.recommendForUser(v, user) }));
      return res.json(enriched);
    }
    return res.json(rows);
  } catch (err) {
    console.error('listMinerals error', err);
    return res.status(500).json({ error: 'Failed to fetch minerals' });
  }
}

async function getMineral(req, res) {
  const id = parseInt(req.params.id, 10);
  if (Number.isNaN(id)) return res.status(400).json({ error: 'invalid id' });
  try {
    const v = await mineralService.getById(id);
    if (!v) return res.status(404).json({ error: 'Not found' });
    const user = await maybeLoadUser(req);
    if (user) {
      v.recommended_for_user = mineralService.recommendForUser(v, user);
    }
    try {
      const db = require('../db');
      // Map Mineral.code like MIN_CA -> CA
      const code = String(v.code || '').toUpperCase().replace(/^MIN_/, '');
      let foods = [];
      let contraindications = [];
      let imageUrl = null;
      let benefits = null;
      const qFoods = `
        SELECT f.food_id, f.name, fn.amount_per_100g AS amount, n.unit
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        JOIN Food f ON f.food_id = fn.food_id
        WHERE UPPER(n.nutrient_code) = $1
        ORDER BY fn.amount_per_100g DESC
        LIMIT 10`;
      const rf = await db.query(qFoods, [code]);
      foods = rf.rows;
      let rN = await db.query('SELECT nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = $1 LIMIT 1', [code]);
      if (rN.rows.length === 0) {
        // Fallback by name if code fails
        rN = await db.query('SELECT nutrient_id FROM Nutrient WHERE LOWER(name) = LOWER($1) LIMIT 1', [v.name || '']);
      }
      if (rN.rows.length > 0) {
        const nid = rN.rows[0].nutrient_id;
        const rc = await db.query('SELECT condition_name FROM NutrientContraindication WHERE nutrient_id = $1 ORDER BY condition_name', [nid]);
        contraindications = rc.rows.map(r => r.condition_name);
        const rnInfo = await db.query('SELECT image_url, benefits FROM Nutrient WHERE nutrient_id = $1', [nid]);
        if (rnInfo.rows.length > 0) {
          imageUrl = rnInfo.rows[0].image_url || null;
          benefits = rnInfo.rows[0].benefits || null;
        }
      }
      v.foods = foods;
      v.contraindications = contraindications;
      if (imageUrl) v.image_url = imageUrl;
      if (benefits) v.benefits = benefits;
    } catch (e) {
      console.warn('getMineral enrichment failed', e && e.message);
    }
    return res.json(v);
  } catch (err) {
    console.error('getMineral error', err);
    return res.status(500).json({ error: 'Failed to fetch mineral' });
  }
}

module.exports = { listMinerals, getMineral };
