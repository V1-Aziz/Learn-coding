# My Litters — Project Plan

A fuel BNPL card app: customers tap an NFC card at the pump to buy fuel on credit, and settle a single invoice at the end of each billing cycle.

This document is the source of truth for product direction, architecture, and remaining work. Update it as decisions change.

---

## 1. Product model — the hybrid

A user enrolls in a **monthly plan** (a tier from the `plans` catalog) which sets their fuel type, monthly liter cap, rate, and BNPL credit limit. Each NFC tap creates one **transaction** authorized in real time against the remaining credit on that subscription. At the end of each billing period, all unbilled transactions are bundled into a single **invoice** that the user pays. The card is just an identifier — credit lives on the subscription.

Why hybrid (rather than pure subscription or pure per-tap):

- Pure subscription = a flat monthly fee with no real-time signal at the pump. Less interesting as a fintech pitch, no use for the card beyond identification.
- Pure per-tap BNPL = clean per-transaction credit, but no recurring relationship — harder to underwrite, and harder to pitch to a fuel company that wants predictable revenue.
- Hybrid = the plan anchors the customer relationship and gives the fuel partner a forecastable monthly base; per-tap transactions give the user a card-shaped product they actually want to use.

## 2. Architecture

```
┌──────────────────────┐        HTTPS/JSON         ┌──────────────────────┐
│   Flutter app        │ ───────────────────────▶  │  Node.js / Express   │
│  (iOS + Android)     │ ◀───────────────────────  │  REST API            │
│                      │     JWT bearer token      │                      │
│  - customer role     │                           │  - auth (JWT/bcrypt) │
│  - staff role        │                           │  - cards / txns      │
│  - NFC via           │                           │  - invoices          │
│    nfc_manager pkg   │                           │                      │
└──────────────────────┘                           └──────────┬───────────┘
                                                              │ Prisma
                                                              ▼
                                                   ┌──────────────────────┐
                                                   │     PostgreSQL       │
                                                   │  (Neon or Supabase)  │
                                                   └──────────────────────┘
```

**Stack pins:**
- Flutter: `dio` (HTTP), `flutter_secure_storage` (JWT at rest), `provider` (state), `nfc_manager` (NFC), `go_router` (navigation, already scaffolded).
- Backend: Express, Prisma + `@prisma/client`, `bcrypt`, `jsonwebtoken`, `zod` (validation), `helmet` + `cors`, `pino` (logging).
- DB: PostgreSQL 15+, hosted on Neon free tier (or local via Docker for dev).

## 3. Where the project stands today

**Working**
- Flutter UI scaffolding: login, dashboard, payments, vehicles, subscriptions, settings — all built with a consistent design system (`utils/app_colors.dart`).
- Express server scaffolded on port 3000 with route stubs for auth/users/vehicles/payments/subscriptions.
- Folder layout follows MVC cleanly on both sides.

**Stubbed**
- Flutter services return hardcoded mock data; no HTTP client in `pubspec.yaml`.
- `lib/main.dart` ignores `app_router.dart` and hardcodes `home: LoginScreen()`.
- Backend `authService.js` returns the literal string `'placeholder_token'`; no bcrypt, no JWT.
- `backend/src/config/db.js` is a commented-out stub; backend models are empty.

**Missing entirely**
- Postgres connection, schema migrations, ORM.
- Any NFC code (`nfc_manager` not added; no card/tap controllers).
- Tests beyond Flutter's default `widget_test.dart`.
- Secure JWT storage on the device.

**Cleanup needed**
- `backend/.env.example` still points at MongoDB — switch to a Postgres URL.
- Three uncommitted screen edits sitting in working tree (`dashboard_screen.dart`, `settings_screen.dart`, `vehicles_screen.dart`) — commit or stash before the next change wave.

## 4. Data model — quick reference

The full DDL lives at `backend/db/schema.sql`. High-level shape:

