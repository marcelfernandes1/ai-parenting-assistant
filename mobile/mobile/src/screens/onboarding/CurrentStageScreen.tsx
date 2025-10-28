/**
 * Current Stage Screen (Onboarding Step 2)
 *
 * Asks user to select their current parenting stage:
 * - Pregnant
 * - Already a parent
 *
 * This determines which questions to show in subsequent screens.
 *
 * Features:
 * - Radio button selection
 * - Next button (disabled until selection made)
 * - Back button to previous screen
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
import { OnboardingNavigationProps, UserMode } from '../../types/onboarding';

/**
 * CurrentStageScreen Component
 *
 * Collects user's current parenting stage (pregnancy vs already a parent).
 * This information is used to customize the onboarding flow.
 */
const CurrentStageScreen: React.FC<OnboardingNavigationProps> = ({ navigation }) => {
  // Selected stage state
  const [selectedStage, setSelectedStage] = useState<UserMode | null>(null);

  /**
   * Handle stage selection
   */
  const handleSelectStage = (stage: UserMode) => {
    setSelectedStage(stage);
  };

  /**
   * Navigate to next screen (Timeline Input)
   * Passes selected stage to next screen
   */
  const handleNext = () => {
    if (!selectedStage) return;

    // Navigate to Timeline screen with selected stage
    navigation.navigate('Timeline', { mode: selectedStage });
  };

  /**
   * Navigate back to Welcome screen
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
          <Text style={styles.progressText}>Step 2 of 7</Text>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: '28.5%' }]} />
          </View>
        </View>

        {/* Title Section */}
        <View style={styles.titleSection}>
          <Text style={styles.title}>Where are you in your journey?</Text>
          <Text style={styles.subtitle}>
            This helps us personalize your experience
          </Text>
        </View>

        {/* Options Section */}
        <View style={styles.optionsSection}>
          {/* Option: Pregnancy */}
          <TouchableOpacity
            style={[
              styles.optionCard,
              selectedStage === 'PREGNANCY' && styles.optionCardSelected,
            ]}
            onPress={() => handleSelectStage('PREGNANCY')}
            activeOpacity={0.7}
          >
            <View style={styles.optionContent}>
              <View style={styles.radioButton}>
                {selectedStage === 'PREGNANCY' && (
                  <View style={styles.radioButtonInner} />
                )}
              </View>
              <View style={styles.optionTextContainer}>
                <Text style={styles.optionTitle}>🤰 I am currently pregnant</Text>
                <Text style={styles.optionDescription}>
                  Get guidance throughout your pregnancy journey
                </Text>
              </View>
            </View>
          </TouchableOpacity>

          {/* Option: Already a Parent */}
          <TouchableOpacity
            style={[
              styles.optionCard,
              selectedStage === 'PARENTING' && styles.optionCardSelected,
            ]}
            onPress={() => handleSelectStage('PARENTING')}
            activeOpacity={0.7}
          >
            <View style={styles.optionContent}>
              <View style={styles.radioButton}>
                {selectedStage === 'PARENTING' && (
                  <View style={styles.radioButtonInner} />
                )}
              </View>
              <View style={styles.optionTextContainer}>
                <Text style={styles.optionTitle}>👶 I am already a parent</Text>
                <Text style={styles.optionDescription}>
                  Get help with your baby's development and care
                </Text>
              </View>
            </View>
          </TouchableOpacity>
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
              !selectedStage && styles.nextButtonDisabled,
            ]}
            onPress={handleNext}
            disabled={!selectedStage}
            activeOpacity={0.8}
          >
            <Text
              style={[
                styles.nextButtonText,
                !selectedStage && styles.nextButtonTextDisabled,
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
    marginBottom: 32,
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
    marginBottom: 'auto',
  },

  // Option card
  optionCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
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
    alignItems: 'flex-start',
  },

  // Radio button
  radioButton: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
    marginTop: 2,
  },

  radioButtonInner: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: '#007AFF',
  },

  // Option text
  optionTextContainer: {
    flex: 1,
  },

  optionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },

  optionDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },

  // Navigation section
  navigationSection: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 32,
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

export default CurrentStageScreen;
