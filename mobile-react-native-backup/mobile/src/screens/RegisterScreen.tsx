/**
 * Register Screen
 *
 * Allows new users to create an account with email and password.
 * Uses AuthContext for registration logic.
 * Navigates to login screen after successful registration.
 *
 * Features:
 * - Email input with validation
 * - Password input with strength indicator
 * - Confirm password field with match validation
 * - Sign Up button with loading state
 * - Error message display
 * - Link to login screen
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { useAuth } from '../context/AuthContext';

/**
 * Navigation prop type for RegisterScreen
 * Used for navigating to other screens
 */
interface RegisterScreenProps {
  navigation: any; // Will be properly typed when React Navigation is set up
}

/**
 * Password strength levels
 */
type PasswordStrength = 'weak' | 'medium' | 'strong';

/**
 * RegisterScreen Component
 *
 * Renders registration form with email, password, and confirm password inputs.
 * Includes password strength indicator and validation.
 */
const RegisterScreen: React.FC<RegisterScreenProps> = ({ navigation }) => {
  // Auth context for registration functionality
  const { register, loading } = useAuth();

  // Form state
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');

  // Password strength state
  const [passwordStrength, setPasswordStrength] = useState<PasswordStrength>('weak');

  /**
   * Calculate password strength based on criteria
   * Updates whenever password changes
   */
  useEffect(() => {
    if (!password) {
      setPasswordStrength('weak');
      return;
    }

    let strength: PasswordStrength = 'weak';

    // Criteria for password strength
    const hasMinLength = password.length >= 8;
    const hasNumber = /\d/.test(password);
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);

    // Calculate strength based on criteria met
    const criteriaMet = [
      hasMinLength,
      hasNumber,
      hasUpperCase,
      hasLowerCase,
      hasSpecialChar,
    ].filter(Boolean).length;

    if (criteriaMet >= 4) {
      strength = 'strong';
    } else if (criteriaMet >= 2) {
      strength = 'medium';
    }

    setPasswordStrength(strength);
  }, [password]);

  /**
   * Get color for password strength indicator
   */
  const getStrengthColor = (): string => {
    switch (passwordStrength) {
      case 'weak':
        return '#ff4444';
      case 'medium':
        return '#ffaa00';
      case 'strong':
        return '#00cc44';
      default:
        return '#ddd';
    }
  };

  /**
   * Get width percentage for strength indicator bar
   */
  const getStrengthWidth = (): string => {
    switch (passwordStrength) {
      case 'weak':
        return '33%';
      case 'medium':
        return '66%';
      case 'strong':
        return '100%';
      default:
        return '0%';
    }
  };

  /**
   * Handle registration button press
   * Validates inputs and calls register method from AuthContext
   */
  const handleRegister = async () => {
    // Clear previous errors
    setError('');

    // Validate email field
    if (!email.trim()) {
      setError('Please enter your email address');
      return;
    }

    // Basic email format validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setError('Please enter a valid email address');
      return;
    }

    // Validate password field
    if (!password) {
      setError('Please enter a password');
      return;
    }

    // Validate password minimum length
    if (password.length < 8) {
      setError('Password must be at least 8 characters long');
      return;
    }

    // Validate password contains at least one number
    if (!/\d/.test(password)) {
      setError('Password must contain at least one number');
      return;
    }

    // Validate confirm password field
    if (!confirmPassword) {
      setError('Please confirm your password');
      return;
    }

    // Validate passwords match
    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    try {
      // Attempt registration via AuthContext
      await register(email.trim().toLowerCase(), password);

      // On success, show message and navigate to login
      Alert.alert(
        'Registration Successful',
        'Your account has been created. Please log in to continue.',
        [
          {
            text: 'OK',
            onPress: () => navigation.navigate('Login'),
          },
        ]
      );
    } catch (err: any) {
      // Display error message from API or generic message
      setError(err.message || 'Registration failed. Please try again.');
    }
  };

  /**
   * Navigate to login screen
   */
  const handleNavigateToLogin = () => {
    navigation.navigate('Login');
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
          <Text style={styles.subtitle}>Create your account</Text>
        </View>

        {/* Registration Form Section */}
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

          {/* Password Input Field with Strength Indicator */}
          <View style={styles.inputContainer}>
            <Text style={styles.inputLabel}>Password</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter your password (min 8 chars, 1 number)"
              placeholderTextColor="#999"
              value={password}
              onChangeText={setPassword}
              secureTextEntry={true}
              autoCapitalize="none"
              autoCorrect={false}
              textContentType="newPassword"
              editable={!loading}
            />

            {/* Password Strength Indicator */}
            {password ? (
              <View style={styles.strengthContainer}>
                <View style={styles.strengthBarBackground}>
                  <View
                    style={[
                      styles.strengthBarFill,
                      {
                        width: getStrengthWidth(),
                        backgroundColor: getStrengthColor(),
                      },
                    ]}
                  />
                </View>
                <Text
                  style={[styles.strengthText, { color: getStrengthColor() }]}
                >
                  {passwordStrength.charAt(0).toUpperCase() + passwordStrength.slice(1)}
                </Text>
              </View>
            ) : null}
          </View>

          {/* Confirm Password Input Field */}
          <View style={styles.inputContainer}>
            <Text style={styles.inputLabel}>Confirm Password</Text>
            <TextInput
              style={styles.input}
              placeholder="Re-enter your password"
              placeholderTextColor="#999"
              value={confirmPassword}
              onChangeText={setConfirmPassword}
              secureTextEntry={true}
              autoCapitalize="none"
              autoCorrect={false}
              textContentType="newPassword"
              editable={!loading}
            />
          </View>

          {/* Sign Up Button */}
          <TouchableOpacity
            style={[styles.signupButton, loading && styles.signupButtonDisabled]}
            onPress={handleRegister}
            disabled={loading}
            activeOpacity={0.8}
          >
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.signupButtonText}>Sign Up</Text>
            )}
          </TouchableOpacity>

          {/* Password Requirements Info */}
          <View style={styles.requirementsContainer}>
            <Text style={styles.requirementsTitle}>Password must contain:</Text>
            <Text style={styles.requirementText}>• At least 8 characters</Text>
            <Text style={styles.requirementText}>• At least 1 number</Text>
          </View>
        </View>

        {/* Login Link Section */}
        <View style={styles.loginSection}>
          <Text style={styles.loginText}>Already have an account? </Text>
          <TouchableOpacity
            onPress={handleNavigateToLogin}
            disabled={loading}
          >
            <Text style={styles.loginLink}>Log In</Text>
          </TouchableOpacity>
        </View>

        {/* Medical Disclaimer */}
        <View style={styles.disclaimerSection}>
          <Text style={styles.disclaimerText}>
            By signing up, you agree to our Terms of Service and Privacy Policy.
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

  // Password strength indicator
  strengthContainer: {
    marginTop: 8,
    flexDirection: 'row',
    alignItems: 'center',
  },

  strengthBarBackground: {
    flex: 1,
    height: 4,
    backgroundColor: '#ddd',
    borderRadius: 2,
    overflow: 'hidden',
  },

  strengthBarFill: {
    height: '100%',
    borderRadius: 2,
  },

  strengthText: {
    marginLeft: 12,
    fontSize: 12,
    fontWeight: '600',
    width: 60,
  },

  // Sign up button
  signupButton: {
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

  signupButtonDisabled: {
    backgroundColor: '#99c9ff',
  },

  signupButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },

  // Password requirements
  requirementsContainer: {
    marginTop: 16,
    padding: 12,
    backgroundColor: '#f0f8ff',
    borderRadius: 8,
  },

  requirementsTitle: {
    fontSize: 12,
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },

  requirementText: {
    fontSize: 12,
    color: '#666',
    marginTop: 2,
  },

  // Login section
  loginSection: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 24,
  },

  loginText: {
    fontSize: 14,
    color: '#666',
  },

  loginLink: {
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

export default RegisterScreen;
