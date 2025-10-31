/// Accessibility service for VoiceOver/TalkBack support, Dynamic Type, and motion preferences.
/// Helps ensure the app is accessible to users with disabilities.
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Service for managing accessibility features
/// Provides utilities for screen readers, text scaling, and motion preferences
class AccessibilityService {
  /// Checks if reduce motion is enabled in system settings
  /// Returns true if user prefers reduced animations
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Gets the current text scale factor from system settings
  /// Returns 1.0 for normal text, higher for larger text sizes
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Checks if bold text is enabled in system settings
  /// Returns true if user prefers bold text
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Gets accessible text style that respects system text scaling
  /// Automatically applies text scale factor from system settings
  static TextStyle getScaledTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final textScaleFactor = getTextScaleFactor(context);
    final boldText = isBoldTextEnabled(context);

    return baseStyle.copyWith(
      fontSize: baseStyle.fontSize != null
          ? baseStyle.fontSize! * textScaleFactor
          : null,
      fontWeight: boldText && baseStyle.fontWeight != null
          ? FontWeight.bold
          : baseStyle.fontWeight,
    );
  }

  /// Calculates luminance contrast ratio between two colors
  /// Returns a value between 1.0 (no contrast) and 21.0 (maximum contrast)
  /// WCAG AA requires 4.5:1 for normal text, 3:1 for large text
  /// WCAG AAA requires 7:1 for normal text, 4.5:1 for large text
  static double getContrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Checks if color combination meets WCAG AA standards
  /// Returns true if contrast ratio is at least 4.5:1 for normal text
  static bool meetsWCAGAA(Color foreground, Color background,
      {bool largeText = false}) {
    final ratio = getContrastRatio(foreground, background);
    return largeText ? ratio >= 3.0 : ratio >= 4.5;
  }

  /// Checks if color combination meets WCAG AAA standards
  /// Returns true if contrast ratio is at least 7:1 for normal text
  static bool meetsWCAGAAA(Color foreground, Color background,
      {bool largeText = false}) {
    final ratio = getContrastRatio(foreground, background);
    return largeText ? ratio >= 4.5 : ratio >= 7.0;
  }

  /// Creates semantic label for screen readers
  /// Combines multiple pieces of information into a readable label
  static String createSemanticLabel({
    required String primary,
    String? secondary,
    String? state,
    String? hint,
  }) {
    final parts = <String>[primary];

    if (secondary != null && secondary.isNotEmpty) {
      parts.add(secondary);
    }

    if (state != null && state.isNotEmpty) {
      parts.add(state);
    }

    if (hint != null && hint.isNotEmpty) {
      parts.add(hint);
    }

    return parts.join('. ');
  }

  /// Announces message to screen reader
  /// Use for important updates that need immediate attention
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Creates accessibility-friendly button label
  /// Example: "Send message button, double tap to activate"
  static String createButtonLabel(String label, {String? hint}) {
    final parts = [label, 'button'];
    if (hint != null) {
      parts.add(hint);
    } else {
      parts.add('double tap to activate');
    }
    return parts.join(', ');
  }

  /// Creates accessibility-friendly text field label
  /// Example: "Email address, text field, enter your email"
  static String createTextFieldLabel(String label, {String? hint}) {
    final parts = [label, 'text field'];
    if (hint != null) {
      parts.add(hint);
    }
    return parts.join(', ');
  }

  /// Creates accessibility-friendly toggle label
  /// Example: "Dark mode, switch, currently on"
  static String createToggleLabel(
    String label, {
    required bool isOn,
    String? hint,
  }) {
    final parts = [label, 'switch', 'currently ${isOn ? 'on' : 'off'}'];
    if (hint != null) {
      parts.add(hint);
    }
    return parts.join(', ');
  }

  /// Gets appropriate animation duration based on reduce motion setting
  /// Returns 0 duration if reduce motion is enabled, normal duration otherwise
  static Duration getAnimationDuration(
    BuildContext context,
    Duration normalDuration,
  ) {
    return isReduceMotionEnabled(context)
        ? Duration.zero
        : normalDuration;
  }

  /// Wraps widget with Semantics for better screen reader support
  /// Automatically configures common accessibility properties
  static Widget withSemantics({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool? isButton,
    bool? isTextField,
    bool? isToggle,
    bool? isEnabled,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton ?? false,
      textField: isTextField ?? false,
      toggled: isToggle,
      enabled: isEnabled ?? true,
      onTap: onTap,
      child: child,
    );
  }
}

/// Extension on BuildContext for easier accessibility access
extension AccessibilityExtension on BuildContext {
  /// Checks if reduce motion is enabled
  bool get reduceMotion => AccessibilityService.isReduceMotionEnabled(this);

  /// Gets text scale factor
  double get textScale => AccessibilityService.getTextScaleFactor(this);

  /// Checks if bold text is enabled
  bool get boldText => AccessibilityService.isBoldTextEnabled(this);

  /// Announces message to screen reader
  void announce(String message) {
    AccessibilityService.announce(this, message);
  }

  /// Gets animation duration respecting reduce motion
  Duration animationDuration(Duration normalDuration) {
    return AccessibilityService.getAnimationDuration(this, normalDuration);
  }
}
