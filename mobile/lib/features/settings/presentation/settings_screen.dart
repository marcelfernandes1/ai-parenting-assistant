/// Settings screen for app configuration and account management.
/// Provides access to subscription management, account settings, and app preferences.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../subscription/presentation/subscription_management_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account section
          _buildSectionHeader(context, 'Account'),
          _buildAccountTile(context, theme, userEmail),

          const Divider(height: 32),

          // Subscription section
          _buildSectionHeader(context, 'Subscription'),
          _buildSubscriptionTile(context),

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
        // TODO: Navigate to account settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account settings coming soon'),
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
}
