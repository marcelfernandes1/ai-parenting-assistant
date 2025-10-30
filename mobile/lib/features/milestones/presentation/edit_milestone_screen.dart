/// Edit Milestone screen for updating existing milestones.
/// Form pre-populated with current milestone data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/milestone_list_provider.dart';
import '../domain/milestone_model.dart';

/// Screen for editing an existing milestone
class EditMilestoneScreen extends ConsumerStatefulWidget {
  final Milestone milestone;

  const EditMilestoneScreen({
    super.key,
    required this.milestone,
  });

  @override
  ConsumerState<EditMilestoneScreen> createState() =>
      _EditMilestoneScreenState();
}

class _EditMilestoneScreenState extends ConsumerState<EditMilestoneScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  // Form fields
  late DateTime _selectedDate;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate form fields with existing milestone data
    _nameController = TextEditingController(text: widget.milestone.name);
    _notesController = TextEditingController(text: widget.milestone.notes ?? '');
    _selectedDate = widget.milestone.achievedDate;
  }

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
      // Update milestone via provider
      await ref.read(milestoneListProvider.notifier).updateMilestone(
            widget.milestone.id,
            name: _nameController.text.trim(),
            achievedDate: _selectedDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Milestone updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update milestone: ${e.toString()}'),
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

  /// Handles delete button press with confirmation
  Future<void> _handleDelete() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Milestone'),
        content: Text(
          'Are you sure you want to delete "${widget.milestone.name}"? This action cannot be undone.',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      // Delete milestone via provider
      await ref
          .read(milestoneListProvider.notifier)
          .deleteMilestone(widget.milestone.id);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Milestone deleted'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete milestone: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  /// Shows date picker dialog
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    final isProcessing = _isSaving || _isDeleting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Milestone'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          // Delete button
          IconButton(
            onPressed: isProcessing ? null : _handleDelete,
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
            tooltip: 'Delete milestone',
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: isProcessing ? null : _handleSave,
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
            // Milestone type badge (read-only, cannot be changed after creation)
            Card(
              color: _getTypeColor(widget.milestone.type).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getTypeIcon(widget.milestone.type),
                      color: _getTypeColor(widget.milestone.type),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Milestone Type',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          widget.milestone.type.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getTypeColor(widget.milestone.type),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

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
              enabled: !isProcessing,
            ),
            const SizedBox(height: 20),

            // Achieved date picker
            InkWell(
              onTap: isProcessing ? null : _selectDate,
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

            // Notes field
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
              enabled: !isProcessing,
            ),
            const SizedBox(height: 20),

            // Photos section (display only, editing not implemented yet)
            if (widget.milestone.photoUrls.isNotEmpty)
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
                            'Attached Photos',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.milestone.photoUrls.length} photo(s) attached',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Photo editing coming soon',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Save button (alternative to app bar button)
            FilledButton.icon(
              onPressed: isProcessing ? null : _handleSave,
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
              label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 12),

            // Delete button (alternative to app bar button)
            OutlinedButton.icon(
              onPressed: isProcessing ? null : _handleDelete,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete),
              label: Text(_isDeleting ? 'Deleting...' : 'Delete Milestone'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
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
