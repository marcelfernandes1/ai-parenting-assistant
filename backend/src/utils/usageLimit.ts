/**
 * Usage Limit Checking Utilities
 *
 * Provides functions to check if users have exceeded their daily usage limits
 * based on subscription tier (FREE vs PREMIUM).
 *
 * Free tier limits:
 * - Messages: 10 per day
 * - Voice minutes: 10 per day
 * - Photos: 100 total
 *
 * Premium tier: Unlimited usage
 */

import { PrismaClient } from '@prisma/client';

// Initialize Prisma Client for database operations
const prisma = new PrismaClient();

/**
 * Response type for usage limit checks
 * Contains information about whether the action is allowed and remaining usage
 */
export interface UsageLimitResult {
  allowed: boolean; // Whether the user can perform this action
  unlimited: boolean; // Whether the user has unlimited access (PREMIUM)
  remaining?: number; // How many uses remain today (FREE tier only)
  resetTime?: string; // When the limit resets (midnight UTC)
}

/**
 * Check if user has exceeded their daily usage limit
 *
 * This function:
 * 1. Checks user's subscription tier
 * 2. If PREMIUM, allows unlimited access
 * 3. If FREE, checks today's usage against limits
 * 4. Returns whether action is allowed and remaining quota
 *
 * @param userId - The user's ID from JWT token
 * @param limitType - Type of limit to check: 'message' or 'voice'
 * @returns UsageLimitResult with allowed status and remaining quota
 *
 * @example
 * const result = await checkUsageLimit(userId, 'message');
 * if (!result.allowed) {
 *   return res.status(429).json({
 *     error: 'limit_reached',
 *     resetTime: result.resetTime
 *   });
 * }
 */
export async function checkUsageLimit(
  userId: string,
  limitType: 'message' | 'voice',
): Promise<UsageLimitResult> {
  // Fetch user to check subscription tier
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      subscriptionTier: true,
      subscriptionStatus: true,
    },
  });

  if (!user) {
    // User not found - deny access (shouldn't happen with valid JWT)
    return {
      allowed: false,
      unlimited: false,
      remaining: 0,
      resetTime: getNextMidnightUTC(),
    };
  }

  // PREMIUM users have unlimited access
  if (user.subscriptionTier === 'PREMIUM') {
    return {
      allowed: true,
      unlimited: true,
    };
  }

  // FREE users - check today's usage
  const today = getTodayDateString();

  // Find or create today's usage tracking record
  const usage = await prisma.usageTracking.findUnique({
    where: {
      userId_date: {
        userId,
        date: new Date(today), // Convert string to Date for DateTime field
      },
    },
  });

  // If no usage record exists, user hasn't used anything today
  const currentUsage = usage
    ? limitType === 'message'
      ? usage.messagesUsed
      : usage.voiceMinutesUsed
    : 0;

  // Define limits for FREE tier
  const limit = limitType === 'message' ? 10 : 10;

  // Check if under limit
  const allowed = currentUsage < limit;
  const remaining = Math.max(0, limit - currentUsage);

  return {
    allowed,
    unlimited: false,
    remaining,
    resetTime: getNextMidnightUTC(),
  };
}

/**
 * Get today's date as ISO string (YYYY-MM-DD format)
 * Used for querying UsageTracking table by date
 */
function getTodayDateString(): string {
  const now = new Date();
  return now.toISOString().split('T')[0];
}

/**
 * Calculate next midnight UTC as ISO string
 * Used to tell users when their daily limit resets
 *
 * @returns ISO 8601 timestamp string for next midnight UTC
 */
function getNextMidnightUTC(): string {
  const now = new Date();
  const midnight = new Date(now);
  midnight.setUTCHours(24, 0, 0, 0); // Set to next midnight UTC
  return midnight.toISOString();
}

/**
 * Check if user has exceeded photo storage limit
 *
 * Free tier: 100 photos maximum
 * Premium tier: Unlimited photos
 *
 * @param userId - The user's ID from JWT token
 * @returns UsageLimitResult with allowed status and remaining quota
 *
 * @example
 * const result = await checkPhotoLimit(userId);
 * if (!result.allowed) {
 *   return res.status(429).json({
 *     error: 'photo_limit_reached',
 *     message: 'Upgrade to Premium for unlimited photo storage'
 *   });
 * }
 */
export async function checkPhotoLimit(userId: string): Promise<UsageLimitResult> {
  // Fetch user to check subscription tier
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      subscriptionTier: true,
    },
  });

  if (!user) {
    return {
      allowed: false,
      unlimited: false,
      remaining: 0,
    };
  }

  // PREMIUM users have unlimited photo storage
  if (user.subscriptionTier === 'PREMIUM') {
    return {
      allowed: true,
      unlimited: true,
    };
  }

  // FREE users - check total photo count
  const photoCount = await prisma.photo.count({
    where: { userId },
  });

  const limit = 100;
  const allowed = photoCount < limit;
  const remaining = Math.max(0, limit - photoCount);

  return {
    allowed,
    unlimited: false,
    remaining,
  };
}

/**
 * Increment usage counter for a user
 * Called after successfully completing an action (message sent, voice minute used)
 *
 * This ensures usage is only counted when action succeeds,
 * not when requests fail or are rejected.
 *
 * @param userId - The user's ID
 * @param limitType - Type of usage to increment: 'message' or 'voice'
 * @param amount - Amount to increment by (default 1 for messages, custom for voice minutes)
 *
 * @example
 * // After sending a message
 * await incrementUsage(userId, 'message', 1);
 *
 * // After voice session (3 minutes)
 * await incrementUsage(userId, 'voice', 3);
 */
export async function incrementUsage(
  userId: string,
  limitType: 'message' | 'voice',
  amount: number = 1,
): Promise<void> {
  const today = getTodayDateString();

  // Upsert: Create record if doesn't exist, update if exists
  await prisma.usageTracking.upsert({
    where: {
      userId_date: {
        userId,
        date: new Date(today), // Convert to Date for DateTime field
      },
    },
    update: {
      // Increment the appropriate counter
      ...(limitType === 'message'
        ? { messagesUsed: { increment: amount } }
        : { voiceMinutesUsed: { increment: amount } }),
    },
    create: {
      userId,
      date: new Date(today), // Convert to Date for DateTime field
      messagesUsed: limitType === 'message' ? amount : 0,
      voiceMinutesUsed: limitType === 'voice' ? amount : 0,
      photosStored: 0,
    },
  });
}
