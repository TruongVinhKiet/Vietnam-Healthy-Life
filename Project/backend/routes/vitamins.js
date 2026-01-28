const express = require('express');
const router = express.Router();
const auth = require('../utils/authMiddleware');
const ctrl = require('../controllers/vitaminController');

// GET /vitamins?top=10  - public; if Authorization header present, returns recommended_for_user
router.get('/', ctrl.listVitamins);

// GET /vitamins/:id
router.get('/:id', ctrl.getVitamin);

module.exports = router;
