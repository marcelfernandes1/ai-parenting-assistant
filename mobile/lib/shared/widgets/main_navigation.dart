/// Main navigation shell with bottom tab bar.
/// Manages navigation between Chat, Photos, and Milestones screens.
/// Watches subscription provider to fetch status on app launch.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/photos/presentation/photos_screen.dart';
import '../../features/milestones/presentation/milestones_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/subscription/providers/subscription_provider.dart';

/// Main navigation screen with bottom tab bar
/// Uses ConsumerStatefulWidget to access Riverpod providers
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  /// Current selected tab index
  int _currentIndex = 0;

  /// List of screens corresponding to each tab
  final List<Widget> _screens = [
    const ChatScreen(),
    const PhotosScreen(),
    const MilestonesScreen(),
    const SettingsScreen(),
  ];

  /// Handles tab selection
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch subscription provider to fetch status on app launch
    // This automatically triggers the fetch when widget is first built
    // and updates when subscription changes (after purchase, etc.)
    final subscriptionAsync = ref.watch(subscriptionProvider);

    // Debug log subscription status
    subscriptionAsync.when(
      data: (subscription) {
        print('💳 Subscription: ${subscription.subscriptionTier} - ${subscription.subscriptionStatus}');
        if (subscription.usage != null) {
          print('💳 Usage: ${subscription.usage!.messagesUsed}/${subscription.usage!.messageLimit ?? "unlimited"} messages');
        }
      },
      loading: () => print('💳 Subscription: Loading...'),
      error: (error, stack) => print('💳 Subscription Error: $error'),
    );

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        elevation: 8,
        destinations: const [
          /// Chat tab
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),

          /// Photos tab
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Photos',
          ),

          /// Milestones tab
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Milestones',
          ),

          /// Settings tab
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
