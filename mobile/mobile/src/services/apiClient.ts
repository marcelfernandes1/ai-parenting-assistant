/**
 * API Client with Automatic Token Refresh
 *
 * Provides a configured axios instance with interceptors for:
 * - Automatic token attachment to requests
 * - Automatic token refresh on 401 responses
 * - Request retry after token refresh
 * - Logout on refresh failure
 *
 * Usage:
 * import { apiClient } from '../services/apiClient';
 * const response = await apiClient.get('/user/profile');
 */

import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * AsyncStorage keys for auth tokens
 * Must match keys used in AuthContext
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
 * Flag to prevent multiple simultaneous refresh attempts
 * When one request triggers a refresh, others wait for it to complete
 */
let isRefreshing = false;

/**
 * Queue of failed requests waiting for token refresh
 * These requests will be retried after refresh succeeds
 */
let failedQueue: Array<{
  resolve: (value?: any) => void;
  reject: (error?: any) => void;
}> = [];

/**
 * Process the queue of failed requests
 * Called after token refresh succeeds or fails
 *
 * @param error - Error to reject all requests with (if refresh failed)
 * @param token - New access token to use for retrying requests (if refresh succeeded)
 */
const processQueue = (error: any = null, token: string | null = null) => {
  failedQueue.forEach((promise) => {
    if (error) {
      promise.reject(error);
    } else {
      promise.resolve(token);
    }
  });

  // Clear the queue
  failedQueue = [];
};

/**
 * Create axios instance with default configuration
 */
export const apiClient: AxiosInstance = axios.create({
  baseURL: API_URL,
  timeout: 30000, // 30 second timeout for requests
  headers: {
    'Content-Type': 'application/json',
  },
});

/**
 * Request Interceptor
 *
 * Automatically attaches access token to all requests.
 * Token is retrieved from AsyncStorage before each request.
 */
apiClient.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    // Get access token from storage
    const accessToken = await AsyncStorage.getItem(ACCESS_TOKEN_KEY);

    // If token exists, add it to Authorization header
    if (accessToken) {
      config.headers.Authorization = `Bearer ${accessToken}`;
    }

    return config;
  },
  (error) => {
    // Request setup failed - return error
    return Promise.reject(error);
  }
);

/**
 * Response Interceptor
 *
 * Automatically handles 401 Unauthorized responses by:
 * 1. Attempting to refresh the access token
 * 2. Retrying the original request with new token
 * 3. Logging out user if refresh fails
 */
apiClient.interceptors.response.use(
  // Success response - pass through unchanged
  (response) => response,

  // Error response - check if token refresh is needed
  async (error: AxiosError) => {
    const originalRequest: any = error.config;

    // Check if error is 401 Unauthorized
    if (error.response?.status === 401 && originalRequest && !originalRequest._retry) {
      // Mark request as retried to prevent infinite loop
      originalRequest._retry = true;

      // If already refreshing, queue this request to be retried after refresh completes
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        })
          .then((token) => {
            // Refresh succeeded - retry original request with new token
            originalRequest.headers.Authorization = `Bearer ${token}`;
            return apiClient(originalRequest);
          })
          .catch((err) => {
            // Refresh failed - reject this request
            return Promise.reject(err);
          });
      }

      // Start refresh process
      isRefreshing = true;

      try {
        // Get refresh token from storage
        const refreshToken = await AsyncStorage.getItem(REFRESH_TOKEN_KEY);

        if (!refreshToken) {
          // No refresh token available - logout user
          throw new Error('No refresh token available');
        }

        // Call refresh endpoint to get new access token
        const response = await axios.post(`${API_URL}/auth/refresh`, {
          refreshToken,
        });

        const { accessToken: newAccessToken } = response.data;

        // Store new access token in AsyncStorage
        await AsyncStorage.setItem(ACCESS_TOKEN_KEY, newAccessToken);

        // Update Authorization header for original request
        originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;

        // Process queued requests with new token
        processQueue(null, newAccessToken);

        // Retry original request with new token
        return apiClient(originalRequest);
      } catch (refreshError) {
        // Token refresh failed - logout user
        console.error('Token refresh failed:', refreshError);

        // Reject all queued requests
        processQueue(refreshError, null);

        // Clear all auth data from storage
        await AsyncStorage.multiRemove([
          ACCESS_TOKEN_KEY,
          REFRESH_TOKEN_KEY,
          USER_DATA_KEY,
        ]);

        // Reject original request
        // App-level navigation logic will detect missing tokens and show login screen
        return Promise.reject(refreshError);
      } finally {
        // Reset refreshing flag
        isRefreshing = false;
      }
    }

    // Not a 401 error or already retried - return original error
    return Promise.reject(error);
  }
);

/**
 * Helper function to set auth token after login
 * Used by AuthContext after successful login/registration
 *
 * @param token - Access token to set for subsequent requests
 */
export const setAuthToken = (token: string | null) => {
  if (token) {
    apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  } else {
    delete apiClient.defaults.headers.common['Authorization'];
  }
};

/**
 * Helper function to clear auth token on logout
 * Used by AuthContext on logout
 */
export const clearAuthToken = () => {
  delete apiClient.defaults.headers.common['Authorization'];
};

export default apiClient;
