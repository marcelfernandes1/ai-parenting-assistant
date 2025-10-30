/**
 * Stripe Webhook Routes
 *
 * IMPORTANT: This route must be registered BEFORE express.json() middleware
 * in the main app because Stripe webhook signature verification requires
 * the raw request body, not a parsed JSON object.
 *
 * In index.ts, this route is registered with express.raw() middleware:
 * app.use('/stripe/webhook', express.raw({ type: 'application/json' }), webhookRoutes);
 */

import { Router } from 'express';
import { handleStripeWebhook } from '../controllers/webhookController';

// Create Express router for webhook routes
const router = Router();

/**
 * POST /stripe/webhook
 *
 * Receives Stripe webhook events for subscription lifecycle management.
 *
 * Headers (set by Stripe):
 * - stripe-signature: Signature for webhook verification
 *
 * Body: Raw JSON payload from Stripe (NOT parsed)
 *
 * Events handled:
 * - customer.subscription.created: New subscription
 * - customer.subscription.updated: Subscription changes
 * - customer.subscription.deleted: Subscription cancelled
 * - invoice.payment_succeeded: Successful payment
 * - invoice.payment_failed: Failed payment
 *
 * Response:
 * - 200: Webhook processed successfully
 * - 400: Invalid signature or missing signature
 * - 500: Server error processing webhook
 */
router.post('/', handleStripeWebhook);

// Export router to be mounted in main app
export default router;
