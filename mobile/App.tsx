/**
 * AI Parenting Assistant - Main App Entry Point
 * React Native 0.74 compatible implementation
 *
 * @format
 */

import React from 'react';
import {
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
} from 'react-native';
import {
  SafeAreaProvider,
  useSafeAreaInsets,
} from 'react-native-safe-area-context';

/**
 * Main App component
 * Sets up the app with SafeAreaProvider for proper screen insets
 * and StatusBar configuration based on color scheme
 */
function App() {
  // Detect if user has dark mode enabled for proper StatusBar styling
  const isDarkMode = useColorScheme() === 'dark';

  return (
    <SafeAreaProvider>
      {/* Configure status bar style based on color scheme */}
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <AppContent />
    </SafeAreaProvider>
  );
}

/**
 * AppContent component - Main content area
 * Uses safe area insets to avoid notches, home indicators, etc.
 */
function AppContent() {
  const safeAreaInsets = useSafeAreaInsets();
  const isDarkMode = useColorScheme() === 'dark';

  // Create background and text colors based on color scheme
  const backgroundColor = isDarkMode ? '#1a1a1a' : '#ffffff';
  const textColor = isDarkMode ? '#ffffff' : '#000000';

  return (
    <View style={[styles.container, { backgroundColor }]}>
      <View
        style={[
          styles.content,
          {
            paddingTop: safeAreaInsets.top || 20,
            paddingBottom: safeAreaInsets.bottom || 20,
            paddingLeft: safeAreaInsets.left || 20,
            paddingRight: safeAreaInsets.right || 20,
          },
        ]}
      >
        {/* Welcome screen - placeholder for actual app screens */}
        <Text style={[styles.title, { color: textColor }]}>
          AI Parenting Assistant
        </Text>
        <Text style={[styles.subtitle, { color: textColor }]}>
          Welcome! 👶
        </Text>
        <Text style={[styles.description, { color: textColor, opacity: 0.7 }]}>
          Your AI-powered parenting companion is ready.
        </Text>
        <Text style={[styles.description, { color: textColor, opacity: 0.7 }]}>
          React Native 0.74 running successfully!
        </Text>
      </View>
    </View>
  );
}

/**
 * Component styles
 * Following a clean, centered layout for the welcome screen
 */
const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 48,
    marginBottom: 24,
    textAlign: 'center',
  },
  description: {
    fontSize: 16,
    marginBottom: 8,
    textAlign: 'center',
  },
});

export default App;
