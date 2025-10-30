/**
 * Subscription Controller
 *
 * Handles Stripe subscription management:
 * - Get subscription status
 * - Create new subscription
 * - Cancel subscription
 *
 * Uses Stripe SDK for payment processing and Prisma for database updates.
 */

import { Request, Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { PrismaClient } from '@prisma/client';
import { stripe } from '../services/stripe';

// Initialize Prisma Client for database operations
const prisma = new PrismaClient();

/**
 * GET /subscription/status
 *
 * Retrieves current subscription status for authenticated user.
 * Returns subscription tier, status, expiry date, and Stripe IDs.
 *
 * Response format:
 * {
 *   subscriptionTier: 'FREE' | 'PREMIUM',
 *   subscriptionStatus: 'ACTIVE' | 'CANCELLED' | 'EXPIRED' | 'TRIALING',
 *   subscriptionExpiresAt: Date | null,
 *   stripeCustomerId: string | null,
 *   stripeSubscriptionId: string | null
 * }
 */
export const getSubscriptionStatus = async (req: Request, res: Response) => {
  try {
    // Extract userId from JWT token (set by authenticateToken middleware)
    const userId = (req as any).user?.userId;

    // Return 401 if userId not found (shouldn't happen with valid JWT)
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Fetch user from database with subscription details
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        subscriptionTier: true,
        subscriptionStatus: true,
        subscriptionExpiresAt: true,
        stripeCustomerId: true,
        stripeSubscriptionId: true,
      },
    });

    // Return 404 if user not found (shouldn't happen with valid JWT)
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Return subscription details
    return res.status(200).json({
      subscriptionTier: user.subscriptionTier,
      subscriptionStatus: user.subscriptionStatus,
      subscriptionExpiresAt: user.subscriptionExpiresAt,
      stripeCustomerId: user.stripeCustomerId,
      stripeSubscriptionId: user.stripeSubscriptionId,
    });
  } catch (error) {
    console.error('❌ Error fetching subscription status:', error);
    return res.status(500).json({ error: 'Failed to fetch subscription status' });
  }
};

/**
 * POST /subscription/create
 *
 * Creates a new Stripe subscription for the user.
 * Steps:
 * 1. Create or retrieve Stripe customer
 * 2. Create Stripe subscription with payment method
 * 3. Update user record with Stripe IDs and subscription details
 *
 * Request body:
 * - paymentMethodId: string (Stripe payment method ID from mobile app)
 * - priceId: string (Stripe price ID for PREMIUM plan)
 *
 * Response:
 * - subscriptionId: string (Stripe subscription ID)
 * - clientSecret: string (for confirming payment if needed)
 */
export const createSubscription = async (req: Request, res: Response) => {
  try {
    // Check if Stripe is initialized
    if (!stripe) {
      return res.status(503).json({
        error: 'Stripe not configured - payment processing unavailable',
      });
    }

    // Extract userId from JWT token
    const userId = (req as any).user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    const { paymentMethodId, priceId } = req.body;

    // Validate required fields
    if (!paymentMethodId || !priceId) {
      return res.status(400).json({
        error: 'Missing required fields: paymentMethodId and priceId',
      });
    }

    // Fetch user from database
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        stripeCustomerId: true,
        stripeSubscriptionId: true,
      },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if user already has an active subscription
    if (user.stripeSubscriptionId) {
      // Verify subscription still exists in Stripe
      try {
        const existingSubscription = await stripe.subscriptions.retrieve(
          user.stripeSubscriptionId,
        );

        // If subscription is active, return error
        if (
          existingSubscription.status === 'active' ||
          existingSubscription.status === 'trialing'
        ) {
          return res.status(400).json({
            error: 'User already has an active subscription',
            subscriptionId: user.stripeSubscriptionId,
          });
        }
      } catch (stripeError) {
        // Subscription doesn't exist in Stripe - continue with creating new one
        console.log('Existing subscription not found in Stripe, creating new one');
      }
    }

    let customerId = user.stripeCustomerId;

    // Create Stripe customer if doesn't exist
    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user.email,
        metadata: {
          userId: user.id,
        },
      });
      customerId = customer.id;

      // Save customer ID to database
      await prisma.user.update({
        where: { id: userId },
        data: { stripeCustomerId: customerId },
      });
    }

    // Attach payment method to customer
    await stripe.paymentMethods.attach(paymentMethodId, {
      customer: customerId,
    });

    // Set as default payment method
    await stripe.customers.update(customerId, {
      invoice_settings: {
        default_payment_method: paymentMethodId,
      },
    });

    // Create subscription
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: priceId }],
      payment_settings: {
        payment_method_types: ['card'],
        save_default_payment_method: 'on_subscription',
      },
      expand: ['latest_invoice.payment_intent'],
    });

    // Calculate expiry date (30 days from now for monthly subscription)
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + 30);

    // Update user record with subscription details
    await prisma.user.update({
      where: { id: userId },
      data: {
        stripeCustomerId: customerId,
        stripeSubscriptionId: subscription.id,
        subscriptionTier: 'PREMIUM',
        subscriptionStatus:
          subscription.status === 'active' || subscription.status === 'trialing'
            ? 'ACTIVE'
            : 'EXPIRED',
        subscriptionExpiresAt: expiryDate,
      },
    });

    console.log(`✅ Subscription created for user ${userId}: ${subscription.id}`);

    // Return subscription details
    return res.status(200).json({
      subscriptionId: subscription.id,
      status: subscription.status,
      // Extract client secret if payment requires confirmation
      clientSecret:
        subscription.status === 'incomplete'
          ? (subscription.latest_invoice as any)?.payment_intent?.client_secret
          : null,
    });
  } catch (error) {
    console.error('❌ Error creating subscription:', error);
    return res.status(500).json({
      error: 'Failed to create subscription',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * POST /subscription/cancel
 *
 * Cancels user's active Stripe subscription.
 * Subscription remains active until end of billing period.
 * Updates user status to CANCELLED in database.
 *
 * Response:
 * - success: boolean
 * - cancelAt: Date (when subscription will actually end)
 */
export const cancelSubscription = async (req: Request, res: Response) => {
  try {
    // Check if Stripe is initialized
    if (!stripe) {
      return res.status(503).json({
        error: 'Stripe not configured - payment processing unavailable',
      });
    }

    // Extract userId from JWT token
    const userId = (req as any).user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Fetch user from database
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        stripeSubscriptionId: true,
        subscriptionExpiresAt: true,
      },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if user has a subscription
    if (!user.stripeSubscriptionId) {
      return res.status(400).json({ error: 'No active subscription found' });
    }

    // Cancel subscription in Stripe (at end of billing period)
    const subscription = await stripe.subscriptions.update(user.stripeSubscriptionId, {
      cancel_at_period_end: true,
    });

    // Update user status to CANCELLED in database
    await prisma.user.update({
      where: { id: userId },
      data: {
        subscriptionStatus: 'CANCELLED',
        // Keep expiry date - user retains access until then
      },
    });

    console.log(`✅ Subscription cancelled for user ${userId}: ${subscription.id}`);

    // Return cancellation details
    return res.status(200).json({
      success: true,
      cancelAt: subscription.cancel_at
        ? new Date(subscription.cancel_at * 1000)
        : user.subscriptionExpiresAt,
      message: 'Subscription will be cancelled at end of billing period',
    });
  } catch (error) {
    console.error('❌ Error cancelling subscription:', error);
    return res.status(500).json({
      error: 'Failed to cancel subscription',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};
