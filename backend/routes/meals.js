const express = require('express');
const router = express.Router();
const mealController = require('../controllers/mealController');
const authMiddleware = require('../utils/authMiddleware');

// Create a meal with items. Body: { meal_type, meal_date (YYYY-MM-DD), items: [{food_id, weight_g}] }
router.post('/', authMiddleware, mealController.createMeal);

// Add dish to meal
router.post('/add-dish', authMiddleware, mealController.addDishToMeal);

// Add food to meal
router.post('/add-food', authMiddleware, mealController.addFoodToMeal);

module.exports = router;
