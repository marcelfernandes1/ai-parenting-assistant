/**
 * Religious Background Screen (Onboarding Step 6 - Question 2)
 *
 * Asks user about their religious/spiritual background.
 * This helps personalize AI guidance to align with their values.
 *
 * Features:
 * - Multi-select checkboxes (can select multiple)
 * - Optional - can skip entirely
 * - Next button always enabled
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
import { OnboardingNavigationProps, ReligiousView } from '../../types/onboarding';

/**
 * ReligiousBackgroundScreen Component
 *
 * Collects user's religious/spiritual background (multi-select).
 * This information is used to provide culturally sensitive guidance.
 */
const ReligiousBackgroundScreen: React.FC<OnboardingNavigationProps> = ({
  navigation,
  route,
}) => {
  // Get data from previous screens
  const previousData = route?.params || {};

  // State for selected religious views (array for multi-select)
  const [selectedViews, setSelectedViews] = useState<ReligiousView[]>([]);

  /**
   * Religious view options
   */
  const religiousOptions: Array<{
    value: ReligiousView;
    label: string;
    icon: string;
  }> = [
    { value: 'CHRISTIAN', label: 'Christian', icon: '✝️' },
    { value: 'MUSLIM', label: 'Muslim', icon: '☪️' },
    { value: 'JEWISH', label: 'Jewish', icon: '✡️' },
    { value: 'HINDU', label: 'Hindu', icon: '🕉️' },
    { value: 'BUDDHIST', label: 'Buddhist', icon: '☸️' },
    { value: 'SECULAR', label: 'Secular', icon: '🌍' },
    { value: 'SPIRITUAL', label: 'Spiritual', icon: '✨' },
    { value: 'PREFER_NOT_TO_SAY', label: 'Prefer not to say', icon: '🤐' },
  ];

  /**
   * Toggle selection of a religious view
   * Allows multiple selections unless "Prefer not to say" is selected
   */
  const toggleView = (view: ReligiousView) => {
    // If "Prefer not to say" is clicked, clear all others and select only it
    if (view === 'PREFER_NOT_TO_SAY') {
      if (selectedViews.includes(view)) {
        // Deselect if already selected
        setSelectedViews([]);
      } else {
        // Select only "Prefer not to say"
        setSelectedViews([view]);
      }
      return;
    }

    // If any other option is clicked, remove "Prefer not to say" if present
    const filteredViews = selectedViews.filter(v => v !== 'PREFER_NOT_TO_SAY');

    // Toggle the clicked view
    if (filteredViews.includes(view)) {
      // Remove if already selected
      setSelectedViews(filteredViews.filter(v => v !== view));
    } else {
      // Add to selection
      setSelectedViews([...filteredViews, view]);
    }
  };

  /**
   * Navigate to next screen (Cultural Background)
   * Passes all collected data forward
   */
  const handleNext = () => {
    navigation.navigate('CulturalBackground', {
      ...previousData,
      religiousViews: selectedViews.length > 0 ? selectedViews : undefined,
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
          <Text style={styles.progressText}>Step 5 of 7</Text>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: '71.4%' }]} />
          </View>
        </View>

        {/* Title Section */}
        <View style={styles.titleSection}>
          <Text style={styles.title}>Religious or spiritual background</Text>
          <Text style={styles.subtitle}>
            Optional - Select all that apply. This helps us provide culturally sensitive guidance.
          </Text>
        </View>

        {/* Options Section */}
        <View style={styles.optionsSection}>
          {religiousOptions.map((option) => {
            const isSelected = selectedViews.includes(option.value);

            return (
              <TouchableOpacity
                key={option.value}
                style={[
                  styles.optionCard,
                  isSelected && styles.optionCardSelected,
                ]}
                onPress={() => toggleView(option.value)}
                activeOpacity={0.7}
              >
                <View style={styles.optionContent}>
                  <View style={styles.checkbox}>
                    {isSelected && (
                      <Text style={styles.checkmark}>✓</Text>
                    )}
                  </View>
                  <Text style={styles.optionIcon}>{option.icon}</Text>
                  <Text style={styles.optionLabel}>{option.label}</Text>
                </View>
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Helper Text */}
        {selectedViews.length > 0 && !selectedViews.includes('PREFER_NOT_TO_SAY') && (
          <Text style={styles.helperText}>
            {selectedViews.length} {selectedViews.length === 1 ? 'option' : 'options'} selected
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

  // Helper text
  helperText: {
    fontSize: 14,
    color: '#007AFF',
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

  nextButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default ReligiousBackgroundScreen;
