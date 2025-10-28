/**
 * AI Parenting Assistant - Main App Entry Point
 * React Native 0.74 compatible implementation with authentication and navigation
 *
 * @format
 */

import React from 'react';
import { StatusBar, useColorScheme } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

// Authentication context provider
import { AuthProvider } from './mobile/src/context/AuthContext';

// Main navigation component
import AppNavigator from './mobile/src/navigation/AppNavigator';

/**
 * Main App component
 * Sets up the app with all necessary providers and navigation
 *
 * Provider hierarchy (outer to inner):
 * 1. GestureHandlerRootView - Required for react-native-gesture-handler
 * 2. SafeAreaProvider - Handles safe area insets (notches, home indicators)
 * 3. AuthProvider - Provides authentication context to entire app
 * 4. AppNavigator - Handles navigation between screens based on auth state
 */
function App() {
  // Detect if user has dark mode enabled for proper StatusBar styling
  const isDarkMode = useColorScheme() === 'dark';

  return (
    // GestureHandlerRootView must wrap the entire app for gesture-based navigation
    <GestureHandlerRootView style={{ flex: 1 }}>
      {/* SafeAreaProvider enables safe area context for all child components */}
      <SafeAreaProvider>
        {/* Configure status bar style based on color scheme */}
        <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />

        {/* AuthProvider makes authentication state available throughout the app */}
        <AuthProvider>
          {/* AppNavigator handles all screen navigation and routing */}
          <AppNavigator />
        </AuthProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

export default App;
