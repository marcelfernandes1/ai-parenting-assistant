/**
 * Authentication Routes
 *
 * Defines all authentication-related API endpoints:
 * - POST /auth/register - Create new user account
 * - POST /auth/login - Log in existing user
 * - POST /auth/refresh - Refresh access token
 * - POST /auth/verify-email - Verify email (stub)
 * - POST /auth/reset-password - Reset password (stub)
 */

import { Router } from 'express';
import { body } from 'express-validator';
import {
  register,
  login,
  refreshAccessToken,
  verifyEmail,
  resetPassword,
} from '../controllers/authController';
import {
  loginRateLimiter,
  registerRateLimiter,
  authRateLimiter,
} from '../middleware/rateLimiter';

// Create Express router for auth routes
const router = Router();

/**
 * POST /auth/register
 *
 * Register a new user account with email and password.
 * Password must be at least 8 characters and contain at least 1 number.
 *
 * Request body:
 * - email: string (valid email format)
 * - password: string (min 8 chars, at least 1 number)
 *
 * Response:
 * - 201: Registration successful
 * - 400: Validation error or email already registered
 * - 500: Server error
 */
router.post(
  '/register',
  // Apply rate limiter: 3 attempts per hour per IP
  registerRateLimiter,
  [
    // Validate email field
    // normalizeEmail() converts to lowercase and removes dots from Gmail addresses
    body('email')
      .isEmail()
      .withMessage('Please provide a valid email address')
      .normalizeEmail(),

    // Validate password field
    // - min 8 characters for security
    // - must contain at least 1 number for strength
    body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/\d/)
      .withMessage('Password must contain at least one number'),
  ],
  register,
);

/**
 * POST /auth/login
 *
 * Log in with email and password.
 * Returns JWT access token (7 days) and refresh token (30 days).
 *
 * Request body:
 * - email: string
 * - password: string
 *
 * Response:
 * - 200: Login successful with tokens and user data
 * - 400: Validation error
 * - 401: Invalid credentials
 * - 500: Server error
 */
router.post(
  '/login',
  // Apply rate limiter: 5 attempts per 15 minutes per IP
  loginRateLimiter,
  [
    // Validate email field
    body('email')
      .isEmail()
      .withMessage('Please provide a valid email address')
      .normalizeEmail(),

    // Validate password field is present
    // Don't validate format on login - user might have old password
    body('password').notEmpty().withMessage('Password is required'),
  ],
  login,
);

/**
 * POST /auth/refresh
 *
 * Refresh access token using refresh token.
 * Allows users to stay logged in without re-entering credentials.
 *
 * Request body:
 * - refreshToken: string (JWT refresh token)
 *
 * Response:
 * - 200: New access token issued
 * - 400: Validation error
 * - 401: Invalid or expired refresh token
 * - 500: Server error
 */
router.post(
  '/refresh',
  // Apply general auth rate limiter: 10 attempts per 15 minutes
  authRateLimiter,
  [
    // Validate refresh token is provided
    body('refreshToken').notEmpty().withMessage('Refresh token is required'),
  ],
  refreshAccessToken,
);

/**
 * POST /auth/verify-email
 *
 * Verify user email address (stub for MVP).
 * Future: Will validate email verification token sent via email.
 *
 * Request body:
 * - token: string (email verification token)
 *
 * Response:
 * - 200: Stub response (not yet implemented)
 */
router.post(
  '/verify-email',
  // Apply general auth rate limiter: 10 attempts per 15 minutes
  authRateLimiter,
  [
    // Validate token is provided
    body('token').notEmpty().withMessage('Verification token is required'),
  ],
  verifyEmail,
);

/**
 * POST /auth/reset-password
 *
 * Request password reset (stub for MVP).
 * Future: Will send password reset email with token.
 *
 * Request body:
 * - email: string
 *
 * Response:
 * - 200: Stub response (not yet implemented)
 */
router.post(
  '/reset-password',
  // Apply general auth rate limiter: 10 attempts per 15 minutes
  authRateLimiter,
  [
    // Validate email is provided
    body('email')
      .isEmail()
      .withMessage('Please provide a valid email address')
      .normalizeEmail(),
  ],
  resetPassword,
);

// Export router to be mounted in main app
export default router;
