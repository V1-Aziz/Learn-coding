#!/usr/bin/env node
/**
 * Monthly billing pass. Run manually or from cron:
 *
 *   node scripts/runBilling.js
 *   node scripts/runBilling.js --as-of=2026-07-01
 *
 * Example crontab (03:00 on the 1st of each month):
 *   0 3 1 * * cd /path/to/backend && node scripts/runBilling.js >> billing.log 2>&1
 */
require('dotenv').config();
const billingService = require('../src/services/billingService');
const prisma = require('../src/config/db');

function parseAsOf(argv) {
  const arg = argv.find((a) => a.startsWith('--as-of='));
  return arg ? arg.split('=')[1] : undefined;
}

(async () => {
  try {
    const asOf = parseAsOf(process.argv.slice(2));
    const report = await billingService.runBilling({ asOf });
    console.log('Billing run complete:');
    console.log(JSON.stringify(report, null, 2));
    process.exitCode = report.invoices.errors.length > 0 ? 1 : 0;
  } catch (err) {
    console.error('Billing run failed:', err);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
})();
