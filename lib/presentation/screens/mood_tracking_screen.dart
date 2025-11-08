import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../../domain/entities/mood_entry.dart';
import '../providers/mood_entry_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';

class MoodTrackingScreen extends ConsumerWidget {
  const MoodTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMoodEntry = ref.watch(todayMoodEntryProvider);
    final recentMoodEntries = ref.watch(recentMoodEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Mood Entry
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            todayMoodEntry.when(
              data: (moodEntry) => moodEntry != null
                  ? _buildTodayMoodCard(context, ref, moodEntry)
                  : _buildMoodEntryForm(context, ref),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => _buildMoodEntryForm(context, ref),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Mood Entries
            Text(
              'Recent Mood Entries',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            recentMoodEntries.when(
              data: (entries) => entries.isEmpty
                  ? CustomCard(
                      child: Text(
                        'No mood entries yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : Column(
                      children: entries.map((entry) => _buildMoodEntryCard(context, entry)).toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildTodayMoodCard(BuildContext context, WidgetRef ref, MoodEntry moodEntry) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Mood Entry',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => _showMoodEntryDialog(context, ref, moodEntry),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                _getMoodIcon(moodEntry.mood),
                size: 48,
                color: _getMoodColor(moodEntry.mood),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMoodLabel(moodEntry.mood),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildMoodMetrics(context, moodEntry),
                  ],
                ),
              ),
            ],
          ),
          if (moodEntry.notes != null && moodEntry.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Notes:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              moodEntry.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodEntryForm(BuildContext context, WidgetRef ref) {
    return CustomCard(
      onTap: () => _showMoodEntryDialog(context, ref),
      child: Column(
        children: [
          const Icon(Icons.mood, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Tap to log your mood',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Track how you\'re feeling today',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEntryCard(BuildContext context, MoodEntry entry) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getMoodIcon(entry.mood),
          size: 32,
          color: _getMoodColor(entry.mood),
        ),
        title: Text(_getMoodLabel(entry.mood)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.entryDate.day}/${entry.entryDate.month}/${entry.entryDate.year}',
            ),
            Text('Wellness Score: ${entry.overallWellness.toStringAsFixed(1)}/10'),
          ],
        ),
        trailing: _buildWellnessIndicator(context, entry.overallWellness),
      ),
    );
  }

