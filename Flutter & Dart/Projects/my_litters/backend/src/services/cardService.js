const prisma = require('../config/db');

const normalizeUid = (uid) => String(uid).replace(/[^A-Fa-f0-9]/g, '').toUpperCase();

exports.listForUser = (userId) =>
  prisma.card.findMany({ where: { userId }, orderBy: { linkedAt: 'desc' } });

/**
 * Link an NFC card UID to a user. If the same UID was previously linked
 * but blocked/lost, we 409 — the operator must rotate or unblock first.
 */
exports.link = async (userId, { cardUid, label }) => {
  if (!cardUid) {
    const e = new Error('cardUid is required');
    e.status = 400;
    throw e;
  }
  const uid = normalizeUid(cardUid);
  const existing = await prisma.card.findUnique({ where: { cardUid: uid } });
  if (existing) {
    const e = new Error('Card already registered');
    e.status = 409;
    throw e;
  }
  return prisma.card.create({
    data: { userId, cardUid: uid, label, status: 'active' },
  });
};

exports.findByUid = (cardUid) =>
  prisma.card.findUnique({
    where: { cardUid: normalizeUid(cardUid) },
    include: { user: true },
  });

exports.setStatus = async (userId, cardId, status) => {
  const card = await prisma.card.findUnique({ where: { id: cardId } });
  if (!card || card.userId !== userId) {
    const e = new Error('Card not found');
    e.status = 404;
    throw e;
  }
  return prisma.card.update({ where: { id: cardId }, data: { status } });
};

exports.normalizeUid = normalizeUid;
