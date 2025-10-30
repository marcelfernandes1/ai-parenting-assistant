/**
 * Unit tests for authentication utilities
 * Tests password hashing, JWT generation, and token verification
 */

import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';

describe('Authentication Utilities', () => {
  describe('Password Hashing', () => {
    it('should hash password with bcrypt', async () => {
      const password = 'MySecurePassword123!';
      const hashedPassword = await bcrypt.hash(password, 10);

      // Hashed password should be different from plaintext
      expect(hashedPassword).not.toBe(password);
      expect(hashedPassword.length).toBeGreaterThan(0);
    });

    it('should verify correct password', async () => {
      const password = 'MySecurePassword123!';
      const hashedPassword = await bcrypt.hash(password, 10);

      const isValid = await bcrypt.compare(password, hashedPassword);
      expect(isValid).toBe(true);
    });

    it('should reject incorrect password', async () => {
      const password = 'MySecurePassword123!';
      const wrongPassword = 'WrongPassword456!';
      const hashedPassword = await bcrypt.hash(password, 10);

      const isValid = await bcrypt.compare(wrongPassword, hashedPassword);
      expect(isValid).toBe(false);
    });
  });

  describe('JWT Token Generation', () => {
    const JWT_SECRET = 'test-secret-key';

    it('should generate valid JWT token', () => {
      const payload = { userId: '123', email: 'test@example.com' };
      const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });

      expect(token).toBeDefined();
      expect(typeof token).toBe('string');
      expect(token.split('.')).toHaveLength(3); // Header.Payload.Signature
    });

    it('should verify valid JWT token', () => {
      const payload = { userId: '123', email: 'test@example.com' };
      const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });

      const decoded = jwt.verify(token, JWT_SECRET) as any;
      expect(decoded.userId).toBe(payload.userId);
      expect(decoded.email).toBe(payload.email);
    });

    it('should reject invalid JWT token', () => {
      const invalidToken = 'invalid.token.here';

      expect(() => {
        jwt.verify(invalidToken, JWT_SECRET);
      }).toThrow();
    });

    it('should reject token with wrong secret', () => {
      const payload = { userId: '123', email: 'test@example.com' };
      const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });

      expect(() => {
        jwt.verify(token, 'wrong-secret');
      }).toThrow();
    });
  });

  describe('Token Expiration', () => {
    const JWT_SECRET = 'test-secret-key';

    it('should create token with expiration', () => {
      const payload = { userId: '123' };
      const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '1h' });

      const decoded = jwt.verify(token, JWT_SECRET) as any;
      expect(decoded.exp).toBeDefined();
      expect(decoded.exp).toBeGreaterThan(Date.now() / 1000);
    });
  });
});
