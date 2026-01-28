const waterService = require('../services/waterService');
const drinkService = require('../services/drinkService');
const db = require('../db');

async function logWater(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });
  const {
    amount_ml,
    date,
    drink_id,
    hydration_ratio,
    drink_name,
    notes,
  } = req.body || {};
  if (!amount_ml || isNaN(Number(amount_ml))) {
    return res
      .status(400)
      .json({ error: 'amount_ml is required and must be a number' });
  }
  try {
    const totals = await waterService.createWaterEntry(
      user.user_id,
      Number(amount_ml),
      date,
      {
        drink_id,
        hydration_ratio,
        drink_name,
        notes,
      }
    );
    if (totals && totals.last_drink_at) {
      totals.last_drink_at = new Date(totals.last_drink_at).toISOString();
    }
    return res.status(201).json({ success: true, today: totals });
  } catch (err) {
    console.error('logWater error', err);
    return res.status(500).json({ error: 'Failed to log water' });
  }
}

async function listDrinks(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });
  try {
    const drinks = await waterService.getDrinkCatalog(user.user_id);
    res.json({ success: true, drinks });
  } catch (err) {
    console.error('[waterController] listDrinks error', err);
    res.status(500).json({ error: 'Failed to load drinks' });
  }
}

async function getTimeline(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });
  try {
    const timeline = await waterService.getWaterTimeline(user.user_id, req.query.date);
    res.json({ success: true, timeline });
  } catch (err) {
    console.error('[waterController] getTimeline error', err);
    res.status(500).json({ error: 'Failed to load water timeline' });
  }
}

async function createCustomDrink(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });
  try {
    const drink = await drinkService.createCustomDrink(user.user_id, req.body || {});
    res.status(201).json({ success: true, drink });
  } catch (err) {
    console.error('[waterController] createCustomDrink error', err);
    res.status(400).json({ error: err.message || 'Failed to create drink' });
  }
}

async function getDrinkDetail(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });
  try {
    const drinkId = Number(req.params.id);
    if (!drinkId) return res.status(400).json({ error: 'Invalid drink id' });
    const drink = await drinkService.getDrinkDetail(drinkId, user.user_id);
    if (!drink) return res.status(404).json({ error: 'Drink not found' });
    res.json({ success: true, drink });
  } catch (err) {
    console.error('[waterController] getDrinkDetail error', err);
    res.status(500).json({ error: 'Failed to load drink detail' });
  }
}

async function deleteCustomDrink(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });
  try {
    const drinkId = Number(req.params.id);
    if (!drinkId) return res.status(400).json({ error: 'Invalid drink id' });
    const deleted = await drinkService.deleteUserDrink(drinkId, user.user_id);
    if (!deleted) {
      const check = await db.query(
        `
        SELECT drink_id, is_public, is_template
        FROM Drink
        WHERE drink_id = $1 AND created_by_user = $2
        `,
        [drinkId, user.user_id]
      );

      if (check.rowCount === 0) {
        return res.status(404).json({ error: 'Drink not found' });
      }

      const row = check.rows[0];
      if (row.is_public === true || row.is_template === true) {
        return res.status(403).json({
          error: 'Cannot delete an approved/public drink',
        });
      }

      return res.status(500).json({ error: 'Failed to delete drink' });
    }
    res.json({ success: true });
  } catch (err) {
    console.error('[waterController] deleteCustomDrink error', err);
    res.status(500).json({ error: 'Failed to delete drink' });
  }
}

module.exports = { logWater, listDrinks, getTimeline, createCustomDrink, getDrinkDetail, deleteCustomDrink };