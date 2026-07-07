-- CreateEnum
CREATE TYPE "InstallmentPlanStatus" AS ENUM ('active', 'completed', 'canceled');

-- CreateEnum
CREATE TYPE "InstallmentStatus" AS ENUM ('pending', 'paid');

-- CreateTable
CREATE TABLE "installment_plans" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "subscription_id" UUID NOT NULL,
    "total_amount" DECIMAL(12,3) NOT NULL,
    "months" SMALLINT NOT NULL,
    "status" "InstallmentPlanStatus" NOT NULL DEFAULT 'active',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "installment_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "installments" (
    "id" UUID NOT NULL,
    "installment_plan_id" UUID NOT NULL,
    "seq" SMALLINT NOT NULL,
    "amount" DECIMAL(12,3) NOT NULL,
    "due_date" DATE NOT NULL,
    "status" "InstallmentStatus" NOT NULL DEFAULT 'pending',
    "paid_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "installments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "installment_plans_user_id_idx" ON "installment_plans"("user_id");

-- CreateIndex
CREATE INDEX "installment_plans_subscription_id_idx" ON "installment_plans"("subscription_id");

-- CreateIndex
CREATE INDEX "installments_installment_plan_id_idx" ON "installments"("installment_plan_id");

-- AddForeignKey
ALTER TABLE "installment_plans" ADD CONSTRAINT "installment_plans_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "installment_plans" ADD CONSTRAINT "installment_plans_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "subscriptions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "installments" ADD CONSTRAINT "installments_installment_plan_id_fkey" FOREIGN KEY ("installment_plan_id") REFERENCES "installment_plans"("id") ON DELETE CASCADE ON UPDATE CASCADE;
