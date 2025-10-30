/**
 * Chat Routes
 *
 * Endpoints for chat messaging with AI assistant.
 * Includes message sending, history retrieval, and session management.
 */

import express, { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import multer from 'multer';
import fs from 'fs/promises';
import { authenticateToken } from '../middleware/auth';
import { generateChatResponse, transcribeAudio, ChatMessage, analyzePhoto } from '../services/openai';
import { checkUsageLimit, incrementUsage } from '../utils/usageLimit';

const router = express.Router();
const prisma = new PrismaClient();

// Configure Multer for audio file uploads
// Store files temporarily in memory for processing
const upload = multer({
  storage: multer.diskStorage({
    destination: '/tmp', // Temporary storage
    filename: (req, file, cb) => {
      // Generate unique filename with timestamp
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      cb(null, 'voice-' + uniqueSuffix + '-' + file.originalname);
    },
  }),
  limits: {
    fileSize: 25 * 1024 * 1024, // 25MB max (Whisper API limit)
  },
  fileFilter: (req, file, cb) => {
    // Accept only audio formats supported by Whisper
    const allowedMimeTypes = [
      'audio/mpeg',      // .mp3
      'audio/mp4',       // .m4a
      'audio/wav',       // .wav
      'audio/webm',      // .webm
      'audio/x-m4a',     // .m4a (alternative mime type)
    ];

    if (allowedMimeTypes.includes(file.mimetype)) {
      cb(null, true); // Accept file
    } else {
      cb(new Error(`Invalid file type. Allowed types: ${allowedMimeTypes.join(', ')}`));
    }
  },
});

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
    const { content, sessionId, photoUrls } = req.body;

    // Allow empty content if photos are provided
    if ((!content || typeof content !== 'string') && (!photoUrls || photoUrls.length === 0)) {
      return res.status(400).json({ error: 'Message content or photos are required' });
    }

    // Validate content length if provided
    if (content && content.trim().length === 0 && (!photoUrls || photoUrls.length === 0)) {
      return res.status(400).json({ error: 'Message content cannot be empty without photos' });
    }

    // Validate content length if provided
    if (content && content.length > 2000) {
      return res.status(400).json({ error: 'Message content exceeds maximum length of 2000 characters' });
    }

    if (!sessionId || typeof sessionId !== 'string') {
      return res.status(400).json({ error: 'Session ID is required' });
    }

    // Check usage limit before processing message
    const usageCheck = await checkUsageLimit(userId, 'message');
    if (!usageCheck.allowed) {
      return res.status(429).json({
        error: 'limit_reached',
        resetTime: usageCheck.resetTime,
        remaining: usageCheck.remaining || 0,
        message: `You've reached your daily message limit. ${usageCheck.unlimited ? '' : `Resets at ${usageCheck.resetTime}. `}Upgrade to Premium for unlimited messaging!`,
      });
    }

    // Fetch user data including profile for AI context
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { profile: true },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Analyze photos with AI Vision if photoUrls provided
    let photoAnalysisText = '';
    if (photoUrls && Array.isArray(photoUrls) && photoUrls.length > 0) {
      console.log(`📸 Analyzing ${photoUrls.length} photo(s) with AI Vision...`);

      // Calculate baby age for context
      let babyAge = '';
      if (user.profile?.babyBirthDate) {
        const today = new Date();
        const ageInDays = Math.floor((today.getTime() - user.profile.babyBirthDate.getTime()) / (1000 * 60 * 60 * 24));
        const ageInMonths = Math.floor(ageInDays / 30);
        const ageInWeeks = Math.floor(ageInDays / 7);

        if (ageInMonths < 3) {
          babyAge = `${ageInWeeks} weeks old`;
        } else {
          babyAge = `${ageInMonths} months old`;
        }
      } else if (user.profile?.dueDate) {
        const today = new Date();
        const weeksPregnant = Math.floor((user.profile.dueDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24 * 7));
        const weeksElapsed = 40 - weeksPregnant;
        babyAge = `${weeksElapsed} weeks pregnant`;
      }

      // Analyze each photo
      const analysisResults: string[] = [];
      for (const photoUrl of photoUrls) {
        try {
          const { analysis } = await analyzePhoto(photoUrl, {
            babyAge: babyAge,
            concerns: content || 'General photo analysis',
          });
          analysisResults.push(analysis);
        } catch (error) {
          console.error('Error analyzing photo:', error);
          analysisResults.push('Unable to analyze this photo.');
        }
      }

      // Combine analysis results
      photoAnalysisText = analysisResults.join('\n\n');
      console.log(`✅ Photo analysis complete`);
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

    // Build message content with photo analysis if available
    let messageContent = content || '';
    if (photoAnalysisText) {
      // Prepend photo analysis to user's message
      messageContent = `[PHOTO ANALYSIS]\n${photoAnalysisText}\n\n${content ? `[USER'S QUESTION]\n${content}` : 'Please provide guidance based on this photo analysis.'}`;
    }

    // Add current user message to history
    conversationHistory.push({
      role: 'user',
      content: messageContent,
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
        content: content || '📸 Photos',
        contentType: photoUrls && photoUrls.length > 0 ? 'IMAGE' : 'TEXT',
        mediaUrls: photoUrls && Array.isArray(photoUrls) ? photoUrls : [],
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

    // Increment usage counter (works for both FREE and PREMIUM tiers)
    await incrementUsage(userId, 'message', 1);

    // Return AI response
    return res.status(200).json({
      message: 'Message sent successfully',
      userMessage: {
        id: userMessage.id,
        content: userMessage.content,
        contentType: userMessage.contentType,
        mediaUrls: userMessage.mediaUrls,
        timestamp: userMessage.timestamp,
      },
      assistantMessage: {
        id: assistantMessage.id,
        content: assistantMessage.content,
        contentType: assistantMessage.contentType,
        mediaUrls: assistantMessage.mediaUrls,
        timestamp: assistantMessage.timestamp,
      },
      tokensUsed: tokensUsed,
      photoAnalysis: photoAnalysisText || undefined,
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
 * GET /chat/conversations
 *
 * Retrieve a list of all conversation sessions for the authenticated user.
 * Returns session metadata including first/last message timestamps and preview.
 *
 * Query params:
 * - limit: number (default: 20, max: 50)
 * - offset: number (default: 0)
 *
 * Returns: Array of conversation sessions with metadata
 */
router.get('/conversations', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from JWT token
    const userId = (req as any).user?.userId;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Parse query parameters
    const limit = Math.min(parseInt(req.query.limit as string) || 20, 50); // Max 50
    const offset = parseInt(req.query.offset as string) || 0;

    // Get all unique session IDs for this user, ordered by most recent activity
    // Use aggregation to get session metadata
    const sessions = await prisma.message.groupBy({
      by: ['sessionId'],
      where: {
        userId: userId,
      },
      _count: {
        id: true, // Count messages per session
      },
      _max: {
        timestamp: true, // Most recent message timestamp
      },
      _min: {
        timestamp: true, // First message timestamp
      },
      orderBy: {
        _max: {
          timestamp: 'desc', // Order by most recent activity
        },
      },
      skip: offset,
      take: limit,
    });

    // For each session, fetch the first user message as preview
    const conversationsWithPreview = await Promise.all(
      sessions.map(async (session) => {
        // Get first user message for preview
        const firstUserMessage = await prisma.message.findFirst({
          where: {
            userId: userId,
            sessionId: session.sessionId,
            role: 'USER',
          },
          orderBy: {
            timestamp: 'asc',
          },
          select: {
            content: true,
            contentType: true,
          },
        });

        // Create a preview text (first 100 chars of first message)
        const previewText = firstUserMessage
          ? firstUserMessage.content.substring(0, 100) +
            (firstUserMessage.content.length > 100 ? '...' : '')
          : 'Empty conversation';

        return {
          sessionId: session.sessionId,
          messageCount: session._count.id,
          firstMessageAt: session._min.timestamp,
          lastMessageAt: session._max.timestamp,
          preview: previewText,
          previewType: firstUserMessage?.contentType || 'TEXT',
        };
      })
    );

    // Get total session count for pagination
    const totalSessions = await prisma.message.groupBy({
      by: ['sessionId'],
      where: {
        userId: userId,
      },
      _count: {
        sessionId: true,
      },
    });

    return res.status(200).json({
      conversations: conversationsWithPreview,
      pagination: {
        total: totalSessions.length,
        limit: limit,
        offset: offset,
        hasMore: offset + sessions.length < totalSessions.length,
      },
    });
  } catch (error) {
    console.error('Error fetching conversations:', error);

    return res.status(500).json({
      error: 'Failed to fetch conversations',
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

/**
 * POST /chat/voice
 *
 * Transcribe voice message using Whisper API and generate AI response.
 * Accepts audio file upload, transcribes it, then processes like regular text message.
 *
 * Request: multipart/form-data
 * - audio: File (audio file - .mp3, .m4a, .wav, .webm)
 * - sessionId: string (conversation session ID)
 *
 * Returns: Transcription text and AI response
 */
router.post('/voice', authenticateToken, upload.single('audio'), async (req: Request, res: Response) => {
  let filePath: string | undefined;

  try {
    // Extract userId from JWT token
    const userId = (req as any).user?.userId;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Check if file was uploaded
    if (!req.file) {
      return res.status(400).json({ error: 'Audio file is required' });
    }

    filePath = req.file.path;

    // Extract sessionId from form data
    const { sessionId } = req.body;

    if (!sessionId || typeof sessionId !== 'string') {
      return res.status(400).json({ error: 'Session ID is required' });
    }

    // Check usage limit before processing voice message
    // For Whisper transcription, we count it as a message (not voice minutes)
    const usageCheck = await checkUsageLimit(userId, 'message');
    if (!usageCheck.allowed) {
      // Clean up uploaded file before returning error
      await fs.unlink(filePath).catch(() => {});

      return res.status(429).json({
        error: 'limit_reached',
        resetTime: usageCheck.resetTime,
        remaining: usageCheck.remaining || 0,
        message: `You've reached your daily message limit. ${usageCheck.unlimited ? '' : `Resets at ${usageCheck.resetTime}. `}Upgrade to Premium for unlimited messaging!`,
      });
    }

    // Fetch user data including profile for AI context
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { profile: true },
    });

    if (!user) {
      // Clean up uploaded file before returning error
      await fs.unlink(filePath).catch(() => {});
      return res.status(404).json({ error: 'User not found' });
    }

    // Transcribe audio using Whisper API
    console.log(`Transcribing audio file: ${req.file.originalname} (${req.file.size} bytes)`);
    const transcription = await transcribeAudio(filePath);
    console.log(`Transcription complete: "${transcription}"`);

    // Clean up uploaded file after transcription
    await fs.unlink(filePath).catch((err) => {
      console.warn('Failed to delete temporary audio file:', err);
    });
    filePath = undefined; // Mark as cleaned up

    // Validate transcription is not empty
    if (!transcription || transcription.trim().length === 0) {
      return res.status(400).json({
        error: 'Transcription failed',
        message: 'Could not transcribe audio. Please try again or speak more clearly.',
      });
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

    // Add transcribed message to history
    conversationHistory.push({
      role: 'user',
      content: transcription,
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

    // Save user voice message to database (with VOICE content type)
    const userMessage = await prisma.message.create({
      data: {
        userId: userId,
        sessionId: sessionId,
        role: 'USER',
        content: transcription, // Store transcribed text
        contentType: 'VOICE',
        mediaUrls: [], // Could store audio URL if we wanted to save it
        tokensUsed: 0,
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

    // Increment usage counter (works for both FREE and PREMIUM tiers)
    await incrementUsage(userId, 'message', 1);

    // Return transcription and AI response
    return res.status(200).json({
      message: 'Voice message transcribed and processed successfully',
      transcription: transcription,
      userMessage: {
        id: userMessage.id,
        content: userMessage.content,
        timestamp: userMessage.timestamp,
        contentType: 'VOICE',
      },
      assistantMessage: {
        id: assistantMessage.id,
        content: assistantMessage.content,
        timestamp: assistantMessage.timestamp,
      },
      tokensUsed: tokensUsed,
    });
  } catch (error) {
    // Clean up uploaded file if error occurred
    if (filePath) {
      await fs.unlink(filePath).catch(() => {});
    }

    console.error('Error processing voice message:', error);

    return res.status(500).json({
      error: 'Failed to process voice message',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
