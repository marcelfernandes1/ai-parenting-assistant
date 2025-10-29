/**
 * Authentication Controller
 *
 * Handles user authentication operations including registration and login.
 * Uses bcrypt for password hashing and JWT for token generation.
 */

import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { PrismaClient } from '@prisma/client';
import { validationResult } from 'express-validator';
import { generateAccessToken, generateRefreshToken } from '../utils/jwt';

// Initialize Prisma Client for database operations
const prisma = new PrismaClient();

// Number of salt rounds for bcrypt password hashing
// 10 rounds provides good security while maintaining reasonable performance
const SALT_ROUNDS = 10;

/**
 * Register a new user account
 *
 * Creates a new user with hashed password and empty profile.
 * Does NOT automatically log in user - they must verify email first (future feature).
 *
 * Request body:
 * - email: string (valid email format)
 * - password: string (min 8 chars, must contain at least 1 number)
 *
 * @param req - Express request object with user registration data
 * @param res - Express response object
 * @returns 201 with success message, or 400/500 with error
 */
export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    // Validate request body using express-validator
    // Errors are populated by validation middleware in routes
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      // Return 400 Bad Request with validation errors
      res.status(400).json({
        error: 'Validation failed',
        details: errors.array(),
      });
      return;
    }

    // Extract email and password from request body
    const { email, password } = req.body;

    // Check if user with this email already exists
    // Email is unique in database, but we check here for better error message
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      // Return 400 Bad Request if email is already registered
      res.status(400).json({
        error: 'Email already registered',
        message: 'An account with this email already exists. Please log in instead.',
      });
      return;
    }

    // Hash password using bcrypt with 10 salt rounds
    // NEVER store plain text passwords in database
    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

    // Create user and profile in a transaction
    // Transaction ensures both are created or neither (atomic operation)
    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        // Create empty profile linked to user (1:1 relationship)
        profile: {
          create: {
            concerns: [], // Initialize empty concerns array
          },
        },
      },
      // Include profile in response for verification
      include: {
        profile: true,
      },
    });

    // Generate JWT tokens for auto-login after registration
    const accessToken = generateAccessToken(user.id, user.email);
    const refreshToken = generateRefreshToken(user.id);

    // Return 201 Created with tokens and user data
    // Auto-login user after successful registration
    res.status(201).json({
      message: 'Registration successful',
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        subscriptionTier: user.subscriptionTier,
        onboardingComplete: user.onboardingComplete, // Always false for new users
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    });
  } catch (error) {
    // Log error for debugging (in production, use proper logging service)
    console.error('Registration error:', error);

    // Return 500 Internal Server Error for unexpected errors
    res.status(500).json({
      error: 'Registration failed',
      message: 'An error occurred during registration. Please try again.',
    });
  }
};

/**
 * Log in an existing user
 *
 * Validates credentials and returns JWT tokens for authentication.
 * Generates both access token (7 days) and refresh token (30 days).
 *
 * Request body:
 * - email: string
 * - password: string
 *
 * @param req - Express request object with login credentials
 * @param res - Express response object
 * @returns 200 with tokens and user data, or 400/401/500 with error
 */
