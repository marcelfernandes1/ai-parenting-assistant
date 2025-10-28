/**
 * Timeline Input Screen (Onboarding Step 3)
 *
 * Collects date information based on user's stage:
 * - If pregnant: Ask for due date (future dates only)
 * - If already a parent: Ask for baby's birth date (past dates, max 24 months ago)
 *
 * Features:
 * - Conditional rendering based on mode from previous screen
 * - Date picker with appropriate constraints
 * - Validation for date selection
 * - Next button enabled only when valid date selected
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  Platform,
} from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { OnboardingNavigationProps, UserMode } from '../../types/onboarding';

/**
 * TimelineInputScreen Component
 *
 * Collects due date (if pregnant) or baby's birth date (if already a parent).
 * Validates dates to ensure they are within acceptable ranges.
 */
const TimelineInputScreen: React.FC<OnboardingNavigationProps> = ({
  navigation,
  route,
}) => {
  // Get mode from previous screen
  const mode: UserMode = route?.params?.mode || 'PREGNANCY';

  // State for selected date
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [showDatePicker, setShowDatePicker] = useState(false);

  // Calculate min/max dates based on mode
  const today = new Date();
  const maxPastDate = new Date();
  maxPastDate.setMonth(maxPastDate.getMonth() - 24); // 24 months ago

  /**
   * Handle date selection from picker
   */
  const handleDateChange = (event: any, date?: Date) => {
    // On Android, picker closes after selection
    if (Platform.OS === 'android') {
      setShowDatePicker(false);
    }

    // If user cancelled, don't update
    if (event.type === 'dismissed') {
      return;
    }

    // Validate and set the selected date
    if (date) {
      setSelectedDate(date);
    }
  };

  /**
   * Show date picker (iOS only, Android shows immediately)
   */
  const handleShowDatePicker = () => {
    setShowDatePicker(true);
  };

  /**
   * Format date for display
   */
  const formatDate = (date: Date): string => {
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  /**
   * Navigate to next screen
   * Passes date to next screen based on mode
   */
  const handleNext = () => {
    if (!selectedDate) return;

    // Determine next screen based on mode
    if (mode === 'PARENTING') {
      // If parent, go to Baby Info screen
      navigation.navigate('BabyInfo', {
        mode,
        babyBirthDate: selectedDate,
      });
    } else {
      // If pregnant, skip Baby Info and go to Parenting Philosophy
      navigation.navigate('ParentingPhilosophy', {
        mode,
        dueDate: selectedDate,
      });
    }
  };

  /**
   * Navigate back to Current Stage screen
   */
  const handleBack = () => {
    navigation.goBack();
  };

  // Determine title and description based on mode
  const title =
    mode === 'PREGNANCY'
      ? 'When is your due date?'
      : "When was your baby born?";
  const subtitle =
    mode === 'PREGNANCY'
      ? 'This helps us provide stage-appropriate guidance'
      : 'This helps us track your baby\'s development milestones';

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Progress Indicator */}
        <View style={styles.progressSection}>
          <Text style={styles.progressText}>Step 3 of 7</Text>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: '42.8%' }]} />
          </View>
        </View>

        {/* Title Section */}
        <View style={styles.titleSection}>
          <Text style={styles.title}>{title}</Text>
          <Text style={styles.subtitle}>{subtitle}</Text>
        </View>

        {/* Date Selection Section */}
        <View style={styles.dateSection}>
          {/* Date Display/Button */}
          <TouchableOpacity
            style={styles.dateButton}
            onPress={handleShowDatePicker}
            activeOpacity={0.7}
          >
            <View style={styles.dateButtonContent}>
              <Text style={styles.dateLabel}>
                {mode === 'PREGNANCY' ? 'Due Date' : 'Birth Date'}
              </Text>
              <Text style={styles.dateValue}>
                {selectedDate ? formatDate(selectedDate) : 'Select date'}
              </Text>
            </View>
            <Text style={styles.dateIcon}>📅</Text>
          </TouchableOpacity>

          {/* Date Picker */}
          {(showDatePicker || Platform.OS === 'ios') && (
            <View style={styles.pickerContainer}>
              <DateTimePicker
                value={selectedDate || today}
                mode="date"
                display={Platform.OS === 'ios' ? 'spinner' : 'default'}
                onChange={handleDateChange}
                maximumDate={mode === 'PREGNANCY' ? undefined : today}
                minimumDate={mode === 'PREGNANCY' ? today : maxPastDate}
                style={styles.datePicker}
              />
            </View>
          )}

          {/* Helper Text */}
          <Text style={styles.helperText}>
            {mode === 'PREGNANCY'
              ? 'Select a future date (or approximate date if unsure)'
              : 'For babies up to 24 months old'}
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

          {/* Next Button */}
          <TouchableOpacity
            style={[
              styles.nextButton,
              !selectedDate && styles.nextButtonDisabled,
            ]}
            onPress={handleNext}
            disabled={!selectedDate}
            activeOpacity={0.8}
          >
            <Text
              style={[
                styles.nextButtonText,
                !selectedDate && styles.nextButtonTextDisabled,
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

  // Date section
  dateSection: {
    marginBottom: 'auto',
  },

  dateButton: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
    borderWidth: 2,
    borderColor: '#007AFF',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },

  dateButtonContent: {
    flex: 1,
  },

  dateLabel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },

  dateValue: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
  },

  dateIcon: {
    fontSize: 24,
    marginLeft: 12,
  },

  // Date picker container
  pickerContainer: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },

  datePicker: {
    width: '100%',
  },

  // Helper text
  helperText: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
    fontStyle: 'italic',
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

export default TimelineInputScreen;
