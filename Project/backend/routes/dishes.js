/**
 * dishes.js
 * 
 * Express routes for Dish Management System
 * Handles routing for dish CRUD operations, ingredients, and statistics
 */

const express = require('express');
const router = express.Router();
const dishController = require('../controllers/dishController');
const dishNotificationController = require('../controllers/dishNotificationController');
const imageUploadController = require('../controllers/imageUploadController');

// Import middleware (assuming these exist in your project)
// Adjust paths based on your actual middleware location
const authMiddleware = require('../utils/authMiddleware');  // User authentication
const adminMiddleware = require('../utils/adminMiddleware');  // Admin authentication
const { requireRole } = require('../utils/roleMiddleware');  // RBAC

/**
 * PUBLIC ROUTES (no authentication required)
 */

// Search dishes (for meal logging - users can search before login)
router.get('/search', dishController.searchDishes);

// Get dish categories
router.get('/categories', dishController.getCategories);

// Get popular dishes
router.get('/popular', dishController.getPopularDishes);

// Check if dish name exists (public route for validation)
router.get('/check-name', dishController.checkNameExists);

/**
 * USER ROUTES (require user authentication)
 */

// Get all dishes (with filters)
router.get('/', authMiddleware, dishController.getAllDishes);

// Get single dish by ID
router.get('/:id', authMiddleware, dishController.getDishById);

// Create a new dish (user can create custom dishes)
router.post('/', authMiddleware, dishController.createDish);

// Update dish (user can only update their own dishes)
router.put('/:id', authMiddleware, dishController.updateDish);

// Delete dish (soft delete for users)
router.delete('/:id', authMiddleware, dishController.deleteDish);

// Get dish nutrients
router.get('/:id/nutrients', authMiddleware, dishController.getDishNutrients);

// Get dish nutrients (admin)
router.get(
  '/admin/:id/nutrients',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager', 'analyst']),
  dishController.getDishNutrients
);

// Manage ingredients (user can manage their own dish ingredients)
router.post('/:id/ingredients', authMiddleware, dishController.addIngredient);
router.put('/ingredients/:ingredientId', authMiddleware, dishController.updateIngredient);
router.delete('/ingredients/:ingredientId', authMiddleware, dishController.removeIngredient);

/**
 * ADMIN ROUTES (require admin authentication and permissions)
 */

// Get all dishes for admin management (with filter for templates, user dishes, etc.)
router.get(
  '/admin/all',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager', 'analyst']),
  dishController.getAllDishes
);

// Get dashboard statistics (admin only)
router.get(
  '/stats/dashboard',
  adminMiddleware,
  requireRole(['super_admin', 'analyst', 'content_manager']),
  dishController.getDashboardStats
);

// Admin dish management (content_manager role)
router.get(
  '/admin/:id',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager', 'analyst']),
  dishController.getDishById
);

router.post(
  '/admin/create',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager']),
  dishController.createDish
);

router.put(
  '/admin/:id',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager']),
  dishController.updateDish
);

// Approve user-created dish to become public template
router.post(
  '/admin/:id/approve',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager']),
  dishController.approveDish
);

// Recalculate dish nutrients (admin only)
router.post(
  '/:id/recalculate',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager']),
  dishController.recalculateNutrients
);

// Admin ingredient management
router.post(
  '/admin/:id/ingredients',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager']),
  dishController.addIngredient
);

router.put(
  '/admin/ingredients/:ingredientId',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager']),
  dishController.updateIngredient
);

router.delete(
  '/admin/ingredients/:ingredientId',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager']),
  dishController.removeIngredient
);

// Admin can force hard delete (more specific route, must come FIRST)
router.delete(
  '/admin/:id/hard',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager']),
  dishController.deleteDish
);

// Admin delete dish (regular delete, will handle soft/hard based on usage)
router.delete(
  '/admin/:id',
  adminMiddleware,
  requireRole(['super_admin', 'content_manager']),
  dishController.deleteDish
);

/**
 * DISH NOTIFICATIONS (user authentication required)
 */
router.get('/notifications', authMiddleware, dishNotificationController.getUserNotifications);
router.put('/notifications/:notificationId/read', authMiddleware, dishNotificationController.markAsRead);
router.put('/notifications/read-all', authMiddleware, dishNotificationController.markAllAsRead);
router.delete('/notifications/:notificationId', authMiddleware, dishNotificationController.deleteNotification);

/**
 * IMAGE UPLOAD (user authentication required)
 */
router.post('/upload-image', authMiddleware, imageUploadController.uploadDishImage);
router.delete('/delete-image', authMiddleware, imageUploadController.deleteDishImage);

module.exports = router;
