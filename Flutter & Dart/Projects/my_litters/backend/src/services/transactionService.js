const prisma = require('../config/db');
const cardService = require('./cardService');

/**
 * Period boundaries for the running monthly liter cap.
 * Uses calendar month for the MVP — we can switch to subscription.billingDay
 * later when invoice generation is wired up.
 */
const monthBounds = (date = new Date()) => {
  const start = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), 1));
  const end = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth() + 1, 1));
  return { start, end };
};

const round3 = (n) => Math.round(Number(n) * 1000) / 1000;

const decline = (subscription, card, fuelType, liters, ppl, reason) => ({
  data: {
    userId: card.userId,
    cardId: card.id,
    subscriptionId: subscription?.id,
    liters,
    pricePerLiter: ppl,
    totalAmount: round3(liters * ppl),
    fuelType,
    status: 'declined',
    declineReason: reason,
  },
});

/**
 * Authorize and record an NFC-tap fuel transaction.
 * Caller is the staff/cashier (req.user.role === 'staff' | 'admin').
 *
 * Returns the created Transaction row, including a `decision` field.
 */
exports.authorizeTap = async ({
  cardUid,
  liters,
  fuelType,
  stationId,
  vehicleId,
  staffUserId,
}) => {
  if (!cardUid) throw Object.assign(new Error('cardUid required'), { status: 400 });
  if (!liters || Number(liters) <= 0)
    throw Object.assign(new Error('liters must be > 0'), { status: 400 });
  if (!fuelType) throw Object.assign(new Error('fuelType required'), { status: 400 });

  const litersN = round3(liters);

  const card = await cardService.findByUid(cardUid);
  if (!card) throw Object.assign(new Error('Unknown card'), { status: 404 });

  // Stub-out authorization checks one at a time so a decline still
  // produces a recorded row in the txn ledger.
  let txn;

  if (card.status !== 'active') {
    txn = await prisma.transaction.create(
      decline(null, card, fuelType, litersN, 0, `Card status: ${card.status}`),
    );
    return txn;
  }

  const subscription = await prisma.subscription.findFirst({
    where: { userId: card.userId, status: 'active' },
    include: { plan: true },
  });
  if (!subscription) {
    txn = await prisma.transaction.create(
      decline(null, card, fuelType, litersN, 0, 'No active subscription'),
    );
    return txn;
  }

  if (subscription.plan.fuelType !== fuelType) {
    txn = await prisma.transaction.create(
      decline(
        subscription, card, fuelType, litersN,
        Number(subscription.plan.pricePerLiter),
        `Fuel type mismatch: plan is ${subscription.plan.fuelType}`,
      ),
    );
    return txn;
  }

  const ppl = Number(subscription.plan.pricePerLiter);
  const total = round3(litersN * ppl);

  // Available BNPL credit = creditLimit − unbilled approved spend
  const aggSpend = await prisma.transaction.aggregate({
    where: {
      subscriptionId: subscription.id,
      status: 'approved',
      invoiceId: null,
    },
    _sum: { totalAmount: true },
  });
  const unbilled = Number(aggSpend._sum.totalAmount || 0);
  const available = Number(subscription.creditLimit) - unbilled;
  if (total > available) {
    txn = await prisma.transaction.create(
      decline(
        subscription, card, fuelType, litersN, ppl,
        `Over credit limit (need ${total.toFixed(3)}, have ${available.toFixed(3)})`,
      ),
    );
    return txn;
  }

  // Monthly liter cap (calendar month for MVP)
  const { start, end } = monthBounds();
  const aggLiters = await prisma.transaction.aggregate({
    where: {
      subscriptionId: subscription.id,
      status: 'approved',
      tappedAt: { gte: start, lt: end },
    },
    _sum: { liters: true },
  });
  const usedLiters = Number(aggLiters._sum.liters || 0);
  if (usedLiters + litersN > subscription.plan.monthlyLitersLimit) {
    txn = await prisma.transaction.create(
      decline(
        subscription, card, fuelType, litersN, ppl,
        `Over monthly liter cap (${subscription.plan.monthlyLitersLimit}L)`,
      ),
    );
    return txn;
  }

  // Approved
  txn = await prisma.transaction.create({
    data: {
      userId: card.userId,
      cardId: card.id,
      subscriptionId: subscription.id,
      stationId: stationId || null,
      vehicleId: vehicleId || null,
      liters: litersN,
      pricePerLiter: ppl,
      totalAmount: total,
      fuelType,
      status: 'approved',
    },
  });
  return txn;
};

exports.listForUser = (userId, { limit = 50 } = {}) =>
  prisma.transaction.findMany({
    where: { userId },
    orderBy: { tappedAt: 'desc' },
    take: limit,
    include: { station: true, card: { select: { label: true, cardUid: true } } },
  });
