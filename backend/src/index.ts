/**
 * AI Parenting Assistant - Backend API Entry Point
 *
 * This is the main server file that initializes the Express application,
 * configures middleware, and starts the HTTP server.
 */

import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import authRoutes from './routes/auth';
import userRoutes from './routes/user';
import chatRoutes from './routes/chat';
import usageRoutes from './routes/usage';
import photosRoutes from './routes/photos';
import milestonesRoutes from './routes/milestones';
import subscriptionRoutes from './routes/subscription';
import webhookRoutes from './routes/webhook';
import { authenticateToken, AuthenticatedRequest } from './middleware/auth';
import { initializeVoiceSocket } from './sockets/voice';

// Load environment variables from .env file
dotenv.config();

/**
 * Express application instance
 * Configured with middleware for JSON parsing, CORS, and error handling
 */
const app = express();

/**
 * Server port from environment variable or default to 3000
 * Used by the HTTP server to listen for incoming connections
 */
const PORT = process.env.PORT || 3000;

// ===========================
// Middleware Configuration
// ===========================

/**
 * CORS middleware to allow cross-origin requests from the mobile app
 * In production, configure to only allow requests from your app's domain
 */
app.use(cors());

/**
 * Stripe webhook route - MUST be registered BEFORE express.json()
 * Uses raw body for webhook signature verification
 * Stripe requires the raw request body to verify the webhook signature
 */
app.use(
  '/stripe/webhook',
  express.raw({ type: 'application/json' }),
  webhookRoutes,
);

/**
 * Body parser middleware to parse JSON request bodies
 * Enables req.body to be populated with parsed JSON data
 */
app.use(express.json());

/**
 * Body parser middleware to parse URL-encoded request bodies
 * Enables form data parsing (e.g., from HTML forms)
 */
app.use(express.urlencoded({ extended: true }));

// ===========================
// Routes
// ===========================

/**
 * Health check endpoint
 * Used to verify the API is running and responsive
 * Returns 200 OK with server status information
 */
app.get('/health', (_req: Request, res: Response) => {
  res.status(200).json({
    status: 'ok',
    message: 'AI Parenting Assistant API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
  });
});

/**
 * Root endpoint
 * Provides basic API information
 */
app.get('/', (_req: Request, res: Response) => {
  res.status(200).json({
    name: 'AI Parenting Assistant API',
    version: '1.0.0',
    description: 'Backend API for AI-powered parenting guidance',
    endpoints: {
      health: '/health',
      auth: '/auth/*',
      user: '/user/*',
      chat: '/chat/*',
      usage: '/usage/*',
      photos: '/photos/*',
      milestones: '/milestones/*',
      subscription: '/subscription/*',
      webhook: '/stripe/webhook',
    },
  });
});

/**
 * Authentication routes
 * Handles user registration, login, and token management
 * All auth endpoints are prefixed with /auth
 */
app.use('/auth', authRoutes);

/**
 * User profile routes
 * Handles user profile management and onboarding data
 * All user endpoints are prefixed with /user
 * Requires authentication
 */
app.use('/user', userRoutes);

/**
 * Chat routes
 * Handles AI chat messaging with personalized responses
 * All chat endpoints are prefixed with /chat
 * Requires authentication
 */
app.use('/chat', chatRoutes);

/**
 * Usage tracking routes
 * Handles usage statistics and daily limits
 * All usage endpoints are prefixed with /usage
 * Requires authentication
 */
app.use('/usage', usageRoutes);

/**
 * Photos routes
 * Handles photo uploads to S3, photo listing, and deletion
 * All photos endpoints are prefixed with /photos
 * Requires authentication
 */
app.use('/photos', photosRoutes);

/**
 * Milestones routes
 * Handles milestone CRUD operations for baby development tracking
 * All milestones endpoints are prefixed with /milestones
 * Requires authentication
 */
app.use('/milestones', milestonesRoutes);

/**
 * Subscription routes
 * Handles Stripe subscription management for premium features
 * All subscription endpoints are prefixed with /subscription
 * Requires authentication
 */
app.use('/subscription', subscriptionRoutes);

/**
 * Protected test endpoint
 * Used to verify authentication middleware is working correctly
 * Requires valid JWT token in Authorization header
 */
app.get('/protected-test', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  res.status(200).json({
    message: 'Authentication successful',
    user: {
      userId: req.user?.userId,
      email: req.user?.email,
    },
  });
});

// ===========================
// Error Handling Middleware
// ===========================

/**
 * 404 handler for undefined routes
 * Catches requests to routes that don't exist
 */
app.use((_req: Request, res: Response) => {
  res.status(404).json({
    error: 'Not Found',
    message: 'The requested resource does not exist',
  });
});

/**
 * Global error handler
 * Catches all errors thrown in the application and returns appropriate response
 * Prevents server crashes by handling uncaught errors gracefully
 */
app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  // Log error for debugging (in production, use proper logging service)
  console.error('Error:', err.message);
  console.error('Stack:', err.stack);

  // Return error response to client
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong',
  });
});

// ===========================
// Server Startup
// ===========================

/**
 * Create HTTP server from Express app
 * Required for Socket.io to work with Express
 */
const httpServer = createServer(app);

/**
 * Initialize Socket.io server
 * Enables real-time WebSocket communication for voice mode
 * CORS configured to allow connections from mobile app
 */
const io = new SocketIOServer(httpServer, {
  cors: {
    origin: '*', // In production, configure to only allow your app's domain
    methods: ['GET', 'POST'],
    credentials: true,
  },
});

/**
 * Initialize voice conversation socket handlers
 * Sets up /voice namespace with authentication and event handlers
 */
initializeVoiceSocket(io);

/**
 * Start the HTTP server
 * Listens on the configured port and logs startup message
 */
httpServer.listen(PORT, () => {
  console.log(`✅ Server is running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🔌 Socket.io enabled on /voice namespace`);
});

/**
 * Export app and io for testing purposes
 * Allows the app to be imported in test files without starting the server
 */
export { io };
export default app;
