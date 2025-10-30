/// Main navigation shell with bottom tab bar.
/// Manages navigation between Chat, Photos, and Milestones screens.
library;

import 'package:flutter/material.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/photos/presentation/photos_screen.dart';
import '../../features/milestones/presentation/milestones_screen.dart';

/// Main navigation screen with bottom tab bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  /// Current selected tab index
  int _currentIndex = 0;

  /// List of screens corresponding to each tab
  final List<Widget> _screens = [
    const ChatScreen(),
    const PhotosScreen(),
    const MilestonesScreen(),
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
        ],
      ),
    );
  }
}
