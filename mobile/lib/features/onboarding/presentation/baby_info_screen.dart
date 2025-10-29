/// Baby Info Screen (Onboarding Step 4)
/// Collects baby name and gender
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_provider.dart';

class BabyInfoScreen extends ConsumerStatefulWidget {
  const BabyInfoScreen({super.key});

  @override
  ConsumerState<BabyInfoScreen> createState() => _BabyInfoScreenState();
}

class _BabyInfoScreenState extends ConsumerState<BabyInfoScreen> {
  final _nameController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleNext() {
    ref.read(onboardingProvider.notifier).setBabyName(_nameController.text.trim());
    if (_selectedGender != null) {
      ref.read(onboardingProvider.notifier).setBabyGender(_selectedGender!);
    }
    context.go('/onboarding/parenting-philosophy');
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
              Text('Step 4 of 7', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: 4 / 7),
              const SizedBox(height: 32),

              Text(
                'Tell us about your baby',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Baby\'s name (optional)',
                  hintText: 'Enter baby\'s name',
                ),
              ),
              const SizedBox(height: 24),

              Text('Gender (optional)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                children: [
                  ChoiceChip(
                    label: const Text('Boy'),
                    selected: _selectedGender == 'MALE',
                    onSelected: (selected) => setState(() => _selectedGender = selected ? 'MALE' : null),
                  ),
                  ChoiceChip(
                    label: const Text('Girl'),
                    selected: _selectedGender == 'FEMALE',
                    onSelected: (selected) => setState(() => _selectedGender = selected ? 'FEMALE' : null),
                  ),
                  ChoiceChip(
                    label: const Text('Prefer not to say'),
                    selected: _selectedGender == 'OTHER',
                    onSelected: (selected) => setState(() => _selectedGender = selected ? 'OTHER' : null),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/onboarding/timeline-input'),
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
