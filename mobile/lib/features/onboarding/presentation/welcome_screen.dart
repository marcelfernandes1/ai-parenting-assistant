/// Welcome Screen (Onboarding Step 1)
///
/// First screen of the onboarding flow.
/// Displays app logo, tagline, intro text, and medical disclaimer.
/// Allows user to start onboarding or skip to main app.
///
/// Features:
/// - App branding and value proposition
/// - Medical disclaimer
/// - "Get Started" button to begin onboarding
/// - "Skip" option to go directly to app
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// WelcomeScreen Component
///
/// Entry point for the onboarding flow.
/// Introduces the app and its benefits to new users.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Navigate to next onboarding screen (Current Stage)
  void _handleGetStarted(BuildContext context) {
    context.go('/onboarding/current-stage');
  }

  /// Skip onboarding and go to main app
  /// User can complete onboarding later from settings
  void _handleSkip(BuildContext context) {
    // For now, just show a snackbar
    // In production, this would mark onboarding as skipped and navigate to home
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Onboarding skipped - you can complete it later from settings'),
      ),
    );
    context.go('/home');
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
              const SizedBox(height: 40),

              // Logo/Icon Section
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '👶',
                      style: TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title Section
              Text(
                'Baby Boomer',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Your personalized guide through pregnancy and parenting',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Intro Section
              Text(
                'Get expert guidance tailored to your unique parenting journey:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),

              // Feature List
              _buildFeatureItem(
                context,
                '24/7 AI-powered answers to your parenting questions',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                'Personalized advice based on your baby\'s age and needs',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                'Track milestones and developmental progress',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                'Respectful of your parenting philosophy and values',
              ),
              const SizedBox(height: 32),

              // Medical Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFD699),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important Notice',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: const Color(0xFFCC6600),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This app provides general parenting information and is not a substitute '
                      'for professional medical advice, diagnosis, or treatment. Always seek '
                      'the advice of your pediatrician or other qualified health provider '
                      'with any questions about your baby\'s health.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF996600),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Get Started Button
              ElevatedButton(
                onPressed: () => _handleGetStarted(context),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 12),

              // Skip Button
              TextButton(
                onPressed: () => _handleSkip(context),
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a feature list item with checkmark bullet
  Widget _buildFeatureItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✓',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.8),
                ),
          ),
        ),
      ],
    );
  }
}
