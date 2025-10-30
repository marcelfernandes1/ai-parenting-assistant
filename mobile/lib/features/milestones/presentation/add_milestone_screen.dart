/// Add Milestone screen for creating new milestones.
/// Form with milestone name, type, date, notes, and photo selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/milestone_list_provider.dart';
import '../domain/milestone_model.dart';

/// Screen for adding a new milestone
class AddMilestoneScreen extends ConsumerStatefulWidget {
  const AddMilestoneScreen({super.key});

  @override
  ConsumerState<AddMilestoneScreen> createState() =>
      _AddMilestoneScreenState();
}

class _AddMilestoneScreenState extends ConsumerState<AddMilestoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  // Form fields
  MilestoneType _selectedType = MilestoneType.physical;
  DateTime _selectedDate = DateTime.now();
  List<String> _photoUrls = []; // Will be populated from photo upload
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Handles save button press
  Future<void> _handleSave() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create milestone via provider
      await ref.read(milestoneListProvider.notifier).createMilestone(
            type: _selectedType,
            name: _nameController.text.trim(),
            achievedDate: _selectedDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            photoUrls: _photoUrls.isEmpty ? null : _photoUrls,
          );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Milestone created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to milestones screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create milestone: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Shows date picker dialog
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), // Allow dates from 2020 onwards
      lastDate: DateTime.now(), // Cannot select future dates
      helpText: 'Select achievement date',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Milestone'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          // Save button in app bar
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Milestone name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Milestone Name *',
                hintText: 'e.g., First steps, First word',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a milestone name';
                }
                return null;
              },
              enabled: !_isSaving,
            ),
            const SizedBox(height: 20),

            // Milestone type dropdown
            DropdownButtonFormField<MilestoneType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Milestone Type *',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: MilestoneType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        size: 20,
                        color: _getTypeColor(type),
                      ),
                      const SizedBox(width: 12),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 20),

            // Achieved date picker
            InkWell(
              onTap: _isSaving ? null : _selectDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Achieved Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy').format(_selectedDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notes field (optional)
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional details...',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 20),

            // Photos section (placeholder for now)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Photos',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () {
                              // TODO: Implement photo picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Photo picker coming soon! For now, upload photos in chat.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Photos'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can attach photos from your gallery or camera',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button (alternative to app bar button)
            FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSaving ? 'Saving...' : 'Save Milestone'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets icon for milestone type
  IconData _getTypeIcon(MilestoneType type) {
    switch (type) {
      case MilestoneType.physical:
        return Icons.directions_run;
      case MilestoneType.feeding:
        return Icons.restaurant;
      case MilestoneType.sleep:
        return Icons.bedtime;
      case MilestoneType.social:
        return Icons.people;
      case MilestoneType.health:
        return Icons.local_hospital;
    }
  }

  /// Gets color for milestone type
  Color _getTypeColor(MilestoneType type) {
    switch (type) {
      case MilestoneType.physical:
        return Colors.blue;
      case MilestoneType.feeding:
        return Colors.orange;
      case MilestoneType.sleep:
        return Colors.purple;
      case MilestoneType.social:
        return Colors.green;
      case MilestoneType.health:
        return Colors.red;
    }
  }
}
