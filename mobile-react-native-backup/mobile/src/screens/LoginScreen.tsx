/**
 * Login Screen
 *
 * Allows existing users to log in with email and password.
 * Uses AuthContext for authentication logic.
 * Navigates to home/onboarding screen on successful login.
 *
 * Features:
 * - Email input with email keyboard type
 * - Password input with secure entry
 * - Login button with loading state
 * - Error message display
 * - Link to registration screen
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { useAuth } from '../context/AuthContext';

/**
 * Navigation prop type for LoginScreen
 * Used for navigating to other screens
 */
interface LoginScreenProps {
  navigation: any; // Will be properly typed when React Navigation is set up
}

/**
 * LoginScreen Component
 *
 * Renders login form with email and password inputs.
 * Handles form validation and submission.
 */
const LoginScreen: React.FC<LoginScreenProps> = ({ navigation }) => {
  // Auth context for login functionality
  const { login, loading } = useAuth();

  // Form state
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  /**
   * Handle login button press
   * Validates inputs and calls login method from AuthContext
   */
  const handleLogin = async () => {
    // Clear previous errors
    setError('');

    // Validate email field
    if (!email.trim()) {
      setError('Please enter your email address');
      return;
    }

    // Validate password field
    if (!password) {
      setError('Please enter your password');
      return;
    }

    // Basic email format validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setError('Please enter a valid email address');
      return;
    }

    try {
      // Attempt login via AuthContext
      await login(email.trim().toLowerCase(), password);

      // On success, navigation will be handled by app-level logic
      // (AuthContext sets isAuthenticated, app navigates to home/onboarding)
    } catch (err: any) {
      // Display error message from API or generic message
      setError(err.message || 'Login failed. Please try again.');
    }
  };

  /**
   * Navigate to registration screen
   */
  const handleNavigateToRegister = () => {
    navigation.navigate('Register');
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 64 : 0}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
      >
        {/* App Logo/Title Section */}
        <View style={styles.headerSection}>
          <Text style={styles.title}>AI Parenting Assistant</Text>
          <Text style={styles.subtitle}>Welcome back!</Text>
        </View>

        {/* Login Form Section */}
        <View style={styles.formSection}>
          {/* Error Message Display */}
          {error ? (
            <View style={styles.errorContainer}>
              <Text style={styles.errorText}>{error}</Text>
            </View>
          ) : null}

          {/* Email Input Field */}
          <View style={styles.inputContainer}>
            <Text style={styles.inputLabel}>Email</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter your email"
              placeholderTextColor="#999"
              value={email}
              onChangeText={setEmail}
              autoCapitalize="none"
              autoCorrect={false}
              keyboardType="email-address"
              textContentType="emailAddress"
              editable={!loading}
            />
          </View>

          {/* Password Input Field */}
          <View style={styles.inputContainer}>
            <Text style={styles.inputLabel}>Password</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter your password"
              placeholderTextColor="#999"
              value={password}
              onChangeText={setPassword}
              secureTextEntry={true}
              autoCapitalize="none"
              autoCorrect={false}
              textContentType="password"
              editable={!loading}
            />
          </View>

          {/* Login Button */}
          <TouchableOpacity
            style={[styles.loginButton, loading && styles.loginButtonDisabled]}
            onPress={handleLogin}
            disabled={loading}
            activeOpacity={0.8}
          >
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.loginButtonText}>Log In</Text>
            )}
          </TouchableOpacity>

          {/* Forgot Password Link (Future Feature) */}
          <TouchableOpacity
            style={styles.forgotPasswordButton}
            onPress={() => Alert.alert('Coming Soon', 'Password reset feature will be available soon.')}
            disabled={loading}
          >
            <Text style={styles.forgotPasswordText}>Forgot password?</Text>
          </TouchableOpacity>
        </View>

        {/* Sign Up Link Section */}
        <View style={styles.signupSection}>
          <Text style={styles.signupText}>Don't have an account? </Text>
          <TouchableOpacity
            onPress={handleNavigateToRegister}
            disabled={loading}
          >
            <Text style={styles.signupLink}>Sign Up</Text>
          </TouchableOpacity>
        </View>

        {/* Medical Disclaimer */}
        <View style={styles.disclaimerSection}>
          <Text style={styles.disclaimerText}>
            This app provides general parenting guidance and is not a substitute for professional medical advice.
          </Text>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

/**
 * Component Styles
 */
const styles = StyleSheet.create({
  // Main container
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },

  // ScrollView content
  scrollContent: {
    flexGrow: 1,
    padding: 24,
    justifyContent: 'center',
  },

  // Header section with title
  headerSection: {
    marginBottom: 40,
    alignItems: 'center',
  },

  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
    textAlign: 'center',
  },

  subtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },

  // Form section
  formSection: {
    marginBottom: 24,
  },

  // Error message container
  errorContainer: {
    backgroundColor: '#fee',
    padding: 12,
    borderRadius: 8,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#fcc',
  },

  errorText: {
    color: '#c00',
    fontSize: 14,
    textAlign: 'center',
  },

  // Input field container
  inputContainer: {
    marginBottom: 20,
  },

  inputLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
  },

  input: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 14,
    fontSize: 16,
    color: '#333',
  },

  // Login button
  loginButton: {
    backgroundColor: '#007AFF',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },

  loginButtonDisabled: {
    backgroundColor: '#99c9ff',
  },

  loginButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },

  // Forgot password link
  forgotPasswordButton: {
    marginTop: 16,
    alignItems: 'center',
  },

  forgotPasswordText: {
    color: '#007AFF',
    fontSize: 14,
  },

  // Sign up section
  signupSection: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 24,
  },

  signupText: {
    fontSize: 14,
    color: '#666',
  },

  signupLink: {
    fontSize: 14,
    color: '#007AFF',
    fontWeight: '600',
  },

  // Disclaimer section
  disclaimerSection: {
    marginTop: 32,
    paddingTop: 24,
    borderTopWidth: 1,
    borderTopColor: '#ddd',
  },

  disclaimerText: {
    fontSize: 12,
    color: '#999',
    textAlign: 'center',
    lineHeight: 18,
  },
});

export default LoginScreen;
