const subscriptionService = require('../services/subscriptionService');
const installmentService = require('../services/installmentService');
const { success, error } = require('../utils/response');

exports.listPlans = async (req, res) => {
  try {
    const plans = await subscriptionService.listPlans();
    return success(res, plans);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};

exports.getActive = async (req, res) => {
  try {
    const sub = await subscriptionService.getActiveForUser(req.user.sub);
    return success(res, sub);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};

exports.getCredit = async (req, res) => {
  try {
    const credit = await subscriptionService.availableCredit(req.user.sub);
    return success(res, credit);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};

exports.subscribe = async (req, res) => {
  try {
    const sub = await subscriptionService.subscribe(req.user.sub, req.body);
    return success(res, sub, 201);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};

// BNPL checkout: subscribe and finance the plan total over 1-4 installments,
// settling the first one now. Body: { planId, months, billingDay? }.
exports.checkout = async (req, res) => {
  try {
    const result = await installmentService.checkout(req.user.sub, req.body);
    return success(res, result, 201);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};
