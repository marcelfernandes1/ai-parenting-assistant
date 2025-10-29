/**
 * Cultural Background Screen (Onboarding Step 7 - Question 3)
 *
 * Asks user about their cultural background (free text).
 * This helps personalize AI guidance to be culturally appropriate.
 *
 * Features:
 * - Optional multiline text input
 * - 200 character limit
 * - Next button always enabled (field is optional)
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { OnboardingNavigationProps } from '../../types/onboarding';

/**
 * CulturalBackgroundScreen Component
 *
 * Collects user's cultural background via free-form text input.
 * This information helps provide culturally appropriate guidance.
 */
const CulturalBackgroundScreen: React.FC<OnboardingNavigationProps> = ({
  navigation,
  route,
}) => {
  // Get data from previous screens
  const previousData = route?.params || {};

  // State for cultural background text
  const [culturalBackground, setCulturalBackground] = useState('');

  // Character limit
  const MAX_CHARACTERS = 200;
  const remainingCharacters = MAX_CHARACTERS - culturalBackground.length;

  /**
   * Navigate to next screen (Concerns)
   * Passes all collected data forward
   */
  const handleNext = () => {
    navigation.navigate('Concerns', {
      ...previousData,
      culturalBackground: culturalBackground.trim() || undefined,
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
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardAvoid}
      >
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
          keyboardShouldPersistTaps="handled"
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
            <Text style={styles.title}>Your cultural background</Text>
            <Text style={styles.subtitle}>
              Optional - This helps us provide culturally appropriate guidance
            </Text>
          </View>

          {/* Text Input Section */}
          <View style={styles.inputSection}>
            <TextInput
              style={styles.textInput}
              value={culturalBackground}
              onChangeText={setCulturalBackground}
              placeholder="e.g., Latin American, South Asian, etc."
              placeholderTextColor="#999"
              multiline
              maxLength={MAX_CHARACTERS}
              textAlignVertical="top"
              autoCapitalize="sentences"
            />

            {/* Character Counter */}
            <Text style={styles.characterCounter}>
              {remainingCharacters} characters remaining
            </Text>
          </View>

          {/* Helper Section */}
          <View style={styles.helperSection}>
            <Text style={styles.helperTitle}>Why we ask:</Text>
            <Text style={styles.helperText}>
              Understanding your cultural background helps us provide advice that respects your traditions,
              values, and practices. This is completely optional and you can update it anytime.
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
      </KeyboardAvoidingView>
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

  // Keyboard avoiding view
  keyboardAvoid: {
    flex: 1,
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

  // Input section
  inputSection: {
    marginBottom: 24,
  },

  textInput: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    fontSize: 16,
    color: '#333',
    borderWidth: 2,
    borderColor: '#e0e0e0',
    height: 120,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },

  characterCounter: {
    fontSize: 12,
    color: '#999',
    textAlign: 'right',
    marginTop: 8,
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

export default CulturalBackgroundScreen;
