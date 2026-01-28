const express = require('express');
const router = express.Router();
const mealEntriesController = require('../controllers/mealEntriesController');
const authMiddleware = require('../utils/authMiddleware');

// POST create a meal entry: { entry_date, meal_type, food_id, weight_g }
router.post('/', authMiddleware, mealEntriesController.postMealEntry);

module.exports = router;    