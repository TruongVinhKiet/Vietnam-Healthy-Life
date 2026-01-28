const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController');
const authMiddleware = require('../utils/authMiddleware');

// All routes require authentication
router.use(authMiddleware);

// GET /recipes - Get all user's recipes
router.get('/', recipeController.getRecipes);

// GET /recipes/:recipeId - Get recipe by ID with ingredients
router.get('/:recipeId', recipeController.getRecipeById);

// POST /recipes - Create a new recipe
router.post('/', recipeController.createRecipe);

// PUT /recipes/:recipeId - Update a recipe
router.put('/:recipeId', recipeController.updateRecipe);

// DELETE /recipes/:recipeId - Delete a recipe
router.delete('/:recipeId', recipeController.deleteRecipe);

// POST /recipes/add-as-meal - Add recipe as meal
router.post('/add-as-meal', recipeController.addRecipeAsMeal);

module.exports = router;
