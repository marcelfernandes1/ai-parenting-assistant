/// Register Screen
///
/// Allows new users to create an account with email and password.
/// Uses Riverpod AuthNotifier for registration logic.
/// Includes password strength indicator and validation.
///
/// Features:
/// - Email input with validation
/// - Password input with strength indicator
/// - Confirm password field with match validation
/// - Sign Up button with loading state
/// - Error message display
/// - Link to login screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../domain/auth_state.dart';

/// Password strength levels for validation feedback
enum PasswordStrength { weak, medium, strong }

/// RegisterScreen Component
///
/// Renders registration form with email, password, and confirm password inputs.
/// Includes password strength indicator and comprehensive validation.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Form controllers for user inputs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  // Local error state for validation messages
  String? _errorMessage;

  // Password strength tracking
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  @override
  void initState() {
    super.initState();
    // Listen to password changes to update strength indicator
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Calculate password strength based on criteria
  /// Updates whenever password changes
  void _updatePasswordStrength() {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() => _passwordStrength = PasswordStrength.weak);
      return;
    }

    // Criteria for password strength
    final hasMinLength = password.length >= 8;
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    // Calculate strength based on criteria met
    final criteriaMet = [
      hasMinLength,
      hasNumber,
      hasUpperCase,
      hasLowerCase,
      hasSpecialChar,
    ].where((met) => met).length;

    setState(() {
      if (criteriaMet >= 4) {
        _passwordStrength = PasswordStrength.strong;
      } else if (criteriaMet >= 2) {
        _passwordStrength = PasswordStrength.medium;
      } else {
        _passwordStrength = PasswordStrength.weak;
      }
    });
  }

  /// Get color for password strength indicator
  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  /// Get width percentage for strength indicator bar
  double _getStrengthWidth() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  /// Handle registration button press
  /// Validates inputs and calls register method from AuthNotifier
  Future<void> _handleRegister() async {
    // Clear previous errors
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final name = _nameController.text.trim();

    // Validate name field
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your name');
      return;
    }

    // Validate email field
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }

    // Basic email format validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    // Validate password field
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter a password');
      return;
    }

    // Validate password minimum length
    if (password.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters long');
      return;
    }

    // Validate password contains at least one number
    if (!RegExp(r'\d').hasMatch(password)) {
      setState(() => _errorMessage = 'Password must contain at least one number');
      return;
    }

    // Validate confirm password field
    if (confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Please confirm your password');
      return;
    }

    // Validate passwords match
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    // Attempt registration via AuthNotifier
    await ref.read(authProvider.notifier).register(email.toLowerCase(), password, name);

    // Check if registration was successful
    final authState = ref.read(authProvider);
    if (authState is AuthStateAuthenticated) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Welcome aboard.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // Router will automatically navigate to onboarding or home
    }
  }

  /// Navigate to login screen
  void _handleNavigateToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Watch authentication state for loading and error states
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthStateLoading;

    // Display error from auth state if present
    final authError = authState is AuthStateError
        ? (authState as AuthStateError).message
        : null;

    // Use local error if present, otherwise use auth error
    final displayError = _errorMessage ?? authError;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // App Logo/Title Section
              Icon(
                Icons.child_care,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              Text(
                'AI Parenting Assistant',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Create your account',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Error Message Display
              if (displayError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  child: Text(
                    displayError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Name Input Field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // Email Input Field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // Password Input Field with Strength Indicator
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password (min 8 chars, 1 number)',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enabled: !isLoading,
              ),

              // Password Strength Indicator
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _getStrengthWidth(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getStrengthColor(),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _passwordStrength.name.substring(0, 1).toUpperCase() +
                          _passwordStrength.name.substring(1),
                      style: TextStyle(
                        color: _getStrengthColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Confirm Password Input Field
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enabled: !isLoading,
                onSubmitted: (_) => _handleRegister(),
              ),
              const SizedBox(height: 24),

              // Sign Up Button
              ElevatedButton(
                onPressed: isLoading ? null : _handleRegister,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign Up'),
              ),
              const SizedBox(height: 16),

              // Password Requirements Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password must contain:',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• At least 8 characters',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '• At least 1 number',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Login Link Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: isLoading ? null : _handleNavigateToLogin,
                    child: const Text('Log In'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Terms and Disclaimer
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  'By signing up, you agree to our Terms of Service and Privacy Policy. '
                  'This app provides general parenting guidance and is not a substitute for professional medical advice.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