- `users` — identity + role (customer / staff / admin).
- `vehicles` — many per user, each with a fuel preference.
- `plans` — admin catalog of tiers (fuel type, monthly liter cap, rate, fee).
- `subscriptions` — user's active enrollment in a plan; holds `credit_limit` and `billing_day`. One active row per user (partial unique index).
- `cards` — physical NFC tags linked to a user; identified by `card_uid`.
- `stations` — fuel stations (seeded for demo).
- `transactions` — one row per NFC tap; references `card`, `subscription`, optional `vehicle`/`station`. Linked to an invoice once the period closes.
- `invoices` — monthly bundle of transactions for a subscription.
- `payments` — settlements against invoices; partial payments allowed.

Helper view `v_user_available_credit` computes `credit_limit − sum(unbilled approved transactions)` per active subscription — used by the tap-authorization endpoint.

## 5. Roadmap (≈ 10–12 weeks remaining)

### Phase 1 — Foundation (Weeks 1–2)
- [x] Schema design (`backend/db/schema.sql`).
- [x] Recovery plan (this doc).
- [ ] Prisma + Postgres wired in backend; first migration applied to a Neon instance.
- [ ] Real auth (bcrypt + JWT), seeded admin + customer.
- [ ] Switch `.env.example` to Postgres; document local Docker option.

### Phase 2 — Flutter ↔ backend (Weeks 3–5)
- [ ] Add `dio`, `flutter_secure_storage`, `provider` to `pubspec.yaml`.
- [ ] Fix `main.dart` to use `MaterialApp.router` + `app_router.dart`.
- [ ] Build `ApiClient` with base URL and JWT interceptor.
- [ ] Replace mock `auth_service`, `dashboard_service`, `vehicle_service`, `payment_service`, `subscription_service`, `user_service` with real HTTP calls.
- [ ] Add loading + error states across controllers.

### Phase 3 — NFC & tap-to-pay (Weeks 6–8)
- [ ] Add `nfc_manager` to Flutter; add Android + iOS NFC entitlements.
- [ ] Build "Link card" flow (read UID → POST `/api/cards`).
- [ ] Build staff-role "Tap to Pay" screen (read UID → POST `/api/transactions` with `liters`, `station_id`).
- [ ] Backend `/api/transactions` endpoint: looks up card → active subscription → checks `v_user_available_credit` → inserts approved or declined row.
- [ ] Customer-side transaction history with running available-credit display.

### Phase 4 — Billing & polish (Weeks 9–10)
- [ ] Invoice generation job (close period, sum transactions, create invoice).
- [ ] Payment screen (mocked gateway, marks invoice paid).
- [ ] Edge cases: declined tap UI, blocked card, paused subscription.
- [ ] UI polish: empty states, error boundaries, retries.

### Phase 5 — Demo prep (Weeks 11–12)
- [ ] Seed convincing demo data (5 customers, 1 station, 30 days of taps).
- [ ] Pitch deck (10–12 slides): problem, hybrid model, demo flow, integration story, numbers.
- [ ] Recorded walkthrough video (fallback if live demo glitches).
- [ ] Bug bash + a couple of integration tests on the critical path (signup → link card → tap → invoice).

## 6. Decisions still open

- **Credit underwriting:** for the MVP, every approved customer gets a fixed `credit_limit` from their plan. Real underwriting (income check, KYC) is out of scope.
- **Repayment gateway:** mocked for the demo. For a pilot, integrate Mada / STC Pay / Apple Pay.
- **Who issues credit in the pitch story:** the fuel company itself is the cleanest narrative — frame My Litters as the platform.
- **Liters on tap:** the cashier/pump enters the liters dispensed; the card just authenticates the customer. (Real pumps would push it over the POS.)

## 7. Risks

- **NFC on iOS** is more restrictive than Android — background reads are limited, you'll likely need to keep the tap flow inside an active screen. Plan around this in the staff/cashier UI.
- **Live demo NFC reliability** is fragile (foil cases, weak chips, phone position). Always have a pre-recorded fallback.
- **Time budget:** 10–12 weeks solo is enough only if scope creep stays ruthlessly cut. Anything that isn't on the demo path waits until after the pitch.

---

_Last updated: phase 1 in progress. Next deliverable: Prisma + Postgres setup (task #3)._
