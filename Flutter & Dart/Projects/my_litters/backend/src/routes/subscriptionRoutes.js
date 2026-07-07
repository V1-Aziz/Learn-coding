const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscriptionController');
const { requireAuth } = require('../middleware/auth');

router.get('/plans', subscriptionController.listPlans);

router.use(requireAuth);
router.get('/active', subscriptionController.getActive);
router.get('/credit', subscriptionController.getCredit);
router.post('/', subscriptionController.subscribe);
router.post('/checkout', subscriptionController.checkout);

module.exports = router;
