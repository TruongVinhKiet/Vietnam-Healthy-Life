const express = require('express');
const router = express.Router();
const portionController = require('../controllers/portionController');
const authMiddleware = require('../utils/authMiddleware');

// GET /portions/:foodId - Get portion suggestions for a food (public + user-specific)
router.get('/:foodId', portionController.getPortionSuggestions);

// POST /portions - Add custom portion size (requires auth)
router.post('/', authMiddleware, portionController.addCustomPortion);

// GET /portions/calculate/nutrition - Calculate nutrition for a portion
router.get('/calculate/nutrition', portionController.calculatePortionNutrition);

module.exports = router;
