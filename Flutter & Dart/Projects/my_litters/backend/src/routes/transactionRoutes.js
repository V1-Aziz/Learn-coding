const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');
const { requireAuth, requireRole } = require('../middleware/auth');

router.use(requireAuth);

router.get('/', transactionController.listMine);
router.post('/authorize', requireRole('staff', 'admin'), transactionController.authorize);

module.exports = router;
