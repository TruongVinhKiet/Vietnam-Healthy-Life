const fattyService = require('../services/fattyService');

async function list(req, res) {
  try {
    const limit = req.query.limit ? parseInt(req.query.limit, 10) : undefined;
    const rows = await fattyService.list(limit);
    if (req.user) {
      // enrich with per-user recommended value
      const enriched = await Promise.all(rows.map(async (r) => {
        const rec = await fattyService.recommendForUser(r, req.user);
        return Object.assign({}, r, { recommended_for_user: rec });
      }));
      return res.json(enriched);
    }
    return res.json(rows);
  } catch (err) {
    console.error('fattyController.list error', err);
    return res.status(500).json({ error: 'internal_error' });
  }
}

async function get(req, res) {
  try {
    const id = Number(req.params.id);
    const row = await fattyService.getById(id);
    if (!row) return res.status(404).json({ error: 'not_found' });
    if (req.user) {
      const rec = await fattyService.recommendForUser(row, req.user);
      row.recommended_for_user = rec;
    }
    try {
      const db = require('../db');
      const q = `
        SELECT f.food_id, f.name, SUM(fn.amount_per_100g) AS amount, MIN(n.unit) AS unit
        FROM NutrientMapping m
        JOIN FoodNutrient fn ON fn.nutrient_id = m.nutrient_id
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        JOIN Food f ON f.food_id = fn.food_id
        WHERE m.fatty_acid_id = $1
        GROUP BY f.food_id, f.name
        ORDER BY amount DESC
        LIMIT 10`;
      const rf = await db.query(q, [id]);
      row.foods = rf.rows;
      // Select image_url and benefits from any mapped nutrient
      const rInfo = await db.query(`
        SELECT image_url, benefits
        FROM Nutrient n
        WHERE n.nutrient_id IN (SELECT nutrient_id FROM NutrientMapping WHERE fatty_acid_id = $1)
        ORDER BY (CASE WHEN COALESCE(image_url,'') <> '' THEN 0 ELSE 1 END), (CASE WHEN COALESCE(benefits,'') <> '' THEN 0 ELSE 1 END)
        LIMIT 1`, [id]);
      if (rInfo.rows.length > 0) {
        const rowInfo = rInfo.rows[0];
        if (rowInfo.image_url) row.image_url = rowInfo.image_url;
        if (rowInfo.benefits) row.benefits = rowInfo.benefits;
      }
      const rc = await db.query(`
        SELECT DISTINCT c.condition_name
        FROM NutrientMapping m
        JOIN NutrientContraindication c ON c.nutrient_id = m.nutrient_id
        WHERE m.fatty_acid_id = $1
        ORDER BY c.condition_name`, [id]);
      row.contraindications = rc.rows.map(r => r.condition_name);
    } catch (e) {
      console.warn('fatty detail enrichment failed', e && e.message);
    }
    return res.json(row);
  } catch (err) {
    console.error('fattyController.get error', err);
    return res.status(500).json({ error: 'internal_error' });
  }
}

module.exports = { list, get };
