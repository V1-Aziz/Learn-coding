# My Litters — Backend API

Express + Prisma + PostgreSQL backend for the My Litters fuel BNPL card platform. See `../PROJECT_PLAN.md` for product context and `db/schema.sql` for a SQL-first reference of the same data model.

## Quick start

```bash
cd backend
cp .env.example .env             # fill in DATABASE_URL + JWT_SECRET
npm install
npx prisma migrate dev --name init   # create the DB schema
npm run db:seed                  # plans, demo admin + customer
npm run dev                      # → http://localhost:3000
```

Smoke-test:

```bash
curl http://localhost:3000/health
curl -X POST http://localhost:3000/api/auth/login \
     -H 'content-type: application/json' \
     -d '{"email":"demo@my-litters.dev","password":"demo12345"}'
```

## Structure

```
backend/
├── prisma/
│   ├── schema.prisma           # source of truth for DB schema
│   └── seed.js                 # idempotent demo seed
├── db/
│   └── schema.sql              # design reference (mirrors prisma/schema.prisma)
├── src/
│   ├── config/                 # env + Prisma client singleton
│   ├── controllers/            # thin request handlers (validation + delegation)
│   ├── routes/                 # Express route definitions
│   ├── services/               # business logic, talks to Prisma
│   ├── middleware/             # JWT auth + error handler
│   ├── utils/                  # shared response helpers
│   └── app.js                  # Express app setup
├── server.js                   # HTTP entry point
└── package.json
```

## API surface

All routes return `{ success, data | message }`. Authenticated routes require `Authorization: Bearer <jwt>`.

### Auth (public)

| Method | Path | Notes |
|---|---|---|
| POST | `/api/auth/signup` | `{ email, password, fullName, phone? }` → `{ token, user }` |
| POST | `/api/auth/login` | `{ email, password }` → `{ token, user }` |
| GET | `/api/auth/me` | _auth_ — returns the current user |

### Subscriptions

| Method | Path | Notes |
|---|---|---|
| GET | `/api/subscriptions/plans` | public catalog |
| GET | `/api/subscriptions/active` | _auth_ — current user's active subscription |
| GET | `/api/subscriptions/credit` | _auth_ — `{ creditLimit, unbilledBalance, availableCredit }` |
| POST | `/api/subscriptions` | _auth_ — `{ planId, creditLimit?, billingDay? }` |

### Cards

| Method | Path | Notes |
|---|---|---|
| GET | `/api/cards` | _auth_ — current user's cards |
| POST | `/api/cards` | _auth_ — `{ cardUid, label? }` |
| POST | `/api/cards/:id/block` | _auth_ |
| POST | `/api/cards/:id/unblock` | _auth_ |

### Transactions (NFC tap)

| Method | Path | Notes |
|---|---|---|
| GET | `/api/transactions` | _auth_ — current user's history |
| POST | `/api/transactions/authorize` | _staff/admin only_ — `{ cardUid, liters, fuelType, stationId?, vehicleId? }` returns `{ status: 'approved' | 'declined', declineReason? }` |

### Vehicles / Payments / Users

| Method | Path | Notes |
|---|---|---|
| GET / POST / DELETE | `/api/vehicles` (`/:id`) | _auth_ |
| GET | `/api/payments/invoices` | _auth_ |
| POST | `/api/payments/invoices/generate` | _auth_ — closes the current period: bundles unbilled approved transactions into one invoice. Optional `{ asOf }` to target a past month |
| GET | `/api/payments` | _auth_ |
| POST | `/api/payments/pay` | _auth_ — `{ invoiceId, amount, method? }` |
| GET / PATCH | `/api/users/:id` | _auth_ — owner or admin |

## Tap-to-pay decision flow

`POST /api/transactions/authorize` walks these checks in order, recording **every** outcome (approved or declined) as a transaction row so the ledger is complete:

1. Card exists and `status = active`.
2. Cardholder has an `active` subscription.
3. Plan fuel type matches the requested fuel type.
4. `liters * pricePerLiter ≤ available_credit` (creditLimit − unbilled approved spend).
5. Cumulative approved liters this calendar month + requested liters ≤ plan's `monthlyLitersLimit`.

If all pass → `status: 'approved'`. Any failure → `status: 'declined'` with `declineReason` set.

## Common commands

```bash
npm run dev               # nodemon
npm run prisma:studio     # GUI DB browser at http://localhost:5555
npm run prisma:migrate    # create & apply a new migration
npm run prisma:generate   # regen the Prisma client after schema edit
npm run db:seed           # idempotent demo data
```
