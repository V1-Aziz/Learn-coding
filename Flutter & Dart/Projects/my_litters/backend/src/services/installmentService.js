const prisma = require('../config/db');
const { splitAmount, addMonths, planTotal } = require('../utils/money');

const ALLOWED_MONTHS = [1, 2, 3, 4];

/**
 * Subscribe + finance in one atomic step (the BNPL checkout).
 *
 * Cancels any prior active subscription, creates the new one, and builds an
 * installment plan splitting the plan's monthly total over `months`
 * installments. The first installment is marked paid immediately (the
 * payment the user makes at checkout) — that is what activates the plan.
 */
exports.checkout = async (userId, { planId, months, billingDay, creditLimit }) => {
  const n = Number(months) || 1;
  if (!ALLOWED_MONTHS.includes(n)) {
    const e = new Error('months must be 1, 2, 3 or 4');
    e.status = 400;
    throw e;
  }

  const plan = await prisma.plan.findUnique({ where: { id: planId } });
  if (!plan || !plan.isActive) {
    const e = new Error('Plan not found');
    e.status = 404;
    throw e;
  }

  const total = planTotal(plan);
  const parts = splitAmount(total, n);
  const now = new Date();

  return prisma.$transaction(async (tx) => {
    await tx.subscription.updateMany({
      where: { userId, status: 'active' },
      data: { status: 'canceled', endsAt: now },
    });

    const subscription = await tx.subscription.create({
      data: {
        userId,
        planId,
        creditLimit: creditLimit ?? '500.000',
        billingDay: billingDay ?? 1,
      },
      include: { plan: true },
    });

    const installmentPlan = await tx.installmentPlan.create({
      data: {
        userId,
        subscriptionId: subscription.id,
        totalAmount: total.toFixed(3),
        months: n,
        // months === 1 is settled in full at checkout.
        status: n === 1 ? 'completed' : 'active',
      },
    });

    const installmentsData = parts.map((amount, i) => {
      const seq = i + 1;
      const paidNow = seq === 1; // first installment settled at checkout
      return {
        installmentPlanId: installmentPlan.id,
        seq,
        amount: amount.toFixed(3),
        dueDate: addMonths(now, i),
        status: paidNow ? 'paid' : 'pending',
        paidAt: paidNow ? now : null,
      };
    });
    await tx.installment.createMany({ data: installmentsData });

    const installments = await tx.installment.findMany({
      where: { installmentPlanId: installmentPlan.id },
      orderBy: { seq: 'asc' },
    });

    return { subscription, installmentPlan: { ...installmentPlan, installments } };
  });
};

/**
 * List the user's installment plans (most recent first) with their
 * installments and the plan/subscription they belong to, so the app can
 * render the BNPL schedule.
 */
exports.listForUser = (userId) =>
  prisma.installmentPlan.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
    include: {
      installments: { orderBy: { seq: 'asc' } },
      subscription: { include: { plan: true } },
    },
  });

/** Pay (simulate) a single pending installment. Completes the plan when last. */
exports.payInstallment = async (userId, installmentId) => {
  const installment = await prisma.installment.findUnique({
    where: { id: installmentId },
    include: { installmentPlan: true },
  });
  if (!installment || installment.installmentPlan.userId !== userId) {
    const e = new Error('Installment not found');
    e.status = 404;
    throw e;
  }
  if (installment.status === 'paid') {
    const e = new Error('Installment already paid');
    e.status = 409;
    throw e;
  }

  return prisma.$transaction(async (tx) => {
    const paid = await tx.installment.update({
      where: { id: installmentId },
      data: { status: 'paid', paidAt: new Date() },
    });

    const remaining = await tx.installment.count({
      where: {
        installmentPlanId: installment.installmentPlanId,
        status: 'pending',
      },
    });
    if (remaining === 0) {
      await tx.installmentPlan.update({
        where: { id: installment.installmentPlanId },
        data: { status: 'completed' },
      });
    }
    return paid;
  });
};

exports.splitAmount = splitAmount;
exports.addMonths = addMonths;
exports.planTotal = planTotal;
exports.ALLOWED_MONTHS = ALLOWED_MONTHS;
