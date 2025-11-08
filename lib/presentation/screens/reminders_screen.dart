import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../../domain/entities/reminder.dart';
import '../providers/reminder_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeReminders = ref.watch(activeRemindersProvider);
    final upcomingReminders = ref.watch(upcomingRemindersProvider);
    final overdueReminders = ref.watch(overdueRemindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overdue Reminders
            overdueReminders.when(
              data: (reminders) => reminders.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overdue',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...reminders.map((reminder) => _buildReminderCard(
                          context, 
                          ref, 
                          reminder, 
                          isOverdue: true,
                        )),
                        const SizedBox(height: 24),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            
            // Upcoming Reminders
            Text(
              'Today',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            upcomingReminders.when(
              data: (reminders) => reminders.isEmpty
                  ? CustomCard(
                      child: Text(
                        'No upcoming reminders for today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : Column(
                      children: reminders.map((reminder) => _buildReminderCard(context, ref, reminder)).toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            
            const SizedBox(height: 24),
            
            // All Active Reminders
            Text(
              'All Active Reminders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            activeReminders.when(
              data: (reminders) => reminders.isEmpty
                  ? CustomCard(
                      child: Text(
                        'No active reminders',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : Column(
                      children: reminders.map((reminder) => _buildReminderCard(context, ref, reminder)).toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildReminderCard(BuildContext context, WidgetRef ref, Reminder reminder, {bool isOverdue = false}) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getReminderIcon(reminder.type),
          color: isOverdue ? Colors.red : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          reminder.title,
          style: isOverdue 
              ? const TextStyle(color: Colors.red)
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description != null)
              Text(reminder.description!),
            Text(
              '${reminder.scheduledAt.day}/${reminder.scheduledAt.month} '
              '${reminder.scheduledAt.hour.toString().padLeft(2, '0')}:'
              '${reminder.scheduledAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isOverdue ? Colors.red : null,
                fontWeight: isOverdue ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleReminderAction(context, ref, reminder, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'complete',
              child: Row(
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text('Complete'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'snooze',
              child: Row(
                children: [
                  Icon(Icons.snooze),
                  SizedBox(width: 8),
                  Text('Snooze 15m'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReminderAction(BuildContext context, WidgetRef ref, Reminder reminder, String action) {
    final notifier = ref.read(reminderProvider.notifier);
    
    switch (action) {
      case 'complete':
        if (reminder.id != null) {
          notifier.markCompleted(reminder.id!);
        }
        break;
      case 'snooze':
        if (reminder.id != null) {
          notifier.snoozeReminder(reminder.id!, const Duration(minutes: 15));
        }
        break;
      case 'edit':
        _showEditReminderDialog(context, ref, reminder);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, reminder);
        break;
    }
  }

  void _showAddReminderDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _ReminderDialog(
        onSave: (reminder) {
          ref.read(reminderProvider.notifier).addReminder(reminder);
        },
      ),
    );
  }

  void _showEditReminderDialog(BuildContext context, WidgetRef ref, Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => _ReminderDialog(
        reminder: reminder,
        onSave: (updatedReminder) {
          ref.read(reminderProvider.notifier).updateReminder(updatedReminder);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              if (reminder.id != null) {
                ref.read(reminderProvider.notifier).deleteReminder(reminder.id!);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getReminderIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.exercise:
        return Icons.fitness_center;
      case ReminderType.assessment:
        return Icons.assessment;
      case ReminderType.appointment:
        return Icons.event;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }
}

class _ReminderDialog extends StatefulWidget {

  const _ReminderDialog({
    this.reminder,
    required this.onSave,
  });
  final Reminder? reminder;
  final Function(Reminder) onSave;

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late ReminderType _selectedType;
  late ReminderFrequency _selectedFrequency;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder?.title ?? '');
    _descriptionController = TextEditingController(text: widget.reminder?.description ?? '');
    _selectedType = widget.reminder?.type ?? ReminderType.custom;
    _selectedFrequency = widget.reminder?.frequency ?? ReminderFrequency.once;
    _selectedDateTime = widget.reminder?.scheduledAt ?? DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReminderType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ReminderType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getReminderTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReminderFrequency>(
              initialValue: _selectedFrequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: ReminderFrequency.values.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(_getReminderFrequencyLabel(frequency)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFrequency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date & Time'),
              subtitle: Text(
                '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} '
                '${_selectedDateTime.hour.toString().padLeft(2, '0')}:'
                '${_selectedDateTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveReminder,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty) return;

    final reminder = Reminder(
      id: widget.reminder?.id,
      title: _titleController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      type: _selectedType,
      frequency: _selectedFrequency,
      scheduledAt: _selectedDateTime,
      isActive: true,
      isCompleted: false,
      createdAt: widget.reminder?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(reminder);
    Navigator.of(context).pop();
  }

  String _getReminderTypeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return 'Medication';
      case ReminderType.exercise:
        return 'Exercise';
      case ReminderType.assessment:
        return 'Assessment';
      case ReminderType.appointment:
        return 'Appointment';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  String _getReminderFrequencyLabel(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'Once';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.monthly:
        return 'Monthly';
    }
  }
}