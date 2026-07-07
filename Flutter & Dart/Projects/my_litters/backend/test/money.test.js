const { test } = require('node:test');
const assert = require('node:assert/strict');
const { round3, splitAmount, addMonths, planTotal } = require('../src/utils/money');

test('splitAmount: months=1 returns the whole total', () => {
  assert.deepEqual(splitAmount(466, 1), [466]);
});

test('splitAmount: even split has no remainder', () => {
  assert.deepEqual(splitAmount(400, 4), [100, 100, 100, 100]);
});

test('splitAmount: remainder goes on the first installment', () => {
  // 466 / 3 = 155.333..., extra 0.001 milli-unit lands on installment #1
  assert.deepEqual(splitAmount(466, 3), [155.334, 155.333, 155.333]);
});

test('splitAmount: parts always sum back to the total', () => {
  for (const total of [466, 199.99, 1000.005, 33.333, 500]) {
    for (const months of [1, 2, 3, 4]) {
      const parts = splitAmount(total, months);
      assert.equal(parts.length, months);
      const sum = round3(parts.reduce((a, b) => a + b, 0));
      assert.equal(sum, round3(total), `sum mismatch for ${total}/${months}`);
    }
  }
});

test('splitAmount: never produces a negative or NaN part', () => {
  for (const part of splitAmount(0.001, 4)) {
    assert.ok(part >= 0 && Number.isFinite(part));
  }
});

test('addMonths: simple advance', () => {
  const d = addMonths(new Date('2026-01-15T00:00:00Z'), 2);
  assert.equal(d.getMonth(), 2); // March (0-indexed)
});

test('addMonths: clamps end-of-month overflow', () => {
  // Jan 31 + 1 month should land on the last day of February, not March.
  const d = addMonths(new Date(2026, 0, 31), 1);
  assert.equal(d.getMonth(), 1); // February
  assert.ok(d.getDate() === 28 || d.getDate() === 29);
});

test('addMonths: does not mutate its input', () => {
  const original = new Date(2026, 0, 15);
  const copy = new Date(original);
  addMonths(original, 3);
  assert.equal(original.getTime(), copy.getTime());
});

test('planTotal: fuel cost plus monthly fee', () => {
  const plan = { pricePerLiter: 2.18, monthlyLitersLimit: 200, monthlyFee: 15 };
  // 2.18 * 200 + 15 = 451
  assert.equal(round3(planTotal(plan)), 451);
});

test('planTotal: zero fee', () => {
  const plan = { pricePerLiter: 2.33, monthlyLitersLimit: 100, monthlyFee: 0 };
  assert.equal(round3(planTotal(plan)), 233);
});

test('planTotal + splitAmount: a realistic checkout balances', () => {
  const plan = { pricePerLiter: 2.18, monthlyLitersLimit: 200, monthlyFee: 15 };
  const total = planTotal(plan); // 451
  const parts = splitAmount(total, 4);
  assert.equal(round3(parts.reduce((a, b) => a + b, 0)), round3(total));
});
