/**
 * Baby Info Screen (Onboarding Step 4)
 *
 * Only shown if user selected "Already a parent" in Step 2.
 * Collects optional information about the baby:
 * - Baby's name (optional)
 * - Baby's gender (optional)
 *
 * Features:
 * - All fields are optional
 * - Next button always enabled
 * - Can skip and add info later
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
import { OnboardingNavigationProps, BabyGender } from '../../types/onboarding';

/**
 * BabyInfoScreen Component
 *
 * Collects optional baby information (name and gender).
 * All fields can be skipped - user can add this information later.
 */
const BabyInfoScreen: React.FC<OnboardingNavigationProps> = ({
  navigation,
  route,
}) => {
  // Get data from previous screens
  const mode = route?.params?.mode;
  const babyBirthDate = route?.params?.babyBirthDate;

  // State for baby information
  const [babyName, setBabyName] = useState('');
  const [selectedGender, setSelectedGender] = useState<BabyGender | null>(null);

  /**
   * Handle gender selection
   */
  const handleSelectGender = (gender: BabyGender) => {
    setSelectedGender(gender);
  };

  /**
   * Navigate to next screen (Parenting Philosophy)
   * Passes all collected data forward
   */
  const handleNext = () => {
    navigation.navigate('ParentingPhilosophy', {
      mode,
      babyBirthDate,
      babyName: babyName.trim() || undefined,
      babyGender: selectedGender || undefined,
    });
  };

  /**
   * Navigate back to Timeline screen
   */
  const handleBack = () => {
    navigation.goBack();
  };

  // Gender options for display
  const genderOptions: Array<{ value: BabyGender; label: string; icon: string }> = [
    { value: 'MALE', label: 'Male', icon: '👦' },
    { value: 'FEMALE', label: 'Female', icon: '👧' },
    { value: 'PREFER_NOT_TO_SAY', label: 'Prefer not to say', icon: '👶' },
  ];

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
            <Text style={styles.progressText}>Step 4 of 7</Text>
            <View style={styles.progressBar}>
              <View style={[styles.progressFill, { width: '57.1%' }]} />
            </View>
          </View>

          {/* Title Section */}
          <View style={styles.titleSection}>
            <Text style={styles.title}>Tell us about your baby</Text>
            <Text style={styles.subtitle}>
              Optional - you can add this information later
            </Text>
          </View>

          {/* Baby Name Input */}
          <View style={styles.inputSection}>
            <Text style={styles.inputLabel}>Baby's Name (Optional)</Text>
            <TextInput
              style={styles.textInput}
              value={babyName}
              onChangeText={setBabyName}
              placeholder="You can add this later"
              placeholderTextColor="#999"
              autoCapitalize="words"
              autoCorrect={false}
              maxLength={50}
            />
          </View>

          {/* Gender Selection */}
          <View style={styles.genderSection}>
            <Text style={styles.sectionTitle}>Gender (Optional)</Text>
            <View style={styles.genderOptions}>
              {genderOptions.map((option) => (
                <TouchableOpacity
                  key={option.value}
                  style={[
                    styles.genderCard,
                    selectedGender === option.value && styles.genderCardSelected,
                  ]}
                  onPress={() => handleSelectGender(option.value)}
                  activeOpacity={0.7}
                >
                  <View style={styles.genderContent}>
                    <View style={styles.radioButton}>
                      {selectedGender === option.value && (
                        <View style={styles.radioButtonInner} />
                      )}
                    </View>
                    <Text style={styles.genderIcon}>{option.icon}</Text>
                    <Text style={styles.genderLabel}>{option.label}</Text>
                  </View>
                </TouchableOpacity>
              ))}
            </View>
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
    marginBottom: 32,
  },

  inputLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 12,
  },

  textInput: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    fontSize: 16,
    color: '#333',
    borderWidth: 2,
    borderColor: '#e0e0e0',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },

  // Gender section
  genderSection: {
    marginBottom: 'auto',
  },

  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 16,
  },

  genderOptions: {
    gap: 12,
  },

  // Gender card
  genderCard: {
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

  genderCardSelected: {
    borderColor: '#007AFF',
    backgroundColor: '#f0f8ff',
  },

  genderContent: {
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

  // Gender display
  genderIcon: {
    fontSize: 24,
    marginRight: 12,
  },

  genderLabel: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
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

  nextButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default BabyInfoScreen;
