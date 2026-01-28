const mealEntriesService = require('../services/mealEntriesService');
const { getVietnamDate } = require('../utils/dateHelper');

async function postMealEntry(req, res) {
  try {
    const userId = req.user.user_id;
    const { entry_date, meal_type, food_id, weight_g } = req.body || {};
    if (!meal_type || !food_id || !weight_g) return res.status(400).json({ error: 'meal_type, food_id and weight_g required' });
    const date = entry_date || getVietnamDate();
    const result = await mealEntriesService.createMealEntry(userId, date, meal_type, Number(food_id), Number(weight_g));
    return res.status(201).json({ entry_id: result.entryId, nutrients: result.nutrients });
  } catch (err) {
    console.error('postMealEntry error', err);
    return res.status(500).json({ error: 'Server error' });
  }
}

module.exports = { postMealEntry };
