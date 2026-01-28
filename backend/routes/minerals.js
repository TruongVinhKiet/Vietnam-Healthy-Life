const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/mineralController');

// GET /minerals?top=6  - public; if Authorization header present, returns recommended_for_user
router.get('/', ctrl.listMinerals);

// GET /minerals/:id
router.get('/:id', ctrl.getMineral);

module.exports = router;
