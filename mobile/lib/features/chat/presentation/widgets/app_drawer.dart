/// Navigation drawer for the app
/// Provides access to chat history, profile, settings, and other modules
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/chat_provider.dart';
import '../../../onboarding/providers/onboarding_provider.dart';

/// Main app navigation drawer
/// Displays user profile, chat history, and navigation options
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatProvider);
    final onboardingData = ref.watch(onboardingProvider);

    // Get baby name and mode for header
    final babyName = onboardingData.babyName ?? 'Your Baby';
    final mode = onboardingData.mode ?? 'PARENTING';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header with user profile info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App icon or user avatar
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      mode == 'PREGNANCY' ? Icons.pregnant_woman : Icons.child_care,
                      size: 32,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Baby name or pregnancy mode
                  Text(
                    babyName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode == 'PREGNANCY' ? 'Pregnancy Mode' : 'Parenting Mode',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // Navigation options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Chat History Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'CHAT HISTORY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  // Current conversation (always shown)
                  ListTile(
                    leading: Icon(
                      Icons.chat_bubble,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Current Conversation'),
                    subtitle: Text(
                      '${chatState.messages.length} messages',
                      style: theme.textTheme.bodySmall,
                    ),
                    selected: true,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                    },
                  ),

                  const Divider(),

                  // App Modules Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'APP MODULES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  // Photos module
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photos'),
                    subtitle: const Text('View baby photos & albums'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.push('/photos'); // Navigate using go_router
                    },
                  ),

                  // Milestones module
                  ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text('Milestones'),
                    subtitle: const Text('Track baby development'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.push('/milestones'); // Navigate using go_router
                    },
                  ),

                  const Divider(),

                  // Settings Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'ACCOUNT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  // Profile settings
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    subtitle: const Text('Edit your information'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.push('/profile'); // Navigate using go_router
                    },
                  ),

                  // App settings
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    subtitle: const Text('App preferences & account'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.push('/settings'); // Navigate using go_router
                    },
                  ),

                  // Subscription/Premium
                  ListTile(
                    leading: Icon(
                      Icons.workspace_premium,
                      color: theme.colorScheme.tertiary,
                    ),
                    title: const Text('Upgrade to Premium'),
                    subtitle: const Text('Unlimited features'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.push('/premium'); // Navigate using go_router
                    },
                  ),
                ],
              ),
            ),

            // Footer with app version
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Baby Boomer v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
