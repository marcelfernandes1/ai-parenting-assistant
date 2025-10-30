/// Profile Screen - Edit user information
/// Allows users to update their profile data, baby info, and preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';

/// Profile screen for viewing and editing user information
/// Displays all user profile data in editable sections
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _babyNameController;
  late TextEditingController _parentingPhilosophyController;
  late TextEditingController _religiousViewsController;

  // Selected values
  String? _selectedMode;
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _nameController = TextEditingController();
    _babyNameController = TextEditingController();
    _parentingPhilosophyController = TextEditingController();
    _religiousViewsController = TextEditingController();

    // Load user data in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  /// Load current user data into form fields
  void _loadUserData() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _nameController.text = user.name ?? '';
      _babyNameController.text = user.babyName ?? '';
      _parentingPhilosophyController.text = user.parentingPhilosophy ?? '';
      _religiousViewsController.text = user.religiousViews ?? '';
      _selectedMode = user.mode;

      // Parse birth date if available
      if (user.babyBirthDate != null) {
        try {
          _selectedDate = DateTime.parse(user.babyBirthDate!);
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
    });

    // Add listeners to track changes
    _nameController.addListener(() => setState(() => _hasChanges = true));
    _babyNameController.addListener(() => setState(() => _hasChanges = true));
    _parentingPhilosophyController.addListener(() => setState(() => _hasChanges = true));
    _religiousViewsController.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _babyNameController.dispose();
    _parentingPhilosophyController.dispose();
    _religiousViewsController.dispose();
    super.dispose();
  }

  /// Show date picker for baby birth date or due date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: _selectedMode == 'PREGNANCY' ? 'Select due date' : 'Select birth date',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _hasChanges = true;
      });
    }
  }

  /// Save profile changes to backend
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      // Build update payload
      final updates = <String, dynamic>{};

      if (_nameController.text.trim().isNotEmpty) {
        updates['name'] = _nameController.text.trim();
      }

      if (_babyNameController.text.trim().isNotEmpty) {
        updates['babyName'] = _babyNameController.text.trim();
      }

      if (_selectedMode != null) {
        updates['mode'] = _selectedMode;
      }

      if (_selectedDate != null) {
        updates['babyBirthDate'] = _selectedDate!.toIso8601String();
      }

      if (_parentingPhilosophyController.text.trim().isNotEmpty) {
        updates['parentingPhilosophy'] = _parentingPhilosophyController.text.trim();
      }

      if (_religiousViewsController.text.trim().isNotEmpty) {
        updates['religiousViews'] = _religiousViewsController.text.trim();
      }

      // Call update method
      await ref.read(authProvider.notifier).updateProfile(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _hasChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Save button (only show if there are changes)
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user data'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile header with avatar
                  _buildProfileHeader(user.email ?? 'No email'),

                  const SizedBox(height: 32),

                  // Basic Info Section
                  _buildSectionHeader('Basic Information'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email (read-only)
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: user.email ?? 'No email',
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Baby Information Section
                  _buildSectionHeader('Baby Information'),
                  const SizedBox(height: 16),

                  // Mode selector (Pregnancy / Parenting)
                  Text('Current Stage', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      ChoiceChip(
                        label: const Text('Pregnancy'),
                        selected: _selectedMode == 'PREGNANCY',
                        onSelected: (selected) {
                          setState(() {
                            _selectedMode = selected ? 'PREGNANCY' : null;
                            _hasChanges = true;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Parenting'),
                        selected: _selectedMode == 'PARENT',
                        onSelected: (selected) {
                          setState(() {
                            _selectedMode = selected ? 'PARENT' : null;
                            _hasChanges = true;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Baby name
                  TextField(
                    controller: _babyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Baby\'s Name',
                      hintText: 'Enter baby\'s name',
                      prefixIcon: Icon(Icons.child_care),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Birth date / Due date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: _selectedMode == 'PREGNANCY' ? 'Due Date' : 'Birth Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                            : 'Select date',
                        style: _selectedDate != null
                            ? null
                            : TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Preferences Section
                  _buildSectionHeader('Preferences'),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _parentingPhilosophyController,
                    decoration: const InputDecoration(
                      labelText: 'Parenting Philosophy',
                      hintText: 'e.g., Attachment parenting',
                      prefixIcon: Icon(Icons.lightbulb_outline),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _religiousViewsController,
                    decoration: const InputDecoration(
                      labelText: 'Religious/Cultural Views',
                      hintText: 'e.g., Christian, Muslim, None',
                      prefixIcon: Icon(Icons.book_outlined),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 32),

                  // Subscription Status Section
                  _buildSectionHeader('Subscription'),
                  const SizedBox(height: 16),
                  _buildSubscriptionCard(user.subscriptionTier),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  /// Build profile header with avatar and email
  Widget _buildProfileHeader(String email) {
    return Column(
      children: [
        // Avatar circle
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 50,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          email,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  /// Build section header text
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  /// Build subscription status card
  Widget _buildSubscriptionCard(String tier) {
    final isPremium = tier == 'PREMIUM';

    return Card(
      color: isPremium
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isPremium ? Icons.star : Icons.star_outline,
              size: 32,
              color: isPremium
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? 'Premium' : 'Free Tier',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium
                        ? 'Unlimited access to all features'
                        : '10 messages/day, 10 voice minutes/day',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!isPremium)
              TextButton(
                onPressed: () => context.push('/premium'),
                child: const Text('Upgrade'),
              ),
          ],
        ),
      ),
    );
  }
}
