const smartSuggestionService = require('../services/smartSuggestionService');

/**
 * GET /api/suggestions/smart
 * Get smart dish/drink suggestions
 * Query params: type (dish|drink|both), limit (5|10|null)
 */
async function getSmartSuggestions(req, res) {
    try {
        const userId = req.user.user_id;
        const { type = 'both', limit } = req.query;
        
        const limitNum = limit ? parseInt(limit) : null;
        
        const suggestions = await smartSuggestionService.getSmartSuggestions(userId, {
            type,
            limit: limitNum
        });
        
        res.json({
            success: true,
            type,
            limit: limitNum,
            count: suggestions.length,
            suggestions
        });
    } catch (error) {
        console.error('Get smart suggestions error:', error);
        res.status(500).json({ 
            error: 'Failed to get suggestions',
            message: error.message 
        });
    }
}

/**
 * GET /api/suggestions/context
 * Get user context (for UI display)
 */
async function getContext(req, res) {
    try {
        const userId = req.user.user_id;
        const context = await smartSuggestionService.getContext(userId);
        
        if (!context) {
            return res.status(404).json({ error: 'User context not found' });
        }
        
        res.json({
            success: true,
            context
        });
    } catch (error) {
        console.error('Get context error:', error);
        res.status(500).json({ 
            error: 'Failed to get context',
            message: error.message 
        });
    }
}

/**
 * GET /api/smart-suggestions/missing
 * Get missing nutrients (macros + micronutrients) for the day
 * Query: date (optional, YYYY-MM-DD)
 */
async function getMissingNutrients(req, res) {
    try {
        const userId = req.user.user_id;
        const { date } = req.query;

        const payload = await smartSuggestionService.getMissingNutrients(
            userId,
            date || null
        );

        res.json({
            success: true,
            ...payload
        });
    } catch (error) {
        console.error('Get missing nutrients error:', error);
        res.status(500).json({
            error: 'Failed to get missing nutrients',
            message: error.message
        });
    }
}

/**
 * POST /api/suggestions/pin
 * Pin a suggestion
 * Body: { item_type: 'dish'|'drink', item_id: number, meal_period: string }
 */
async function pinSuggestion(req, res) {
    try {
        const userId = req.user.user_id;
        const { item_type, item_id, meal_period } = req.body;
        
        if (!item_type || !item_id) {
            return res.status(400).json({ 
                error: 'item_type and item_id are required' 
            });
        }
        
        if (!['dish', 'drink'].includes(item_type)) {
            return res.status(400).json({ 
                error: 'item_type must be "dish" or "drink"' 
            });
        }
        
        const pin = await smartSuggestionService.pinSuggestion(
            userId, 
            item_type, 
            item_id, 
            meal_period
        );
        
        res.json({
            success: true,
            message: 'Đã ghim gợi ý',
            pin
        });
    } catch (error) {
        console.error('Pin suggestion error:', error);
        res.status(500).json({ 
            error: 'Failed to pin suggestion',
            message: error.message 
        });
    }
}

/**
 * DELETE /api/suggestions/pin
 * Unpin a suggestion
 * Body: { item_type: 'dish'|'drink', item_id: number }
 */
async function unpinSuggestion(req, res) {
    try {
        const userId = req.user.user_id;
        const { item_type, item_id } = req.body;
        
        if (!item_type || !item_id) {
            return res.status(400).json({ 
                error: 'item_type and item_id are required' 
            });
        }
        
        await smartSuggestionService.unpinSuggestion(userId, item_type, item_id);
        
        res.json({
            success: true,
            message: 'Đã bỏ ghim gợi ý'
        });
    } catch (error) {
        console.error('Unpin suggestion error:', error);
        res.status(500).json({ 
            error: 'Failed to unpin suggestion',
            message: error.message 
        });
    }
}

/**
 * GET /api/suggestions/pinned
 * Get user's pinned suggestions
 */
async function getPinnedSuggestions(req, res) {
    try {
        const userId = req.user.user_id;
        const pins = await smartSuggestionService.getPinnedSuggestions(userId);
        
        res.json({
            success: true,
            count: pins.length,
            pins
        });
    } catch (error) {
        console.error('Get pinned suggestions error:', error);
        res.status(500).json({ 
            error: 'Failed to get pinned suggestions',
            message: error.message 
        });
    }
}

/**
 * POST /api/suggestions/preferences
 * Add/update user food preference
 * Body: { food_id, preference_type, intensity, notes }
 */
async function setFoodPreference(req, res) {
    try {
        const userId = req.user.user_id;
        const { food_id, preference_type, intensity, notes } = req.body;
        
        if (!food_id || !preference_type) {
            return res.status(400).json({ 
                error: 'food_id and preference_type are required' 
            });
        }
        
        if (!['allergy', 'dislike', 'favorite'].includes(preference_type)) {
            return res.status(400).json({ 
                error: 'preference_type must be "allergy", "dislike", or "favorite"' 
            });
        }
        
        const preference = await smartSuggestionService.setFoodPreference(
            userId, 
            food_id, 
            preference_type, 
            intensity || 3,
            notes
        );
        
        res.json({
            success: true,
            message: 'Đã lưu sở thích',
            preference
        });
    } catch (error) {
        console.error('Set food preference error:', error);
        res.status(500).json({ 
            error: 'Failed to set preference',
            message: error.message 
        });
    }
}

/**
 * GET /api/suggestions/preferences
 * Get user food preferences
 * Query: preference_type (optional)
 */
async function getFoodPreferences(req, res) {
    try {
        const userId = req.user.user_id;
        const { preference_type } = req.query;
        
        const preferences = await smartSuggestionService.getFoodPreferences(
            userId, 
            preference_type
        );
        
        res.json({
            success: true,
            count: preferences.length,
            preferences
        });
    } catch (error) {
        console.error('Get food preferences error:', error);
        res.status(500).json({ 
            error: 'Failed to get preferences',
            message: error.message 
        });
    }
}

module.exports = {
    getSmartSuggestions,
    getContext,
    getMissingNutrients,
    pinSuggestion,
    unpinSuggestion,
    getPinnedSuggestions,
    setFoodPreference,
    getFoodPreferences
};
