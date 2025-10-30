/**
 * Voice Conversation Socket.io Handlers
 *
 * Manages real-time WebSocket connections for voice conversations.
 * Handles audio streaming, transcription, AI responses, and TTS.
 */

import { Server as SocketIOServer, Socket } from 'socket.io';
import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';
import { transcribeAudio, generateChatResponse, UserProfile } from '../services/openai';
import fs from 'fs/promises';
import path from 'path';
import { randomUUID } from 'crypto';

const prisma = new PrismaClient();

// Free tier daily limit for voice minutes
const FREE_TIER_VOICE_MINUTES_LIMIT = 10;

/**
 * Interface for JWT payload from authentication token
 * Contains user identification data
 */
interface JWTPayload {
  userId: string;
  email: string;
}

/**
 * Interface for authenticated socket connection
 * Extends Socket with user data after authentication
 */
interface AuthenticatedSocket extends Socket {
  user?: JWTPayload;
  voiceSessionId?: string;
  sessionStartTime?: number;
  audioBuffer?: Buffer[];
}

/**
 * Socket.io authentication middleware
 * Verifies JWT token from handshake auth and attaches user data to socket
 *
 * @param socket - Socket connection to authenticate
 * @param next - Callback to continue or reject connection
 */
const authenticateSocket = async (
  socket: AuthenticatedSocket,
  next: (err?: Error) => void
) => {
  try {
    // Extract token from handshake auth
    // Client should send token as: socket.auth = { token: 'Bearer <token>' }
    const token = socket.handshake.auth.token?.replace('Bearer ', '');

    if (!token) {
      return next(new Error('Authentication error: No token provided'));
    }

    // Verify JWT token
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as JWTPayload;

    // Attach user data to socket for use in event handlers
    socket.user = decoded;

    next();
  } catch (error) {
    next(new Error('Authentication error: Invalid token'));
  }
};

/**
 * Initialize voice conversation Socket.io namespace
 * Sets up /voice namespace with authentication and event handlers
 *
 * @param io - Socket.io server instance
 */
