const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { requireAuth } = require('../middleware/auth');
const { authLimiter } = require('../middleware/rateLimit');

router.post('/signup', authLimiter, authController.signup);
router.post('/login', authLimiter, authController.login);
router.get('/me', requireAuth, authController.me);

module.exports = router;
