const express = require('express');
const router = express.Router();
const nutrientTrackingController = require('../controllers/nutrientTrackingController');
const db = require('../db');
const { getVietnamDate } = require('../utils/dateHelper');

// Dev-only endpoint: accepts body { user_id, food_name, nutrients }
// Calls the existing approveScanNutrition controller while bypassing auth.
router.post('/approve-scan', async (req, res) => {
  try {
    const { user_id, food_name, nutrients } = req.body;
    if (!user_id || !Array.isArray(nutrients)) {
      return res.status(400).json({ success: false, message: 'user_id and nutrients[] required' });
    }

    // Build a fake req object for the controller
    const fakeReq = {
      user: { user_id },
      body: { food_name: food_name || 'dev: simulated food', nutrients }
    };

    // Reuse the controller which will send a response via the real res
    return nutrientTrackingController.approveScanNutrition(fakeReq, res);
  } catch (err) {
    console.error('Debug approve-scan error:', err);
    res.status(500).json({ success: false, message: 'internal error', error: err.message });
  }
});

// Dev-only endpoint: fetch daily tracking for a user (bypasses auth)
router.get('/tracking/:user_id', async (req, res) => {
  try {
    const userId = parseInt(req.params.user_id, 10);
    if (Number.isNaN(userId)) return res.status(400).json({ success: false, message: 'invalid user id' });

    const today = getVietnamDate();
    const result = await db.query(`
      SELECT nutrient_type, nutrient_id, SUM(current_amount) as current_amount, unit
      FROM UserNutrientTracking
      WHERE user_id = $1 AND date = $2
      GROUP BY nutrient_type, nutrient_id, unit
    `, [userId, today]);

    res.json({ success: true, date: today, user_id: userId, tracking: result.rows });
  } catch (err) {
    console.error('Debug tracking error:', err);
    res.status(500).json({ success: false, message: 'internal error', error: err.message });
  }
});

module.exports = router;
