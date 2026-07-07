/**
 * Pure money/date helpers with no database dependency, so they can be unit
 * tested in isolation. Shared by the installment and invoice services.
 */

/** Round to 3 decimal places (the DB stores Decimal(12,3)). */
const round3 = (n) => Math.round(Number(n) * 1000) / 1000;

/**
 * Split a total into `months` equal installments at 3-decimal precision.
 * Work in integer "milli-units" to avoid floating-point drift, then push any
 * rounding remainder onto the FIRST installment (paid at checkout).
 * e.g. splitAmount(466, 3) -> [155.334, 155.333, 155.333].
 */
function splitAmount(total, months) {
  const totalMilli = Math.round(Number(total) * 1000);
  const base = Math.floor(totalMilli / months);
  const remainder = totalMilli - base * months;
  const parts = [];
  for (let i = 0; i < months; i++) {
    const milli = base + (i === 0 ? remainder : 0);
    parts.push(milli / 1000);
  }
  return parts;
}

/** Add `n` whole months to a date, clamping the day on overflow. */
function addMonths(date, n) {
  const d = new Date(date);
  const day = d.getDate();
  d.setMonth(d.getMonth() + n);
  if (d.getDate() < day) d.setDate(0); // e.g. Jan 31 + 1 month -> Feb 28/29
  return d;
}

/** The plan's monthly total: fuel (price x liter cap) plus the monthly fee. */
function planTotal(plan) {
  return (
    Number(plan.pricePerLiter) * plan.monthlyLitersLimit +
    Number(plan.monthlyFee)
  );
}

module.exports = { round3, splitAmount, addMonths, planTotal };
