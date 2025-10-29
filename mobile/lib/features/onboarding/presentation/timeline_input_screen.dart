/// Timeline Input Screen (Onboarding Step 3)
/// Collects due date (pregnancy) or birth date (parent)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_provider.dart';

class TimelineInputScreen extends ConsumerStatefulWidget {
  const TimelineInputScreen({super.key});

  @override
  ConsumerState<TimelineInputScreen> createState() => _TimelineInputScreenState();
}

class _TimelineInputScreenState extends ConsumerState<TimelineInputScreen> {
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _handleNext() {
    if (_selectedDate == null) return;

    final mode = ref.read(onboardingProvider).mode;
    final dateString = _selectedDate!.toIso8601String().split('T')[0];

    if (mode == 'PREGNANCY') {
      ref.read(onboardingProvider.notifier).setDueDate(dateString);
    } else {
      ref.read(onboardingProvider.notifier).setBirthDate(dateString);
    }

    context.go('/onboarding/baby-info');
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(onboardingProvider).mode;
    final isPregnancy = mode == 'PREGNANCY';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Step 3 of 7', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: 3 / 7),
              const SizedBox(height: 32),

              Text(
                isPregnancy ? 'When is your due date?' : 'When was your baby born?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(_selectedDate == null
                      ? 'Select date'
                      : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectDate,
                ),
              ),
              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/onboarding/current-stage'),
                      child: const Text('← Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selectedDate != null ? _handleNext : null,
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
