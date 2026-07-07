-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('customer', 'staff', 'admin');

-- CreateEnum
CREATE TYPE "FuelType" AS ENUM ('p91', 'p95', 'diesel');

-- CreateEnum
CREATE TYPE "CardStatus" AS ENUM ('active', 'blocked', 'lost');

-- CreateEnum
CREATE TYPE "SubStatus" AS ENUM ('active', 'paused', 'canceled');

-- CreateEnum
CREATE TYPE "TxnStatus" AS ENUM ('approved', 'declined', 'voided');

-- CreateEnum
CREATE TYPE "InvoiceStatus" AS ENUM ('open', 'due', 'paid', 'overdue');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('card', 'bank', 'cash', 'wallet');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('pending', 'completed', 'failed', 'refunded');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "password_hash" TEXT NOT NULL,
    "full_name" TEXT NOT NULL,
    "national_id" TEXT,
    "role" "UserRole" NOT NULL DEFAULT 'customer',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vehicles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "plate_number" TEXT NOT NULL,
    "make" TEXT,
    "model" TEXT,
    "year" INTEGER,
    "fuel_type" "FuelType" NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "vehicles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "plans" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "fuel_type" "FuelType" NOT NULL,
    "monthly_liters_limit" INTEGER NOT NULL,
    "price_per_liter" DECIMAL(12,3) NOT NULL,
    "monthly_fee" DECIMAL(12,3) NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subscriptions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "plan_id" UUID NOT NULL,
    "status" "SubStatus" NOT NULL DEFAULT 'active',
    "credit_limit" DECIMAL(12,3) NOT NULL,
    "billing_day" SMALLINT NOT NULL DEFAULT 1,
    "started_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ends_at" TIMESTAMPTZ(6),

    CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cards" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "card_uid" TEXT NOT NULL,
    "label" TEXT,
    "status" "CardStatus" NOT NULL DEFAULT 'active',
    "linked_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cards_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stations" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "city" TEXT,
    "lat" DECIMAL(9,6),
    "lng" DECIMAL(9,6),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoices" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "subscription_id" UUID NOT NULL,
    "period_start" DATE NOT NULL,
    "period_end" DATE NOT NULL,
    "subtotal" DECIMAL(12,3) NOT NULL DEFAULT 0,
    "monthly_fee" DECIMAL(12,3) NOT NULL DEFAULT 0,
    "total" DECIMAL(12,3) NOT NULL DEFAULT 0,
    "status" "InvoiceStatus" NOT NULL DEFAULT 'open',
    "due_date" DATE NOT NULL,
    "paid_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invoices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "transactions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "card_id" UUID NOT NULL,
    "subscription_id" UUID NOT NULL,
    "station_id" UUID,
    "vehicle_id" UUID,
    "liters" DECIMAL(8,3) NOT NULL,
    "price_per_liter" DECIMAL(12,3) NOT NULL,
    "total_amount" DECIMAL(12,3) NOT NULL,
    "fuel_type" "FuelType" NOT NULL,
    "status" "TxnStatus" NOT NULL DEFAULT 'approved',
    "decline_reason" TEXT,
    "invoice_id" UUID,
    "tapped_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" UUID NOT NULL,
    "invoice_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "amount" DECIMAL(12,3) NOT NULL,
    "method" "PaymentMethod" NOT NULL,
    "reference" TEXT,
    "status" "PaymentStatus" NOT NULL DEFAULT 'pending',
    "paid_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "users_national_id_key" ON "users"("national_id");

-- CreateIndex
CREATE INDEX "vehicles_user_id_idx" ON "vehicles"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "vehicles_user_id_plate_number_key" ON "vehicles"("user_id", "plate_number");

-- CreateIndex
CREATE INDEX "subscriptions_user_id_idx" ON "subscriptions"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "cards_card_uid_key" ON "cards"("card_uid");

-- CreateIndex
CREATE INDEX "cards_user_id_idx" ON "cards"("user_id");

-- CreateIndex
CREATE INDEX "invoices_user_id_idx" ON "invoices"("user_id");

-- CreateIndex
CREATE INDEX "invoices_status_idx" ON "invoices"("status");

-- CreateIndex
CREATE UNIQUE INDEX "invoices_subscription_id_period_start_key" ON "invoices"("subscription_id", "period_start");

-- CreateIndex
CREATE INDEX "transactions_user_id_tapped_at_idx" ON "transactions"("user_id", "tapped_at" DESC);

-- CreateIndex
CREATE INDEX "transactions_subscription_id_idx" ON "transactions"("subscription_id");

-- CreateIndex
CREATE INDEX "transactions_invoice_id_idx" ON "transactions"("invoice_id");

-- CreateIndex
CREATE INDEX "transactions_card_id_idx" ON "transactions"("card_id");

-- CreateIndex
CREATE INDEX "payments_invoice_id_idx" ON "payments"("invoice_id");

-- CreateIndex
CREATE INDEX "payments_user_id_idx" ON "payments"("user_id");

-- AddForeignKey
ALTER TABLE "vehicles" ADD CONSTRAINT "vehicles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "plans"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cards" ADD CONSTRAINT "cards_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoices" ADD CONSTRAINT "invoices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoices" ADD CONSTRAINT "invoices_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "subscriptions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_card_id_fkey" FOREIGN KEY ("card_id") REFERENCES "cards"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "subscriptions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_station_id_fkey" FOREIGN KEY ("station_id") REFERENCES "stations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_vehicle_id_fkey" FOREIGN KEY ("vehicle_id") REFERENCES "vehicles"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoices"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
