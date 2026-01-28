const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const adminController = require('../controllers/adminController');
const authMiddleware = require('../utils/authMiddleware');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/login/mfa/verify', authController.loginMfaVerify);
// allow blocked users to submit an unblock request
router.post('/unblock-request', authController.submitUnblockRequest);
router.post('/admin/login', adminController.login);
router.post('/admin/register', adminController.register);
router.post('/admin/verify', adminController.verify);
router.get('/me', authMiddleware, authController.me);
router.put('/me', authMiddleware, authController.updateProfile);
router.post('/me/recompute-targets', authMiddleware, authController.recomputeTargets);
router.post('/me/recompute-daily-targets', authMiddleware, authController.recomputeDailyTargets);

// Security endpoints
router.get('/2fa/status', authMiddleware, authController.twoFaStatus);
router.post('/2fa/enable', authMiddleware, authController.twoFaEnable);
router.post('/2fa/verify', authMiddleware, authController.twoFaVerify);
router.post('/2fa/disable', authMiddleware, authController.twoFaDisable);
router.post('/password/change/request', authMiddleware, authController.requestPasswordChangeCode);
router.post('/password/change/confirm', authMiddleware, authController.confirmPasswordChange);
router.post('/security', authMiddleware, authController.updateSecurity);
router.post('/unlock/request', authController.requestUnlockCode);
router.post('/unlock/confirm', authController.confirmUnlockCode);
router.get('/notifications', authMiddleware, authController.notifications);

module.exports = router;
