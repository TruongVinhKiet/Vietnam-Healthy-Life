const express = require('express');
const router = express.Router();
const mealHistoryController = require('../controllers/mealHistoryController');
const authMiddleware = require('../utils/authMiddleware');

// All routes require authentication
router.use(authMiddleware);

// GET /meal-history - Get user's meal history with pagination
router.get('/', mealHistoryController.getMealHistory);

// GET /meal-history/quick-add - Get quick add suggestions
router.get('/quick-add', mealHistoryController.getQuickAddSuggestions);

// GET /meal-history/stats - Get meal statistics
router.get('/stats', mealHistoryController.getMealStats);
router.get('/period-summary', mealHistoryController.getMealPeriodSummary);

// POST /meal-history/favorite - Toggle favorite status
router.post('/favorite', mealHistoryController.toggleFavorite);

// POST /meal-history/quick-add - Quick add a meal
router.post('/quick-add', mealHistoryController.quickAddMeal);

module.exports = router;
