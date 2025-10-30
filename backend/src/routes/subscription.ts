/**
 * Subscription Routes
 *
 * Defines all subscription-related API endpoints:
 * - GET /subscription/status - Get current subscription status
 * - POST /subscription/create - Create new Stripe subscription
 * - POST /subscription/cancel - Cancel active subscription
 */

import { Router } from 'express';
import { body } from 'express-validator';
import {
  getSubscriptionStatus,
  createSubscription,
  cancelSubscription,
} from '../controllers/subscriptionController';
import { authenticateToken } from '../middleware/auth';
import { authRateLimiter } from '../middleware/rateLimiter';

// Create Express router for subscription routes
const router = Router();

/**
 * GET /subscription/status
 *
 * Retrieves current subscription status for authenticated user.
 * Returns subscription tier, status, expiry date, and Stripe IDs.
 *
 * Headers:
 * - Authorization: Bearer <JWT_TOKEN>
 *
 * Response:
 * - 200: Subscription status returned
 * - 401: Unauthorized (invalid or missing JWT)
 * - 404: User not found
 * - 500: Server error
 */
router.get(
  '/status',
  // Require authentication
  authenticateToken,
  // Apply rate limiter: 10 requests per 15 minutes
  authRateLimiter,
  getSubscriptionStatus,
);

/**
 * POST /subscription/create
 *
 * Creates a new Stripe subscription for the user.
 * Requires payment method ID from mobile app (Stripe SDK).
 *
 * Headers:
 * - Authorization: Bearer <JWT_TOKEN>
 *
 * Request body:
 * - paymentMethodId: string (Stripe payment method ID)
 * - priceId: string (Stripe price ID for PREMIUM plan)
 *
 * Response:
 * - 200: Subscription created successfully
 * - 400: Validation error or user already has active subscription
 * - 401: Unauthorized
 * - 404: User not found
 * - 500: Server error
 */
router.post(
  '/create',
  // Require authentication
  authenticateToken,
  // Apply rate limiter: 10 requests per 15 minutes
  authRateLimiter,
  [
    // Validate paymentMethodId field
    body('paymentMethodId')
      .notEmpty()
      .withMessage('Payment method ID is required')
      .isString()
      .withMessage('Payment method ID must be a string'),

    // Validate priceId field
    body('priceId')
      .notEmpty()
      .withMessage('Price ID is required')
      .isString()
      .withMessage('Price ID must be a string'),
  ],
  createSubscription,
);

/**
 * POST /subscription/cancel
 *
 * Cancels user's active Stripe subscription.
 * Subscription remains active until end of billing period.
 *
 * Headers:
 * - Authorization: Bearer <JWT_TOKEN>
 *
 * Response:
 * - 200: Subscription cancelled successfully
 * - 400: No active subscription found
 * - 401: Unauthorized
 * - 404: User not found
 * - 500: Server error
 */
router.post(
  '/cancel',
  // Require authentication
  authenticateToken,
  // Apply rate limiter: 10 requests per 15 minutes
  authRateLimiter,
  cancelSubscription,
);

// Export router to be mounted in main app
export default router;
