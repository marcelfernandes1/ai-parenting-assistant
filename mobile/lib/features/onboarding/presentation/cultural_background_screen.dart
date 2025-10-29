/// Cultural Background Screen (Onboarding Step 7)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_provider.dart';

class CulturalBackgroundScreen extends ConsumerStatefulWidget {
  const CulturalBackgroundScreen({super.key});

  @override
  ConsumerState<CulturalBackgroundScreen> createState() => _CulturalBackgroundScreenState();
}

class _CulturalBackgroundScreenState extends ConsumerState<CulturalBackgroundScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_controller.text.trim().isNotEmpty) {
      ref.read(onboardingProvider.notifier).setCulturalBackground(_controller.text.trim());
    }
    context.go('/onboarding/concerns');
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
              Text('Step 7 of 7', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: 7 / 7),
              const SizedBox(height: 32),

              Text(
                'Cultural background',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Optional - any cultural traditions we should know about?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Cultural background',
                  hintText: 'e.g., South Asian, Latin American, etc.',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 48),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/onboarding/religious-background'),
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
