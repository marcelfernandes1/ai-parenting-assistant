/**
 * Usage Tracking Routes
 *
 * Endpoints for tracking and retrieving user usage statistics.
 * Used to enforce free tier limits and display usage to users.
 */

import express, { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticateToken } from '../middleware/auth';

const router = express.Router();
const prisma = new PrismaClient();

/**
 * GET /usage/today
 *
 * Retrieve today's usage statistics for the authenticated user.
 * Shows messages used, voice minutes used, and photos stored.
 *
 * Returns: Usage statistics for current day
 */
router.get('/today', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from JWT token
    const userId = (req as any).user?.userId;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Get today's date (midnight)
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Find today's usage record
    const usage = await prisma.usageTracking.findUnique({
      where: {
        userId_date: {
          userId: userId,
          date: today,
        },
      },
    });

    // If no record exists, return zeros (user hasn't used anything today)
    if (!usage) {
      return res.status(200).json({
        date: today.toISOString(),
        messagesUsed: 0,
        voiceMinutesUsed: 0,
        photosStored: 0,
      });
    }

    // Return usage data
    return res.status(200).json({
      date: usage.date.toISOString(),
      messagesUsed: usage.messagesUsed,
      voiceMinutesUsed: usage.voiceMinutesUsed,
      photosStored: usage.photosStored,
    });
  } catch (error) {
    console.error('Error fetching usage data:', error);

    return res.status(500).json({
      error: 'Failed to fetch usage data',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * GET /usage/history
 *
 * Retrieve usage history for the authenticated user.
 * Shows daily usage over a specified time period.
 *
 * Query params:
 * - days: number (default: 7, max: 90) - number of days to retrieve
 *
 * Returns: Array of daily usage records
 */
router.get('/history', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from JWT token
    const userId = (req as any).user?.userId;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Parse query parameters
    const days = Math.min(parseInt(req.query.days as string) || 7, 90); // Max 90 days

    // Calculate date range
    const endDate = new Date();
    endDate.setHours(23, 59, 59, 999);

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    // Fetch usage records within date range
    const usageRecords = await prisma.usageTracking.findMany({
      where: {
        userId: userId,
        date: {
          gte: startDate,
          lte: endDate,
        },
      },
      orderBy: {
        date: 'desc',
      },
      select: {
        date: true,
        messagesUsed: true,
        voiceMinutesUsed: true,
        photosStored: true,
      },
    });

    return res.status(200).json({
      records: usageRecords,
      period: {
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString(),
        days: days,
      },
    });
  } catch (error) {
    console.error('Error fetching usage history:', error);

    return res.status(500).json({
      error: 'Failed to fetch usage history',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
