import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../providers/database_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';

class FastingScreen extends ConsumerStatefulWidget {
  const FastingScreen({super.key});

  @override
  ConsumerState<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends ConsumerState<FastingScreen> {
  bool is16_8Active = false;
  DateTime? current30HourStart;
  Timer? extendedFastTimer;
  String extendedFastDuration = '00:00:00';

  @override
  void initState() {
    super.initState();
    _loadFastingData();
    _startExtendedFastTimer();
  }

  @override
  void dispose() {
    extendedFastTimer?.cancel();
    super.dispose();
  }

  void _loadFastingData() async {
    final database = ref.read(databaseProvider);
    
    try {
      // Check for active 30-hour fast
      final extendedFasts = await (database.select(database.fastingTable)
            ..where((t) => t.fastType.equals(FastType.extended30Hour.name) & t.isCompleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();
      
      if (extendedFasts.isNotEmpty) {
        setState(() {
          current30HourStart = extendedFasts.first.startTime;
        });
      }

      // Check today's 16:8 status
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      final todayFasts = await (database.select(database.fastingTable)
            ..where((t) => 
                t.fastType.equals(FastType.intermittent16_8.name) & 
                t.startTime.isBiggerOrEqualValue(todayDate) & 
                t.startTime.isSmallerThanValue(todayDate.add(const Duration(days: 1)))))
          .get();
      
      setState(() {
        is16_8Active = todayFasts.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error loading fasting data: $e');
    }
  }

  void _startExtendedFastTimer() {
    extendedFastTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (current30HourStart != null) {
        final duration = DateTime.now().difference(current30HourStart!);
        setState(() {
          extendedFastDuration = _formatDuration(duration);
        });
        
        // Auto-complete after 30 hours
        if (duration.inHours >= 30) {
          _completeExtendedFast();
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _toggle16_8Fast() async {
    final database = ref.read(databaseProvider);
    
    try {
      if (is16_8Active) {
        // Mark as not respecting 16:8 today - we don't delete, just track the decision
        setState(() {
          is16_8Active = false;
        });
      } else {
        // Log that 16:8 is being respected today
        await database.into(database.fastingTable).insert(
          FastingTableCompanion.insert(
            fastType: FastType.intermittent16_8,
            startTime: DateTime.now(),
            isCompleted: const Value(true),
            durationHours: const Value(16), // Standard 16:8
            notes: const Value('16:8 intermittent fasting respected today'),
          ),
        );
        
        setState(() {
          is16_8Active = true;
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(is16_8Active 
              ? '16:8 fasting activated for today!' 
              : '16:8 fasting deactivated for today'),
        ),
      );
    } catch (e) {
      debugPrint('Error toggling 16:8 fast: $e');
    }
  }

  Future<void> _start30HourFast() async {
    final database = ref.read(databaseProvider);
    
    try {
      final now = DateTime.now();
      await database.into(database.fastingTable).insert(
        FastingTableCompanion.insert(
          fastType: FastType.extended30Hour,
          startTime: now,
          notes: const Value('30-hour extended fast started'),
        ),
      );
      
      setState(() {
        current30HourStart = now;
        extendedFastDuration = '00:00:00';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('30-hour fast started!')),
      );
    } catch (e) {
      debugPrint('Error starting 30-hour fast: $e');
    }
  }

  Future<void> _completeExtendedFast() async {
    if (current30HourStart == null) return;
    
    final database = ref.read(databaseProvider);
    
    try {
      final endTime = DateTime.now();
      final duration = endTime.difference(current30HourStart!);
      
      // Find and update the active extended fast
      final activeFasts = await (database.select(database.fastingTable)
            ..where((t) => 
                t.fastType.equals(FastType.extended30Hour.name) & 
                t.isCompleted.equals(false) &
                t.startTime.equals(current30HourStart!)))
          .get();
      
      if (activeFasts.isNotEmpty) {
        final fastEntry = activeFasts.first;
        await (database.update(database.fastingTable)
              ..where((t) => t.id.equals(fastEntry.id)))
            .write(FastingTableCompanion(
              endTime: Value(endTime),
              durationHours: Value(duration.inHours),
              isCompleted: const Value(true),
            ));
      }
      
      setState(() {
        current30HourStart = null;
        extendedFastDuration = '00:00:00';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('30-hour fast completed! Duration: ${duration.inHours}h ${duration.inMinutes.remainder(60)}m'),
        ),
      );
    } catch (e) {
      debugPrint('Error completing extended fast: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fasting'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _build16_8Card(),
            const SizedBox(height: 16),
            _buildExtendedFastCard(),
            const SizedBox(height: 16),
            _buildFeedingWindowCard(),
            const SizedBox(height: 16),
            _buildFastingHistoryCard(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _build16_8Card() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '16:8 Intermittent Fasting',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              is16_8Active 
                  ? 'You\'re respecting 16:8 fasting today! ✅' 
                  : 'Toggle to track 16:8 fasting for today',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Respect 16:8 today',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: is16_8Active,
                  onChanged: (_) => _toggle16_8Fast(),
                ),
              ],
            ),
            if (is16_8Active) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('16:8 fasting active for today'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExtendedFastCard() {
    final isActive = current30HourStart != null;
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: isActive ? Colors.orange : Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '30-Hour Extended Fast',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isActive) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Fast in Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      extendedFastDuration,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Started: ${_formatTime(current30HourStart!)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _completeExtendedFast,
                      icon: const Icon(Icons.stop),
                      label: const Text('End Fast'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Start a 30-hour extended fast for deeper ketosis and autophagy benefits.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _start30HourFast,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start 30-Hour Fast'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingWindowCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Feeding Window',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant),
                  const SizedBox(width: 8),
                  Flexible(
                    child: const Text(
                      '12:00 PM - 8:00 PM',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '8-hour eating window for 16:8 intermittent fasting',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastingHistoryCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Fasts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // This would be populated with actual history data
            _buildHistoryItem('30-Hour Fast', 'Completed', '32h 15m', Icons.timer),
            _buildHistoryItem('16:8 Fast', 'Yesterday', '16h 00m', Icons.access_time),
            _buildHistoryItem('16:8 Fast', '2 days ago', '16h 00m', Icons.access_time),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // Navigate to full history
              },
              icon: const Icon(Icons.history),
              label: const Text('View Full History'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String type, String status, String duration, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  status,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}