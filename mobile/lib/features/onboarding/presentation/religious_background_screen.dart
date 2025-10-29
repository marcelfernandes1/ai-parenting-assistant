/// Religious Background Screen (Onboarding Step 6)
/// Collects user's religious preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_provider.dart';

class ReligiousBackgroundScreen extends ConsumerStatefulWidget {
  const ReligiousBackgroundScreen({super.key});

  @override
  ConsumerState<ReligiousBackgroundScreen> createState() => _ReligiousBackgroundScreenState();
}

class _ReligiousBackgroundScreenState extends ConsumerState<ReligiousBackgroundScreen> {
  String? _selected;

  final _options = [
    'Christian',
    'Muslim',
    'Jewish',
    'Hindu',
    'Buddhist',
    'Non-religious',
    'Prefer not to say',
  ];

  void _handleNext() {
    if (_selected != null) {
      ref.read(onboardingProvider.notifier).setReligiousBackground(_selected!);
    }
    context.go('/onboarding/cultural-background');
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
              Text('Step 6 of 7', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: 6 / 7),
              const SizedBox(height: 32),

              Text(
                'Religious background',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Optional - helps us respect your values and traditions',
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
                      onPressed: () => context.go('/onboarding/parenting-philosophy'),
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
