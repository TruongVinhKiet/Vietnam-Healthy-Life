const express = require("express");
const router = express.Router();
const adminMiddleware = require("../utils/adminMiddleware");
const { requireRole, requireSuperAdmin, attachRoles } = require("../utils/roleMiddleware");
const adminController = require("../controllers/adminController");
const dashboardController = require("../controllers/adminDashboardController");
const adminAiController = require("../controllers/adminAiController");
const drinkController = require("../controllers/drinkController");
const activityController = require("../controllers/adminActivityController");
const approvalLogController = require("../controllers/adminApprovalLogController");
const roleController = require("../controllers/roleController");
const { sse } = require("../controllers/adminController");

// Simple admin-only ping endpoint for testing role-based access
router.get("/ping", adminMiddleware, (req, res) => {
  try {
    return res.json({
      ok: true,
      admin: { admin_id: req.admin.admin_id, username: req.admin.username },
    });
  } catch (err) {
    console.error("admin ping error", err);
    return res.status(500).json({ error: "Server error" });
  }
});

// Dashboard stats (All authenticated admins)
router.get(
  "/dashboard/stats",
  adminMiddleware,
  attachRoles,
  dashboardController.getDashboardStats
);

// Admin notifications via Server-Sent Events
router.get('/events', adminMiddleware, sse);

// User Management (User Manager or Super Admin)
router.get("/users", adminMiddleware, requireRole(['user_manager', 'analyst', 'support']), dashboardController.getUsers);
router.get("/users/:id", adminMiddleware, requireRole(['user_manager', 'analyst', 'support']), dashboardController.getUserDetails);
router.delete("/users/:id", adminMiddleware, requireRole('user_manager'), dashboardController.deleteUser);
router.post('/users/:id/block', adminMiddleware, requireRole('user_manager'), dashboardController.blockUser);
router.post('/users/:id/unblock', adminMiddleware, requireRole(['user_manager', 'support']), dashboardController.unblockUser);
router.get('/unblock-requests', adminMiddleware, requireRole(['user_manager', 'support']), dashboardController.getUnblockRequests);
router.post('/unblock-requests/:id/decision', adminMiddleware, requireRole(['user_manager', 'support']), dashboardController.decideUnblockRequest);

// User Activity Analytics (Analyst, User Manager, or Super Admin)
router.get('/users/:userId/activity', adminMiddleware, requireRole(['analyst', 'user_manager']), activityController.getUserActivityLogs);
router.get('/users/:userId/activity/analytics', adminMiddleware, requireRole(['analyst', 'user_manager']), activityController.getUserActivityAnalytics);
router.post('/users/:userId/activity', adminMiddleware, requireRole('user_manager'), activityController.logUserActivity);
router.get('/activity/overview', adminMiddleware, requireRole(['analyst', 'user_manager']), activityController.getAllUsersActivityOverview);

router.get(
  "/approval-logs",
  adminMiddleware,
  requireRole(['super_admin', 'content_manager', 'analyst']),
  approvalLogController.listApprovalLogs
);

// Food Management (Content Manager or Super Admin)
router.get("/foods", adminMiddleware, requireRole(['content_manager', 'analyst']), dashboardController.getFoods);
router.get("/foods/:id", adminMiddleware, requireRole(['content_manager', 'analyst']), dashboardController.getFoodDetails);
router.post("/foods", adminMiddleware, requireRole('content_manager'), dashboardController.upsertFood);
router.put("/foods/:id", adminMiddleware, requireRole('content_manager'), dashboardController.upsertFood);
router.delete("/foods/:id", adminMiddleware, requireRole('content_manager'), dashboardController.deleteFood);

// Drink Management
router.get(
  "/drinks",
  adminMiddleware,
  requireRole(['content_manager', 'analyst']),
  drinkController.listAdminDrinks
);
router.get(
  "/drinks/:id",
  adminMiddleware,
  requireRole(['content_manager', 'analyst']),
  drinkController.getDrinkDetails
);
router.post(
  "/drinks",
  adminMiddleware,
  requireRole('content_manager'),
  drinkController.upsertDrink
);
router.put(
  "/drinks/:id",
  adminMiddleware,
  requireRole('content_manager'),
  drinkController.upsertDrink
);
router.delete(
  "/drinks/:id",
  adminMiddleware,
  requireRole('content_manager'),
  drinkController.deleteDrink
);
router.get(
  "/drinks/check-name",
  adminMiddleware,
  requireRole('content_manager'),
  drinkController.checkNameExists
);

router.post(
  "/drinks/:id/approve",
  adminMiddleware,
  requireRole(['super_admin', 'content_manager']),
  drinkController.approveUserDrink
);

