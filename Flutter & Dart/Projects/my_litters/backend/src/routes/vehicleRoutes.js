const express = require('express');
const router = express.Router();
const vehicleController = require('../controllers/vehicleController');
const { requireAuth } = require('../middleware/auth');

router.use(requireAuth);

router.get('/', vehicleController.list);
router.post('/', vehicleController.create);
router.delete('/:id', vehicleController.remove);

module.exports = router;
