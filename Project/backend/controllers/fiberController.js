const fiberService = require('../services/fiberService');
const jwt = require('jsonwebtoken');
const db = require('../db');

async function maybeLoadUser(req) {
  const auth = req.headers['authorization'] || req.headers['Authorization'];
  if (!auth) return null;
  const parts = auth.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') return null;
  try {
    const payload = jwt.verify(parts[1], process.env.JWT_SECRET || 'change_this_secret');
    const r = await db.query('SELECT u.user_id, u.gender, u.weight_kg, up.goal_type, up.activity_factor, up.tdee FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id WHERE u.user_id = $1', [payload.user_id]);
    if (r.rows.length === 0) return null;
    return r.rows[0];
  } catch (e) {
    return null;
  }
}

async function listFibers(req, res) {
  try {
    const top = parseInt(req.query.top || '0', 10) || 0;
    const user = await maybeLoadUser(req);
    const rows = await fiberService.list(top > 0 ? top : null);
    if (user) {
      const enriched = await Promise.all(rows.map(async (f) => {
        const rec = await fiberService.recommendForUser(f, user);
        return { ...f, recommended_for_user: rec };
      }));
      return res.json(enriched);
    }
    return res.json(rows);
  } catch (err) {
    console.error('listFibers error', err);
    return res.status(500).json({ error: 'Failed to fetch fibers' });
  }
}

async function getFiber(req, res) {
  const id = parseInt(req.params.id, 10);
  if (Number.isNaN(id)) return res.status(400).json({ error: 'invalid id' });
  try {
    const v = await fiberService.getById(id);
    if (!v) return res.status(404).json({ error: 'Not found' });
    const user = await maybeLoadUser(req);
    if (user) {
      v.recommended_for_user = await fiberService.recommendForUser(v, user);
    }
    try {
      // Enrich with top foods via NutrientMapping -> Nutrient -> FoodNutrient
      const q = `
        SELECT f.food_id, f.name, SUM(fn.amount_per_100g) AS amount, MIN(n.unit) AS unit
        FROM NutrientMapping m
        JOIN FoodNutrient fn ON fn.nutrient_id = m.nutrient_id
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        JOIN Food f ON f.food_id = fn.food_id
        WHERE m.fiber_id = $1
        GROUP BY f.food_id, f.name
        ORDER BY amount DESC
        LIMIT 10`;
      const r = await db.query(q, [id]);
      v.foods = r.rows;
      // Pick an image_url and benefits from any mapped nutrient (first non-empty)
      const rInfo = await db.query(`
        SELECT image_url, benefits
        FROM Nutrient n
        WHERE n.nutrient_id IN (SELECT nutrient_id FROM NutrientMapping WHERE fiber_id = $1)
        ORDER BY (CASE WHEN COALESCE(image_url,'') <> '' THEN 0 ELSE 1 END), (CASE WHEN COALESCE(benefits,'') <> '' THEN 0 ELSE 1 END)
        LIMIT 1`, [id]);
      if (rInfo.rows.length > 0) {
        const row = rInfo.rows[0];
        if (row.image_url) v.image_url = row.image_url;
        if (row.benefits) v.benefits = row.benefits;
      }
      // Collect contraindications from mapped nutrients if any
      const rc = await db.query(`
        SELECT DISTINCT c.condition_name
        FROM NutrientMapping m
        JOIN NutrientContraindication c ON c.nutrient_id = m.nutrient_id
        WHERE m.fiber_id = $1
        ORDER BY c.condition_name`, [id]);
      v.contraindications = rc.rows.map(r => r.condition_name);
    } catch (e) {
      console.warn('getFiber enrichment failed', e && e.message);
    }
    return res.json(v);
  } catch (err) {
    console.error('getFiber error', err);
    return res.status(500).json({ error: 'Failed to fetch fiber' });
  }
}

module.exports = { listFibers, getFiber };
