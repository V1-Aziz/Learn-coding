const prisma = require('../config/db');
const invoiceService = require('./invoiceService');

/**
 * Close the billing period for every active subscription and flag any
 * invoice whose due date has passed. Designed to be run on a schedule
 * (cron / a worker) or triggered by an admin.
 *
 * Invoice generation is idempotent per (subscription, period), so running
 * this repeatedly in the same month is safe — it just recomputes totals.
 */

/** Marks open/due invoices whose dueDate is before today as `overdue`. */
async function markOverdueInvoices(asOf = new Date()) {
  const today = new Date(
    Date.UTC(asOf.getUTCFullYear(), asOf.getUTCMonth(), asOf.getUTCDate()),
  );
  const res = await prisma.invoice.updateMany({
    where: {
      status: { in: ['open', 'due'] },
      dueDate: { lt: today },
    },
    data: { status: 'overdue' },
  });
  return res.count;
}

/** Runs invoice generation for all active subscriptions. */
async function generateAllInvoices(asOf) {
  const subs = await prisma.subscription.findMany({
    where: { status: 'active' },
    select: { userId: true },
  });

  let generated = 0;
  let skipped = 0;
  const errors = [];

  for (const { userId } of subs) {
    try {
      await invoiceService.generateForUser(userId, asOf ? { asOf } : {});
      generated += 1;
    } catch (e) {
      // 409 = nothing to bill this period, 404 = no active sub anymore.
      if (e.status === 409 || e.status === 404) {
        skipped += 1;
      } else {
        errors.push({ userId, message: e.message });
      }
    }
  }
  return { total: subs.length, generated, skipped, errors };
}

/**
 * The full monthly billing pass: generate invoices, then flag overdue ones.
 * Returns a report suitable for logging or an admin response.
 */
exports.runBilling = async ({ asOf } = {}) => {
  const when = asOf ? new Date(asOf) : new Date();
  const invoices = await generateAllInvoices(asOf);
  const overdue = await markOverdueInvoices(when);
  return {
    ranAt: new Date().toISOString(),
    asOf: when.toISOString(),
    invoices,
    markedOverdue: overdue,
  };
};

exports.markOverdueInvoices = markOverdueInvoices;
exports.generateAllInvoices = generateAllInvoices;
