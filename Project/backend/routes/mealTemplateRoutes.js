const express = require('express');
const router = express.Router();
const mealTemplateController = require('../controllers/mealTemplateController');
const authMiddleware = require('../utils/authMiddleware');

// All routes require authentication
router.use(authMiddleware);

// GET /meal-templates - Get all user's templates
router.get('/', mealTemplateController.getTemplates);

// GET /meal-templates/:templateId - Get template by ID with items
router.get('/:templateId', mealTemplateController.getTemplateById);

// POST /meal-templates - Create a new template
router.post('/', mealTemplateController.createTemplate);

// POST /meal-templates/save-current - Save current meal as template
router.post('/save-current', mealTemplateController.saveCurrentMealAsTemplate);

// PUT /meal-templates/:templateId - Update a template
router.put('/:templateId', mealTemplateController.updateTemplate);

// DELETE /meal-templates/:templateId - Delete a template
router.delete('/:templateId', mealTemplateController.deleteTemplate);

// POST /meal-templates/apply - Apply template to add all items
router.post('/apply', mealTemplateController.applyTemplate);

module.exports = router;
