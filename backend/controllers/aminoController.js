const aminoService = require('../services/aminoService');

async function maybeLoadUser(req) {
  const auth = req.headers['authorization'] || req.headers['Authorization'];
  if (!auth) return null;
  const parts = auth.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') return null;
  try {
    const jwt = require('jsonwebtoken');
    const payload = jwt.verify(parts[1], process.env.JWT_SECRET || 'change_this_secret');
    const db = require('../db');
    const r = await db.query('SELECT u.user_id, u.gender as sex, u.weight_kg FROM "User" u WHERE u.user_id = $1', [payload.user_id]);
    if (r.rows.length === 0) return null;
    return r.rows[0];
  } catch (e) {
    return null;
  }
}

async function listAmino(req, res) {
  try {
    const top = parseInt(req.query.top || '0', 10) || 0;
    const user = await maybeLoadUser(req);
    const rows = await aminoService.list(top > 0 ? top : null);
    if (user) {
      // attach recommended_for_user per row
      const enriched = await Promise.all(rows.map(async (a) => {
        const rec = await aminoService.getRecommendedForUser(a.id, user);
        return { ...a, recommended_for_user: rec };
      }));
      return res.json(enriched);
    }
    return res.json(rows);
  } catch (err) {
    console.error('listAmino error', err);
    return res.status(500).json({ error: 'Failed to fetch amino acids' });
  }
}

async function getAmino(req, res) {
  const id = parseInt(req.params.id, 10);
  if (Number.isNaN(id)) return res.status(400).json({ error: 'invalid id' });
  try {
    const a = await aminoService.getById(id);
    if (!a) return res.status(404).json({ error: 'Not found' });
    const user = await maybeLoadUser(req);
    if (user) {
      a.recommended_for_user = await aminoService.getRecommendedForUser(a.id, user);
    }
    try {
      const db = require('../db');
      // Foods via mapped nutrients
      const rf = await db.query(`
        SELECT f.food_id, f.name, SUM(fn.amount_per_100g) AS amount, MIN(n.unit) AS unit
        FROM NutrientMapping m
        JOIN FoodNutrient fn ON fn.nutrient_id = m.nutrient_id
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        JOIN Food f ON f.food_id = fn.food_id
        WHERE m.amino_id = $1
        GROUP BY f.food_id, f.name
        ORDER BY amount DESC
        LIMIT 10`, [id]);
      a.foods = rf.rows;
      // Contraindications via mapped nutrients
      const rc = await db.query(`
        SELECT DISTINCT c.condition_name
        FROM NutrientMapping m
        JOIN NutrientContraindication c ON c.nutrient_id = m.nutrient_id
        WHERE m.amino_id = $1
        ORDER BY c.condition_name`, [id]);
      a.contraindications = rc.rows.map(r => r.condition_name);
      // Image and benefits from any mapped nutrient
      const rInfo = await db.query(`
        SELECT image_url, benefits
        FROM Nutrient
        WHERE nutrient_id IN (SELECT nutrient_id FROM NutrientMapping WHERE amino_id = $1)
        ORDER BY (CASE WHEN COALESCE(image_url,'') <> '' THEN 0 ELSE 1 END), (CASE WHEN COALESCE(benefits,'') <> '' THEN 0 ELSE 1 END)
        LIMIT 1`, [id]);
      if (rInfo.rows.length > 0) {
        const row = rInfo.rows[0];
        if (row.image_url) a.image_url = row.image_url;
        if (row.benefits) a.benefits = row.benefits;
      }
    } catch (e) {
      console.warn('amino detail enrichment failed', e && e.message);
    }
    return res.json(a);
  } catch (err) {
    console.error('getAmino error', err);
    return res.status(500).json({ error: 'Failed to fetch amino acid' });
  }
}

module.exports = { listAmino, getAmino };
