const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/fiberController');

// GET /fibers?top=10  - public; if Authorization header present, returns recommended_for_user
router.get('/', ctrl.listFibers);

// GET /fibers/:id
router.get('/:id', ctrl.getFiber);

module.exports = router;
