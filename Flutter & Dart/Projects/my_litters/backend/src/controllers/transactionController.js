const transactionService = require('../services/transactionService');
const { success, error } = require('../utils/response');

/**
 * POST /api/transactions/authorize
 * Body: { cardUid, liters, fuelType, stationId?, vehicleId? }
 * Auth: staff | admin only
 */
exports.authorize = async (req, res) => {
  try {
    const txn = await transactionService.authorizeTap({
      ...req.body,
      staffUserId: req.user.sub,
    });
    const status = txn.status === 'approved' ? 201 : 200;
    return success(res, txn, status);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};

/** GET /api/transactions — current user's history */
exports.listMine = async (req, res) => {
  try {
    const txns = await transactionService.listForUser(req.user.sub);
    return success(res, txns);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};
