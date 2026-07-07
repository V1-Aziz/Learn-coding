const prisma = require('../config/db');

exports.listPlans = () =>
  prisma.plan.findMany({ where: { isActive: true }, orderBy: { name: 'asc' } });

exports.getActiveForUser = (userId) =>
  prisma.subscription.findFirst({
    where: { userId, status: 'active' },
    include: { plan: true },
  });

/**
 * Compute remaining BNPL credit for a user's active subscription.
 * Returns { creditLimit, unbilledBalance, availableCredit } as numbers.
 */
exports.availableCredit = async (userId) => {
  const sub = await exports.getActiveForUser(userId);
  if (!sub) return null;
  const agg = await prisma.transaction.aggregate({
    where: {
      subscriptionId: sub.id,
      status: 'approved',
      invoiceId: null,
    },
    _sum: { totalAmount: true },
  });
  const unbilled = Number(agg._sum.totalAmount || 0);
  const limit = Number(sub.creditLimit);
  return {
    subscriptionId: sub.id,
    creditLimit: limit,
    unbilledBalance: unbilled,
    availableCredit: limit - unbilled,
    plan: sub.plan,
  };
};

/**
 * Subscribe a user to a plan. Cancels any prior active subscription
 * (one-active-per-user is enforced by a partial unique index).
 */
exports.subscribe = async (userId, { planId, creditLimit, billingDay }) => {
  const plan = await prisma.plan.findUnique({ where: { id: planId } });
  if (!plan || !plan.isActive) {
    const e = new Error('Plan not found');
    e.status = 404;
    throw e;
  }
  return prisma.$transaction(async (tx) => {
    await tx.subscription.updateMany({
      where: { userId, status: 'active' },
      data: { status: 'canceled', endsAt: new Date() },
    });
    return tx.subscription.create({
      data: {
        userId,
        planId,
        creditLimit: creditLimit ?? '500.000',
        billingDay: billingDay ?? 1,
      },
      include: { plan: true },
    });
  });
};
