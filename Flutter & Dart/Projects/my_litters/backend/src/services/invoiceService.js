const prisma = require('../config/db');

const round3 = (n) => Math.round(Number(n) * 1000) / 1000;

/**
 * Calendar-month boundaries (UTC) for the period an invoice covers.
 * `start` is the first of the month, `endExclusive` is the first of the
 * next month, and `endInclusive` is the last day of the month (stored on
 * the invoice as period_end, a DATE column).
 */
const monthBounds = (date = new Date()) => {
  const y = date.getUTCFullYear();
  const m = date.getUTCMonth();
  return {
    start: new Date(Date.UTC(y, m, 1)),
    endInclusive: new Date(Date.UTC(y, m + 1, 0)),
    endExclusive: new Date(Date.UTC(y, m + 1, 1)),
    // Repayment is due two weeks into the following month for the demo.
    dueDate: new Date(Date.UTC(y, m + 1, 14)),
  };
};

/**
 * Close the current billing period for a user's active subscription:
 * bundle all unbilled approved transactions in the period into a single
 * invoice and stamp those transactions with the new invoice id.
 *
 * Idempotent within a period — if an invoice already exists for the
 * (subscription, periodStart) pair it is reused and its totals recomputed
 * from every transaction now linked to it.
 *
 * Returns the invoice with its linked transactions.
 */
exports.generateForUser = async (userId, { asOf } = {}) => {
  const sub = await prisma.subscription.findFirst({
    where: { userId, status: 'active' },
    include: { plan: true },
  });
  if (!sub) {
    throw Object.assign(new Error('No active subscription'), { status: 404 });
  }

  const { start, endInclusive, endExclusive, dueDate } = monthBounds(
    asOf ? new Date(asOf) : new Date(),
  );
  const monthlyFee = round3(Number(sub.plan.monthlyFee));

  return prisma.$transaction(async (tx) => {
    const unbilled = await tx.transaction.findMany({
      where: {
        subscriptionId: sub.id,
        status: 'approved',
        invoiceId: null,
        tappedAt: { gte: start, lt: endExclusive },
      },
      select: { id: true },
    });
    if (unbilled.length === 0) {
      throw Object.assign(
        new Error('No unbilled transactions to invoice for this period'),
        { status: 409 },
      );
    }

    let invoice = await tx.invoice.findUnique({
      where: {
        subscriptionId_periodStart: {
          subscriptionId: sub.id,
          periodStart: start,
        },
      },
    });
    if (!invoice) {
      invoice = await tx.invoice.create({
        data: {
          userId,
          subscriptionId: sub.id,
          periodStart: start,
          periodEnd: endInclusive,
          monthlyFee,
          dueDate,
          status: 'due',
        },
      });
    }

    await tx.transaction.updateMany({
      where: { id: { in: unbilled.map((t) => t.id) } },
      data: { invoiceId: invoice.id },
    });

    // Recompute totals from every approved transaction now on this invoice
    // so re-running stays consistent.
    const agg = await tx.transaction.aggregate({
      where: { invoiceId: invoice.id, status: 'approved' },
      _sum: { totalAmount: true },
    });
    const subtotal = round3(Number(agg._sum.totalAmount || 0));

    return tx.invoice.update({
      where: { id: invoice.id },
      data: {
        subtotal,
        monthlyFee,
        total: round3(subtotal + monthlyFee),
        status: invoice.status === 'paid' ? 'paid' : 'due',
      },
      include: { transactions: true },
    });
  });
};
