/**
 * AI Parenting Assistant - Backend API Entry Point
 *
 * This is the main server file that initializes the Express application,
 * configures middleware, and starts the HTTP server.
 */

import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth';

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
    },
  });
});

/**
 * Authentication routes
 * Handles user registration, login, and token management
 * All auth endpoints are prefixed with /auth
 */
app.use('/auth', authRoutes);

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
 * Start the HTTP server
 * Listens on the configured port and logs startup message
 */
app.listen(PORT, () => {
  console.log(`✅ Server is running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});

/**
 * Export app for testing purposes
 * Allows the app to be imported in test files without starting the server
 */
export default app;
