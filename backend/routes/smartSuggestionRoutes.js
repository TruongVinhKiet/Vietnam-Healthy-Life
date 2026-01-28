const express = require('express');
const router = express.Router();
const smartSuggestionController = require('../controllers/smartSuggestionController');
const authMiddleware = require('../utils/authMiddleware');

// All routes require authentication
router.use(authMiddleware);

// Smart suggestions
router.get('/smart', smartSuggestionController.getSmartSuggestions);
router.get('/context', smartSuggestionController.getContext);
router.get('/missing', smartSuggestionController.getMissingNutrients);

// Pin management
router.post('/pin', smartSuggestionController.pinSuggestion);
router.delete('/pin', smartSuggestionController.unpinSuggestion);
router.get('/pinned', smartSuggestionController.getPinnedSuggestions);

// User preferences
router.post('/preferences', smartSuggestionController.setFoodPreference);
router.get('/preferences', smartSuggestionController.getFoodPreferences);

module.exports = router;
