const express = require('express');
const router = express.Router();
const cardController = require('../controllers/cardController');
const { requireAuth } = require('../middleware/auth');

router.use(requireAuth);

router.get('/', cardController.list);
router.post('/', cardController.link);
router.post('/:id/block', cardController.block);
router.post('/:id/unblock', cardController.unblock);

module.exports = router;
