require('dotenv').config();

const required = (name) => {
  const v = process.env[name];
  if (v === undefined || v === '') {
    throw new Error(`Missing required env var: ${name}`);
  }
  return v;
};

// Comma-separated allowlist of browser origins, e.g.
//   CORS_ORIGINS=https://app.mylitters.com,https://admin.mylitters.com
// When unset, CORS is left open (fine for local dev and native apps, which
// don't send a browser Origin header anyway).
const parseOrigins = (raw) => {
  if (!raw) return null;
  const list = raw.split(',').map((s) => s.trim()).filter(Boolean);
  return list.length ? list : null;
};

module.exports = {
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  databaseUrl: required('DATABASE_URL'),
  jwtSecret: required('JWT_SECRET'),
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  corsOrigins: parseOrigins(process.env.CORS_ORIGINS),
  // Payment gateway (Tap). Unset today → gateway runs in simulated mode.
  tapSecretKey: process.env.TAP_SECRET_KEY || null,
};
