const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const prisma = require('../config/db');
const env = require('../config/env');

const SALT_ROUNDS = 10;

const sanitize = (user) => {
  if (!user) return null;
  const { passwordHash, ...rest } = user;
  return rest;
};

const sign = (user) =>
  jwt.sign(
    { sub: user.id, role: user.role, email: user.email },
    env.jwtSecret,
    { expiresIn: env.jwtExpiresIn },
  );

exports.signup = async ({ email, password, fullName, phone }) => {
  const normalized = String(email).trim().toLowerCase();
  const existing = await prisma.user.findUnique({ where: { email: normalized } });
  if (existing) {
    const e = new Error('Email already in use');
    e.status = 409;
    throw e;
  }
  const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);
  const user = await prisma.user.create({
    data: {
      email: normalized,
      passwordHash,
      fullName,
      phone: phone || null,
      role: 'customer',
    },
  });
  return { token: sign(user), user: sanitize(user) };
};

exports.login = async ({ email, password }) => {
  const normalized = String(email).trim().toLowerCase();
  const user = await prisma.user.findUnique({ where: { email: normalized } });
  if (!user) {
    const e = new Error('Invalid credentials');
    e.status = 401;
    throw e;
  }
  const ok = await bcrypt.compare(password, user.passwordHash);
  if (!ok) {
    const e = new Error('Invalid credentials');
    e.status = 401;
    throw e;
  }
  return { token: sign(user), user: sanitize(user) };
};

exports.me = async (userId) => {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) {
    const e = new Error('User not found');
    e.status = 404;
    throw e;
  }
  return sanitize(user);
};

exports.verify = (token) => jwt.verify(token, env.jwtSecret);
