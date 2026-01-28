const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/aminoController');

// GET /amino_acids?top=6
router.get('/', ctrl.listAmino);

// GET /amino_acids/:id
router.get('/:id', ctrl.getAmino);

module.exports = router;
