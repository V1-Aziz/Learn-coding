const rateLimit = require('express-rate-limit');

/**
 * Brute-force protection for credential endpoints. 20 attempts per IP per
 * 15 minutes is generous for real users but shuts down password spraying.
 */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many attempts. Please try again in a few minutes.',
  },
});

module.exports = { authLimiter };
