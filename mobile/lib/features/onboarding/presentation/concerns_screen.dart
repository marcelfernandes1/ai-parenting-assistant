/// Concerns Screen - Collects primary parenting concerns
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_provider.dart';

class ConcernsScreen extends ConsumerStatefulWidget {
  const ConcernsScreen({super.key});

  @override
  ConsumerState<ConcernsScreen> createState() => _ConcernsScreenState();
}

class _ConcernsScreenState extends ConsumerState<ConcernsScreen> {
  final _selectedConcerns = <String>{};

  final _concerns = [
    'Sleep training',
    'Feeding & nutrition',
    'Development milestones',
    'Behavior & discipline',
    'Health & safety',
    'Bonding & attachment',
  ];

  void _handleNext() {
    if (_selectedConcerns.isNotEmpty) {
      ref.read(onboardingProvider.notifier).setConcerns(_selectedConcerns.toList());
    }
    context.go('/onboarding/notification-preferences');
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
              Text(
                'What are your main concerns?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select all that apply',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 32),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _concerns.map((concern) => FilterChip(
                  label: Text(concern),
                  selected: _selectedConcerns.contains(concern),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedConcerns.add(concern);
                      } else {
                        _selectedConcerns.remove(concern);
                      }
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 48),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/onboarding/cultural-background'),
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
