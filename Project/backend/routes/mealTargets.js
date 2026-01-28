const express = require('express');
const router = express.Router();
const mealTargetsController = require('../controllers/mealTargetsController');
const authMiddleware = require('../utils/authMiddleware');

router.get('/', authMiddleware, mealTargetsController.getMealTargets);
router.put('/', authMiddleware, mealTargetsController.putMealTargets);

module.exports = router;
