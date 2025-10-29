/// Usage Limits Explanation Screen - Final onboarding screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/domain/auth_state.dart';
import '../providers/onboarding_provider.dart';

class UsageLimitsExplanationScreen extends ConsumerWidget {
  const UsageLimitsExplanationScreen({super.key});

  Future<void> _handleComplete(BuildContext context, WidgetRef ref) async {
    // Get all onboarding data
    final onboardingData = ref.read(onboardingProvider);

    // Submit to backend via auth provider
    try {
      await ref.read(authProvider.notifier).completeOnboarding(onboardingData.toJson());

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome! Your profile is set up.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home (router will handle automatically)
        context.go('/home');
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing onboarding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthStateLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.info_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              Text(
                'About our free plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                'Start with our free plan:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              _buildFeatureItem(context, '10 chat messages per day'),
              _buildFeatureItem(context, '10 minutes of voice chat per day'),
              _buildFeatureItem(context, '100 photo uploads'),
              _buildFeatureItem(context, 'All milestone tracking features'),
              const SizedBox(height: 24),

              Card(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '✨ Upgrade to Premium',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get unlimited messages, voice chat, and photos',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: isLoading ? null : () => _handleComplete(context, ref),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Complete Setup'),
              ),
              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: isLoading ? null : () => context.go('/onboarding/notification-preferences'),
                child: const Text('← Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.tertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
