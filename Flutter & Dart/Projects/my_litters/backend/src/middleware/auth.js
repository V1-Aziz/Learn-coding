const jwt = require('jsonwebtoken');
const env = require('../config/env');
const { error } = require('../utils/response');

/**
 * requireAuth: rejects requests without a valid Bearer JWT.
 * Decoded payload is attached as req.user (shape: { sub, role, email, iat, exp }).
 */
const requireAuth = (req, res, next) => {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) {
    return error(res, 'Missing bearer token', 401);
  }
  try {
    req.user = jwt.verify(token, env.jwtSecret);
    return next();
  } catch (err) {
    return error(res, 'Invalid or expired token', 401);
  }
};

/**
 * requireRole(...roles): chained after requireAuth. Returns 403 unless the
 * decoded JWT carries one of the allowed roles.
 *
 *   router.post('/cards', requireAuth, requireRole('admin', 'staff'), ...)
 */
const requireRole = (...roles) => (req, res, next) => {
  if (!req.user || !roles.includes(req.user.role)) {
    return error(res, 'Forbidden', 403);
  }
  return next();
};

module.exports = requireAuth;
module.exports.requireAuth = requireAuth;
module.exports.requireRole = requireRole;
