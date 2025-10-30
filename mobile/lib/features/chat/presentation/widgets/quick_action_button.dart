import 'package:flutter/material.dart';

/// Quick action button for pre-filled chat messages.
/// Displays an icon and label, and triggers a callback when tapped.
///
/// Used in the chat screen to provide contextual quick responses
/// based on user's parenting stage and baby age.
class QuickActionButton extends StatelessWidget {
  /// The icon to display on the button
  final IconData icon;

  /// The label text for the button
  final String label;

  /// Callback function when button is tapped
  final VoidCallback onTap;

  /// Optional background color (defaults to theme primary container)
  final Color? backgroundColor;

  /// Optional icon color (defaults to theme primary)
  final Color? iconColor;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor ?? theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                icon,
                size: 20,
                color: iconColor ?? theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              // Label
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick action configuration model
/// Defines the properties for each quick action button
class QuickAction {
  /// Icon to display
  final IconData icon;

  /// Button label
  final String label;

  /// Message to send when button is tapped
  final String message;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.message,
  });
}
