/**
 * Stripe service for subscription management
 * Initializes Stripe SDK with secret key from environment
 * Used for creating subscriptions, managing customers, and handling webhooks
 */
import Stripe from 'stripe';

// Initialize Stripe with API key from environment
const stripeSecretKey = process.env.STRIPE_SECRET_KEY;

/**
 * Stripe client instance
 * Configured with latest API version and TypeScript support
 * Returns null if STRIPE_SECRET_KEY is not set (for development)
 */
export const stripe: Stripe | null = stripeSecretKey
  ? new Stripe(stripeSecretKey, {
      apiVersion: '2025-10-29.clover',  // Use latest stable API version compatible with SDK
      typescript: true,
    })
  : null;

// Warn if Stripe is not initialized
if (!stripe) {
  console.warn('⚠️ STRIPE_SECRET_KEY not set - Stripe features will not work');
}

export default stripe;
