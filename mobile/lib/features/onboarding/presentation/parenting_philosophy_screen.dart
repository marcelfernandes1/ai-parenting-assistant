/// Parenting Philosophy Screen (Onboarding Step 5)
/// Collects user's parenting style preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_provider.dart';

class ParentingPhilosophyScreen extends ConsumerStatefulWidget {
  const ParentingPhilosophyScreen({super.key});

  @override
  ConsumerState<ParentingPhilosophyScreen> createState() => _ParentingPhilosophyScreenState();
}

class _ParentingPhilosophyScreenState extends ConsumerState<ParentingPhilosophyScreen> {
  String? _selected;

  final _options = [
    'Attachment parenting',
    'Positive discipline',
    'Traditional',
    'Gentle parenting',
    'No specific philosophy',
  ];

  void _handleNext() {
    if (_selected != null) {
      ref.read(onboardingProvider.notifier).setParentingPhilosophy(_selected!);
    }
    context.go('/onboarding/religious-background');
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
              Text('Step 5 of 7', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: 5 / 7),
              const SizedBox(height: 32),

              Text(
                'What\'s your parenting philosophy?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us give advice that aligns with your values',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 32),

              ..._options.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: _selected == option ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _selected == option
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      width: _selected == option ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selected,
                    onChanged: (value) => setState(() => _selected = value),
                  ),
                ),
              )),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/onboarding/baby-info'),
                      child: const Text('← Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      child: const Text('Next →'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
