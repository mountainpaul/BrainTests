import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../providers/database_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily', icon: Icon(Icons.today)),
            Tab(text: 'Weekly', icon: Icon(Icons.calendar_view_week)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DailyJournalTab(),
          WeeklyJournalTab(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 4),
    );
  }
}

class DailyJournalTab extends ConsumerStatefulWidget {
  const DailyJournalTab({super.key});

  @override
  ConsumerState<DailyJournalTab> createState() => _DailyJournalTabState();
}

class _DailyJournalTabState extends ConsumerState<DailyJournalTab> {
  final _reflectionsController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime selectedDate = DateTime.now();
  JournalEntry? currentEntry;
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadJournalEntry();
    _setupChangeListeners();
  }

  @override
  void dispose() {
    _reflectionsController.dispose();
    _gratitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setupChangeListeners() {
    _reflectionsController.addListener(_onTextChanged);
    _gratitudeController.addListener(_onTextChanged);
    _notesController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!hasUnsavedChanges) {
      setState(() {
        hasUnsavedChanges = true;
      });
    }
  }

  void _loadJournalEntry() async {
    final database = ref.read(databaseProvider);
    final date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    try {
      final entries = await (database.select(database.journalTable)
            ..where((t) => t.journalType.equals(JournalType.daily.name) & t.entryDate.equals(date)))
          .get();
      
      if (entries.isNotEmpty) {
        final entry = entries.first;
        setState(() {
          currentEntry = entry;
          hasUnsavedChanges = false;
        });
        
        _reflectionsController.text = entry.reflections ?? '';
        _gratitudeController.text = entry.gratitude ?? '';
        _notesController.text = entry.notes ?? '';
      } else {
        setState(() {
          currentEntry = null;
          hasUnsavedChanges = false;
        });
        
        _reflectionsController.clear();
        _gratitudeController.clear();
        _notesController.clear();
      }
    } catch (e) {
      debugPrint('Error loading journal entry: $e');
    }
  }

  Future<void> _saveJournalEntry() async {
    final database = ref.read(databaseProvider);
    final date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    try {
      final reflections = _reflectionsController.text.trim();
      final gratitude = _gratitudeController.text.trim();
      final notes = _notesController.text.trim();
      
      if (reflections.isEmpty && gratitude.isEmpty && notes.isEmpty) {
        // Don't save empty entries
        return;
      }

      if (currentEntry != null) {
        // Update existing entry
        await (database.update(database.journalTable)
              ..where((t) => t.id.equals(currentEntry!.id)))
            .write(JournalTableCompanion(
              reflections: reflections.isNotEmpty ? Value(reflections) : const Value(null),
              gratitude: gratitude.isNotEmpty ? Value(gratitude) : const Value(null),
              notes: notes.isNotEmpty ? Value(notes) : const Value(null),
              updatedAt: Value(DateTime.now()),
            ));
      } else {
        // Create new entry
        await database.into(database.journalTable).insert(
          JournalTableCompanion.insert(
            journalType: JournalType.daily,
            entryDate: date,
            reflections: reflections.isNotEmpty ? Value(reflections) : const Value.absent(),
            gratitude: gratitude.isNotEmpty ? Value(gratitude) : const Value.absent(),
            notes: notes.isNotEmpty ? Value(notes) : const Value.absent(),
          ),
        );
      }
      
      setState(() {
        hasUnsavedChanges = false;
      });
      
      // Reload to get the updated entry
      _loadJournalEntry();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry saved!')),
      );
    } catch (e) {
      debugPrint('Error saving journal entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving entry: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatDate(selectedDate),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (hasUnsavedChanges) ...[
                    const Icon(Icons.edit, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                  ],
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 7)),
                      );
                      if (date != null) {
                        if (hasUnsavedChanges) {
                          final save = await _showUnsavedChangesDialog();
                          if (save == true) {
                            await _saveJournalEntry();
                          }
                        }
                        setState(() {
                          selectedDate = date;
                        });
                        _loadJournalEntry();
                      }
                    },
                    child: const Text('Change Date'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Daily Reflection Prompts
          Text(
            'Daily Reflection',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'How was your day?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reflect on your mood, energy, challenges, and accomplishments.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reflectionsController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Today I felt... I accomplished... I struggled with...',
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.pink),
                      const SizedBox(width: 8),
                      Text(
                        'What are you grateful for?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'List 3 things you\'re thankful for today, big or small.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _gratitudeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '1. My morning coffee\n2. A call from a friend\n3. Beautiful weather',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Additional Notes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Any other thoughts, ideas, or observations about your day.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Free-form notes about your day...',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: hasUnsavedChanges ? _saveJournalEntry : null,
              icon: const Icon(Icons.save),
              label: Text(hasUnsavedChanges ? 'Save Entry' : 'Entry Saved'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Journal Prompts
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need inspiration?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildPromptChip('What made me smile today?'),
                      _buildPromptChip('What did I learn?'),
                      _buildPromptChip('How did I help someone?'),
                      _buildPromptChip('What challenged me?'),
                      _buildPromptChip('What am I looking forward to?'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String prompt) {
    return ActionChip(
      label: Text(prompt, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        // Add prompt to reflections if not already there
        final current = _reflectionsController.text;
        if (!current.contains(prompt)) {
          final newText = current.isEmpty ? prompt : '$current\n\n$prompt';
          _reflectionsController.text = newText;
          _reflectionsController.selection = TextSelection.fromPosition(
            TextPosition(offset: newText.length),
          );
        }
      },
    );
  }

  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to save them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final day = date.day;
    final isToday = DateTime.now().difference(date).inDays == 0;
    
    if (isToday) return 'Today, ${months[date.month - 1]} $day';
    
    return '${months[date.month - 1]} $day, ${date.year}';
  }
}

class WeeklyJournalTab extends ConsumerStatefulWidget {
  const WeeklyJournalTab({super.key});

  @override
  ConsumerState<WeeklyJournalTab> createState() => _WeeklyJournalTabState();
}

class _WeeklyJournalTabState extends ConsumerState<WeeklyJournalTab> {
  final _winsController = TextEditingController();
  final _lessonsController = TextEditingController();
  final _nextWeekController = TextEditingController();
  
  DateTime selectedWeek = DateTime.now();
  JournalEntry? currentEntry;
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadWeeklyEntry();
    _setupChangeListeners();
  }

  @override
  void dispose() {
    _winsController.dispose();
    _lessonsController.dispose();
    _nextWeekController.dispose();
    super.dispose();
  }

  void _setupChangeListeners() {
    _winsController.addListener(_onTextChanged);
    _lessonsController.addListener(_onTextChanged);
    _nextWeekController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!hasUnsavedChanges) {
      setState(() {
        hasUnsavedChanges = true;
      });
    }
  }

  DateTime _getMondayOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;
    final monday = date.subtract(Duration(days: dayOfWeek - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  void _loadWeeklyEntry() async {
    final database = ref.read(databaseProvider);
    final monday = _getMondayOfWeek(selectedWeek);
    
    try {
      final entries = await (database.select(database.journalTable)
            ..where((t) => t.journalType.equals(JournalType.weekly.name) & t.entryDate.equals(monday)))
          .get();
      
      if (entries.isNotEmpty) {
        final entry = entries.first;
        setState(() {
          currentEntry = entry;
          hasUnsavedChanges = false;
        });
        
        _winsController.text = entry.wins ?? '';
        _lessonsController.text = entry.lessons ?? '';
        _nextWeekController.text = entry.nextWeekPlan ?? '';
      } else {
        setState(() {
          currentEntry = null;
          hasUnsavedChanges = false;
        });
        
        _winsController.clear();
        _lessonsController.clear();
        _nextWeekController.clear();
      }
    } catch (e) {
      debugPrint('Error loading weekly journal entry: $e');
    }
  }

  Future<void> _saveWeeklyEntry() async {
    final database = ref.read(databaseProvider);
    final monday = _getMondayOfWeek(selectedWeek);
    
    try {
      final wins = _winsController.text.trim();
      final lessons = _lessonsController.text.trim();
      final nextWeek = _nextWeekController.text.trim();
      
      if (wins.isEmpty && lessons.isEmpty && nextWeek.isEmpty) {
        return;
      }

      if (currentEntry != null) {
        await (database.update(database.journalTable)
              ..where((t) => t.id.equals(currentEntry!.id)))
            .write(JournalTableCompanion(
              wins: wins.isNotEmpty ? Value(wins) : const Value(null),
              lessons: lessons.isNotEmpty ? Value(lessons) : const Value(null),
              nextWeekPlan: nextWeek.isNotEmpty ? Value(nextWeek) : const Value(null),
              updatedAt: Value(DateTime.now()),
            ));
      } else {
        await database.into(database.journalTable).insert(
          JournalTableCompanion.insert(
            journalType: JournalType.weekly,
            entryDate: monday,
            wins: wins.isNotEmpty ? Value(wins) : const Value.absent(),
            lessons: lessons.isNotEmpty ? Value(lessons) : const Value.absent(),
            nextWeekPlan: nextWeek.isNotEmpty ? Value(nextWeek) : const Value.absent(),
          ),
        );
      }
      
      setState(() {
        hasUnsavedChanges = false;
      });
      
      _loadWeeklyEntry();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weekly reflection saved!')),
      );
    } catch (e) {
      debugPrint('Error saving weekly entry: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final monday = _getMondayOfWeek(selectedWeek);
    final sunday = monday.add(const Duration(days: 6));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week Selector
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.calendar_view_week, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week of ${_formatDateShort(monday)} - ${_formatDateShort(sunday)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _getWeekStatus(monday),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (hasUnsavedChanges) ...[
                    const Icon(Icons.edit, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                  ],
                  TextButton(
                    onPressed: _changeWeek,
                    child: const Text('Change Week'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Weekly Reflection
          Text(
            'Weekly Reflection',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.celebration, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Wins & Achievements',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What went well this week? What are you proud of?',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _winsController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'This week I accomplished...\nI felt proud when...\nI made progress on...',
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Lessons & Growth',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What did you learn? What would you do differently?',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lessonsController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'I learned that...\nNext time I will...\nI realized...',
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Next Week\'s Focus',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What are your priorities and intentions for next week?',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nextWeekController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Next week I want to focus on...\nMy main priorities are...\nI plan to...',
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: hasUnsavedChanges ? _saveWeeklyEntry : null,
              icon: const Icon(Icons.save),
              label: Text(hasUnsavedChanges ? 'Save Weekly Reflection' : 'Reflection Saved'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeWeek() async {
    // Simple week navigation for now
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Week'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Previous Week'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedWeek = selectedWeek.subtract(const Duration(days: 7));
                });
                _loadWeeklyEntry();
              },
            ),
            ListTile(
              title: const Text('This Week'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedWeek = DateTime.now();
                });
                _loadWeeklyEntry();
              },
            ),
            ListTile(
              title: const Text('Next Week'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedWeek = selectedWeek.add(const Duration(days: 7));
                });
                _loadWeeklyEntry();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getWeekStatus(DateTime monday) {
    final now = DateTime.now();
    final thisWeekMonday = _getMondayOfWeek(now);
    
    if (monday.isAtSameMomentAs(thisWeekMonday)) {
      return 'This week';
    } else if (monday.isBefore(thisWeekMonday)) {
      final weeksDiff = thisWeekMonday.difference(monday).inDays ~/ 7;
      return weeksDiff == 1 ? 'Last week' : '$weeksDiff weeks ago';
    } else {
      final weeksDiff = monday.difference(thisWeekMonday).inDays ~/ 7;
      return weeksDiff == 1 ? 'Next week' : 'In $weeksDiff weeks';
    }
  }
}