// Singleton Prisma client — re-used across all hot reloads in dev so
// we don't exhaust the Postgres connection pool.
const { PrismaClient } = require('@prisma/client');
const env = require('./env');

const globalForPrisma = globalThis;

const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: env.nodeEnv === 'development' ? ['warn', 'error'] : ['error'],
  });

if (env.nodeEnv !== 'production') {
  globalForPrisma.prisma = prisma;
}

module.exports = prisma;
