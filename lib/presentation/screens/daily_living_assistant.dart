import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyLivingAssistant extends ConsumerStatefulWidget {
  const DailyLivingAssistant({super.key});

  @override
  ConsumerState<DailyLivingAssistant> createState() => _DailyLivingAssistantState();
}

class _DailyLivingAssistantState extends ConsumerState<DailyLivingAssistant> {
  int selectedIndex = 0;
  List<SmartReminder> reminders = [];
  List<MemoryAid> memoryAids = [];
  List<DailyTask> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();

    reminders = [
      SmartReminder(
        id: '1',
        title: 'Take Morning Medications',
        description: 'Vitamin D, B12, and blood pressure medication',
        scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
        type: ReminderType.medication,
        isCompleted: false,
        repeatDaily: true,
      ),
      SmartReminder(
        id: '2',
        title: 'Call Mom',
        description: 'Weekly check-in call',
        scheduledTime: DateTime(now.year, now.month, now.day, 14, 0),
        type: ReminderType.social,
        isCompleted: false,
        repeatWeekly: true,
      ),
      SmartReminder(
        id: '3',
        title: 'Grocery Shopping',
        description: 'Pick up items from your shopping list',
        scheduledTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
        type: ReminderType.task,
        isCompleted: false,
      ),
    ];

    memoryAids = [
      MemoryAid(
        id: '1',
        title: 'Important Phone Numbers',
        content: {
          'Doctor': '(555) 123-4567',
          'Emergency Contact': '(555) 987-6543',
          'Pharmacy': '(555) 456-7890',
          'Son John': '(555) 111-2222',
        },
        category: MemoryCategory.contacts,
      ),
      MemoryAid(
        id: '2',
        title: 'Daily Routine',
        content: {
          '7:00 AM': 'Wake up, drink water',
          '7:30 AM': 'Morning medications',
          '8:00 AM': 'Breakfast',
          '9:00 AM': 'Light exercise/walk',
          '10:00 AM': 'Cognitive activities',
          '12:00 PM': 'Lunch',
          '2:00 PM': 'Rest time',
          '6:00 PM': 'Dinner',
          '9:00 PM': 'Evening routine',
        },
        category: MemoryCategory.routine,
      ),
      MemoryAid(
        id: '3',
        title: 'Current Medications',
        content: {
          'Lisinopril 10mg': 'Once daily with breakfast',
          'Vitamin D 2000 IU': 'Once daily',
          'Vitamin B12 500mcg': 'Once daily',
          'Aspirin 81mg': 'Once daily with food',
        },
        category: MemoryCategory.medical,
      ),
    ];

