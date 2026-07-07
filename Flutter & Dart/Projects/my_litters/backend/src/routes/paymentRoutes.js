const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const gatewayController = require('../controllers/gatewayController');
const { requireAuth, requireRole } = require('../middleware/auth');

router.use(requireAuth);

router.get('/invoices', paymentController.listInvoices);
router.post('/invoices/generate', paymentController.generateInvoice);
router.post('/billing/run', requireRole('admin'), paymentController.runBilling);
// Payment gateway (Tap-shaped; simulated until real keys are configured).
router.post('/gateway/charge', gatewayController.createCharge);
router.post('/gateway/:id/confirm', gatewayController.confirmCharge);
router.get('/', paymentController.listPayments);
router.post('/pay', paymentController.pay);

module.exports = router;
