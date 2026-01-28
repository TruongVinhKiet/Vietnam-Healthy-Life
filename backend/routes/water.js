const express = require('express');
const router = express.Router();
const auth = require('../utils/authMiddleware');
const ctrl = require('../controllers/waterController');
const periodCtrl = require('../controllers/waterPeriodController');

router.post('/', auth, ctrl.logWater);
router.get('/catalog', auth, ctrl.listDrinks);
router.get('/timeline', auth, ctrl.getTimeline);
router.get('/period-summary', auth, periodCtrl.getWaterPeriodSummary);
router.get('/detail/:id', auth, ctrl.getDrinkDetail);
router.post('/custom-drink', auth, ctrl.createCustomDrink);
router.delete('/custom-drink/:id', auth, ctrl.deleteCustomDrink);

module.exports = router;