    tasks = [
      DailyTask(
        id: '1',
        title: 'Morning Walk',
        description: '20-minute walk around the neighborhood',
        priority: TaskPriority.high,
        estimatedTime: 30,
        isCompleted: true,
        category: 'Exercise',
      ),
      DailyTask(
        id: '2',
        title: 'Brain Training Game',
        description: 'Complete daily cognitive exercises',
        priority: TaskPriority.medium,
        estimatedTime: 15,
        isCompleted: false,
        category: 'Cognitive',
      ),
      DailyTask(
        id: '3',
        title: 'Review Today\'s Schedule',
        description: 'Check calendar and prepare for appointments',
        priority: TaskPriority.high,
        estimatedTime: 10,
        isCompleted: false,
        category: 'Planning',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Living Assistant'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                _buildRemindersTab(),
                _buildMemoryAidsTab(),
                _buildTasksTab(),
                _buildEmergencyTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildTabBar() {
    const tabs = [
      {'icon': Icons.alarm, 'label': 'Reminders'},
      {'icon': Icons.lightbulb, 'label': 'Memory'},
      {'icon': Icons.checklist, 'label': 'Tasks'},
      {'icon': Icons.emergency, 'label': 'Emergency'},
    ];

    return Container(
      color: Colors.grey.shade100,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRemindersTab() {
    final upcomingReminders = reminders.where((r) => !r.isCompleted).toList();
    final completedReminders = reminders.where((r) => r.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Reminders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (upcomingReminders.isNotEmpty) ...[
            ...upcomingReminders.map(_buildReminderCard),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: Colors.green.shade300),
                    const SizedBox(height: 12),
                    const Text(
                      'All reminders completed!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text('Great job staying on top of things today.'),
                  ],
                ),
              ),
            ),
          ],

          if (completedReminders.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Completed Today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...completedReminders.map(_buildReminderCard),
          ],
        ],
      ),
    );
  }

  Widget _buildReminderCard(SmartReminder reminder) {
    final isOverdue = !reminder.isCompleted && reminder.scheduledTime.isBefore(DateTime.now());
    final timeUntil = reminder.scheduledTime.difference(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: reminder.isCompleted
          ? Colors.green.shade50
          : isOverdue
              ? Colors.red.shade50
              : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getReminderTypeColor(reminder.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getReminderTypeIcon(reminder.type),
                color: _getReminderTypeColor(reminder.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (reminder.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reminder.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: isOverdue ? Colors.red : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.isCompleted
                            ? 'Completed'
                            : isOverdue
                                ? 'Overdue'
                                : _formatTimeUntil(timeUntil),
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.grey.shade600,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!reminder.isCompleted) ...[
              Column(
                children: [
                  IconButton(
                    onPressed: () => _completeReminder(reminder.id),
                    icon: const Icon(Icons.check_circle_outline),
                    color: Colors.green,
                  ),
                  IconButton(
                    onPressed: () => _snoozeReminder(reminder.id),
                    icon: const Icon(Icons.snooze),
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryAidsTab() {
    const categories = MemoryCategory.values;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Memory Aids',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Quick search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search your memory aids...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 20),

          // Categories
          for (final category in categories) ...[
            _buildMemoryCategorySection(category),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildMemoryCategorySection(MemoryCategory category) {
    final categoryAids = memoryAids.where((aid) => aid.category == category).toList();
    if (categoryAids.isEmpty) return const SizedBox();

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(_getMemoryCategoryIcon(category), color: _getMemoryCategoryColor(category)),
            const SizedBox(width: 12),
            Text(
              _getMemoryCategoryTitle(category),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: categoryAids.map(_buildMemoryAidItem).toList(),
      ),
    );
  }

  Widget _buildMemoryAidItem(MemoryAid aid) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            aid.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...aid.content.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      '${entry.key}:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(entry.value),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Tasks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Progress indicator
          _buildTaskProgress(),
          const SizedBox(height: 20),

          // Incomplete tasks
          if (incompleteTasks.isNotEmpty) ...[
            const Text(
              'To Do',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...incompleteTasks.map(_buildTaskCard),
            const SizedBox(height: 20),
          ],

          // Completed tasks
          if (completedTasks.isNotEmpty) ...[
            const Text(
              'Completed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...completedTasks.map(_buildTaskCard),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskProgress() {
    final completed = tasks.where((t) => t.isCompleted).length;
    final total = tasks.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Progress',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$completed/$total tasks',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(DailyTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: task.isCompleted ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => _toggleTask(task.id),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTaskPriorityChip(task.priority),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.category,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 2),
                      Text(
                        '${task.estimatedTime} min',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskPriorityChip(TaskPriority priority) {
    Color color;
    String text;

    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        text = 'High';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        text = 'Medium';
        break;
      case TaskPriority.low:
        color = Colors.green;
        text = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmergencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildEmergencyCard(
            'Emergency Services',
            '911',
            Icons.local_hospital,
            Colors.red,
            'Fire, Police, Medical Emergency',
          ),
          _buildEmergencyCard(
            'Doctor',
            '(555) 123-4567',
            Icons.medical_services,
            Colors.blue,
            'Primary Care Physician',
          ),
          _buildEmergencyCard(
            'Emergency Contact',
            '(555) 987-6543',
            Icons.person,
            Colors.green,
            'John (Son)',
          ),
          _buildEmergencyCard(
            'Poison Control',
            '1-800-222-1222',
            Icons.warning,
            Colors.orange,
            '24/7 Poison Help',
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Important Medical Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Blood Type', 'O+'),
                  _buildInfoRow('Allergies', 'Penicillin, Shellfish'),
                  _buildInfoRow('Medical ID', '123-45-6789'),
                  _buildInfoRow('Insurance', 'Blue Cross Blue Shield'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Safety Reminders',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('• Keep this information easily accessible'),
                  Text('• Share emergency contacts with family'),
                  Text('• Update medical information regularly'),
                  Text('• Consider wearing a medical alert bracelet'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(String title, String number, IconData icon, Color color, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Icon(Icons.phone, size: 20),
          ],
        ),
        onTap: () => _makePhoneCall(number),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (selectedIndex) {
      case 0: // Reminders
        return FloatingActionButton(
          onPressed: _addReminder,
          child: const Icon(Icons.add_alarm),
        );
      case 1: // Memory aids
        return FloatingActionButton(
          onPressed: _addMemoryAid,
          child: const Icon(Icons.add),
        );
      case 2: // Tasks
        return FloatingActionButton(
          onPressed: _addTask,
          child: const Icon(Icons.add_task),
        );
      default:
        return null;
    }
  }

  Color _getReminderTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return Colors.red;
      case ReminderType.appointment:
        return Colors.blue;
      case ReminderType.social:
        return Colors.green;
      case ReminderType.task:
        return Colors.orange;
      case ReminderType.exercise:
        return Colors.purple;
    }
  }

  IconData _getReminderTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.appointment:
        return Icons.event;
      case ReminderType.social:
        return Icons.people;
      case ReminderType.task:
        return Icons.task;
      case ReminderType.exercise:
        return Icons.fitness_center;
    }
  }

  Color _getMemoryCategoryColor(MemoryCategory category) {
    switch (category) {
      case MemoryCategory.contacts:
        return Colors.blue;
      case MemoryCategory.medical:
        return Colors.red;
      case MemoryCategory.routine:
        return Colors.green;
      case MemoryCategory.important:
        return Colors.orange;
    }
  }

  IconData _getMemoryCategoryIcon(MemoryCategory category) {
    switch (category) {
      case MemoryCategory.contacts:
        return Icons.contacts;
      case MemoryCategory.medical:
        return Icons.medical_services;
      case MemoryCategory.routine:
        return Icons.schedule;
      case MemoryCategory.important:
        return Icons.star;
    }
  }

  String _getMemoryCategoryTitle(MemoryCategory category) {
    switch (category) {
      case MemoryCategory.contacts:
        return 'Important Contacts';
      case MemoryCategory.medical:
        return 'Medical Information';
      case MemoryCategory.routine:
        return 'Daily Routines';
      case MemoryCategory.important:
        return 'Important Notes';
    }
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.inMinutes < 60) {
      return 'in ${duration.inMinutes} minutes';
    } else if (duration.inHours < 24) {
      return 'in ${duration.inHours} hours';
    } else {
      return 'in ${duration.inDays} days';
    }
  }

  void _completeReminder(String id) {
    setState(() {
      final index = reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        reminders[index] = reminders[index].copyWith(isCompleted: true);
      }
    });
  }

  void _snoozeReminder(String id) {
    setState(() {
      final index = reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        reminders[index] = reminders[index].copyWith(
          scheduledTime: DateTime.now().add(const Duration(minutes: 30)),
        );
      }
    });
  }

  void _toggleTask(String id) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index] = tasks[index].copyWith(isCompleted: !tasks[index].isCompleted);
      }
    });
  }

  void _addReminder() async {
    final result = await showDialog<SmartReminder>(
      context: context,
      builder: (context) => const AddReminderDialog(),
    );

    if (result != null) {
      setState(() {
        reminders.add(result);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder "${result.title}" added!')),
        );
      }
    }
  }

  void _addMemoryAid() async {
    final result = await showDialog<MemoryAid>(
      context: context,
      builder: (context) => const AddMemoryAidDialog(),
    );

    if (result != null) {
      setState(() {
        memoryAids.add(result);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Memory aid "${result.title}" added!')),
        );
      }
    }
  }

  void _addTask() async {
    final result = await showDialog<DailyTask>(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );

    if (result != null) {
      setState(() {
        tasks.add(result);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "${result.title}" added!')),
        );
      }
    }
  }

  void _showSettings() {
    // TODO: Implement settings page for Daily Living Assistant
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon!')),
    );
  }

  void _makePhoneCall(String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Would call $number (phone functionality not implemented)')),
    );
  }
}

