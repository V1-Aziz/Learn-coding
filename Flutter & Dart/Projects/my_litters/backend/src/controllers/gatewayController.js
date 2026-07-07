const gatewayService = require('../services/gatewayService');
const { success, error } = require('../utils/response');

// Create a charge (Tap-shaped). Returns the charge; a live integration would
// also return a hosted `transactionUrl` to redirect the customer to.
exports.createCharge = async (req, res) => {
  try {
    const charge = await gatewayService.createCharge(req.body || {});
    return success(res, charge, 201);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};

// Confirm/settle a charge. In simulated mode the client calls this after the
// mock checkout; with a real gateway this logic lives in the signed webhook.
exports.confirmCharge = async (req, res) => {
  try {
    const charge = await gatewayService.confirmCharge({
      chargeId: req.params.id,
      approve: req.body?.approve !== false,
      method: req.body?.method,
    });
    return success(res, charge);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};
