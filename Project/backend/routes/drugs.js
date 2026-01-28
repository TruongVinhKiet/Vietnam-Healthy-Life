const express = require("express");
const router = express.Router();
const adminMiddleware = require("../utils/adminMiddleware");
const authMiddleware = require("../utils/authMiddleware");
const { requireRole } = require("../utils/roleMiddleware");
const drugController = require("../controllers/drugController");
const medicationController = require("../controllers/medicationController");

// ============================================================
// ADMIN ROUTES
// ============================================================

// Drug statistics
router.get("/admin/stats", adminMiddleware, drugController.getDrugStats);

// List drugs
router.get(
  "/admin",
  adminMiddleware,
  requireRole(["content_manager", "analyst"]),
  drugController.listDrugs
);

// Get drug details
router.get(
  "/admin/:id",
  adminMiddleware,
  requireRole(["content_manager", "analyst"]),
  drugController.getDrugDetails
);

// Create drug
router.post(
  "/admin",
  adminMiddleware,
  requireRole("content_manager"),
  drugController.createDrug
);

// Update drug
router.put(
  "/admin/:id",
  adminMiddleware,
  requireRole("content_manager"),
  drugController.updateDrug
);

// Delete drug
router.delete(
  "/admin/:id",
  adminMiddleware,
  requireRole("content_manager"),
  drugController.deleteDrug
);

// ============================================================
// USER ROUTES
// ============================================================

// Get drugs for a condition
router.get(
  "/conditions/:conditionId/drugs",
  authMiddleware,
  medicationController.getDrugsForCondition
);

// Log medication taken
router.post("/log", authMiddleware, medicationController.logMedication);

// Check drug-nutrient interaction
router.get(
  "/check-interaction",
  authMiddleware,
  medicationController.checkInteraction
);

// Get medication history statistics
router.get(
  "/history/stats",
  authMiddleware,
  medicationController.getMedicationHistoryStats
);

// Get medication schedule
router.get(
  "/schedule",
  authMiddleware,
  medicationController.getMedicationSchedule
);

// Get all drugs (for user selection)
router.get("/drugs", authMiddleware, medicationController.getAllDrugs);

module.exports = router;
