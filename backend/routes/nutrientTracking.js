const express = require('express');
const router = express.Router();
const authMiddleware = require('../utils/authMiddleware');
const nutrientTrackingController = require('../controllers/nutrientTrackingController');

// All routes require authentication
router.use(authMiddleware);

// Daily tracking
router.get('/tracking/daily', nutrientTrackingController.getDailyTracking);
router.get('/tracking/breakdown', nutrientTrackingController.getNutrientBreakdown);
router.post('/tracking/update', nutrientTrackingController.updateTracking);
router.post('/approve-scan', nutrientTrackingController.approveScanNutrition);

// Deficiency checking
router.post('/tracking/check-deficiencies', nutrientTrackingController.checkDeficiencies);

// Notifications
router.get('/tracking/notifications', nutrientTrackingController.getNotifications);
router.put('/tracking/notifications/:id/read', nutrientTrackingController.markNotificationRead);
router.put('/tracking/notifications/read-all', nutrientTrackingController.markAllNotificationsRead);

// Summary and reports
router.get('/tracking/summary', nutrientTrackingController.getSummary);
router.get('/tracking/report', nutrientTrackingController.getComprehensiveReport);

module.exports = router;
