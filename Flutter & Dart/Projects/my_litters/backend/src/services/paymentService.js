const prisma = require('../config/db');

exports.listInvoices = (userId) =>
  prisma.invoice.findMany({
    where: { userId },
    orderBy: { dueDate: 'desc' },
    include: { transactions: true },
  });

exports.listPayments = (userId) =>
  prisma.payment.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
    include: { invoice: true },
  });

/**
 * Mock payment: instantly marks the payment as completed and the
 * invoice as paid if the running total clears the invoice. Real
 * integration with Mada/STC Pay is out of scope for the MVP.
 */
exports.payInvoice = async (userId, { invoiceId, amount, method }) => {
  const invoice = await prisma.invoice.findUnique({ where: { id: invoiceId } });
  if (!invoice || invoice.userId !== userId) {
    const e = new Error('Invoice not found');
    e.status = 404;
    throw e;
  }
  if (invoice.status === 'paid') {
    const e = new Error('Invoice already paid');
    e.status = 409;
    throw e;
  }

  return prisma.$transaction(async (tx) => {
    const payment = await tx.payment.create({
      data: {
        invoiceId,
        userId,
        amount,
        method: method || 'card',
        status: 'completed',
        paidAt: new Date(),
      },
    });

    const totals = await tx.payment.aggregate({
      where: { invoiceId, status: 'completed' },
      _sum: { amount: true },
    });
    const paidSoFar = Number(totals._sum.amount || 0);
    if (paidSoFar >= Number(invoice.total)) {
      await tx.invoice.update({
        where: { id: invoiceId },
        data: { status: 'paid', paidAt: new Date() },
      });
    }
    return payment;
  });
};
