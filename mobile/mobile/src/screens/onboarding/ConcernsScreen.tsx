/**
 * Concerns Screen (Onboarding Step 8 - Question 4)
 *
 * Asks user about their main parenting concerns.
 * This helps prioritize relevant guidance and content.
 *
 * Features:
 * - Multi-select checkboxes (max 3 selections)
 * - Selection counter
 * - Next button enabled after at least 1 selection
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  SafeAreaView,
} from 'react-native';
import { OnboardingNavigationProps, Concern } from '../../types/onboarding';

/**
 * ConcernsScreen Component
 *
 * Collects user's top parenting concerns (max 3).
 * This helps personalize AI responses to focus on their specific needs.
 */
const ConcernsScreen: React.FC<OnboardingNavigationProps> = ({
  navigation,
  route,
}) => {
  // Get data from previous screens
  const previousData = route?.params || {};

  // State for selected concerns (max 3)
  const [selectedConcerns, setSelectedConcerns] = useState<Concern[]>([]);

  // Maximum number of selections allowed
  const MAX_SELECTIONS = 3;

  /**
   * Concern options
   */
  const concernOptions: Array<{
    value: Concern;
    label: string;
    icon: string;
  }> = [
    { value: 'SLEEP', label: 'Sleep', icon: '😴' },
    { value: 'FEEDING', label: 'Feeding', icon: '🍼' },
    { value: 'DEVELOPMENT', label: 'Development', icon: '👶' },
    { value: 'HEALTH', label: 'Health', icon: '🏥' },
    { value: 'CRYING', label: 'Crying', icon: '😢' },
    { value: 'POSTPARTUM_RECOVERY', label: 'Postpartum recovery', icon: '💪' },
    { value: 'WORK_PARENTING_BALANCE', label: 'Work/parenting balance', icon: '⚖️' },
    { value: 'PARTNER_COORDINATION', label: 'Partner coordination', icon: '👫' },
  ];

  /**
   * Toggle selection of a concern
   * Limits to max 3 selections
   */
  const toggleConcern = (concern: Concern) => {
    if (selectedConcerns.includes(concern)) {
      // Remove if already selected
      setSelectedConcerns(selectedConcerns.filter(c => c !== concern));
    } else {
      // Add only if under max limit
      if (selectedConcerns.length < MAX_SELECTIONS) {
        setSelectedConcerns([...selectedConcerns, concern]);
      }
    }
  };

  /**
   * Navigate to next screen (Notification Preferences)
   * Passes all collected data forward
   */
  const handleNext = () => {
    if (selectedConcerns.length === 0) return;

    navigation.navigate('NotificationPreferences', {
      ...previousData,
      concerns: selectedConcerns,
    });
  };

  /**
   * Navigate back to previous screen
   */
  const handleBack = () => {
    navigation.goBack();
  };

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
          <Text style={styles.title}>What are your main concerns?</Text>
          <Text style={styles.subtitle}>
            Select up to 3 areas where you'd like the most guidance
          </Text>
        </View>

        {/* Selection Counter */}
        {selectedConcerns.length > 0 && (
          <View style={styles.counterSection}>
            <Text style={styles.counterText}>
              Selected: {selectedConcerns.length}/{MAX_SELECTIONS}
            </Text>
          </View>
        )}

        {/* Options Section */}
        <View style={styles.optionsSection}>
          {concernOptions.map((option) => {
            const isSelected = selectedConcerns.includes(option.value);
            const isDisabled = !isSelected && selectedConcerns.length >= MAX_SELECTIONS;

            return (
              <TouchableOpacity
                key={option.value}
                style={[
                  styles.optionCard,
                  isSelected && styles.optionCardSelected,
                  isDisabled && styles.optionCardDisabled,
                ]}
                onPress={() => toggleConcern(option.value)}
                disabled={isDisabled}
                activeOpacity={0.7}
              >
                <View style={styles.optionContent}>
                  <View style={[
                    styles.checkbox,
                    isDisabled && styles.checkboxDisabled,
                  ]}>
                    {isSelected && (
                      <Text style={styles.checkmark}>✓</Text>
                    )}
                  </View>
                  <Text style={styles.optionIcon}>{option.icon}</Text>
                  <Text style={[
                    styles.optionLabel,
                    isDisabled && styles.optionLabelDisabled,
                  ]}>
                    {option.label}
                  </Text>
                </View>
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Helper Text */}
        {selectedConcerns.length >= MAX_SELECTIONS && (
          <Text style={styles.helperText}>
            Maximum of 3 concerns selected. Deselect one to choose another.
          </Text>
        )}

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

          {/* Next Button */}
          <TouchableOpacity
            style={[
              styles.nextButton,
              selectedConcerns.length === 0 && styles.nextButtonDisabled,
            ]}
            onPress={handleNext}
            disabled={selectedConcerns.length === 0}
            activeOpacity={0.8}
          >
            <Text
              style={[
                styles.nextButtonText,
                selectedConcerns.length === 0 && styles.nextButtonTextDisabled,
              ]}
            >
              Next →
            </Text>
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
    marginBottom: 16,
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

  // Counter section
  counterSection: {
    backgroundColor: '#007AFF',
    borderRadius: 20,
    paddingVertical: 8,
    paddingHorizontal: 16,
    alignSelf: 'center',
    marginBottom: 16,
  },

  counterText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#fff',
  },

  // Options section
  optionsSection: {
    gap: 12,
    marginBottom: 16,
  },

  // Option card
  optionCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    borderWidth: 2,
    borderColor: '#e0e0e0',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },

  optionCardSelected: {
    borderColor: '#007AFF',
    backgroundColor: '#f0f8ff',
  },

  optionCardDisabled: {
    opacity: 0.5,
  },

  optionContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },

  // Checkbox
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 6,
    borderWidth: 2,
    borderColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
    backgroundColor: '#fff',
  },

  checkboxDisabled: {
    borderColor: '#ccc',
  },

  checkmark: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#007AFF',
  },

  // Option display
  optionIcon: {
    fontSize: 20,
    marginRight: 8,
  },

  optionLabel: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
    flex: 1,
  },

  optionLabelDisabled: {
    color: '#999',
  },

  // Helper text
  helperText: {
    fontSize: 14,
    color: '#ff9500',
    textAlign: 'center',
    marginBottom: 16,
    fontWeight: '500',
  },

  // Navigation section
  navigationSection: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 'auto',
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

  nextButtonDisabled: {
    backgroundColor: '#ccc',
  },

  nextButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },

  nextButtonTextDisabled: {
    color: '#999',
  },
});

export default ConcernsScreen;
