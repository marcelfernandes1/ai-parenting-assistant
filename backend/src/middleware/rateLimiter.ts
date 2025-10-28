/**
 * Rate Limiting Middleware
 *
 * Provides rate limiting for authentication endpoints to prevent brute-force attacks.
 * Uses express-rate-limit package to track requests by IP address.
 *
 * Rate limits:
 * - Login: 5 attempts per 15 minutes per IP
 * - Register: 3 attempts per hour per IP
 */

import rateLimit from 'express-rate-limit';

/**
 * Rate limiter for login endpoint
 *
 * Limits login attempts to prevent brute-force password attacks.
 * Restricts each IP address to 5 login attempts per 15-minute window.
 *
 * Security considerations:
 * - Tracks requests by IP address to prevent credential stuffing
 * - Returns 429 status when limit exceeded
 * - Provides clear error message with retry time
 * - Resets counter after time window expires
 */
export const loginRateLimiter = rateLimit({
  // Time window: 15 minutes (in milliseconds)
  windowMs: 15 * 60 * 1000,

  // Maximum requests per window: 5 attempts
  max: 5,

  // Message returned when limit is exceeded
  message: {
    error: 'Too many login attempts',
    message: 'Please wait 15 minutes before trying again.',
    retryAfter: '15 minutes',
  },

  // Return 429 Too Many Requests status code when limit exceeded
  statusCode: 429,

  // Use default headers (X-RateLimit-* headers for client visibility)
  standardHeaders: true,

  // Disable legacy X-RateLimit-* headers
  legacyHeaders: false,

  // Skip successful requests from counting against limit (optional)
  // This means only failed login attempts count toward the limit
  skipSuccessfulRequests: false,

  // Skip failed requests from counting (we want to count all attempts)
  skipFailedRequests: false,
});

/**
 * Rate limiter for registration endpoint
 *
 * Limits registration attempts to prevent spam account creation.
 * Restricts each IP address to 3 registration attempts per hour.
 *
 * Security considerations:
 * - Prevents mass spam account creation
 * - Tracks by IP address to limit abuse
 * - Stricter limit than login (3 vs 5) since registration is less frequent
 * - Longer window (1 hour vs 15 min) to further discourage spam
 */
export const registerRateLimiter = rateLimit({
  // Time window: 1 hour (in milliseconds)
  windowMs: 60 * 60 * 1000,

  // Maximum requests per window: 3 attempts
  max: 3,

  // Message returned when limit is exceeded
  message: {
    error: 'Too many registration attempts',
    message: 'Please wait 1 hour before trying again.',
    retryAfter: '1 hour',
  },

  // Return 429 Too Many Requests status code when limit exceeded
  statusCode: 429,

  // Use default headers (X-RateLimit-* headers for client visibility)
  standardHeaders: true,

  // Disable legacy X-RateLimit-* headers
  legacyHeaders: false,

  // Count all registration attempts (both successful and failed)
  skipSuccessfulRequests: false,
  skipFailedRequests: false,
});

/**
 * General rate limiter for other auth endpoints
 *
 * Applied to endpoints like token refresh, password reset, etc.
 * More lenient than login/register since these are less sensitive.
 */
export const authRateLimiter = rateLimit({
  // Time window: 15 minutes
  windowMs: 15 * 60 * 1000,

  // Maximum requests per window: 10 attempts
  max: 10,

  // Message returned when limit is exceeded
  message: {
    error: 'Too many requests',
    message: 'Please wait before trying again.',
    retryAfter: '15 minutes',
  },

  // Return 429 Too Many Requests status code
  statusCode: 429,

  // Standard headers
  standardHeaders: true,
  legacyHeaders: false,
});
