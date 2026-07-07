const paymentService = require('../services/paymentService');
const invoiceService = require('../services/invoiceService');
const billingService = require('../services/billingService');
const { success, error } = require('../utils/response');

exports.listInvoices = async (req, res) => {
  try {
    const invoices = await paymentService.listInvoices(req.user.sub);
    return success(res, invoices);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};

exports.listPayments = async (req, res) => {
  try {
    const payments = await paymentService.listPayments(req.user.sub);
    return success(res, payments);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};

exports.pay = async (req, res) => {
  try {
    const payment = await paymentService.payInvoice(req.user.sub, req.body);
    return success(res, payment, 201);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};

// Close the current billing period: bundle the signed-in user's unbilled
// approved transactions into an invoice. Stand-in for the scheduled
// end-of-period billing job described in PROJECT_PLAN.md.
exports.generateInvoice = async (req, res) => {
  try {
    const invoice = await invoiceService.generateForUser(req.user.sub, req.body || {});
    return success(res, invoice, 201);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};

// Admin-only: run the full billing pass for all active subscriptions and
// flag overdue invoices. The same work runs headless via scripts/runBilling.js.
exports.runBilling = async (req, res) => {
  try {
    const report = await billingService.runBilling(req.body || {});
    return success(res, report);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};
