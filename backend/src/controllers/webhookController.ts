/**
 * Stripe Webhook Controller
 *
 * Handles Stripe webhook events for subscription lifecycle management.
 * Verifies webhook signatures and updates user subscription status in database.
 *
 * Key events handled:
 * - customer.subscription.created: New subscription activated
 * - customer.subscription.updated: Subscription changed (payment method, plan, etc.)
 * - customer.subscription.deleted: Subscription cancelled or expired
 * - invoice.payment_succeeded: Successful recurring payment
 * - invoice.payment_failed: Failed payment (may lead to cancellation)
 */

import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { stripe } from '../services/stripe';
import Stripe from 'stripe';

// Initialize Prisma Client for database operations
const prisma = new PrismaClient();

/**
 * POST /stripe/webhook
 *
 * Receives and processes Stripe webhook events.
 * IMPORTANT: This endpoint must receive the raw request body (not JSON parsed)
 * for signature verification to work correctly.
 *
 * Stripe sends webhooks for subscription events, which we use to:
 * - Activate new subscriptions
 * - Update subscription status changes
 * - Handle payment failures
 * - Deactivate expired/cancelled subscriptions
 *
 * Security: Verifies webhook signature using STRIPE_WEBHOOK_SECRET
 * to ensure events are genuinely from Stripe.
 */
