const express = require('express');
const router = express.Router();
const dailyMealSuggestionController = require('../controllers/dailyMealSuggestionController');
const authenticateToken = require('../utils/authMiddleware');

/**
 * Daily Meal Suggestion Routes
 * Base path: /api/suggestions/daily-meals
 */

// All routes require authentication
router.use(authenticateToken);

/**
 * @route   POST /api/suggestions/daily-meals
 * @desc    Generate daily meal suggestions for current user
 * @access  Private
 * @body    { date?: string } - Optional date (YYYY-MM-DD), defaults to today
 */
router.post('/', dailyMealSuggestionController.generateSuggestions);

/**
 * @route   GET /api/suggestions/daily-meals
 * @desc    Get current user's daily meal suggestions
 * @access  Private
 * @query   date?: string - Optional date (YYYY-MM-DD), defaults to today
 */
router.get('/', dailyMealSuggestionController.getSuggestions);

/**
 * @route   GET /api/suggestions/daily-meals/stats
 * @desc    Get statistics about user's suggestions
 * @access  Private
 * @query   startDate?: string, endDate?: string
 */
router.get('/stats', dailyMealSuggestionController.getStats);
router.post('/consume', dailyMealSuggestionController.consumeSuggestion);

/**
 * @route   PUT /api/suggestions/daily-meals/:id/accept
 * @desc    Accept a meal suggestion
 * @access  Private
 * @param   id - Suggestion ID
 */
router.put('/:id/accept', dailyMealSuggestionController.acceptSuggestion);

/**
 * @route   PUT /api/suggestions/daily-meals/:id/reject
 * @desc    Reject a suggestion and generate a new one
 * @access  Private
 * @param   id - Suggestion ID
 */
router.put('/:id/reject', dailyMealSuggestionController.rejectSuggestion);

/**
 * @route   DELETE /api/suggestions/daily-meals/:id
 * @desc    Delete a suggestion
 * @access  Private
 * @param   id - Suggestion ID
 */
router.delete('/:id', dailyMealSuggestionController.deleteSuggestion);

/**
 * @route   POST /api/suggestions/daily-meals/cleanup
 * @desc    Manual cleanup of old suggestions (admin only)
 * @access  Private (Admin)
 */
router.post('/cleanup', dailyMealSuggestionController.cleanupOldSuggestions);

/**
 * @route   POST /api/suggestions/daily-meals/cleanup-passed
 * @desc    Cleanup passed meal suggestions for current user
 * @access  Private
 */
router.post('/cleanup-passed', dailyMealSuggestionController.cleanupPassedMeals);

module.exports = router;
