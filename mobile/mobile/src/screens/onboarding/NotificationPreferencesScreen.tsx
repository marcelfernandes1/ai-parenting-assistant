/**
 * Notification Preferences Screen (Onboarding Step 9)
 *
 * Asks user about their notification preferences.
 * Controls what types of push notifications they want to receive.
 *
 * Features:
 * - Toggle switches for each notification type
 * - Default values (all ON)
 * - Next button always enabled
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  Switch,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  Platform,
} from 'react-native';
import { OnboardingNavigationProps } from '../../types/onboarding';

/**
 * NotificationPreferencesScreen Component
 *
 * Collects user's notification preferences.
 * Users can enable/disable different types of notifications.
 */
const NotificationPreferencesScreen: React.FC<OnboardingNavigationProps> = ({
  navigation,
  route,
}) => {
  // Get data from previous screens
  const previousData = route?.params || {};

  // State for notification preferences (default all ON)
  const [preferences, setPreferences] = useState({
    dailyMilestoneUpdates: true,
    weeklyTipsGuidance: true,
    milestoneReminders: true,
  });

  /**
   * Toggle a preference
   */
  const togglePreference = (key: keyof typeof preferences) => {
    setPreferences(prev => ({
      ...prev,
      [key]: !prev[key],
    }));
  };

  /**
   * Navigate to final screen (Usage Limits Explanation)
   * Passes all collected data forward
   */
  const handleNext = () => {
    navigation.navigate('UsageLimitsExplanation', {
      ...previousData,
      notificationPreferences: preferences,
    });
  };

  /**
   * Navigate back to previous screen
   */
  const handleBack = () => {
    navigation.goBack();
  };

  /**
   * Notification options with descriptions
   */
  const notificationOptions = [
    {
      key: 'dailyMilestoneUpdates' as keyof typeof preferences,
      title: 'Daily milestone updates',
      description: 'Get daily insights about your baby\'s development stage',
      icon: '📅',
    },
    {
      key: 'weeklyTipsGuidance' as keyof typeof preferences,
      title: 'Weekly tips and guidance',
      description: 'Receive helpful parenting tips every week',
      icon: '💡',
    },
    {
      key: 'milestoneReminders' as keyof typeof preferences,
      title: 'Milestone reminders',
      description: 'Reminders to log milestones and track progress',
      icon: '⏰',
    },
  ];

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Progress Indicator */}
        <View style={styles.progressSection}>
          <Text style={styles.progressText}>Step 6 of 7</Text>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: '85.7%' }]} />
          </View>
        </View>

        {/* Title Section */}
        <View style={styles.titleSection}>
          <Text style={styles.title}>Notification preferences</Text>
          <Text style={styles.subtitle}>
            Choose how you'd like to stay connected
          </Text>
        </View>

        {/* Notification Options */}
        <View style={styles.optionsSection}>
          {notificationOptions.map((option) => (
            <View key={option.key} style={styles.optionCard}>
              <View style={styles.optionContent}>
                <Text style={styles.optionIcon}>{option.icon}</Text>
                <View style={styles.optionTextContainer}>
                  <Text style={styles.optionTitle}>{option.title}</Text>
                  <Text style={styles.optionDescription}>{option.description}</Text>
                </View>
                <Switch
                  value={preferences[option.key]}
                  onValueChange={() => togglePreference(option.key)}
                  trackColor={{ false: '#e0e0e0', true: '#007AFF' }}
                  thumbColor={Platform.OS === 'ios' ? '#fff' : preferences[option.key] ? '#fff' : '#f4f3f4'}
                  ios_backgroundColor="#e0e0e0"
                />
              </View>
            </View>
          ))}
        </View>

        {/* Helper Section */}
        <View style={styles.helperSection}>
          <Text style={styles.helperTitle}>📱 About notifications</Text>
          <Text style={styles.helperText}>
            You can change these preferences anytime in Settings. We'll never spam you -
            notifications are designed to be helpful and timely.
          </Text>
        </View>

        {/* Navigation Buttons */}
        <View style={styles.navigationSection}>
          {/* Back Button */}
          <TouchableOpacity
            style={styles.backButton}
            onPress={handleBack}
            activeOpacity={0.7}
          >
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>

          {/* Next Button - Always enabled */}
          <TouchableOpacity
            style={styles.nextButton}
            onPress={handleNext}
            activeOpacity={0.8}
          >
            <Text style={styles.nextButtonText}>Next →</Text>
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
    backgroundColor: '#007AFF',
    borderRadius: 2,
  },

  // Title section
  titleSection: {
    marginBottom: 24,
  },

  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },

  subtitle: {
    fontSize: 16,
    color: '#666',
    lineHeight: 24,
  },

  // Options section
  optionsSection: {
    gap: 16,
    marginBottom: 24,
  },

  // Option card
  optionCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
    borderWidth: 1,
    borderColor: '#e0e0e0',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },

  optionContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },

  optionIcon: {
    fontSize: 24,
    marginRight: 12,
  },

  optionTextContainer: {
    flex: 1,
    marginRight: 12,
  },

  optionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },

  optionDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },

  // Helper section
  helperSection: {
    backgroundColor: '#f0f8ff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 'auto',
    borderLeftWidth: 4,
    borderLeftColor: '#007AFF',
  },

  helperTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#007AFF',
    marginBottom: 8,
  },

  helperText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },

  // Navigation section
  navigationSection: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 24,
    paddingTop: 24,
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
  },

  // Back button
  backButton: {
    flex: 1,
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#007AFF',
    alignItems: 'center',
  },

  backButtonText: {
    color: '#007AFF',
    fontSize: 16,
    fontWeight: '600',
  },

  // Next button
  nextButton: {
    flex: 2,
    backgroundColor: '#007AFF',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },

  nextButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default NotificationPreferencesScreen;