// Nutrient Management (Content Manager or Super Admin)
router.get("/nutrients", adminMiddleware, requireRole(['content_manager', 'analyst']), dashboardController.getNutrients);
router.get(
  "/nutrients/:id",
  adminMiddleware,
  requireRole(['content_manager', 'analyst']),
  dashboardController.getNutrientDetails
);
router.post("/nutrients", adminMiddleware, requireRole('content_manager'), dashboardController.upsertNutrient);
router.put(
  "/nutrients/:id",
  adminMiddleware,
  requireRole('content_manager'),
  dashboardController.upsertNutrient
);
router.delete(
  "/nutrients/:id",
  adminMiddleware,
  requireRole('content_manager'),
  dashboardController.deleteNutrient
);

// Health Condition Management (Content Manager or Super Admin)
router.get(
  "/conditions",
  adminMiddleware,
  requireRole(['content_manager', 'analyst']),
  dashboardController.getHealthConditions
);
router.get(
  "/conditions/:id",
  adminMiddleware,
  requireRole(['content_manager', 'analyst']),
  dashboardController.getConditionDetails
);
router.post(
  "/conditions",
  adminMiddleware,
  requireRole('content_manager'),
  dashboardController.createHealthCondition
);
router.put(
  "/conditions/:id",
  adminMiddleware,
  requireRole('content_manager'),
  dashboardController.updateHealthCondition
);
router.delete(
  "/conditions/:id",
  adminMiddleware,
  requireRole('content_manager'),
  dashboardController.deleteHealthCondition
);
router.post(
  "/conditions/effects",
  adminMiddleware,
  requireRole('content_manager'),
  dashboardController.upsertConditionEffect
);
router.post(
  "/conditions/recommendations",
  adminMiddleware,
  requireRole('content_manager'),
  dashboardController.upsertConditionFoodRecommendation
);
router.delete(
  "/conditions/recommendations/:id",
  adminMiddleware,
  requireRole('content_manager'),
  dashboardController.deleteConditionRecommendation
);

// Drug Management (Content Manager or Super Admin)
const drugController = require("../controllers/drugController");
router.get(
  "/drugs",
  adminMiddleware,
  requireRole(['content_manager', 'analyst']),
  drugController.listDrugs
);
router.get(
  "/drugs/stats",
  adminMiddleware,
  drugController.getDrugStats
);
router.get(
  "/drugs/:id",
  adminMiddleware,
  requireRole(['content_manager', 'analyst']),
  drugController.getDrugDetails
);
router.post(
  "/drugs",
  adminMiddleware,
  requireRole('content_manager'),
  drugController.createDrug
);
router.put(
  "/drugs/:id",
  adminMiddleware,
  requireRole('content_manager'),
  drugController.updateDrug
);
router.delete(
  "/drugs/:id",
  adminMiddleware,
  requireRole('content_manager'),
  drugController.deleteDrug
);

// Role Management (Super Admin Only)
router.get('/admins', adminMiddleware, requireSuperAdmin, adminController.getAllAdmins);
router.get('/roles/all', adminMiddleware, requireSuperAdmin, roleController.getAllRoles);
router.get('/roles/my-roles', adminMiddleware, attachRoles, roleController.getMyRoles);
router.get('/roles/permissions', adminMiddleware, attachRoles, roleController.getRolePermissions);
router.get('/roles/admins/:adminId', adminMiddleware, requireSuperAdmin, roleController.getAdminRoles);
router.post('/roles/admins/:adminId/assign', adminMiddleware, requireSuperAdmin, roleController.assignRoleToAdmin);
router.delete('/roles/admins/:adminId/remove', adminMiddleware, requireSuperAdmin, roleController.removeRoleFromAdmin);

// App Settings (Analyst or Super Admin)
router.get(
  "/settings/stats",
  adminMiddleware,
  requireRole(['analyst', 'user_manager', 'content_manager']),
  dashboardController.getAppSettings
);

// Bulk import foods (Content Manager or Super Admin only)
router.post("/import-foods", adminMiddleware, requireRole('content_manager'), async (req, res) => {
  try {
    return await adminController.importFoods(req, res);
  } catch (err) {
    console.error("admin import route error", err);
    return res.status(500).json({ error: "Server error" });
  }
});

// AI management (Analyst / Content Manager / Super Admin)
router.get(
  "/ai-meals",
  adminMiddleware,
  requireRole(["content_manager", "analyst"]),
  adminAiController.listAiMeals
);
router.post(
  "/ai-meals/:id/promote",
  adminMiddleware,
  requireRole(["content_manager", "analyst"]),
  adminAiController.promoteAiMeal
);
router.delete(
  "/ai-meals/:id/reject",
  adminMiddleware,
  requireRole(["content_manager", "analyst"]),
  adminAiController.rejectAiMeal
);

module.exports = router;
