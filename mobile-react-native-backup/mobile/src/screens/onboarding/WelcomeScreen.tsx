/**
 * Welcome Screen (Onboarding Step 1)
 *
 * First screen of the onboarding flow.
 * Displays app logo, tagline, intro text, and medical disclaimer.
 * Allows user to start onboarding or skip to main app.
 *
 * Features:
 * - App branding and value proposition
 * - Medical disclaimer
 * - "Get Started" button to begin onboarding
 * - "Skip" option to go directly to app
 */

import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  SafeAreaView,
} from 'react-native';
import { OnboardingNavigationProps } from '../../types/onboarding';

/**
 * WelcomeScreen Component
 *
 * Entry point for the onboarding flow.
 * Introduces the app and its benefits to new users.
 */
const WelcomeScreen: React.FC<OnboardingNavigationProps> = ({ navigation }) => {
  /**
   * Navigate to next onboarding screen (Current Stage)
   */
  const handleGetStarted = () => {
    navigation.navigate('CurrentStage');
  };

  /**
   * Skip onboarding and go to main app
   * User can complete onboarding later from settings
   */
  const handleSkip = () => {
    // Navigate to main app (will be implemented when main navigation is set up)
    // For now, just log
    console.log('Skip onboarding - navigate to main app');
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Logo/Icon Section */}
        <View style={styles.logoSection}>
          {/* Placeholder for app logo/icon */}
          <View style={styles.logoPlaceholder}>
            <Text style={styles.logoText}>👶</Text>
          </View>
        </View>

        {/* Title Section */}
        <View style={styles.titleSection}>
          <Text style={styles.title}>AI Parenting Assistant</Text>
          <Text style={styles.tagline}>
            Your personalized guide through pregnancy and parenting
          </Text>
        </View>

        {/* Intro Section */}
        <View style={styles.introSection}>
          <Text style={styles.introText}>
            Get expert guidance tailored to your unique parenting journey:
          </Text>

          {/* Feature List */}
          <View style={styles.featureList}>
            <View style={styles.featureItem}>
              <Text style={styles.featureBullet}>✓</Text>
              <Text style={styles.featureText}>
                24/7 AI-powered answers to your parenting questions
              </Text>
            </View>

            <View style={styles.featureItem}>
              <Text style={styles.featureBullet}>✓</Text>
              <Text style={styles.featureText}>
                Personalized advice based on your baby's age and needs
              </Text>
            </View>

            <View style={styles.featureItem}>
              <Text style={styles.featureBullet}>✓</Text>
              <Text style={styles.featureText}>
                Track milestones and developmental progress
              </Text>
            </View>

            <View style={styles.featureItem}>
              <Text style={styles.featureBullet}>✓</Text>
              <Text style={styles.featureText}>
                Respectful of your parenting philosophy and values
              </Text>
            </View>
          </View>
        </View>

        {/* Medical Disclaimer */}
        <View style={styles.disclaimerSection}>
          <Text style={styles.disclaimerTitle}>Important Notice</Text>
          <Text style={styles.disclaimerText}>
            This app provides general parenting information and is not a substitute
            for professional medical advice, diagnosis, or treatment. Always seek
            the advice of your pediatrician or other qualified health provider
            with any questions about your baby's health.
          </Text>
        </View>

        {/* Action Buttons */}
        <View style={styles.buttonSection}>
          {/* Get Started Button */}
          <TouchableOpacity
            style={styles.getStartedButton}
            onPress={handleGetStarted}
            activeOpacity={0.8}
          >
            <Text style={styles.getStartedButtonText}>Get Started</Text>
          </TouchableOpacity>

          {/* Skip Button */}
          <TouchableOpacity
            style={styles.skipButton}
            onPress={handleSkip}
            activeOpacity={0.6}
          >
            <Text style={styles.skipButtonText}>Skip for now</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

/**
 * Component Styles
 */
const styles = StyleSheet.create({
  // Safe area container
  safeArea: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },

  // ScrollView content
  scrollContent: {
    flexGrow: 1,
    padding: 24,
    paddingTop: 40,
  },

  // Logo section
  logoSection: {
    alignItems: 'center',
    marginBottom: 32,
  },

  logoPlaceholder: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 5,
  },

  logoText: {
    fontSize: 48,
  },

  // Title section
  titleSection: {
    marginBottom: 32,
    alignItems: 'center',
  },

  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 8,
  },

  tagline: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    lineHeight: 24,
  },

  // Intro section
  introSection: {
    marginBottom: 32,
  },

  introText: {
    fontSize: 16,
    color: '#333',
    marginBottom: 16,
    fontWeight: '600',
  },

  // Feature list
  featureList: {
    gap: 12,
  },

  featureItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },

  featureBullet: {
    fontSize: 18,
    color: '#00cc44',
    marginRight: 12,
    fontWeight: 'bold',
  },

  featureText: {
    flex: 1,
    fontSize: 15,
    color: '#555',
    lineHeight: 22,
  },

  // Disclaimer section
  disclaimerSection: {
    backgroundColor: '#fff4e6',
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#ffd699',
    marginBottom: 32,
  },

  disclaimerTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#cc6600',
    marginBottom: 8,
  },

  disclaimerText: {
    fontSize: 12,
    color: '#996600',
    lineHeight: 18,
  },

  // Button section
  buttonSection: {
    gap: 12,
    marginTop: 'auto',
    paddingBottom: 16,
  },

  // Get Started button
  getStartedButton: {
    backgroundColor: '#007AFF',
    padding: 18,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },

  getStartedButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },

  // Skip button
  skipButton: {
    padding: 12,
    alignItems: 'center',
  },

  skipButtonText: {
    color: '#999',
    fontSize: 14,
  },
});

export default WelcomeScreen;
