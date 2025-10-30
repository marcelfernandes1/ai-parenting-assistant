/**
 * Jest test setup file
 * Runs before each test suite to configure the test environment
 */

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-key-for-testing';
process.env.JWT_REFRESH_SECRET = 'test-jwt-refresh-secret-for-testing';

// Mock console methods to reduce test output noise
global.console = {
  ...console,
  log: jest.fn(), // Mock console.log
  debug: jest.fn(), // Mock console.debug
  info: jest.fn(), // Mock console.info
  warn: jest.fn(), // Mock console.warn (keep errors)
};

// Global test timeout
jest.setTimeout(10000); // 10 seconds
