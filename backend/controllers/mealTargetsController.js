const mealTargetsService = require('../services/mealTargetsService');
const { getVietnamDate } = require('../utils/dateHelper');

async function getMealTargets(req, res) {
  try {
    const userId = req.user.user_id;
    const date = req.query.date || getVietnamDate();
    const rows = await mealTargetsService.getTargetsForDate(userId, date);
    return res.json({ date, targets: rows });
  } catch (err) {
    console.error('getMealTargets error', err);
    return res.status(500).json({ error: 'Server error' });
  }
}

async function putMealTargets(req, res) {
  try {
    const userId = req.user.user_id;
    const date = req.body.date || getVietnamDate();
    const targets = req.body.targets || [];
    if (!Array.isArray(targets)) return res.status(400).json({ error: 'targets must be an array' });
    const updated = await mealTargetsService.upsertTargets(userId, date, targets);
    return res.json({ date, targets: updated });
  } catch (err) {
    console.error('putMealTargets error', err);
    return res.status(500).json({ error: 'Server error' });
  }
}

module.exports = { getMealTargets, putMealTargets };
