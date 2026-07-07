const express = require('express');
const router = express.Router();
const installmentController = require('../controllers/installmentController');
const { requireAuth } = require('../middleware/auth');

router.use(requireAuth);

router.get('/', installmentController.list);
router.post('/:id/pay', installmentController.pay);

module.exports = router;