  Widget _buildMoodMetrics(BuildContext context, MoodEntry moodEntry) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Energy:', style: Theme.of(context).textTheme.bodyMedium),
            Text('${moodEntry.energyLevel}/10', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Stress:', style: Theme.of(context).textTheme.bodyMedium),
            Text('${moodEntry.stressLevel}/10', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sleep Quality:', style: Theme.of(context).textTheme.bodyMedium),
            Text('${moodEntry.sleepQuality}/10', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Wellness Score:', style: Theme.of(context).textTheme.titleMedium),
            Text(
              '${moodEntry.overallWellness.toStringAsFixed(1)}/10',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getWellnessColor(moodEntry.overallWellness),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWellnessIndicator(BuildContext context, double wellness) {
    final color = _getWellnessColor(wellness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        wellness.toStringAsFixed(1),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showMoodEntryDialog(BuildContext context, WidgetRef ref, [MoodEntry? existingEntry]) {
    showDialog(
      context: context,
      builder: (context) => _MoodEntryDialog(
        existingEntry: existingEntry,
        onSave: (moodEntry) {
          ref.read(moodEntryProvider.notifier).addOrUpdateTodayMoodEntry(moodEntry);
        },
      ),
    );
  }

  IconData _getMoodIcon(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return Icons.sentiment_very_satisfied;
      case MoodLevel.good:
        return Icons.sentiment_satisfied;
      case MoodLevel.neutral:
        return Icons.sentiment_neutral;
      case MoodLevel.low:
        return Icons.sentiment_dissatisfied;
      case MoodLevel.veryLow:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  Color _getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return Colors.green;
      case MoodLevel.good:
        return Colors.lightGreen;
      case MoodLevel.neutral:
        return Colors.yellow;
      case MoodLevel.low:
        return Colors.orange;
      case MoodLevel.veryLow:
        return Colors.red;
    }
  }

  String _getMoodLabel(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return 'Excellent';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.neutral:
        return 'Neutral';
      case MoodLevel.low:
        return 'Low';
      case MoodLevel.veryLow:
        return 'Very Low';
    }
  }

  Color _getWellnessColor(double wellness) {
    if (wellness >= 8) {
      return Colors.green;
    } else if (wellness >= 6) {
      return Colors.lightGreen;
    } else if (wellness >= 4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class _MoodEntryDialog extends StatefulWidget {

  const _MoodEntryDialog({
    this.existingEntry,
    required this.onSave,
  });
  final MoodEntry? existingEntry;
  final Function(MoodEntry) onSave;

  @override
  State<_MoodEntryDialog> createState() => _MoodEntryDialogState();
}

class _MoodEntryDialogState extends State<_MoodEntryDialog> {
  late MoodLevel _selectedMood;
  late int _energyLevel;
  late int _stressLevel;
  late int _sleepQuality;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.existingEntry?.mood ?? MoodLevel.neutral;
    _energyLevel = widget.existingEntry?.energyLevel ?? 5;
    _stressLevel = widget.existingEntry?.stressLevel ?? 5;
    _sleepQuality = widget.existingEntry?.sleepQuality ?? 5;
    _notesController = TextEditingController(text: widget.existingEntry?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingEntry == null ? 'Log Your Mood' : 'Edit Mood Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mood Selection
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: MoodLevel.values.map((mood) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedMood == mood
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : null,
                      border: Border.all(
                        color: _selectedMood == mood
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getMoodIcon(mood),
                          size: 32,
                          color: _getMoodColor(mood),
                        ),
                        Text(
                          _getMoodLabel(mood),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Energy Level
            _buildSlider(
              'Energy Level',
              _energyLevel,
              (value) => setState(() => _energyLevel = value.round()),
            ),
            
            // Stress Level
            _buildSlider(
              'Stress Level',
              _stressLevel,
              (value) => setState(() => _stressLevel = value.round()),
            ),
            
            // Sleep Quality
            _buildSlider(
              'Sleep Quality',
              _sleepQuality,
              (value) => setState(() => _sleepQuality = value.round()),
            ),
            
            const SizedBox(height: 16),
            
            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'How are you feeling today?',
              ),
              maxLines: 3,
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
          onPressed: _saveMoodEntry,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, int value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$value/10'),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _saveMoodEntry() {
    final moodEntry = MoodEntry(
      id: widget.existingEntry?.id,
      mood: _selectedMood,
      energyLevel: _energyLevel,
      stressLevel: _stressLevel,
      sleepQuality: _sleepQuality,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      entryDate: DateTime.now(),
      createdAt: widget.existingEntry?.createdAt ?? DateTime.now(),
    );

    widget.onSave(moodEntry);
    Navigator.of(context).pop();
  }

  IconData _getMoodIcon(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return Icons.sentiment_very_satisfied;
      case MoodLevel.good:
        return Icons.sentiment_satisfied;
      case MoodLevel.neutral:
        return Icons.sentiment_neutral;
      case MoodLevel.low:
        return Icons.sentiment_dissatisfied;
      case MoodLevel.veryLow:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  Color _getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return Colors.green;
      case MoodLevel.good:
        return Colors.lightGreen;
      case MoodLevel.neutral:
        return Colors.yellow;
      case MoodLevel.low:
        return Colors.orange;
      case MoodLevel.veryLow:
        return Colors.red;
    }
  }

  String _getMoodLabel(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return 'Excellent';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.neutral:
        return 'Neutral';
      case MoodLevel.low:
        return 'Low';
      case MoodLevel.veryLow:
        return 'Very Low';
    }
  }
}