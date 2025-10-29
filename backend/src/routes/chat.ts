/**
 * Chat Routes
 *
 * Endpoints for chat messaging with AI assistant.
 * Includes message sending, history retrieval, and session management.
 */

import express, { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticateToken } from '../middleware/auth';
import { generateChatResponse, ChatMessage } from '../services/openai';

const router = express.Router();
const prisma = new PrismaClient();

// Daily usage limits for free tier
const FREE_TIER_MESSAGE_LIMIT = 10;

/**
 * POST /chat/message
 *
 * Send a message and receive AI response.
 * Checks daily usage limits, saves messages, and generates AI response.
 *
 * Request body:
 * - content: string (message text, max 2000 chars)
 * - sessionId: string (conversation session ID)
 *
 * Returns: AI response message
 */
router.post('/message', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from JWT token (set by authenticateToken middleware)
    const userId = (req as any).user?.userId;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Extract and validate request body
    const { content, sessionId } = req.body;

    if (!content || typeof content !== 'string') {
      return res.status(400).json({ error: 'Message content is required' });
    }

    if (content.trim().length === 0) {
      return res.status(400).json({ error: 'Message content cannot be empty' });
    }

    if (content.length > 2000) {
      return res.status(400).json({ error: 'Message content exceeds maximum length of 2000 characters' });
    }

    if (!sessionId || typeof sessionId !== 'string') {
      return res.status(400).json({ error: 'Session ID is required' });
    }

    // Fetch user data including subscription tier
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { profile: true },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check daily usage limit for free tier users
    if (user.subscriptionTier === 'FREE') {
      // Get today's date (midnight)
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // Find or create today's usage record
      let usage = await prisma.usageTracking.findUnique({
        where: {
          userId_date: {
            userId: userId,
            date: today,
          },
        },
      });

      // Check if limit exceeded
      if (usage && usage.messagesUsed >= FREE_TIER_MESSAGE_LIMIT) {
        return res.status(429).json({
          error: 'Daily message limit reached',
          limit: FREE_TIER_MESSAGE_LIMIT,
          used: usage.messagesUsed,
          resetTime: 'midnight',
          message: `You've reached your daily limit of ${FREE_TIER_MESSAGE_LIMIT} messages. Upgrade to Premium for unlimited messaging!`,
        });
      }
    }

    // Fetch last 10 messages from this session for context
    const recentMessages = await prisma.message.findMany({
      where: {
        userId: userId,
        sessionId: sessionId,
      },
      orderBy: {
        timestamp: 'desc',
      },
      take: 10,
    });

    // Reverse to get chronological order (oldest first)
    recentMessages.reverse();

    // Convert to ChatMessage format for OpenAI
    const conversationHistory: ChatMessage[] = recentMessages.map((msg) => ({
      role: msg.role === 'USER' ? 'user' : 'assistant',
      content: msg.content,
    }));

    // Add current user message to history
    conversationHistory.push({
      role: 'user',
      content: content,
    });

    // Build user profile for system prompt
    const userProfile = {
      mode: user.profile?.mode,
      babyName: user.profile?.babyName,
      babyBirthDate: user.profile?.babyBirthDate,
      dueDate: user.profile?.dueDate,
      parentingPhilosophy: user.profile?.parentingPhilosophy as string | undefined,
      religiousViews: user.profile?.religiousViews as string | undefined,
      culturalBackground: user.profile?.culturalBackground,
      concerns: user.profile?.concerns,
    };

    // Generate AI response using OpenAI service
    const { response: aiResponse, tokensUsed } = await generateChatResponse(
      conversationHistory,
      userProfile
    );

    // Save user message to database
    const userMessage = await prisma.message.create({
      data: {
        userId: userId,
        sessionId: sessionId,
        role: 'USER',
        content: content,
        contentType: 'TEXT',
        mediaUrls: [],
        tokensUsed: 0, // User messages don't consume tokens
        timestamp: new Date(),
      },
    });

    // Save assistant response to database
    const assistantMessage = await prisma.message.create({
      data: {
        userId: userId,
        sessionId: sessionId,
        role: 'ASSISTANT',
        content: aiResponse,
        contentType: 'TEXT',
        mediaUrls: [],
        tokensUsed: tokensUsed,
        timestamp: new Date(),
      },
    });

    // Update usage tracking for free tier users
    if (user.subscriptionTier === 'FREE') {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // Upsert usage record (increment messagesUsed)
      await prisma.usageTracking.upsert({
        where: {
          userId_date: {
            userId: userId,
            date: today,
          },
        },
        update: {
          messagesUsed: {
            increment: 1,
          },
          updatedAt: new Date(),
        },
        create: {
          userId: userId,
          date: today,
          messagesUsed: 1,
          voiceMinutesUsed: 0,
          photosStored: 0,
        },
      });
    }

    // Return AI response
    return res.status(200).json({
      message: 'Message sent successfully',
      userMessage: {
        id: userMessage.id,
        content: userMessage.content,
        timestamp: userMessage.timestamp,
      },
      assistantMessage: {
        id: assistantMessage.id,
        content: assistantMessage.content,
        timestamp: assistantMessage.timestamp,
      },
      tokensUsed: tokensUsed,
    });
  } catch (error) {
    console.error('Error sending message:', error);

    return res.status(500).json({
      error: 'Failed to send message',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * GET /chat/history
 *
 * Retrieve chat message history for the authenticated user.
 * Supports pagination.
 *
 * Query params:
 * - sessionId: string (optional - filter by session)
 * - limit: number (default: 50, max: 100)
 * - offset: number (default: 0)
 *
 * Returns: Array of messages ordered by timestamp (newest first)
 */
router.get('/history', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from JWT token
    const userId = (req as any).user?.userId;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Parse query parameters
    const sessionId = req.query.sessionId as string | undefined;
    const limit = Math.min(parseInt(req.query.limit as string) || 50, 100); // Max 100
    const offset = parseInt(req.query.offset as string) || 0;

    // Build where clause
    const where: any = {
      userId: userId,
    };

    if (sessionId) {
      where.sessionId = sessionId;
    }

    // Fetch messages from database
    const messages = await prisma.message.findMany({
      where: where,
      orderBy: {
        timestamp: 'desc', // Newest first
      },
      take: limit,
      skip: offset,
      select: {
        id: true,
        role: true,
        content: true,
        contentType: true,
        mediaUrls: true,
        timestamp: true,
        sessionId: true,
      },
    });

    // Get total count for pagination
    const totalCount = await prisma.message.count({
      where: where,
    });

    return res.status(200).json({
      messages: messages,
      pagination: {
        total: totalCount,
        limit: limit,
        offset: offset,
        hasMore: offset + messages.length < totalCount,
      },
    });
  } catch (error) {
    console.error('Error fetching chat history:', error);

    return res.status(500).json({
      error: 'Failed to fetch chat history',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * DELETE /chat/session
 *
 * Delete all messages from a specific session.
 * Useful for "New Conversation" feature.
 *
 * Request body:
 * - sessionId: string (session to delete)
 *
 * Returns: Success message with count of deleted messages
 */
router.delete('/session', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from JWT token
    const userId = (req as any).user?.userId;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Extract sessionId from request body
    const { sessionId } = req.body;

    if (!sessionId || typeof sessionId !== 'string') {
      return res.status(400).json({ error: 'Session ID is required' });
    }

    // Delete all messages in this session for this user
    const deleteResult = await prisma.message.deleteMany({
      where: {
        userId: userId,
        sessionId: sessionId,
      },
    });

    return res.status(200).json({
      message: 'Session deleted successfully',
      deletedCount: deleteResult.count,
    });
  } catch (error) {
    console.error('Error deleting session:', error);

    return res.status(500).json({
      error: 'Failed to delete session',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
