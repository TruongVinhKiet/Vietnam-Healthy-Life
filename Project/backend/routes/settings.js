const express = require('express');
const router = express.Router();
const settingsController = require('../controllers/settingsController');
const authMiddleware = require('../utils/authMiddleware');

router.get('/', authMiddleware, settingsController.getSettings);
router.put('/', authMiddleware, settingsController.updateSettings);
router.post('/weather/refresh', authMiddleware, settingsController.refreshWeather);

module.exports = router;
