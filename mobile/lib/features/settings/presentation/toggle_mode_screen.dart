/// Screen for toggling from PREGNANCY mode to PARENTING mode.
/// Collects baby details and permanently switches user mode (one-way operation).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

/// Toggle Mode screen
/// Allows PREGNANCY mode users to switch to PARENTING mode after baby is born
class ToggleModeScreen extends ConsumerStatefulWidget {
  const ToggleModeScreen({super.key});

  @override
  ConsumerState<ToggleModeScreen> createState() => _ToggleModeScreenState();
}

class _ToggleModeScreenState extends ConsumerState<ToggleModeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _babyNameController = TextEditingController();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _selectedBirthDate;
  String? _selectedGender;

  @override
  void dispose() {
    _babyNameController.dispose();
    super.dispose();
  }

  /// Shows date picker for baby's birth date
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // Can't be in the future
      helpText: 'Select Baby\'s Birth Date',
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  /// Validates baby name
  String? _validateBabyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Baby name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates birth date
  String? _validateBirthDate() {
    if (_selectedBirthDate == null) {
      return 'Birth date is required';
    }
    if (_selectedBirthDate!.isAfter(DateTime.now())) {
      return 'Birth date cannot be in the future';
    }
    return null;
  }

  /// Validates gender selection
  String? _validateGender() {
    if (_selectedGender == null) {
      return 'Gender selection is required';
    }
    return null;
  }

  /// Handles mode toggle submission
  Future<void> _handleSubmit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate birth date and gender
    final birthDateError = _validateBirthDate();
    final genderError = _validateGender();

    if (birthDateError != null || genderError != null) {
      setState(() {
        _errorMessage = birthDateError ?? genderError;
      });
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch to Parenting Mode?'),
        content: const Text(
          'This will permanently switch your account from Pregnancy mode to Parenting mode. '
          'This action cannot be reversed.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Switch Mode'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call settings repository to toggle mode
      final repository = ref.read(settingsRepositoryProvider);
      final updatedProfile = await repository.toggleMode(
        babyName: _babyNameController.text.trim(),
        babyGender: _selectedGender!,
        babyBirthDate: _selectedBirthDate!,
      );

      // Refresh user data to get updated profile
      await ref.read(authProvider.notifier).refreshUser();

      if (mounted) {
        // Show success message with congratulations
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.celebration,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text('Congratulations!'),
              ],
            ),
            content: Text(
              'Welcome to Parenting mode! Your account has been updated and you can now '
              'track ${_babyNameController.text}\'s milestones and get personalized parenting advice.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Return to settings
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    // Only show this screen to PREGNANCY mode users
    if (currentUser?.mode != 'PREGNANCY') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Switch Mode'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Mode switching is only available\nfor Pregnancy mode users',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Format date for display
    String? dateText;
    if (_selectedBirthDate != null) {
      dateText =
          '${_selectedBirthDate!.month}/${_selectedBirthDate!.day}/${_selectedBirthDate!.year}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Your Baby'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Congratulatory header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.child_care,
                    size: 48,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Baby Has Arrived!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s switch your account to Parenting mode and '
                    'start tracking your baby\'s journey.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Info text
            Text(
              'Baby Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your baby\'s details to complete the switch.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 24),

            // Baby Name field
            TextFormField(
              controller: _babyNameController,
              decoration: const InputDecoration(
                labelText: 'Baby Name',
                hintText: 'Enter your baby\'s name',
                prefixIcon: Icon(Icons.child_care),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: _validateBabyName,
              enabled: !_isLoading,
            ),

            const SizedBox(height: 16),

            // Birth Date field
            InkWell(
              onTap: _isLoading ? null : _selectBirthDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Birth Date',
                  hintText: 'Select birth date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  errorText: _validateBirthDate(),
                ),
                child: Text(
                  dateText ?? 'Not set',
                  style: dateText != null
                      ? theme.textTheme.bodyLarge
                      : theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Gender selection
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'MALE', child: Text('Boy')),
                DropdownMenuItem(value: 'FEMALE', child: Text('Girl')),
                DropdownMenuItem(
                    value: 'OTHER', child: Text('Prefer not to say')),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedGender = value;
                        _errorMessage = null;
                      });
                    },
              validator: (_) => _validateGender(),
            ),

            const SizedBox(height: 24),

            // Warning message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Once you switch to Parenting mode, you cannot revert '
                      'back to Pregnancy mode.',
                      style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Submit button
            FilledButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Switch to Parenting Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
