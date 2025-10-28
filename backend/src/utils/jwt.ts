/**
 * JWT Token Generation and Verification Utilities
 *
 * This module provides functions for generating and verifying JWT tokens
 * used for user authentication in the AI Parenting Assistant app.
 *
 * Token Types:
 * - Access Token: Short-lived (7 days), used for API authentication
 * - Refresh Token: Long-lived (30 days), used to get new access tokens
 */

import jwt from 'jsonwebtoken';

/**
 * Payload structure for JWT access tokens
 * Contains user identification and authorization data
 */
export interface AccessTokenPayload {
  userId: string; // User's UUID from database
  email: string; // User's email address
}

/**
 * Payload structure for JWT refresh tokens
 * Contains minimal data since refresh tokens are only for token renewal
 */
export interface RefreshTokenPayload {
  userId: string; // User's UUID from database
}

/**
 * Generates a JWT access token for authenticated users
 *
 * Access tokens are short-lived (7 days) and contain user identification.
 * They are sent with every API request in the Authorization header.
 *
 * @param userId - UUID of the user from database
 * @param email - User's email address for token payload
 * @returns Signed JWT access token string with 7-day expiry
 * @throws Error if JWT_SECRET environment variable is not set
 */
export function generateAccessToken(
  userId: string,
  email: string,
): string {
  // Verify JWT_SECRET is configured in environment
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET environment variable is not set');
  }

  // Create token payload with user identification
  const payload: AccessTokenPayload = {
    userId,
    email,
  };

  // Sign token with secret key and set 7-day expiration
  // expiresIn: '7d' means token is valid for 7 days from creation
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: '7d',
  });
}

/**
 * Generates a JWT refresh token for token renewal
 *
 * Refresh tokens are long-lived (30 days) and contain minimal data.
 * They are used to obtain new access tokens without re-authentication.
 *
 * @param userId - UUID of the user from database
 * @returns Signed JWT refresh token string with 30-day expiry
 * @throws Error if JWT_REFRESH_SECRET environment variable is not set
 */
export function generateRefreshToken(userId: string): string {
  // Verify JWT_REFRESH_SECRET is configured in environment
  if (!process.env.JWT_REFRESH_SECRET) {
    throw new Error('JWT_REFRESH_SECRET environment variable is not set');
  }

  // Create token payload with only user ID (minimal data for security)
  const payload: RefreshTokenPayload = {
    userId,
  };

  // Sign token with separate secret key and set 30-day expiration
  // Using separate secret allows invalidating refresh tokens independently
  return jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
    expiresIn: '30d',
  });
}

/**
 * Verifies and decodes a JWT access token
 *
 * Validates the token signature and expiration, then returns the payload.
 * Used by authentication middleware to verify user identity.
 *
 * @param token - JWT access token string to verify
 * @returns Decoded token payload with user data
 * @throws Error if token is invalid, expired, or JWT_SECRET is not set
 */
export function verifyAccessToken(token: string): AccessTokenPayload {
  // Verify JWT_SECRET is configured in environment
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET environment variable is not set');
  }

  // Verify token signature and decode payload
  // jwt.verify() throws error if token is invalid or expired
  const decoded = jwt.verify(token, process.env.JWT_SECRET);

  // Return decoded payload (TypeScript assertion for type safety)
  return decoded as AccessTokenPayload;
}

/**
 * Verifies and decodes a JWT refresh token
 *
 * Validates the refresh token signature and expiration.
 * Used when user requests a new access token.
 *
 * @param token - JWT refresh token string to verify
 * @returns Decoded token payload with user ID
 * @throws Error if token is invalid, expired, or JWT_REFRESH_SECRET is not set
 */
export function verifyRefreshToken(
  token: string,
): RefreshTokenPayload {
  // Verify JWT_REFRESH_SECRET is configured in environment
  if (!process.env.JWT_REFRESH_SECRET) {
    throw new Error('JWT_REFRESH_SECRET environment variable is not set');
  }

  // Verify token signature with refresh token secret and decode payload
  const decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET);

  // Return decoded payload (TypeScript assertion for type safety)
  return decoded as RefreshTokenPayload;
}
