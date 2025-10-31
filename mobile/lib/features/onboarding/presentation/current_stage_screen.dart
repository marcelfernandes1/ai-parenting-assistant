/// Current Stage Screen (Onboarding Step 2)
///
/// Asks user to select their current parenting stage:
/// - Pregnant
/// - Already a parent
///
/// This determines which questions to show in subsequent screens.
///
/// Features:
/// - Radio button selection with cards
/// - Next button (disabled until selection made)
/// - Back button to previous screen
/// - Progress indicator
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/onboarding_provider.dart';

/// CurrentStageScreen Component
///
/// Collects user's current parenting stage (pregnancy vs already a parent).
/// This information is used to customize the onboarding flow and advice.
class CurrentStageScreen extends ConsumerStatefulWidget {
  const CurrentStageScreen({super.key});

  @override
  ConsumerState<CurrentStageScreen> createState() => _CurrentStageScreenState();
}

class _CurrentStageScreenState extends ConsumerState<CurrentStageScreen> {
  // Selected stage state (local to this screen)
  String? _selectedStage;

  /// Handle stage selection
  void _handleSelectStage(String stage) {
    setState(() => _selectedStage = stage);
  }

  /// Navigate to next screen (Timeline Input)
  /// Saves selected stage to onboarding provider
  void _handleNext() {
    if (_selectedStage == null) return;

    // Save mode to onboarding provider
    ref.read(onboardingProvider.notifier).setMode(_selectedStage!);

    // Navigate to timeline input screen
    context.go('/onboarding/timeline-input');
  }

  /// Navigate back to Welcome screen
  void _handleBack() {
    context.go('/onboarding/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Indicator
              _buildProgressIndicator(context),
              const SizedBox(height: 32),

              // Title Section
              Text(
                'Where are you in your journey?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              Text(
                'This helps us personalize your experience',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 32),

              // Options Section
              _buildOptionCard(
                context,
                stage: 'PREGNANCY',
                icon: '🤰',
                title: 'I am currently pregnant',
                description: 'Get guidance throughout your pregnancy journey',
                isSelected: _selectedStage == 'PREGNANCY',
                onTap: () => _handleSelectStage('PREGNANCY'),
              ),
              const SizedBox(height: 16),

              _buildOptionCard(
                context,
                stage: 'PARENTING',
                icon: '👶',
                title: 'I am already a parent',
                description: 'Get help with your baby\'s development and care',
                isSelected: _selectedStage == 'PARENTING',
                onTap: () => _handleSelectStage('PARENTING'),
              ),
              const SizedBox(height: 48),

              // Navigation Buttons
              _buildNavigationButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build progress indicator showing step 2 of 7
  Widget _buildProgressIndicator(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2 of 7',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 2 / 7, // 28.5%
          backgroundColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.5),
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// Build option card with radio button
  Widget _buildOptionCard(
    BuildContext context, {
    required String stage,
    required String icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Option text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$icon $title',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build navigation buttons (back and next)
  Widget _buildNavigationButtons(BuildContext context) {
    final hasSelection = _selectedStage != null;

    return Row(
      children: [
        // Back button
        Expanded(
          child: OutlinedButton(
            onPressed: _handleBack,
            child: const Text('← Back'),
          ),
        ),
        const SizedBox(width: 12),

        // Next button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: hasSelection ? _handleNext : null,
            child: const Text('Next →'),
          ),
        ),
      ],
    );
  }
}