export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    // Validate request body using express-validator
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      // Return 400 Bad Request with validation errors
      res.status(400).json({
        error: 'Validation failed',
        details: errors.array(),
      });
      return;
    }

    // Extract email and password from request body
    const { email, password } = req.body;

    // Look up user by email
    const user = await prisma.user.findUnique({
      where: { email },
      // Include profile for user data in response
      include: {
        profile: true,
      },
    });

    // Return 401 Unauthorized if user not found
    // Use generic message to avoid leaking information about registered emails
    if (!user) {
      res.status(401).json({
        error: 'Invalid credentials',
        message: 'Email or password is incorrect.',
      });
      return;
    }

    // Compare provided password with stored hash using bcrypt
    // bcrypt.compare() handles timing-safe comparison to prevent timing attacks
    const passwordValid = await bcrypt.compare(password, user.passwordHash);

    if (!passwordValid) {
      // Return 401 Unauthorized if password doesn't match
      res.status(401).json({
        error: 'Invalid credentials',
        message: 'Email or password is incorrect.',
      });
      return;
    }

    // Generate JWT tokens for authenticated session
    // Access token (7 days): Used for API requests
    // Refresh token (30 days): Used to get new access tokens
    const accessToken = generateAccessToken(user.id, user.email);
    const refreshToken = generateRefreshToken(user.id);

    // Return 200 OK with tokens and user data
    res.status(200).json({
      message: 'Login successful',
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        subscriptionTier: user.subscriptionTier,
        subscriptionStatus: user.subscriptionStatus,
        // Use onboardingComplete field from User model
        onboardingComplete: user.onboardingComplete,
        // Include profile data if available
        mode: user.profile?.mode,
        babyName: user.profile?.babyName,
        babyBirthDate: user.profile?.babyBirthDate?.toISOString() || null,
        parentingPhilosophy: user.profile?.parentingPhilosophy,
        religiousViews: user.profile?.religiousViews,
        primaryConcerns: user.profile?.concerns,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    });
  } catch (error) {
    // Log error for debugging
    console.error('Login error:', error);

    // Return 500 Internal Server Error for unexpected errors
    res.status(500).json({
      error: 'Login failed',
      message: 'An error occurred during login. Please try again.',
    });
  }
};

/**
 * Refresh access token using refresh token
 *
 * Allows users to get a new access token without logging in again.
 * Validates refresh token and issues new access token.
 *
 * Request body:
 * - refreshToken: string (JWT refresh token)
 *
 * @param req - Express request object with refresh token
 * @param res - Express response object
 * @returns 200 with new access token, or 400/401/500 with error
 */
export const refreshAccessToken = async (
  req: Request,
  res: Response,
): Promise<void> => {
  try {
    const { refreshToken } = req.body;

    // Validate refresh token is provided
    if (!refreshToken) {
      res.status(400).json({
        error: 'Refresh token required',
        message: 'Please provide a refresh token.',
      });
      return;
    }

    // Verify refresh token (will throw if invalid/expired)
    // Note: verifyRefreshToken is imported but needs to be added to jwt.ts
    // For now, we'll implement basic validation
    const { verifyRefreshToken } = require('../utils/jwt');
    const decoded = verifyRefreshToken(refreshToken);

    // Look up user to ensure they still exist and are active
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
    });

    if (!user) {
      res.status(401).json({
        error: 'Invalid refresh token',
        message: 'User not found. Please log in again.',
      });
      return;
    }

    // Generate new access token
    const newAccessToken = generateAccessToken(user.id, user.email);

    // Return new access token
    res.status(200).json({
      message: 'Token refreshed successfully',
      accessToken: newAccessToken,
    });
  } catch (error) {
    // Log error for debugging
    console.error('Token refresh error:', error);

    // Return 401 for invalid/expired refresh tokens
    res.status(401).json({
      error: 'Invalid refresh token',
      message: 'Refresh token is invalid or expired. Please log in again.',
    });
  }
};

/**
 * Verify email endpoint (stub for MVP)
 *
 * Future implementation: Verify email address using token sent via email.
 * For MVP: Simple stub that returns success.
 *
 * @param req - Express request object
 * @param res - Express response object
 */
export const verifyEmail = async (
  req: Request,
  res: Response,
): Promise<void> => {
  // TODO: Implement email verification in post-MVP
  // For now, return success stub
  res.status(200).json({
    message: 'Email verification not yet implemented',
    note: 'This feature will be added in post-MVP phase',
  });
};

/**
 * Reset password endpoint (stub for MVP)
 *
 * Future implementation: Send password reset email with token.
 * For MVP: Simple stub that returns success.
 *
 * @param req - Express request object
 * @param res - Express response object
 */
export const resetPassword = async (
  req: Request,
  res: Response,
): Promise<void> => {
  // TODO: Implement password reset in post-MVP
  // For now, return success stub
  res.status(200).json({
    message: 'Password reset not yet implemented',
    note: 'This feature will be added in post-MVP phase',
  });
};
