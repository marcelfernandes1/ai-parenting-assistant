/**
 * Usage Limits Explanation Screen (Onboarding Step 10 - Final)
 *
 * Explains free tier usage limits and premium benefits.
 * Allows user to either start free trial or continue with free tier.
 *
 * Features:
 * - Visual explanation of limits
 * - Premium benefits list
 * - Two action buttons (Start Free Trial / Continue with Free)
 * - Saves all onboarding data when completed
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { OnboardingNavigationProps } from '../../types/onboarding';

/**
 * UsageLimitsExplanationScreen Component
 *
 * Final onboarding screen that explains usage limits and premium options.
 * Saves all collected onboarding data to backend when user completes.
 */
const UsageLimitsExplanationScreen: React.FC<OnboardingNavigationProps> = ({
  navigation,
  route,
}) => {
  // Get all data from previous screens
  const onboardingData = route?.params || {};

  // Loading state for data submission
  const [isSubmitting, setIsSubmitting] = useState(false);

  /**
   * Handle completion with free trial option
   * For MVP, we'll skip the actual Stripe integration
   */
  const handleStartFreeTrial = async () => {
    // For MVP, treat this the same as free tier
    // TODO: Phase 4 - Implement Stripe free trial flow
    await handleComplete(true);
  };

  /**
   * Handle completion with free tier
   */
  const handleContinueWithFree = async () => {
    await handleComplete(false);
  };

  /**
   * Complete onboarding and save data to backend
   */
  const handleComplete = async (startFreeTrial: boolean) => {
    setIsSubmitting(true);

    try {
      // TODO: Implement API call to save onboarding data
      // const response = await api.put('/user/profile', {
      //   ...onboardingData,
      //   startFreeTrial,
      // });

      // For now, just log the data
      console.log('Onboarding data to save:', {
        ...onboardingData,
        startFreeTrial,
      });

      // Simulate API call delay
      await new Promise(resolve => setTimeout(resolve, 1000));

      // Mark onboarding as complete in AsyncStorage
      // TODO: Implement AsyncStorage persistence

      // Navigate to main app (Home screen)
      // TODO: Replace with actual navigation to Home screen
      Alert.alert(
        'Onboarding Complete!',
        'Welcome to AI Parenting Assistant. Your profile has been saved.',
        [
          {
            text: 'Get Started',
            onPress: () => {
              // TODO: Navigate to Home screen
              console.log('Navigate to Home screen');
            },
          },
        ]
      );
    } catch (error) {
      console.error('Error saving onboarding data:', error);
      Alert.alert(
        'Error',
        'Failed to save your profile. Please try again.',
        [{ text: 'OK' }]
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  /**
   * Navigate back to previous screen
   */
  const handleBack = () => {
    navigation.goBack();
  };

  /**
   * Premium benefits list
   */
  const premiumBenefits = [
    '✓ Unlimited AI chat messages',
    '✓ Unlimited voice conversations',
    '✓ Unlimited photo storage',
    '✓ Priority support',
    '✓ Advanced milestone tracking',
  ];

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Progress Indicator */}
        <View style={styles.progressSection}>
          <Text style={styles.progressText}>Step 7 of 7</Text>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: '100%' }]} />
          </View>
        </View>

        {/* Title Section */}
        <View style={styles.titleSection}>
          <Text style={styles.title}>You're almost ready!</Text>
          <Text style={styles.subtitle}>
            Choose how you'd like to start your parenting journey
          </Text>
        </View>

        {/* Free Tier Limits */}
        <View style={styles.limitsSection}>
          <Text style={styles.sectionTitle}>Free Tier Includes:</Text>
          <View style={styles.limitCard}>
            <Text style={styles.limitIcon}>💬</Text>
            <Text style={styles.limitText}>10 AI messages per day</Text>
          </View>
          <View style={styles.limitCard}>
            <Text style={styles.limitIcon}>🎤</Text>
            <Text style={styles.limitText}>10 minutes of voice chat per day</Text>
          </View>
          <View style={styles.limitCard}>
            <Text style={styles.limitIcon}>📸</Text>
            <Text style={styles.limitText}>Up to 100 photos stored</Text>
          </View>
        </View>

        {/* Premium Benefits */}
        <View style={styles.premiumSection}>
          <Text style={styles.premiumTitle}>Premium Benefits:</Text>
          {premiumBenefits.map((benefit, index) => (
            <Text key={index} style={styles.premiumBenefit}>
              {benefit}
            </Text>
          ))}
          <Text style={styles.premiumNote}>
            Free 7-day trial • Cancel anytime
          </Text>
        </View>

        {/* Action Buttons */}
        <View style={styles.actionsSection}>
          {/* Start Free Trial Button */}
          <TouchableOpacity
            style={styles.premiumButton}
            onPress={handleStartFreeTrial}
            disabled={isSubmitting}
            activeOpacity={0.8}
          >
            {isSubmitting ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <>
                <Text style={styles.premiumButtonText}>Start Free Trial</Text>
                <Text style={styles.premiumButtonSubtext}>7 days free, then $9.99/month</Text>
              </>
            )}
          </TouchableOpacity>

          {/* Continue with Free Button */}
          <TouchableOpacity
            style={styles.freeButton}
            onPress={handleContinueWithFree}
            disabled={isSubmitting}
            activeOpacity={0.8}
          >
            <Text style={styles.freeButtonText}>Continue with Free</Text>
          </TouchableOpacity>

          {/* Back Button */}
          <TouchableOpacity
            style={styles.backButton}
            onPress={handleBack}
            disabled={isSubmitting}
            activeOpacity={0.7}
          >
            <Text style={styles.backButtonText}>← Back</Text>
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
  },

  // Progress section
  progressSection: {
    marginBottom: 32,
  },

  progressText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },

  progressBar: {
    height: 4,
    backgroundColor: '#e0e0e0',
    borderRadius: 2,
    overflow: 'hidden',
  },

  progressFill: {
    height: '100%',
    backgroundColor: '#34C759',
    borderRadius: 2,
  },

  // Title section
  titleSection: {
    marginBottom: 24,
  },

  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },

  subtitle: {
    fontSize: 16,
    color: '#666',
    lineHeight: 24,
  },

  // Limits section
  limitsSection: {
    marginBottom: 24,
  },

  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginBottom: 12,
  },

  limitCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 8,
    padding: 12,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },

  limitIcon: {
    fontSize: 20,
    marginRight: 12,
  },

  limitText: {
    fontSize: 15,
    color: '#333',
  },

  // Premium section
  premiumSection: {
    backgroundColor: '#007AFF',
    borderRadius: 12,
    padding: 20,
    marginBottom: 24,
  },

  premiumTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 12,
  },

  premiumBenefit: {
    fontSize: 15,
    color: '#fff',
    marginBottom: 8,
    paddingLeft: 8,
  },

  premiumNote: {
    fontSize: 13,
    color: '#fff',
    marginTop: 12,
    fontStyle: 'italic',
    opacity: 0.9,
  },

  // Actions section
  actionsSection: {
    gap: 12,
    marginTop: 'auto',
  },

  // Premium button
  premiumButton: {
    backgroundColor: '#34C759',
    padding: 20,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 4,
  },

  premiumButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 4,
  },

  premiumButtonSubtext: {
    color: '#fff',
    fontSize: 13,
    opacity: 0.9,
  },

  // Free button
  freeButton: {
    backgroundColor: '#fff',
    padding: 18,
    borderRadius: 12,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#007AFF',
  },

  freeButtonText: {
    color: '#007AFF',
    fontSize: 16,
    fontWeight: '600',
  },

  // Back button
  backButton: {
    padding: 12,
    alignItems: 'center',
  },

  backButtonText: {
    color: '#666',
    fontSize: 16,
  },
});

export default UsageLimitsExplanationScreen;
