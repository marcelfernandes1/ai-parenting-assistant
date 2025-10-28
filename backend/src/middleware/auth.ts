/**
 * Authentication Middleware
 *
 * This middleware protects routes by verifying JWT tokens.
 * It extracts the token from the Authorization header, verifies it,
 * and attaches user data to the request object for downstream handlers.
 */

import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, AccessTokenPayload } from '../utils/jwt';

/**
 * Extended Express Request interface with user data
 * Adds 'user' property populated by authentication middleware
 */
export interface AuthenticatedRequest extends Request {
  user?: AccessTokenPayload;
}

/**
 * Authentication middleware for protected routes
 *
 * Verifies JWT token from Authorization header and attaches user data to request.
 * Routes using this middleware require a valid Bearer token.
 *
 * Usage:
 * ```typescript
 * router.get('/protected', authenticateToken, (req: AuthenticatedRequest, res) => {
 *   const userId = req.user.userId; // Access authenticated user's ID
 *   // ... handle request
 * });
 * ```
 *
 * @param req - Express request object
 * @param res - Express response object
 * @param next - Express next function to pass control to next middleware
 * @returns 401 if no token provided, 403 if token invalid/expired
 */
export const authenticateToken = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
): void => {
  // Extract Authorization header from request
  // Expected format: "Bearer <token>"
  const authHeader = req.headers['authorization'];

  // Split "Bearer <token>" and get the token part
  // authHeader?.split(' ') returns ['Bearer', '<token>']
  // [1] gets the second element (the actual token)
  const token = authHeader && authHeader.split(' ')[1];

  // Return 401 Unauthorized if no token provided
  // This means the request requires authentication but none was provided
  if (!token) {
    res.status(401).json({
      error: 'No token provided',
      message: 'Authentication required. Please provide a valid token.',
    });
    return;
  }

  try {
    // Verify token signature and expiration
    // verifyAccessToken() throws error if token is invalid or expired
    const decoded = verifyAccessToken(token);

    // Attach decoded user data to request object
    // This makes user ID and email available to route handlers
    req.user = decoded;

    // Continue to next middleware or route handler
    next();
  } catch (error) {
    // Token verification failed (invalid signature or expired)
    // Return 403 Forbidden to indicate invalid/expired token
    res.status(403).json({
      error: 'Invalid or expired token',
      message: 'Please log in again to get a new token.',
    });
  }
};

/**
 * Optional authentication middleware
 *
 * Similar to authenticateToken but doesn't fail if no token is provided.
 * Useful for routes that have optional authentication (different behavior for logged-in users).
 *
 * @param req - Express request object
 * @param res - Express response object
 * @param next - Express next function to pass control to next middleware
 */
export const optionalAuth = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
): void => {
  // Extract Authorization header
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  // If no token provided, just continue without authentication
  // Route handler can check if req.user exists to see if user is authenticated
  if (!token) {
    next();
    return;
  }

  try {
    // Verify token and attach user data if valid
    const decoded = verifyAccessToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    // If token is invalid, just continue without authentication
    // Don't return error - this is optional authentication
    next();
  }
};
