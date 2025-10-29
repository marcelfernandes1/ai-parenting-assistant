/// Login Screen
///
/// Allows existing users to log in with email and password.
/// Uses Riverpod AuthNotifier for authentication logic.
/// Automatically navigates to home/onboarding on successful login via router.
///
/// Features:
/// - Email input with email keyboard type
/// - Password input with secure entry
/// - Login button with loading state
/// - Error message display
/// - Link to registration screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../domain/auth_state.dart';

/// LoginScreen Component
///
/// Renders login form with email and password inputs.
/// Handles form validation and submission using Riverpod state management.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Form controllers for email and password inputs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Local error state for validation messages
  String? _errorMessage;

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login button press
  /// Validates inputs and calls login method from AuthNotifier
  Future<void> _handleLogin() async {
    // Clear previous errors
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate email field
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }

    // Validate password field
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }

    // Basic email format validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    // Attempt login via AuthNotifier
    await ref.read(authProvider.notifier).login(email.toLowerCase(), password);

    // Check if login was successful or failed
    // AuthNotifier will update state, and router will handle navigation
    // If there's an error, it will be displayed via the auth state
  }

  /// Navigate to registration screen
  void _handleNavigateToRegister() {
    context.go('/register');
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

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
                'Welcome back!',
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

              // Password Input Field
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enabled: !isLoading,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Log In'),
              ),
              const SizedBox(height: 12),

              // Forgot Password Link (Future Feature)
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password reset feature coming soon',
                            ),
                          ),
                        );
                      },
                child: const Text('Forgot password?'),
              ),
              const SizedBox(height: 32),

              // Sign Up Link Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: isLoading ? null : _handleNavigateToRegister,
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Medical Disclaimer
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
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
