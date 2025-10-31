/// Onboarding state provider for managing user input across onboarding flow.
/// Collects user data from multiple screens and submits to backend when complete.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding data model - stores all user inputs during onboarding
class OnboardingData {
  final String? mode; // PREGNANCY or PARENTING
  final String? dueDate; // For pregnancy mode
  final String? birthDate; // For parent mode
  final String? babyName;
  final String? babyGender;
  final String? parentingPhilosophy;
  final String? religiousBackground;
  final String? culturalBackground;
  final List<String>? concerns;
  final bool? notificationsEnabled;

  const OnboardingData({
    this.mode,
    this.dueDate,
    this.birthDate,
    this.babyName,
    this.babyGender,
    this.parentingPhilosophy,
    this.religiousBackground,
    this.culturalBackground,
    this.concerns,
    this.notificationsEnabled,
  });

  /// Copy method to update specific fields
  OnboardingData copyWith({
    String? mode,
    String? dueDate,
    String? birthDate,
    String? babyName,
    String? babyGender,
    String? parentingPhilosophy,
    String? religiousBackground,
    String? culturalBackground,
    List<String>? concerns,
    bool? notificationsEnabled,
  }) {
    return OnboardingData(
      mode: mode ?? this.mode,
      dueDate: dueDate ?? this.dueDate,
      birthDate: birthDate ?? this.birthDate,
      babyName: babyName ?? this.babyName,
      babyGender: babyGender ?? this.babyGender,
      parentingPhilosophy: parentingPhilosophy ?? this.parentingPhilosophy,
      religiousBackground: religiousBackground ?? this.religiousBackground,
      culturalBackground: culturalBackground ?? this.culturalBackground,
      concerns: concerns ?? this.concerns,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      if (mode != null) 'mode': mode,
      if (dueDate != null) 'dueDate': dueDate,
      if (birthDate != null) 'babyBirthDate': birthDate,
      if (babyName != null) 'babyName': babyName,
      if (babyGender != null) 'babyGender': babyGender,
      if (parentingPhilosophy != null) 'parentingPhilosophy': parentingPhilosophy,
      if (religiousBackground != null) 'religiousViews': religiousBackground,
      if (culturalBackground != null) 'culturalBackground': culturalBackground,
      if (concerns != null) 'primaryConcerns': concerns,
      if (notificationsEnabled != null) 'notificationsEnabled': notificationsEnabled,
    };
  }
}

/// State notifier for managing onboarding data
/// Allows screens to update individual fields as user progresses
class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(const OnboardingData());

  /// Update mode (PREGNANCY or PARENTING)
  void setMode(String mode) {
    state = state.copyWith(mode: mode);
  }

  /// Update due date (for pregnancy mode)
  void setDueDate(String dueDate) {
    state = state.copyWith(dueDate: dueDate);
  }

  /// Update birth date (for parent mode)
  void setBirthDate(String birthDate) {
    state = state.copyWith(birthDate: birthDate);
  }

  /// Update baby name
  void setBabyName(String name) {
    state = state.copyWith(babyName: name);
  }

  /// Update baby gender
  void setBabyGender(String gender) {
    state = state.copyWith(babyGender: gender);
  }

  /// Update parenting philosophy
  void setParentingPhilosophy(String philosophy) {
    state = state.copyWith(parentingPhilosophy: philosophy);
  }

  /// Update religious background
  void setReligiousBackground(String background) {
    state = state.copyWith(religiousBackground: background);
  }

  /// Update cultural background
  void setCulturalBackground(String background) {
    state = state.copyWith(culturalBackground: background);
  }

  /// Update concerns list
  void setConcerns(List<String> concerns) {
    state = state.copyWith(concerns: concerns);
  }

  /// Update notifications preference
  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  /// Reset onboarding data (used when starting over)
  void reset() {
    state = const OnboardingData();
  }
}

/// Provider for onboarding state
/// Watch this to access or update onboarding data across screens
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingData>((ref) {
  return OnboardingNotifier();
});
