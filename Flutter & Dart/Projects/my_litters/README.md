# My Litters

A fuel **Buy-Now-Pay-Later (BNPL)** card platform. Customers subscribe to a
monthly fuel plan, split the cost over 1–4 installments, and pay at the pump by
tapping a physical NFC card **or** their phone. Staff authorize fuel purchases
against the customer's remaining credit and monthly liter cap.

- **Frontend:** Flutter (Android / iOS)
- **Backend:** Node.js + Express + Prisma
- **Database:** PostgreSQL

## Features

- Email/password auth with JWT, bcrypt hashing, and role-based access
  (`customer`, `staff`, `admin`).
- Subscription plans in two tiers (Basic 200L / Plus 400L) across three grades
  (91, 95, diesel).
- BNPL checkout: the plan's monthly total is split into equal installments; the
  first is settled at checkout, the rest scheduled monthly.
- NFC payments — link a physical card, **or** turn the phone into the card via
  Android Host Card Emulation (HCE).
- Card management: view, block, and unblock linked cards.
- Invoicing and a monthly billing job that generates invoices and flags overdue
  ones.
- Local push reminders the day before an installment is due.

## Prerequisites

- Flutter SDK (Dart 3.7+)
- Node.js 18+
- PostgreSQL 14+

## Backend setup

```bash
cd backend
cp .env.example .env         # then edit DATABASE_URL and JWT_SECRET
npm install
npm run prisma:migrate       # create the schema
npm run db:seed              # seed plans, stations, and demo users
npm run dev                  # starts on http://localhost:3000
```

Key environment variables (see `.env.example`):

- `DATABASE_URL` — PostgreSQL connection string
- `JWT_SECRET` — 32+ char secret
- `CORS_ORIGINS` — optional comma-separated browser origin allowlist (leave
  unset in development)

### Billing job

Generate invoices for all active subscriptions and mark overdue ones:

```bash
npm run billing:run                       # for the current month
node scripts/runBilling.js --as-of=2026-07-01
```

Schedule it via cron (e.g. `0 3 1 * * cd /path/to/backend && npm run billing:run`),
or trigger it as an admin through `POST /api/payments/billing/run`.

### Tests

```bash
npm test        # node --test — unit tests for the installment/money math
```

## Frontend setup

```bash
flutter pub get
flutter run                  # from the project root
```

The app reads its API base URL from a compile-time define. The default
(`http://localhost:3000`) works for web and the iOS simulator. For other
targets, pass `--dart-define`:

- **Android emulator:** `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000`
- **Physical device:** use your computer's LAN IP (phone and computer on the
  same Wi-Fi):
  `flutter run --dart-define="API_BASE_URL=http://192.168.x.x:3000"`

## NFC / phone-as-card notes

- **Physical cards** work on Android and iOS (iOS NFC entitlements are
  configured).
- **Phone-as-card (HCE)** is **Android only** — Apple reserves card emulation
  for Apple Pay. On iOS the app falls back to physical cards.
- HCE and reminders add native code, so after pulling changes run a full
  `flutter run` (not hot reload) and let `flutter pub get` fetch new packages.
- Testing phone-as-card end to end needs real NFC hardware (emulators have no
  NFC): one phone emulating, one running staff Tap-to-pay.

## Project structure

```
lib/
  controllers/   # thin wrappers around services (UI-facing API)
  models/        # data classes / JSON parsing
  services/      # HTTP, NFC, HCE, notifications
  state/         # Session (auth) provider
  views/         # screens + widgets
backend/
  src/
    controllers/ # request handlers
    services/    # business logic (auth, installments, billing, invoices)
    routes/      # Express routers
    middleware/  # auth, rate limiting, error handling
  prisma/        # schema + seed
  scripts/       # runBilling.js
  test/          # node:test suites
```
