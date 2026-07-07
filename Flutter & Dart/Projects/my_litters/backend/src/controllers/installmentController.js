const installmentService = require('../services/installmentService');
const { success, error } = require('../utils/response');

exports.list = async (req, res) => {
  try {
    const plans = await installmentService.listForUser(req.user.sub);
    return success(res, plans);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};

exports.pay = async (req, res) => {
  try {
    const installment = await installmentService.payInstallment(
      req.user.sub,
      req.params.id
    );
    return success(res, installment, 201);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};
