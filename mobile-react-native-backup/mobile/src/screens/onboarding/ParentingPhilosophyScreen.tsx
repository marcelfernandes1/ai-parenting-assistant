/**
 * Parenting Philosophy Screen (Onboarding Step 5)
 *
 * Asks user about their parenting philosophy approach.
 * This helps personalize AI responses to align with their parenting style.
 *
 * Features:
 * - Single-select radio buttons
 * - Multiple philosophy options
 * - Next button enabled after selection
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
import { OnboardingNavigationProps, ParentingPhilosophy } from '../../types/onboarding';

/**
 * ParentingPhilosophyScreen Component
 *
 * Collects user's parenting philosophy preference.
 * This information is used to customize AI guidance to match their parenting style.
 */
const ParentingPhilosophyScreen: React.FC<OnboardingNavigationProps> = ({
  navigation,
  route,
}) => {
  // Get data from previous screens
  const previousData = route?.params || {};

  // State for selected philosophy
  const [selectedPhilosophy, setSelectedPhilosophy] = useState<ParentingPhilosophy | null>(null);

  /**
   * Philosophy options with descriptions
   */
  const philosophyOptions: Array<{
    value: ParentingPhilosophy;
    label: string;
    description: string;
    icon: string;
  }> = [
    {
      value: 'GENTLE_ATTACHMENT',
      label: 'Gentle/Attachment',
      description: 'Baby-led, responsive to needs, co-sleeping, extended breastfeeding',
      icon: '🤱',
    },
    {
      value: 'STRUCTURED_SCHEDULED',
      label: 'Structured/Scheduled',
      description: 'Routine-based, sleep training, scheduled feeds and activities',
      icon: '📋',
    },
    {
      value: 'BALANCED_FLEXIBLE',
      label: 'Balanced/Flexible',
      description: 'Mix of approaches, adapting to what works for your family',
      icon: '⚖️',
    },
    {
      value: 'FIGURING_IT_OUT',
      label: 'Still figuring it out',
      description: 'Exploring different approaches and finding what works',
      icon: '🤔',
    },
    {
      value: 'PREFER_NOT_TO_SAY',
      label: 'Prefer not to say',
      description: 'Skip this question',
      icon: '🤐',
    },
  ];

  /**
   * Handle philosophy selection
   */
  const handleSelectPhilosophy = (philosophy: ParentingPhilosophy) => {
    setSelectedPhilosophy(philosophy);
  };

  /**
   * Navigate to next screen (Religious Background)
   * Passes all collected data forward
   */
  const handleNext = () => {
    if (!selectedPhilosophy) return;

    navigation.navigate('ReligiousBackground', {
      ...previousData,
      parentingPhilosophy: selectedPhilosophy,
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
          <Text style={styles.title}>What's your parenting philosophy?</Text>
          <Text style={styles.subtitle}>
            This helps us provide guidance that aligns with your approach
          </Text>
        </View>

        {/* Philosophy Options */}
        <View style={styles.optionsSection}>
          {philosophyOptions.map((option) => (
            <TouchableOpacity
              key={option.value}
              style={[
                styles.optionCard,
                selectedPhilosophy === option.value && styles.optionCardSelected,
              ]}
              onPress={() => handleSelectPhilosophy(option.value)}
              activeOpacity={0.7}
            >
              <View style={styles.optionContent}>
                <View style={styles.optionHeader}>
                  <View style={styles.radioButton}>
                    {selectedPhilosophy === option.value && (
                      <View style={styles.radioButtonInner} />
                    )}
                  </View>
                  <Text style={styles.optionIcon}>{option.icon}</Text>
                  <Text style={styles.optionLabel}>{option.label}</Text>
                </View>
                <Text style={styles.optionDescription}>{option.description}</Text>
              </View>
            </TouchableOpacity>
          ))}
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

          {/* Next Button */}
          <TouchableOpacity
            style={[
              styles.nextButton,
              !selectedPhilosophy && styles.nextButtonDisabled,
            ]}
            onPress={handleNext}
            disabled={!selectedPhilosophy}
            activeOpacity={0.8}
          >
            <Text
              style={[
                styles.nextButtonText,
                !selectedPhilosophy && styles.nextButtonTextDisabled,
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
    marginBottom: 24,
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
    gap: 8,
  },

  optionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },

  // Radio button
  radioButton: {
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 2,
    borderColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },

  radioButtonInner: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: '#007AFF',
  },

  // Option text
  optionIcon: {
    fontSize: 20,
    marginRight: 8,
  },

  optionLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    flex: 1,
  },

  optionDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
    marginLeft: 32,
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

export default ParentingPhilosophyScreen;
