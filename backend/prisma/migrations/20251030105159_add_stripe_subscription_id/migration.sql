-- Add stripeSubscriptionId column to User table
-- This column stores the Stripe subscription ID for tracking active subscriptions
ALTER TABLE "User" ADD COLUMN "stripeSubscriptionId" TEXT;

-- Add unique constraint to ensure one subscription per Stripe ID
CREATE UNIQUE INDEX "User_stripeSubscriptionId_key" ON "User"("stripeSubscriptionId");
