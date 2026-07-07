/**
 * Seed script for the My Litters DB.
 *
 *   npm run db:seed
 *
 * Idempotent — running twice does not duplicate rows. Uses upsert on
 * stable natural keys (email for users, name for plans/stations).
 */

const bcrypt = require('bcryptjs');
const prisma = require('../src/config/db');

async function main() {
  // ---------- Plans ----------
  // Two tiers (Basic 200L, Plus 400L), each offered in three fuel grades.
  // Per-liter rate is fixed per grade; the monthly price shown in the app is
  // pricePerLiter * monthlyLitersLimit.
  const GRADE_RATE = { p91: '2.180', p95: '2.330', diesel: '1.790' };
  const TIERS = [
    { name: 'Basic', liters: 200, monthlyFee: '0', idBase: 1 },
    { name: 'Plus', liters: 400, monthlyFee: '15.000', idBase: 4 },
  ];
  const GRADES = ['p91', 'p95', 'diesel'];

  const planIds = {}; // `${tier}-${grade}` -> id
  for (const tier of TIERS) {
    for (let i = 0; i < GRADES.length; i++) {
      const grade = GRADES[i];
      const id =
        '00000000-0000-0000-0000-0000000000' +
        String(tier.idBase + i).padStart(2, '0');
      const data = {
        name: tier.name,
        fuelType: grade,
        monthlyLitersLimit: tier.liters,
        pricePerLiter: GRADE_RATE[grade],
        monthlyFee: tier.monthlyFee,
      };
      await prisma.plan.upsert({
        where: { id },
        update: data,
        create: { id, ...data },
      });
      planIds[`${tier.name}-${grade}`] = id;
    }
  }
  // Default plan for the demo customer's subscription.
  const plus95 = { id: planIds['Plus-p95'] };

  // ---------- Stations ----------
  await prisma.station.upsert({
    where: { id: '00000000-0000-0000-0000-000000000010' },
    update: {},
    create: {
      id: '00000000-0000-0000-0000-000000000010',
      name: 'My Litters — Demo Station',
      city: 'Riyadh',
      lat: '24.713600',
      lng: '46.675300',
    },
  });

  // ---------- Users ----------
  const adminPassword = await bcrypt.hash('admin12345', 10);
  await prisma.user.upsert({
    where: { email: 'admin@my-litters.dev' },
    update: {},
    create: {
      email: 'admin@my-litters.dev',
      passwordHash: adminPassword,
      fullName: 'Demo Admin',
      role: 'admin',
    },
  });

  const customerPassword = await bcrypt.hash('demo12345', 10);
  const customer = await prisma.user.upsert({
    where: { email: 'demo@my-litters.dev' },
    update: {},
    create: {
      email: 'demo@my-litters.dev',
      passwordHash: customerPassword,
      fullName: 'Demo Customer',
      role: 'customer',
      phone: '+966500000000',
    },
  });

  // ---------- Subscription for the demo customer ----------
  const existingSub = await prisma.subscription.findFirst({
    where: { userId: customer.id, status: 'active' },
  });
  if (!existingSub) {
    await prisma.subscription.create({
      data: {
        userId: customer.id,
        planId: plus95.id,
        creditLimit: '900.000',
        billingDay: 1,
      },
    });
  }

  console.log('✓ Seed complete.');
  console.log('  Admin:    admin@my-litters.dev  /  admin12345');
  console.log('  Customer: demo@my-litters.dev   /  demo12345');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
