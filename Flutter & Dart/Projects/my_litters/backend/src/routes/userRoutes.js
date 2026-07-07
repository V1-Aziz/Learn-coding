const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { requireAuth } = require('../middleware/auth');

router.use(requireAuth);

// Convenience endpoints for the signed-in user — keeps the Flutter
// client from having to know its own user id.
router.get('/me', userController.getMe);
router.patch('/me', userController.updateMe);

router.get('/:id', userController.getUser);
router.patch('/:id', userController.updateUser);

module.exports = router;
