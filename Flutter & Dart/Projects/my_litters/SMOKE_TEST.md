# Smoke test runbook

End-to-end check after fresh setup. Targets the seeded demo data
(see `backend/prisma/seed.js`).

## 0. Prerequisites

- Node 20+, Flutter 3.22+, Postgres reachable.
- Either Neon (`postgresql://USER:PASS@HOST/db?sslmode=require`) or
  local Docker:
  ```bash
  docker run --name my-litters-pg -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_DB=my_litters -p 5432:5432 -d postgres:16
  ```

## 1. Backend boot

```bash
cd backend
cp .env.example .env       # fill DATABASE_URL + JWT_SECRET
npm install
npx prisma migrate dev --name init
npm run db:seed
npm run dev                # listens on :3000
```

Health check:
```bash
curl http://localhost:3000/health
# -> {"ok":true,"ts":"..."}
```

## 2. Auth smoke

```bash
# Login as the seeded customer
curl -s -X POST http://localhost:3000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"demo@my-litters.dev","password":"demo12345"}' | jq .

# Capture the token
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"demo@my-litters.dev","password":"demo12345"}' \
  | jq -r .data.token)

curl -s http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer $TOKEN" | jq .
```

## 3. Subscription + credit smoke

```bash
curl -s http://localhost:3000/api/subscriptions/plans | jq .
curl -s http://localhost:3000/api/subscriptions/active \
  -H "Authorization: Bearer $TOKEN" | jq .
curl -s http://localhost:3000/api/subscriptions/credit \
  -H "Authorization: Bearer $TOKEN" | jq .
```

Expect `availableCredit == creditLimit` (no transactions yet) and
`plan.fuelType == "p95"` from the seeded Plus 95 plan.

## 4. Tap-to-pay smoke (admin)

```bash
ADMIN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@my-litters.dev","password":"admin12345"}' \
  | jq -r .data.token)

# Link a card on the demo customer first (use a fake UID hex)
curl -s -X POST http://localhost:3000/api/cards \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"cardUid":"04A1B2C3D4E5F6","label":"Demo card"}' | jq .

# Now authorize a tap as admin
curl -s -X POST http://localhost:3000/api/transactions/authorize \
  -H "Authorization: Bearer $ADMIN" \
  -H 'Content-Type: application/json' \
  -d '{"cardUid":"04A1B2C3D4E5F6","liters":20,"fuelType":"p95"}' | jq .
```

Expect `status: "approved"` with `totalAmount = liters * pricePerLiter`.
Re-running `/api/subscriptions/credit` should now show
`unbilledBalance > 0`.

## 5. Flutter smoke

```bash
# From repo root
flutter pub get

# Pick the right base URL for the device:
#   iOS sim / desktop:  http://localhost:3000
#   Android emulator:    http://10.0.2.2:3000
#   physical device:     http://<your-LAN-ip>:3000
flutter run \
  --dart-define=API_BASE_URL=http://localhost:3000
```

Then in the app:

1. Login screen → email `demo@my-litters.dev` / password `demo12345`.
2. Dashboard renders with the Plus 95 fuel meter (≈ 200L cap),
   "No upcoming payment", 0 active vehicles, "—" efficiency.
3. Pull-to-refresh works.
4. Tap **Vehicles** → "Add vehicle" → save → list shows the new car.
5. Tap **Settings** → Profile → Edit Profile → save → name updates.
6. Tap **Link a card** → only works on a real device with NFC.
   On simulator/desktop the button just shows the NFC error
   ("NFC is off or unavailable on this device") — that's expected.
7. Log out (top-right icon) → returns to login.

## 6. Common pitfalls

- **CORS** — already enabled in `app.js` (`cors()`), but if you serve
  from a different origin, the browser/web flutter target may need
  origin allow-listing.
- **Android emulator can't reach localhost** — use `10.0.2.2`.
- **Physical Android device** — make sure phone + dev machine are on
  the same Wi-Fi and the laptop firewall lets port 3000 in.
- **NFC** — needs a real device with NFC enabled; simulator throws
  "NFC is off or unavailable on this device".
- **iOS NFC** — after first run, in Xcode open `Runner.xcworkspace`,
  select the Runner target → Signing & Capabilities → "+ Capability"
  → "Near Field Communication Tag Reading", and confirm
  `Runner.entitlements` is selected as Code Signing Entitlements.
