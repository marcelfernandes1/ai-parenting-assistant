/// Settings screen for app configuration and account management.
/// Provides access to subscription management, account settings, and app preferences.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../subscription/presentation/subscription_management_screen.dart';
import '../providers/settings_provider.dart';
import 'change_email_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'toggle_mode_screen.dart';

/// Main Settings screen
/// Displays list of settings options and account information
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    // Get user email from auth state
    final userEmail = authState.when(
      authenticated: (user) => user.email,
      unauthenticated: () => null,
      initial: () => null,
      loading: () => null,
      error: (message) => null,  // Return null on error state
    );

    // Get user mode from auth state
    final userMode = authState.when(
      authenticated: (user) => user.mode,
      unauthenticated: () => null,
      initial: () => null,
      loading: () => null,
      error: (message) => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account section
          _buildSectionHeader(context, 'Account'),
          _buildAccountTile(context, theme, userEmail),
          _buildListTile(
            context,
            Icons.email_outlined,
            'Change Email',
            'Update your email address',
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChangeEmailScreen(),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            Icons.lock_outline,
            'Change Password',
            'Update your password',
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),

          // Mode toggle (only for PREGNANCY mode users)
          if (userMode == 'PREGNANCY')
            _buildListTile(
              context,
              Icons.child_care,
              'Baby Has Arrived',
              'Switch to Parenting mode',
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ToggleModeScreen(),
                  ),
                );
              },
            ),

          const Divider(height: 32),

          // Subscription section
          _buildSectionHeader(context, 'Subscription'),
          _buildSubscriptionTile(context),

          const Divider(height: 32),

          // Privacy & Data section
          _buildSectionHeader(context, 'Privacy & Data'),
          _buildListTile(
            context,
            Icons.download_outlined,
            'Export My Data',
            'Download all your data (GDPR)',
            () {
              _handleExportData(context, ref);
            },
          ),
          _buildListTile(
            context,
            Icons.delete_forever_outlined,
            'Delete Account',
            'Permanently delete your account',
            () {
              _handleDeleteAccount(context, ref);
            },
          ),

          const Divider(height: 32),

          // App section
          _buildSectionHeader(context, 'App'),
          _buildListTile(
            context,
            Icons.notifications_outlined,
            'Notifications',
            'Manage notification preferences',
            () {
              // TODO: Navigate to notifications settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings coming soon'),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            Icons.language_outlined,
            'Language',
            'English',
            () {
              // TODO: Navigate to language settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Language settings coming soon'),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            Icons.palette_outlined,
            'Theme',
            'System default',
            () {
              // TODO: Navigate to theme settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme settings coming soon'),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Support section
          _buildSectionHeader(context, 'Support'),
          _buildListTile(
            context,
            Icons.help_outline,
            'Help & FAQ',
            'Get help and find answers',
            () {
              // TODO: Navigate to help
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help center coming soon'),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            Icons.bug_report_outlined,
            'Report a Problem',
            'Send feedback or report issues',
            () {
              // TODO: Navigate to feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback form coming soon'),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'View our privacy policy',
            () {
              // TODO: Open privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy policy coming soon'),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            Icons.description_outlined,
            'Terms of Service',
            'View terms of service',
            () {
              // TODO: Open terms of service
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms of service coming soon'),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          // App version
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section header
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds the account tile showing user email
  Widget _buildAccountTile(
    BuildContext context,
    ThemeData theme,
    String? email,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.person,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: const Text('Account'),
      subtitle: Text(email ?? 'Not signed in'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to Edit Profile screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const EditProfileScreen(),
          ),
        );
      },
    );
  }

  /// Builds the subscription management tile
  Widget _buildSubscriptionTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.card_membership),
      title: const Text('Subscription'),
      subtitle: const Text('Manage your subscription plan'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to subscription management screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SubscriptionManagementScreen(),
          ),
        );
      },
    );
  }

  /// Builds a generic list tile
  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Handles user logout
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Perform logout
      await ref.read(authProvider.notifier).logout();

      // Navigation is handled automatically by router
    }
  }

  /// Handles data export
  Future<void> _handleExportData(BuildContext context, WidgetRef ref) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Call settings repository to export data
      final repository = ref.read(settingsRepositoryProvider);
      final data = await repository.exportUserData();

      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show success dialog with data preview
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Data Export Ready'),
            content: SingleChildScrollView(
              child: Text(
                'Your data has been exported successfully.\n\n'
                'Data includes:\n'
                '• User profile\n'
                '• ${data['messages']?.length ?? 0} messages\n'
                '• ${data['milestones']?.length ?? 0} milestones\n'
                '• ${data['photos']?.length ?? 0} photos\n\n'
                'In a production app, this would trigger a download or email.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handles account deletion
  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    // Show strong warning dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            const Text('Delete Account?'),
          ],
        ),
        content: const Text(
          'This action is PERMANENT and IRREVERSIBLE.\n\n'
          'All your data will be deleted:\n'
          '• All chat messages\n'
          '• All photos\n'
          '• All milestones\n'
          '• Your profile\n\n'
          'Are you absolutely sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete My Account'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show password confirmation dialog
    final passwordController = TextEditingController();
    final passwordConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your password to confirm account deletion:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Confirm Deletion'),
          ),
        ],
      ),
    );

    if (passwordConfirmed != true || !context.mounted) return;

    final password = passwordController.text;
    passwordController.dispose();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Call settings repository to delete account
      final repository = ref.read(settingsRepositoryProvider);
      await repository.deleteAccount(password: password);

      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Logout user
        await ref.read(authProvider.notifier).logout();

        // Show final message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
