/// Screen for changing user's email address.
/// Requires current password for verification.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/settings_repository.dart';
import '../providers/settings_provider.dart';

/// Change Email screen
/// Allows user to update their email address with password verification
class ChangeEmailScreen extends ConsumerStatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Basic email regex
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password is not empty
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required for verification';
    }
    return null;
  }

  /// Handles email change submission
  Future<void> _handleSubmit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call settings repository to change email
      final repository = ref.read(settingsRepositoryProvider);
      await repository.changeEmail(
        newEmail: _newEmailController.text.trim(),
        password: _passwordController.text,
      );

      // Update auth state with new email
      ref.read(authProvider.notifier).updateEmail(_newEmailController.text.trim());

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Email'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info text
            Text(
              'Enter your new email address and current password to verify the change.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 24),

            // New Email field
            TextFormField(
              controller: _newEmailController,
              decoration: const InputDecoration(
                labelText: 'New Email',
                hintText: 'Enter your new email address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              enabled: !_isLoading,
            ),

            const SizedBox(height: 16),

            // Current Password field
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                hintText: 'Enter your password to verify',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              enabled: !_isLoading,
              onFieldSubmitted: (_) => _handleSubmit(),
            ),

            const SizedBox(height: 24),

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

            // Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
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
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
