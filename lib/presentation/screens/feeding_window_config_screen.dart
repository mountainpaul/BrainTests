import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../providers/database_provider.dart';
import '../widgets/custom_card.dart';

class FeedingWindowConfigScreen extends ConsumerStatefulWidget {
  const FeedingWindowConfigScreen({super.key});

  @override
  ConsumerState<FeedingWindowConfigScreen> createState() => _FeedingWindowConfigScreenState();
}

class _FeedingWindowConfigScreenState extends ConsumerState<FeedingWindowConfigScreen> {
  List<FeedingWindow> feedingWindows = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedingWindows();
  }

  Future<void> _loadFeedingWindows() async {
    final database = ref.read(databaseProvider);
    try {
      final windows = await (database.select(database.feedingWindowTable)
            ..orderBy([(t) => drift.OrderingTerm.asc(t.startHour)]))
          .get();
      setState(() {
        feedingWindows = windows;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading feeding windows: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Windows'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedingWindows.isEmpty
              ? _buildEmptyState()
              : _buildFeedingWindowsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFeedingWindow,
        icon: const Icon(Icons.add),
        label: const Text('Add Window'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Feeding Windows Configured',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up time windows when you plan to eat during the day',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addFeedingWindow,
              icon: const Icon(Icons.add),
              label: const Text('Add Feeding Window'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingWindowsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: feedingWindows.length + 1,
      itemBuilder: (context, index) {
        if (index == feedingWindows.length) {
          return const SizedBox(height: 80); // Space for FAB
        }

        final window = feedingWindows[index];
        return _buildFeedingWindowCard(window);
      },
    );
  }

  Widget _buildFeedingWindowCard(FeedingWindow window) {
    final startTime = TimeOfDay(hour: window.startHour, minute: window.startMinute);
    final endTime = TimeOfDay(hour: window.endHour, minute: window.endMinute);
    final duration = _calculateDuration(window);

    return CustomCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: window.isActive ? Colors.blue : Colors.grey,
          child: Icon(
            window.isActive ? Icons.schedule : Icons.schedule_outlined,
            color: Colors.white,
          ),
        ),
        title: Text(
          '${_formatTime(startTime)} - ${_formatTime(endTime)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: window.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          'Duration: ${duration.inHours}h ${duration.inMinutes % 60}m${window.isActive ? '' : ' (Inactive)'}',
          style: TextStyle(
            color: window.isActive ? null : Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: window.isActive,
              onChanged: (value) => _toggleWindowActive(window, value),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editFeedingWindow(window),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Duration _calculateDuration(FeedingWindow window) {
    final startMinutes = window.startHour * 60 + window.startMinute;
    final endMinutes = window.endHour * 60 + window.endMinute;

    final durationMinutes = endMinutes > startMinutes
        ? endMinutes - startMinutes
        : (24 * 60) - startMinutes + endMinutes; // Crosses midnight

    return Duration(minutes: durationMinutes);
  }

  Future<void> _toggleWindowActive(FeedingWindow window, bool isActive) async {
    try {
      final database = ref.read(databaseProvider);
      await (database.update(database.feedingWindowTable)
            ..where((t) => t.id.equals(window.id)))
          .write(
        FeedingWindowTableCompanion(
          isActive: drift.Value(isActive),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      await _loadFeedingWindows();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating window: $e')),
        );
      }
    }
  }

  Future<void> _addFeedingWindow() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const FeedingWindowDialog(),
    );

    if (result == true) {
      await _loadFeedingWindows();
    }
  }

  Future<void> _editFeedingWindow(FeedingWindow window) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => FeedingWindowDialog(window: window),
    );

    if (result == true) {
      await _loadFeedingWindows();
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Feeding Windows'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Feeding windows help you track when you eat during the day, which is useful for:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Time-restricted eating (16:8, 18:6, etc.)'),
              Text('• Intermittent fasting'),
              Text('• Meal timing optimization'),
              Text('• Circadian rhythm alignment'),
              SizedBox(height: 12),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Set a consistent daily eating window'),
              Text('• Allow 12-16 hours between last and first meal'),
              Text('• Align eating with daylight hours when possible'),
              Text('• Use inactive windows for off-days or flexible schedules'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class FeedingWindowDialog extends ConsumerStatefulWidget {
  final FeedingWindow? window;

  const FeedingWindowDialog({super.key, this.window});

  @override
  ConsumerState<FeedingWindowDialog> createState() => _FeedingWindowDialogState();
}

class _FeedingWindowDialogState extends ConsumerState<FeedingWindowDialog> {
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.window != null) {
      startTime = TimeOfDay(
        hour: widget.window!.startHour,
        minute: widget.window!.startMinute,
      );
      endTime = TimeOfDay(
        hour: widget.window!.endHour,
        minute: widget.window!.endMinute,
      );
      isActive = widget.window!.isActive;
    } else {
      // Default: 12 PM - 8 PM (8 hour window)
      startTime = const TimeOfDay(hour: 12, minute: 0);
      endTime = const TimeOfDay(hour: 20, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = _calculateDuration();

    return AlertDialog(
      title: Text(widget.window == null ? 'Add Feeding Window' : 'Edit Feeding Window'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Time'),
            trailing: Text(
              _formatTime(startTime),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onTap: () => _selectTime(true),
          ),
          ListTile(
            title: const Text('End Time'),
            trailing: Text(
              _formatTime(endTime),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onTap: () => _selectTime(false),
          ),
          const Divider(),
          ListTile(
            title: const Text('Duration'),
            trailing: Text(
              '${duration.inHours}h ${duration.inMinutes % 60}m',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          CheckboxListTile(
            title: const Text('Active'),
            value: isActive,
            onChanged: (value) {
              setState(() {
                isActive = value ?? true;
              });
            },
          ),
        ],
      ),
      actions: [
        if (widget.window != null)
          TextButton(
            onPressed: _deleteWindow,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveWindow,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Duration _calculateDuration() {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    final durationMinutes = endMinutes > startMinutes
        ? endMinutes - startMinutes
        : (24 * 60) - startMinutes + endMinutes;

    return Duration(minutes: durationMinutes);
  }

  Future<void> _saveWindow() async {
    try {
      final database = ref.read(databaseProvider);

      if (widget.window == null) {
        // Create new window
        await database.into(database.feedingWindowTable).insert(
          FeedingWindowTableCompanion.insert(
            startHour: startTime.hour,
            startMinute: startTime.minute,
            endHour: endTime.hour,
            endMinute: endTime.minute,
            isActive: drift.Value(isActive),
          ),
        );
      } else {
        // Update existing window
        await (database.update(database.feedingWindowTable)
              ..where((t) => t.id.equals(widget.window!.id)))
            .write(
          FeedingWindowTableCompanion(
            startHour: drift.Value(startTime.hour),
            startMinute: drift.Value(startTime.minute),
            endHour: drift.Value(endTime.hour),
            endMinute: drift.Value(endTime.minute),
            isActive: drift.Value(isActive),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving window: $e')),
        );
      }
    }
  }

  Future<void> _deleteWindow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feeding Window'),
        content: const Text('Are you sure you want to delete this feeding window?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.window != null) {
      try {
        final database = ref.read(databaseProvider);
        await (database.delete(database.feedingWindowTable)
              ..where((t) => t.id.equals(widget.window!.id)))
            .go();

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting window: $e')),
          );
        }
      }
    }
  }
}