export function initializeVoiceSocket(io: SocketIOServer): void {
  // Create /voice namespace for voice conversations
  const voiceNamespace = io.of('/voice');

  // Apply authentication middleware to all connections
  voiceNamespace.use(authenticateSocket);

  // Handle new socket connections
  voiceNamespace.on('connection', async (socket: AuthenticatedSocket) => {
    console.log(`🎙️ Voice client connected: ${socket.user?.userId}`);

    // Initialize session data
    socket.voiceSessionId = randomUUID();
    socket.sessionStartTime = Date.now();
    socket.audioBuffer = [];

    /**
     * Handle voice session start
     * Client emits this when starting a voice conversation
     * Checks if user has remaining voice minutes available
     */
    socket.on('start_session', async () => {
      try {
        if (!socket.user) return;

        // Get user subscription tier
        const user = await prisma.user.findUnique({
          where: { id: socket.user.userId },
          select: { subscriptionTier: true },
        });

        if (!user) {
          socket.emit('error', { message: 'User not found' });
          return;
        }

        // Check daily voice usage limit for free tier users
        if (user.subscriptionTier === 'FREE') {
          const today = new Date().toISOString().split('T')[0];
          const usage = await prisma.usageTracking.findUnique({
            where: {
              userId_date: {
                userId: socket.user.userId,
                date: today,
              },
            },
          });

          const minutesUsed = usage?.voiceMinutesUsed || 0;

          if (minutesUsed >= FREE_TIER_VOICE_MINUTES_LIMIT) {
            socket.emit('limit_reached', {
              message: 'Daily voice minute limit reached',
              minutesUsed,
              limit: FREE_TIER_VOICE_MINUTES_LIMIT,
            });
            return;
          }

          // Send remaining minutes to client
          socket.emit('session_started', {
            voiceSessionId: socket.voiceSessionId,
            minutesRemaining: FREE_TIER_VOICE_MINUTES_LIMIT - minutesUsed,
          });
        } else {
          // Premium users have unlimited minutes
          socket.emit('session_started', {
            voiceSessionId: socket.voiceSessionId,
            minutesRemaining: -1, // -1 indicates unlimited
          });
        }
      } catch (error) {
        console.error('Error starting voice session:', error);
        socket.emit('error', { message: 'Failed to start voice session' });
      }
    });

    /**
     * Handle incoming audio chunks
     * Client streams audio data in chunks during recording
     * Server buffers chunks until client signals completion
     */
    socket.on('audio_chunk', async (data: { chunk: Buffer; isLast: boolean }) => {
      try {
        if (!socket.user || !socket.audioBuffer) return;

        // Add chunk to buffer
        socket.audioBuffer.push(data.chunk);

        // If this is the last chunk, process the complete audio
        if (data.isLast) {
          // Combine all buffered chunks into single audio file
          const audioData = Buffer.concat(socket.audioBuffer);

          // Save temporary audio file for Whisper API
          const tempFileName = `voice-${socket.voiceSessionId}-${Date.now()}.m4a`;
          const tempFilePath = path.join('/tmp', tempFileName);
          await fs.writeFile(tempFilePath, audioData);

          // Transcribe audio with Whisper API
          const transcribedText = await transcribeAudio(tempFilePath);

          // Send transcription back to client
          socket.emit('transcription', { text: transcribedText });

          // Generate AI response based on transcription
          const prismaUserProfile = await prisma.userProfile.findUnique({
            where: { userId: socket.user.userId },
          });

          // Get last 10 messages for context
          const recentMessages = await prisma.message.findMany({
            where: { userId: socket.user.userId },
            orderBy: { timestamp: 'desc' },
            take: 10,
          });

          // Reverse to get chronological order and convert role to lowercase for OpenAI API
          const contextMessages = recentMessages.reverse().map((msg) => ({
            role: msg.role.toLowerCase() as 'user' | 'assistant',
            content: msg.content,
          }));

          // Add current user message
          contextMessages.push({
            role: 'user',
            content: transcribedText,
          });

          // Convert Prisma UserProfile to OpenAI UserProfile interface
          const userProfile: UserProfile | undefined = prismaUserProfile
            ? {
                mode: prismaUserProfile.mode,
                babyName: prismaUserProfile.babyName,
                babyBirthDate: prismaUserProfile.babyBirthDate,
                dueDate: prismaUserProfile.dueDate,
                parentingPhilosophy:
                  typeof prismaUserProfile.parentingPhilosophy === 'string'
                    ? prismaUserProfile.parentingPhilosophy
                    : undefined,
                religiousViews:
                  typeof prismaUserProfile.religiousViews === 'string'
                    ? prismaUserProfile.religiousViews
                    : undefined,
                culturalBackground: prismaUserProfile.culturalBackground,
                concerns: Array.isArray(prismaUserProfile.concerns)
                  ? (prismaUserProfile.concerns as string[])
                  : [],
              }
            : undefined;

          // Check if user profile exists before generating AI response
          if (!userProfile) {
            socket.emit('error', { message: 'User profile not found' });
            // Clear audio buffer on error
            socket.audioBuffer = [];
            return;
          }

          // Generate AI response
          const aiResponse = await generateChatResponse(
            contextMessages,
            userProfile
          );

          // Send AI response text to client
          socket.emit('ai_response', {
            text: aiResponse.response,
            tokensUsed: aiResponse.tokensUsed,
          });

          // Save messages to database with uppercase roles
          await prisma.message.createMany({
            data: [
              {
                userId: socket.user.userId,
                role: 'USER',
                content: transcribedText,
                contentType: 'VOICE',
                sessionId: socket.voiceSessionId || '',
              },
              {
                userId: socket.user.userId,
                role: 'ASSISTANT',
                content: aiResponse.response,
                contentType: 'TEXT',
                sessionId: socket.voiceSessionId || '',
              },
            ],
          });

          // Clean up temporary audio file
          await fs.unlink(tempFilePath).catch(() => {
            // Ignore error if file doesn't exist
          });

          // Clear audio buffer for next message
          socket.audioBuffer = [];
        }
      } catch (error) {
        console.error('Error processing audio chunk:', error);
        socket.emit('error', { message: 'Failed to process audio' });

        // Clear buffer on error
        if (socket.audioBuffer) {
          socket.audioBuffer = [];
        }
      }
    });

    /**
     * Handle voice session end
     * Client emits this when ending a voice conversation
     * Calculates elapsed time and updates usage tracking
     */
    socket.on('end_session', async () => {
      try {
        if (!socket.user || !socket.sessionStartTime) return;

        // Calculate elapsed time in minutes
        const elapsedMs = Date.now() - socket.sessionStartTime;
        const elapsedMinutes = Math.ceil(elapsedMs / 60000); // Round up to nearest minute

        // Update usage tracking
        const today = new Date().toISOString().split('T')[0];

        await prisma.usageTracking.upsert({
          where: {
            userId_date: {
              userId: socket.user.userId,
              date: today,
            },
          },
          update: {
            voiceMinutesUsed: {
              increment: elapsedMinutes,
            },
          },
          create: {
            userId: socket.user.userId,
            date: today,
            messagesUsed: 0,
            voiceMinutesUsed: elapsedMinutes,
            photosStored: 0,
          },
        });

        // Send session summary to client
        socket.emit('session_ended', {
          duration: elapsedMinutes,
          voiceSessionId: socket.voiceSessionId,
        });

        console.log(
          `🎙️ Voice session ended: ${socket.user.userId} (${elapsedMinutes} min)`
        );
      } catch (error) {
        console.error('Error ending voice session:', error);
        socket.emit('error', { message: 'Failed to end voice session' });
      }
    });

    /**
     * Handle socket disconnection
     * Cleanup resources and save session data if needed
     */
    socket.on('disconnect', async () => {
      console.log(`🎙️ Voice client disconnected: ${socket.user?.userId}`);

      // If session was not properly ended, update usage tracking
      if (socket.sessionStartTime && socket.user) {
        const elapsedMs = Date.now() - socket.sessionStartTime;
        const elapsedMinutes = Math.ceil(elapsedMs / 60000);

        const today = new Date().toISOString().split('T')[0];

        await prisma.usageTracking.upsert({
          where: {
            userId_date: {
              userId: socket.user.userId,
              date: today,
            },
          },
          update: {
            voiceMinutesUsed: {
              increment: elapsedMinutes,
            },
          },
          create: {
            userId: socket.user.userId,
            date: today,
            messagesUsed: 0,
            voiceMinutesUsed: elapsedMinutes,
            photosStored: 0,
          },
        });
      }

      // Clear audio buffer
      if (socket.audioBuffer) {
        socket.audioBuffer = [];
      }
    });
  });
}