export const handleStripeWebhook = async (req: Request, res: Response) => {
  try {
    // Check if Stripe is initialized
    if (!stripe) {
      console.error('❌ Stripe not configured - cannot process webhook');
      return res.status(503).json({
        error: 'Stripe not configured - webhook processing unavailable',
      });
    }

    // Get Stripe signature from headers
    const sig = req.headers['stripe-signature'];

    if (!sig) {
      console.error('❌ No Stripe signature in webhook request');
      return res.status(400).json({ error: 'No signature provided' });
    }

    // Get webhook secret from environment
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

    if (!webhookSecret) {
      console.error('❌ STRIPE_WEBHOOK_SECRET not configured');
      return res.status(500).json({ error: 'Webhook secret not configured' });
    }

    let event: Stripe.Event;

    try {
      // Verify webhook signature and construct event
      // This ensures the webhook is genuinely from Stripe
      // IMPORTANT: req.body must be raw buffer, not parsed JSON
      event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
    } catch (err) {
      console.error('❌ Webhook signature verification failed:', err);
      return res.status(400).json({
        error: 'Webhook signature verification failed',
        details: err instanceof Error ? err.message : 'Unknown error',
      });
    }

    console.log(`📨 Received Stripe webhook: ${event.type}`);

    // Process different event types
    switch (event.type) {
      case 'customer.subscription.created':
      case 'customer.subscription.updated':
        await handleSubscriptionCreatedOrUpdated(event);
        break;

      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event);
        break;

      case 'invoice.payment_succeeded':
        await handlePaymentSucceeded(event);
        break;

      case 'invoice.payment_failed':
        await handlePaymentFailed(event);
        break;

      default:
        // Log unhandled events for monitoring
        console.log(`ℹ️ Unhandled webhook event type: ${event.type}`);
    }

    // Return 200 to acknowledge receipt of webhook
    // This tells Stripe we successfully processed the event
    return res.status(200).json({ received: true });
  } catch (error) {
    console.error('❌ Error processing webhook:', error);
    return res.status(500).json({
      error: 'Failed to process webhook',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * Handle subscription creation or update events
 * Updates user's subscription status and expiry date in database
 */
async function handleSubscriptionCreatedOrUpdated(event: Stripe.Event) {
  const subscription = event.data.object as Stripe.Subscription;

  console.log(
    `📝 Processing subscription ${subscription.id} (status: ${subscription.status})`,
  );

  // Find user by Stripe customer ID
  const user = await prisma.user.findUnique({
    where: { stripeCustomerId: subscription.customer as string },
  });

  if (!user) {
    console.error(
      `❌ User not found for Stripe customer ${subscription.customer}`,
    );
    return;
  }

  // Map Stripe subscription status to our database status
  let subscriptionStatus: 'ACTIVE' | 'CANCELLED' | 'EXPIRED' | 'TRIALING';

  switch (subscription.status) {
    case 'active':
      subscriptionStatus = 'ACTIVE';
      break;
    case 'trialing':
      subscriptionStatus = 'TRIALING';
      break;
    case 'canceled':
    case 'incomplete_expired':
    case 'unpaid':
      subscriptionStatus = 'EXPIRED';
      break;
    case 'past_due':
      // Keep as active but flag for monitoring
      subscriptionStatus = 'ACTIVE';
      console.warn(
        `⚠️ Subscription ${subscription.id} is past_due - payment failed but still active`,
      );
      break;
    default:
      subscriptionStatus = 'EXPIRED';
  }

  // Calculate expiry date from subscription period end
  const expiryDate = new Date((subscription as any).current_period_end * 1000);

  // Update user record with subscription details
  await prisma.user.update({
    where: { id: user.id },
    data: {
      stripeSubscriptionId: subscription.id,
      subscriptionTier:
        subscriptionStatus === 'ACTIVE' || subscriptionStatus === 'TRIALING'
          ? 'PREMIUM'
          : 'FREE',
      subscriptionStatus,
      subscriptionExpiresAt: expiryDate,
    },
  });

  console.log(
    `✅ Updated user ${user.id} subscription to ${subscriptionStatus} (expires: ${expiryDate.toISOString()})`,
  );
}

/**
 * Handle subscription deletion/cancellation events
 * Downgrades user to FREE tier and marks subscription as EXPIRED
 */
async function handleSubscriptionDeleted(event: Stripe.Event) {
  const subscription = event.data.object as Stripe.Subscription;

  console.log(`🗑️ Processing subscription deletion: ${subscription.id}`);

  // Find user by Stripe customer ID
  const user = await prisma.user.findUnique({
    where: { stripeCustomerId: subscription.customer as string },
  });

  if (!user) {
    console.error(
      `❌ User not found for Stripe customer ${subscription.customer}`,
    );
    return;
  }

  // Downgrade user to FREE tier with EXPIRED status
  await prisma.user.update({
    where: { id: user.id },
    data: {
      subscriptionTier: 'FREE',
      subscriptionStatus: 'EXPIRED',
      // Keep stripeCustomerId and stripeSubscriptionId for records
    },
  });

  console.log(
    `✅ Downgraded user ${user.id} to FREE tier (subscription cancelled)`,
  );
}

/**
 * Handle successful payment events
 * Extends subscription expiry date based on new billing period
 */
async function handlePaymentSucceeded(event: Stripe.Event) {
  const invoice = event.data.object as Stripe.Invoice;

  // Only process if this is a subscription invoice
  if (!(invoice as any).subscription) {
    return;
  }

  console.log(
    `💰 Processing successful payment for subscription ${(invoice as any).subscription}`,
  );

  // Find user by Stripe customer ID
  const user = await prisma.user.findUnique({
    where: { stripeCustomerId: invoice.customer as string },
  });

  if (!user) {
    console.error(`❌ User not found for Stripe customer ${invoice.customer}`);
    return;
  }

  // Fetch subscription details to get new period end date
  if (!stripe) return;

  const subscription = await stripe.subscriptions.retrieve(
    (invoice as any).subscription as string,
  );

  // Update subscription expiry date with new period end
  const expiryDate = new Date((subscription as any).current_period_end * 1000);

  await prisma.user.update({
    where: { id: user.id },
    data: {
      subscriptionTier: 'PREMIUM',
      subscriptionStatus: 'ACTIVE',
      subscriptionExpiresAt: expiryDate,
    },
  });

  console.log(
    `✅ Extended user ${user.id} subscription to ${expiryDate.toISOString()}`,
  );
}

/**
 * Handle failed payment events
 * Logs failure for monitoring - Stripe will retry automatically
 * If all retries fail, subscription will eventually be cancelled
 */
async function handlePaymentFailed(event: Stripe.Event) {
  const invoice = event.data.object as Stripe.Invoice;

  // Only process if this is a subscription invoice
  if (!(invoice as any).subscription) {
    return;
  }

  console.error(
    `❌ Payment failed for subscription ${(invoice as any).subscription}`,
  );

  // Find user for logging purposes
  const user = await prisma.user.findUnique({
    where: { stripeCustomerId: invoice.customer as string },
  });

  if (user) {
    console.warn(
      `⚠️ User ${user.id} payment failed - Stripe will retry automatically`,
    );
    // Optionally: Send email notification to user about failed payment
  }

  // Don't immediately downgrade - let Stripe's retry logic handle it
  // If all retries fail, we'll get a subscription.deleted event
}
