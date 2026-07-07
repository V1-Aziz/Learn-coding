const crypto = require('crypto');
const env = require('../config/env');

/**
 * Payment-gateway abstraction, modeled on Tap's create-charge → confirm flow.
 *
 * Currently runs in SIMULATED mode: no external HTTP call, no real money.
 * When you're ready to go live with Tap, replace the body of `createCharge`
 * with a POST to https://api.tap.company/v2/charges using `env.tapSecretKey`,
 * return the provider's charge id + `transaction.url`, and validate the
 * webhook signature instead of trusting `confirmCharge`. The controller,
 * routes, and Flutter client stay the same.
 */

const round3 = (n) => Math.round(Number(n) * 1000) / 1000;

// Mirrors Tap "source" ids so the swap is 1:1 later.
const ALLOWED_METHODS = ['src_all', 'src_card', 'src_mada', 'src_tamara', 'src_tabby'];

exports.ALLOWED_METHODS = ALLOWED_METHODS;

exports.createCharge = async ({ amount, currency = 'SAR', method = 'src_all', metadata = {} }) => {
  const amt = Number(amount);
  if (!amt || amt <= 0) {
    throw Object.assign(new Error('amount must be greater than 0'), { status: 400 });
  }
  if (!ALLOWED_METHODS.includes(method)) {
    throw Object.assign(new Error(`Unsupported payment method: ${method}`), { status: 400 });
  }

  // --- SWAP POINT: real Tap call goes here when env.tapSecretKey is set. ---
  // For now, produce a simulated charge that the client "completes" locally.
  return {
    id: `chg_sim_${crypto.randomUUID()}`,
    object: 'charge',
    status: 'INITIATED',
    amount: round3(amt),
    currency,
    method,
    live: Boolean(env.tapSecretKey), // false today; a signal for later
    simulated: !env.tapSecretKey,
    transactionUrl: null, // a real gateway returns a hosted checkout URL here
    metadata,
  };
};

/**
 * Simulated settlement. With a real gateway this is replaced by the webhook:
 * verify the signature, read the provider's status, and never trust the client.
 */
exports.confirmCharge = async ({ chargeId, approve = true, method }) => {
  if (!chargeId) {
    throw Object.assign(new Error('chargeId is required'), { status: 400 });
  }
  return {
    id: chargeId,
    status: approve ? 'CAPTURED' : 'DECLINED',
    method,
    simulated: !env.tapSecretKey,
  };
};
