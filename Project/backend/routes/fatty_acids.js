const express = require('express');
const router = express.Router();
const fattyController = require('../controllers/fattyController');

// GET /fatty-acids
router.get('/', fattyController.list);
// GET /fatty-acids/:id
router.get('/:id', fattyController.get);

module.exports = router;
