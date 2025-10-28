/**
 * Authentication Context
 *
 * Provides authentication state and methods throughout the React Native app.
 * Uses React Context API to share auth state with all components.
 * Stores JWT tokens in AsyncStorage for persistent login sessions.
 *
 * Features:
 * - User registration and login
 * - JWT token storage (access + refresh tokens)
 * - Automatic token loading on app launch
 * - Logout functionality
 * - Loading states for async operations
 */

import React, { createContext, useState, useContext, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';

/**
 * User data structure returned from backend API
 * Matches the user object from /auth/login response
 */
interface User {
  id: string;
  email: string;
  subscriptionTier: 'FREE' | 'PREMIUM';
  subscriptionStatus: 'ACTIVE' | 'INACTIVE' | 'EXPIRED';
  profile: {
    mode: 'PREGNANCY' | 'PARENTING';
    babyName: string | null;
  };
}

/**
 * Authentication context value provided to all consuming components
 * Contains auth state and methods for auth operations
 */
interface AuthContextValue {
  // Current authenticated user (null if not logged in)
  user: User | null;

  // JWT access token (7-day expiry) for API requests
  accessToken: string | null;

  // JWT refresh token (30-day expiry) for getting new access tokens
  refreshToken: string | null;

  // Loading state for async operations (login, register, token load)
  loading: boolean;

  // Boolean helper: true if user is authenticated
  isAuthenticated: boolean;

  // Methods for auth operations
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

/**
 * AsyncStorage keys for storing tokens
 * Prefixed with app name to avoid conflicts with other apps
 */
const ACCESS_TOKEN_KEY = '@AIParenting:accessToken';
const REFRESH_TOKEN_KEY = '@AIParenting:refreshToken';
const USER_DATA_KEY = '@AIParenting:userData';

/**
 * API base URL from environment variable
 * Defaults to localhost for development
 */
const API_URL = process.env.API_URL || 'http://localhost:3000';

/**
 * Create the AuthContext with undefined default value
 * Will be provided by AuthProvider component
 */
const AuthContext = createContext<AuthContextValue | undefined>(undefined);

/**
 * AuthProvider Component
 *
 * Wraps the entire app to provide authentication state to all components.
 * Handles token storage, loading, and all auth operations.
 *
 * Usage:
 * <AuthProvider>
 *   <App />
 * </AuthProvider>
 */
export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  // Auth state
  const [user, setUser] = useState<User | null>(null);
  const [accessToken, setAccessToken] = useState<string | null>(null);
  const [refreshToken, setRefreshToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  /**
   * Load stored tokens and user data from AsyncStorage on app launch
   * Runs once when AuthProvider mounts
   */
  useEffect(() => {
    loadStoredAuth();
  }, []);

  /**
   * Load authentication data from AsyncStorage
   * Called on app launch to restore previous login session
   */
  const loadStoredAuth = async () => {
    try {
      // Attempt to load all auth data in parallel for faster startup
      const [storedAccessToken, storedRefreshToken, storedUserData] = await Promise.all([
        AsyncStorage.getItem(ACCESS_TOKEN_KEY),
        AsyncStorage.getItem(REFRESH_TOKEN_KEY),
        AsyncStorage.getItem(USER_DATA_KEY),
      ]);

      // If all auth data exists, restore the session
      if (storedAccessToken && storedRefreshToken && storedUserData) {
        setAccessToken(storedAccessToken);
        setRefreshToken(storedRefreshToken);
        setUser(JSON.parse(storedUserData));
      }
    } catch (error) {
      // If loading fails, log error but continue (user will see login screen)
      console.error('Failed to load auth data from storage:', error);
    } finally {
      // Set loading to false regardless of success/failure
      // This allows app to render (either login screen or home screen)
      setLoading(false);
    }
  };

  /**
   * Store authentication data in AsyncStorage
   * Called after successful login/registration
   *
   * @param accessToken - JWT access token from API
   * @param refreshToken - JWT refresh token from API
   * @param userData - User object from API response
   */
  const storeAuth = async (
    accessToken: string,
    refreshToken: string,
    userData: User
  ) => {
    try {
      // Store all auth data in parallel for better performance
      await Promise.all([
        AsyncStorage.setItem(ACCESS_TOKEN_KEY, accessToken),
        AsyncStorage.setItem(REFRESH_TOKEN_KEY, refreshToken),
        AsyncStorage.setItem(USER_DATA_KEY, JSON.stringify(userData)),
      ]);

      // Update state after storage succeeds
      setAccessToken(accessToken);
      setRefreshToken(refreshToken);
      setUser(userData);
    } catch (error) {
      // If storage fails, throw error so calling code can handle it
      console.error('Failed to store auth data:', error);
      throw new Error('Failed to save login session');
    }
  };

  /**
   * Clear authentication data from AsyncStorage
   * Called on logout
   */
  const clearAuth = async () => {
    try {
      // Remove all auth data in parallel
      await Promise.all([
        AsyncStorage.removeItem(ACCESS_TOKEN_KEY),
        AsyncStorage.removeItem(REFRESH_TOKEN_KEY),
        AsyncStorage.removeItem(USER_DATA_KEY),
      ]);

      // Clear state
      setAccessToken(null);
      setRefreshToken(null);
      setUser(null);
    } catch (error) {
      // If clearing fails, log error but continue
      // (state is cleared even if storage fails)
      console.error('Failed to clear auth data:', error);
    }
  };

  /**
   * Register a new user account
   *
   * Calls POST /auth/register API endpoint.
   * Does NOT automatically log in user - they must log in separately.
   *
   * @param email - User's email address
   * @param password - User's password (min 8 chars, 1 number)
   * @throws Error if registration fails
   */
  const register = async (email: string, password: string): Promise<void> => {
    setLoading(true);
    try {
      // Call registration API endpoint
      const response = await axios.post(`${API_URL}/auth/register`, {
        email,
        password,
      });

      // Registration successful - user must now log in
      // (Backend does not auto-login for security reasons)
      console.log('Registration successful:', response.data);
    } catch (error: any) {
      // Handle registration errors
      if (error.response) {
        // Server responded with error (400, 500, etc)
        const errorMessage = error.response.data?.message || 'Registration failed';
        throw new Error(errorMessage);
      } else if (error.request) {
        // Request made but no response (network error)
        throw new Error('Network error. Please check your connection.');
      } else {
        // Other errors
        throw new Error('An unexpected error occurred');
      }
    } finally {
      setLoading(false);
    }
  };

  /**
   * Log in an existing user
   *
   * Calls POST /auth/login API endpoint.
   * Stores tokens and user data on successful login.
   *
   * @param email - User's email address
   * @param password - User's password
   * @throws Error if login fails
   */
  const login = async (email: string, password: string): Promise<void> => {
    setLoading(true);
    try {
      // Call login API endpoint
      const response = await axios.post(`${API_URL}/auth/login`, {
        email,
        password,
      });

      // Extract tokens and user data from response
      const { accessToken, refreshToken, user: userData } = response.data;

      // Store auth data in AsyncStorage and state
      await storeAuth(accessToken, refreshToken, userData);

      console.log('Login successful');
    } catch (error: any) {
      // Handle login errors
      if (error.response) {
        // Server responded with error
        const errorMessage = error.response.data?.message || 'Login failed';
        throw new Error(errorMessage);
      } else if (error.request) {
        // Network error
        throw new Error('Network error. Please check your connection.');
      } else {
        // Other errors
        throw new Error('An unexpected error occurred');
      }
    } finally {
      setLoading(false);
    }
  };

  /**
   * Log out the current user
   *
   * Clears tokens and user data from AsyncStorage and state.
   * User will be redirected to login screen by navigation logic.
   */
  const logout = async (): Promise<void> => {
    setLoading(true);
    try {
      // Clear all auth data
      await clearAuth();
      console.log('Logout successful');
    } catch (error) {
      // Log error but still complete logout
      console.error('Logout error:', error);
    } finally {
      setLoading(false);
    }
  };

  /**
   * Computed value: is user authenticated?
   * True if user and tokens exist
   */
  const isAuthenticated = !!(user && accessToken && refreshToken);

  /**
   * Context value provided to all consumers
   * Contains auth state and methods
   */
  const value: AuthContextValue = {
    user,
    accessToken,
    refreshToken,
    loading,
    isAuthenticated,
    login,
    register,
    logout,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

/**
 * useAuth Hook
 *
 * Custom hook to access auth context in any component.
 * Throws error if used outside of AuthProvider.
 *
 * Usage:
 * const { user, login, logout, isAuthenticated } = useAuth();
 */
export const useAuth = (): AuthContextValue => {
  const context = useContext(AuthContext);

  // Ensure hook is used within AuthProvider
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }

  return context;
};
