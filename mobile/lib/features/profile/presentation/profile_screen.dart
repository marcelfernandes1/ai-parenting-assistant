/// Profile Screen - Edit user information
/// Allows users to update their profile data, baby info, preferences, and manage account security
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth/providers/auth_provider.dart';

/// Profile screen for viewing and editing user information
/// Displays all user profile data in editable sections with image upload capabilities
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

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // Selected images (local files before upload)
  File? _selectedProfileImage;
  File? _selectedBabyImage;

  // Image URLs from server
  String? _profileImageUrl;
  String? _babyImageUrl;

  // Scroll controller for auto-scrolling to errors
  final ScrollController _scrollController = ScrollController();

  // Global keys for field focus and scrolling
  final GlobalKey _modeFieldKey = GlobalKey();
  final GlobalKey _babyInfoSectionKey = GlobalKey();

  // Validation error messages
  String? _modeError;
  String? _nameError;

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

      // TODO: Load profile image URL and baby image URL from user object
      // _profileImageUrl = user.profileImageUrl;
      // _babyImageUrl = user.babyImageUrl;
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
    _scrollController.dispose();
    super.dispose();
  }

  /// Validate form fields before saving
  bool _validateForm() {
    setState(() {
      _modeError = null;
      _nameError = null;
    });

    bool isValid = true;

    // Validate mode is selected
    if (_selectedMode == null) {
      setState(() {
        _modeError = 'Please select your current stage';
      });
      isValid = false;
    }

    return isValid;
  }

  /// Scroll to the first error field
  void _scrollToError() {
    if (_modeError != null && _modeFieldKey.currentContext != null) {
      // Scroll to mode field if it has error
      Scrollable.ensureVisible(
        _modeFieldKey.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.2, // Position field 20% from top of screen
      );
    }
  }

  /// Pick profile image from gallery or camera
  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedProfileImage = File(pickedFile.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pick baby image from gallery or camera
  Future<void> _pickBabyImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedBabyImage = File(pickedFile.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show image source picker (Camera or Gallery)
  Future<void> _showImageSourcePicker(bool isProfilePicture) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isProfilePicture ? 'Choose Profile Picture' : 'Choose Baby Picture',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  if (isProfilePicture) {
                    _pickProfileImage(ImageSource.camera);
                  } else {
                    _pickBabyImage(ImageSource.camera);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  if (isProfilePicture) {
                    _pickProfileImage(ImageSource.gallery);
                  } else {
                    _pickBabyImage(ImageSource.gallery);
                  }
                },
              ),
              if ((isProfilePicture && (_selectedProfileImage != null || _profileImageUrl != null)) ||
                  (!isProfilePicture && (_selectedBabyImage != null || _babyImageUrl != null)))
                ListTile(
                  leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  title: Text(
                    'Remove Photo',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      if (isProfilePicture) {
                        _selectedProfileImage = null;
                        _profileImageUrl = null;
                      } else {
                        _selectedBabyImage = null;
                        _babyImageUrl = null;
                      }
                      _hasChanges = true;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
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

  /// Show change email dialog
  Future<void> _showChangeEmailDialog() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'New Email',
                hintText: 'Enter new email address',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                hintText: 'Confirm your password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Text(
              'You will need to verify your new email address',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement email change via backend API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email change will be implemented with backend'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Change Email'),
          ),
        ],
      ),
    );

    emailController.dispose();
    passwordController.dispose();
  }

  /// Show change password dialog
  Future<void> _showChangePasswordDialog() async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter current password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  hintText: 'Re-enter new password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Text(
                'Password must be at least 8 characters',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Validate passwords match
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // TODO: Implement password change via backend API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password change will be implemented with backend'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  /// Save profile changes to backend
  Future<void> _saveProfile() async {
    // Validate form first
    if (!_validateForm()) {
      // Scroll to first error
      _scrollToError();
      return;
    }

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

      // TODO: Upload profile image to S3 and include URL in updates
      // if (_selectedProfileImage != null) {
      //   final profileImageUrl = await uploadImageToS3(_selectedProfileImage!);
      //   updates['profileImageUrl'] = profileImageUrl;
      // }

      // TODO: Upload baby image to S3 and include URL in updates
      // if (_selectedBabyImage != null) {
      //   final babyImageUrl = await uploadImageToS3(_selectedBabyImage!);
      //   updates['babyImageUrl'] = babyImageUrl;
      // }

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
          // Clear selected images after successful upload
          _selectedProfileImage = null;
          _selectedBabyImage = null;
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
              controller: _scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile header with avatar and change picture button
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

                  // Email with change button
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: user.email ?? 'No email',
                      prefixIcon: const Icon(Icons.email),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _showChangeEmailDialog,
                        tooltip: 'Change email',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Account Security Section
                  _buildSectionHeader('Account Security'),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your account password'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showChangePasswordDialog,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Baby Information Section
                  _buildSectionHeader('Baby Information'),
                  const SizedBox(height: 16),

                  // Baby picture upload
                  _buildBabyPictureSection(),

                  const SizedBox(height: 24),

                  // Mode selector (Pregnancy / Parenting) with error handling
                  Container(
                    key: _modeFieldKey, // Key for auto-scrolling to error
                    padding: EdgeInsets.all(_modeError != null ? 16 : 0),
                    decoration: _modeError != null
                        ? BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.error,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
                          )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Current Stage',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _modeError != null
                                        ? Theme.of(context).colorScheme.error
                                        : null,
                                  ),
                            ),
                            if (_modeError != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '*',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_modeError != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _modeError!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                                  _modeError = null; // Clear error when user selects
                                });
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Parenting'),
                              selected: _selectedMode == 'PARENTING',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedMode = selected ? 'PARENTING' : null;
                                  _hasChanges = true;
                                  _modeError = null; // Clear error when user selects
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
        // Avatar circle with edit button overlay
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: _selectedProfileImage != null
                  ? FileImage(_selectedProfileImage!)
                  : _profileImageUrl != null
                      ? CachedNetworkImageProvider(_profileImageUrl!) as ImageProvider
                      : null,
              child: _selectedProfileImage == null && _profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () => _showImageSourcePicker(true),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          email,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () => _showImageSourcePicker(true),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Change Profile Picture'),
        ),
      ],
    );
  }

  /// Build baby picture section
  Widget _buildBabyPictureSection() {
    final hasBabyPicture = _selectedBabyImage != null || _babyImageUrl != null;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Baby\'s Picture',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (hasBabyPicture)
              Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _selectedBabyImage != null
                          ? Image.file(
                              _selectedBabyImage!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : _babyImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: _babyImageUrl!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 200,
                                    height: 200,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 200,
                                    height: 200,
                                    color: Theme.of(context).colorScheme.errorContainer,
                                    child: Icon(
                                      Icons.error_outline,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showImageSourcePicker(false),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.baby_changing_station,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No baby picture yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showImageSourcePicker(false),
                icon: Icon(hasBabyPicture ? Icons.edit : Icons.add_photo_alternate),
                label: Text(hasBabyPicture ? 'Change Baby Picture' : 'Add Baby Picture'),
              ),
            ),
          ],
        ),
      ),
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
