/// Screen for editing user profile information.
/// Allows updating baby details, parenting preferences, and other profile data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

/// Edit Profile screen
/// Allows user to update their profile information
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _babyNameController = TextEditingController();
  final _culturalBackgroundController = TextEditingController();
  final _concernsController = TextEditingController();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;

  // Profile field values
  String? _selectedMode;
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedParentingPhilosophy;
  String? _selectedReligiousViews;

  @override
  void initState() {
    super.initState();
    // Load current user data
    _loadUserData();
  }

  @override
  void dispose() {
    _babyNameController.dispose();
    _culturalBackgroundController.dispose();
    _concernsController.dispose();
    super.dispose();
  }

  /// Loads current user data into form fields
  void _loadUserData() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      setState(() {
        _selectedMode = currentUser.mode;
        _babyNameController.text = currentUser.babyName ?? '';
        _selectedGender = currentUser.babyGender;
        _selectedParentingPhilosophy = currentUser.parentingPhilosophy;
        _selectedReligiousViews = currentUser.religiousViews;
        _culturalBackgroundController.text = currentUser.culturalBackground ?? '';

        // Parse date
        if (currentUser.babyBirthDate != null) {
          try {
            _selectedDate = DateTime.parse(currentUser.babyBirthDate!);
          } catch (e) {
            // Invalid date format, leave null
          }
        }

        // Load concerns as comma-separated string
        if (currentUser.primaryConcerns != null && currentUser.primaryConcerns!.isNotEmpty) {
          _concernsController.text = currentUser.primaryConcerns!.join(', ');
        }
      });
    }
  }

  /// Shows date picker for birth date or due date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: _selectedMode == 'PREGNANCY' ? 'Select Due Date' : 'Select Birth Date',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Validates baby name (required if mode is PARENTING)
  String? _validateBabyName(String? value) {
    if (_selectedMode == 'PARENTING' && (value == null || value.isEmpty)) {
      return 'Baby name is required for parenting mode';
    }
    return null;
  }

  /// Handles profile update submission
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
      // Parse concerns from comma-separated string
      final concernsList = _concernsController.text.isEmpty
          ? <String>[]
          : _concernsController.text
              .split(',')
              .map((c) => c.trim())
              .where((c) => c.isNotEmpty)
              .toList();

      // Build update data
      final updateData = <String, dynamic>{
        if (_selectedMode != null) 'mode': _selectedMode,
        if (_babyNameController.text.isNotEmpty) 'babyName': _babyNameController.text,
        if (_selectedGender != null) 'babyGender': _selectedGender,
        if (_selectedParentingPhilosophy != null)
          'parentingPhilosophy': _selectedParentingPhilosophy,
        if (_selectedReligiousViews != null)
          'religiousViews': _selectedReligiousViews,
        if (_culturalBackgroundController.text.isNotEmpty)
          'culturalBackground': _culturalBackgroundController.text,
        if (concernsList.isNotEmpty) 'concerns': concernsList,
      };

      // Add date based on mode
      if (_selectedDate != null) {
        if (_selectedMode == 'PREGNANCY') {
          updateData['dueDate'] = _selectedDate!.toIso8601String();
        } else {
          updateData['babyBirthDate'] = _selectedDate!.toIso8601String();
        }
      }

      // Call auth provider to update profile
      await ref.read(authProvider.notifier).updateProfile(updateData);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
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

    // Format date for display
    String? dateText;
    if (_selectedDate != null) {
      dateText = '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info text
            Text(
              'Update your profile information and preferences.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 24),

            // Mode section (read-only, informational)
            Text(
              'Current Mode',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedMode == 'PREGNANCY'
                        ? Icons.pregnant_woman
                        : Icons.child_care,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedMode == 'PREGNANCY' ? 'Pregnancy' : 'Parenting',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Baby/Pregnancy Details section
            Text(
              _selectedMode == 'PREGNANCY' ? 'Pregnancy Details' : 'Baby Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Baby Name (only for PARENTING mode)
            if (_selectedMode == 'PARENTING')
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _babyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Baby Name',
                    hintText: 'Enter your baby\'s name',
                    prefixIcon: Icon(Icons.child_care),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _validateBabyName,
                  enabled: !_isLoading,
                ),
              ),

            // Date field (Due Date or Birth Date)
            InkWell(
              onTap: _isLoading ? null : _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: _selectedMode == 'PREGNANCY' ? 'Due Date' : 'Birth Date',
                  hintText: 'Select date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  dateText ?? 'Not set',
                  style: dateText != null
                      ? theme.textTheme.bodyLarge
                      : theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Baby Gender
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'MALE', child: Text('Male')),
                DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                DropdownMenuItem(value: 'OTHER', child: Text('Prefer not to say')),
              ],
              onChanged: _isLoading ? null : (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Preferences section
            Text(
              'Parenting Preferences',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Parenting Philosophy
            DropdownButtonFormField<String>(
              value: _selectedParentingPhilosophy,
              decoration: const InputDecoration(
                labelText: 'Parenting Philosophy',
                prefixIcon: Icon(Icons.psychology),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'ATTACHMENT', child: Text('Attachment Parenting')),
                DropdownMenuItem(value: 'AUTHORITATIVE', child: Text('Authoritative')),
                DropdownMenuItem(value: 'GENTLE', child: Text('Gentle Parenting')),
                DropdownMenuItem(value: 'TRADITIONAL', child: Text('Traditional')),
                DropdownMenuItem(value: 'ECLECTIC', child: Text('Eclectic/Mixed')),
              ],
              onChanged: _isLoading ? null : (value) {
                setState(() {
                  _selectedParentingPhilosophy = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Religious Views
            DropdownButtonFormField<String>(
              value: _selectedReligiousViews,
              decoration: const InputDecoration(
                labelText: 'Religious/Spiritual Views',
                prefixIcon: Icon(Icons.auto_awesome),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'CHRISTIAN', child: Text('Christian')),
                DropdownMenuItem(value: 'MUSLIM', child: Text('Muslim')),
                DropdownMenuItem(value: 'JEWISH', child: Text('Jewish')),
                DropdownMenuItem(value: 'HINDU', child: Text('Hindu')),
                DropdownMenuItem(value: 'BUDDHIST', child: Text('Buddhist')),
                DropdownMenuItem(value: 'SECULAR', child: Text('Secular/Non-religious')),
                DropdownMenuItem(value: 'SPIRITUAL', child: Text('Spiritual but not religious')),
                DropdownMenuItem(value: 'OTHER', child: Text('Other')),
              ],
              onChanged: _isLoading ? null : (value) {
                setState(() {
                  _selectedReligiousViews = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Cultural Background
            TextFormField(
              controller: _culturalBackgroundController,
              decoration: const InputDecoration(
                labelText: 'Cultural Background (Optional)',
                hintText: 'e.g., Nigerian, Italian-American',
                prefixIcon: Icon(Icons.public),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
            ),

            const SizedBox(height: 16),

            // Primary Concerns (comma-separated)
            TextFormField(
              controller: _concernsController,
              decoration: const InputDecoration(
                labelText: 'Primary Concerns (Optional)',
                hintText: 'e.g., Sleep, Feeding, Development',
                helperText: 'Separate multiple concerns with commas',
                prefixIcon: Icon(Icons.list),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
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