// Data models
class SmartReminder {

  SmartReminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    required this.type,
    this.isCompleted = false,
    this.repeatDaily = false,
    this.repeatWeekly = false,
  });
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final ReminderType type;
  final bool isCompleted;
  final bool repeatDaily;
  final bool repeatWeekly;

  SmartReminder copyWith({
    bool? isCompleted,
    DateTime? scheduledTime,
  }) {
    return SmartReminder(
      id: id,
      title: title,
      description: description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      type: type,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatDaily: repeatDaily,
      repeatWeekly: repeatWeekly,
    );
  }
}

enum ReminderType { medication, appointment, social, task, exercise }

class MemoryAid {

  MemoryAid({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
  });
  final String id;
  final String title;
  final Map<String, String> content;
  final MemoryCategory category;
}

enum MemoryCategory { contacts, medical, routine, important }

class DailyTask {

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedTime,
    this.isCompleted = false,
    required this.category,
  });
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final int estimatedTime;
  final bool isCompleted;
  final String category;

  DailyTask copyWith({bool? isCompleted}) {
    return DailyTask(
      id: id,
      title: title,
      description: description,
      priority: priority,
      estimatedTime: estimatedTime,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category,
    );
  }
}

enum TaskPriority { high, medium, low }

// Add Reminder Dialog
class AddReminderDialog extends StatefulWidget {
  const AddReminderDialog({super.key});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  ReminderType _selectedType = ReminderType.task;
  DateTime _selectedTime = DateTime.now().add(const Duration(hours: 1));
  bool _repeatDaily = false;
  bool _repeatWeekly = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ReminderType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: ReminderType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text('Time: ${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_selectedTime),
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = DateTime(
                      _selectedTime.year,
                      _selectedTime.month,
                      _selectedTime.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              },
            ),
            CheckboxListTile(
              title: const Text('Repeat Daily'),
              value: _repeatDaily,
              onChanged: (value) => setState(() => _repeatDaily = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Repeat Weekly'),
              value: _repeatWeekly,
              onChanged: (value) => setState(() => _repeatWeekly = value ?? false),
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
          onPressed: () {
            if (_titleController.text.isEmpty) return;

            final reminder = SmartReminder(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              description: _descriptionController.text,
              scheduledTime: _selectedTime,
              type: _selectedType,
              repeatDaily: _repeatDaily,
              repeatWeekly: _repeatWeekly,
            );

            Navigator.of(context).pop(reminder);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Add Memory Aid Dialog
class AddMemoryAidDialog extends StatefulWidget {
  const AddMemoryAidDialog({super.key});

  @override
  State<AddMemoryAidDialog> createState() => _AddMemoryAidDialogState();
}

class _AddMemoryAidDialogState extends State<AddMemoryAidDialog> {
  final _titleController = TextEditingController();
  final List<MapEntry<TextEditingController, TextEditingController>> _contentControllers = [];
  MemoryCategory _selectedCategory = MemoryCategory.important;

  @override
  void initState() {
    super.initState();
    _addContentRow();
  }

  void _addContentRow() {
    setState(() {
      _contentControllers.add(MapEntry(
        TextEditingController(),
        TextEditingController(),
      ));
    });
  }

  void _removeContentRow(int index) {
    setState(() {
      _contentControllers[index].key.dispose();
      _contentControllers[index].value.dispose();
      _contentControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final entry in _contentControllers) {
      entry.key.dispose();
      entry.value.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Memory Aid'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MemoryCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: MemoryCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text('Content (Key-Value pairs):'),
              const SizedBox(height: 8),
              ..._contentControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controllers = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controllers.key,
                          decoration: const InputDecoration(
                            labelText: 'Key',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controllers.value,
                          decoration: const InputDecoration(
                            labelText: 'Value',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeContentRow(index),
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addContentRow,
                icon: const Icon(Icons.add),
                label: const Text('Add Row'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty) return;

            final content = <String, String>{};
            for (final controllers in _contentControllers) {
              final key = controllers.key.text.trim();
              final value = controllers.value.text.trim();
              if (key.isNotEmpty && value.isNotEmpty) {
                content[key] = value;
              }
            }

            if (content.isEmpty) return;

            final memoryAid = MemoryAid(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              content: content,
              category: _selectedCategory,
            );

            Navigator.of(context).pop(memoryAid);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Add Task Dialog
class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(text: 'general');
  TaskPriority _selectedPriority = TaskPriority.medium;
  int _estimatedTime = 30;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskPriority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPriority = value);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Estimated Time (minutes): '),
                Expanded(
                  child: Slider(
                    value: _estimatedTime.toDouble(),
                    min: 5,
                    max: 180,
                    divisions: 35,
                    label: _estimatedTime.toString(),
                    onChanged: (value) {
                      setState(() => _estimatedTime = value.toInt());
                    },
                  ),
                ),
                Text('$_estimatedTime'),
              ],
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
          onPressed: () {
            if (_titleController.text.isEmpty) return;

            final task = DailyTask(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              description: _descriptionController.text,
              priority: _selectedPriority,
              estimatedTime: _estimatedTime,
              category: _categoryController.text,
            );

            Navigator.of(context).pop(task);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}