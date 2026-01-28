const express = require('express');
const router = express.Router();
const foodController = require('../controllers/foodController');
const authMiddleware = require('../utils/authMiddleware');
const adminMiddleware = require('../utils/adminMiddleware');

// Public routes (no authentication required)
router.get('/search', foodController.searchFoods);
router.get('/:id', foodController.getFoodById);

// Admin-only routes
router.get('/', adminMiddleware, foodController.getAllFoods);
router.post('/', adminMiddleware, foodController.createFood);
router.put('/:id', adminMiddleware, foodController.updateFood);
router.delete('/:id', adminMiddleware, foodController.deleteFood);
router.get('/stats/summary', adminMiddleware, foodController.getFoodStats);
router.get('/nutrients/available', adminMiddleware, foodController.getAvailableNutrients);

module.exports = router;
