import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalCognitiveTracker extends ConsumerStatefulWidget {
  const PersonalCognitiveTracker({super.key});

  @override
  ConsumerState<PersonalCognitiveTracker> createState() => _PersonalCognitiveTrackerState();
}

class _PersonalCognitiveTrackerState extends ConsumerState<PersonalCognitiveTracker> {
  int selectedTabIndex = 0;
  List<CognitiveEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Sample data showing trends over time
    final now = DateTime.now();
    entries = [
      CognitiveEntry(
        date: now.subtract(const Duration(days: 30)),
        memoryScore: 85,
        attentionScore: 90,
        processingScore: 80,
        moodRating: 4,
        sleepQuality: 3,
        notes: "Felt sharp today, good sleep last night",
      ),
      CognitiveEntry(
        date: now.subtract(const Duration(days: 23)),
        memoryScore: 82,
        attentionScore: 85,
        processingScore: 78,
        moodRating: 3,
        sleepQuality: 2,
        notes: "Little foggy, didn't sleep well",
      ),
      CognitiveEntry(
        date: now.subtract(const Duration(days: 16)),
        memoryScore: 88,
        attentionScore: 92,
        processingScore: 85,
        moodRating: 4,
        sleepQuality: 4,
        notes: "Great day, exercised this morning",
      ),
      CognitiveEntry(
        date: now.subtract(const Duration(days: 9)),
        memoryScore: 80,
        attentionScore: 83,
        processingScore: 75,
        moodRating: 3,
        sleepQuality: 3,
        notes: "Stressed about work presentation",
      ),
      CognitiveEntry(
        date: now.subtract(const Duration(days: 2)),
        memoryScore: 87,
        attentionScore: 89,
        processingScore: 83,
        moodRating: 4,
        sleepQuality: 4,
        notes: "Feeling good, started new meditation routine",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cognitive Journey'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: _showInsights,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: selectedTabIndex,
              children: [
                _buildDashboard(),
                _buildTrends(),
                _buildQuickTests(),
                _buildJournal(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEntry,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = [
      {'icon': Icons.dashboard, 'label': 'Today'},
      {'icon': Icons.trending_up, 'label': 'Trends'},
      {'icon': Icons.psychology, 'label': 'Quick Test'},
      {'icon': Icons.book, 'label': 'Journal'},
    ];

    return Container(
      color: Colors.grey.shade100,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTabIndex = index),
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
                        fontSize: 12,
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

  Widget _buildDashboard() {
    final latestEntry = entries.isNotEmpty ? entries.last : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 16),
          _buildTodaysSummary(latestEntry),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildRecentTrends(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'How are you feeling today? Track your cognitive well-being and discover patterns in your mental sharpness.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysSummary(CognitiveEntry? entry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (entry != null) ...[
              Row(
                children: [
                  Expanded(child: _buildScoreIndicator('Memory', entry.memoryScore, Colors.blue)),
                  Expanded(child: _buildScoreIndicator('Focus', entry.attentionScore, Colors.green)),
                  Expanded(child: _buildScoreIndicator('Speed', entry.processingScore, Colors.orange)),
                ],
              ),
              const SizedBox(height: 16),
              _buildMoodAndSleep(entry),
            ] else ...[
              const Text('No data for today yet. Take a quick test to get started!'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _addNewEntry,
                child: const Text('Start Today\'s Check-in'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(String label, int score, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodAndSleep(CognitiveEntry entry) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    Icons.star,
                    size: 20,
                    color: i < entry.moodRating ? Colors.amber : Colors.grey.shade300,
                  );
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sleep', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    Icons.bedtime,
                    size: 20,
                    color: i < entry.sleepQuality ? Colors.blue : Colors.grey.shade300,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.quiz, 'label': 'Memory Test', 'color': Colors.blue},
      {'icon': Icons.speed, 'label': 'Quick Check', 'color': Colors.green},
      {'icon': Icons.palette, 'label': 'Brain Game', 'color': Colors.purple},
      {'icon': Icons.note_add, 'label': 'Add Note', 'color': Colors.orange},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: actions.map((action) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _handleQuickAction(action['label'] as String),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (action['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action['label'] as String,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrends() {
    if (entries.length < 2) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Trends (Past 7 days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getChartSpots('memory'),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _getChartSpots('attention'),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _getChartSpots('processing'),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Memory', Colors.blue),
                const SizedBox(width: 16),
                _buildLegendItem('Focus', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('Speed', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTrends() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Cognitive Trends',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailedChart(),
          const SizedBox(height: 20),
          _buildTrendInsights(),
          const SizedBox(height: 20),
          _buildCorrelationInsights(),
        ],
      ),
    );
  }

  Widget _buildDetailedChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Cognitive Performance Over Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(),
                              style: const TextStyle(fontSize: 10));
                        },
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < entries.length) {
                            final date = entries[value.toInt()].date;
                            return Text(
                              '${date.month}/${date.day}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getDetailedChartSpots('memory'),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue,
                            strokeColor: Colors.white,
                            strokeWidth: 2,
                          );
                        },
                      ),
                    ),
                    LineChartBarData(
                      spots: _getDetailedChartSpots('attention'),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.green,
                            strokeColor: Colors.white,
                            strokeWidth: 2,
                          );
                        },
                      ),
                    ),
                    LineChartBarData(
                      spots: _getDetailedChartSpots('processing'),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.orange,
                            strokeColor: Colors.white,
                            strokeWidth: 2,
                          );
                        },
                      ),
                    ),
                  ],
                  minY: 60,
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insights & Patterns',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.trending_up,
              'Memory Improvement',
              'Your memory scores have improved by 3% over the past month!',
              Colors.green,
            ),
            _buildInsightItem(
              Icons.schedule,
              'Best Performance Time',
              'You tend to score highest in the mornings around 9-11 AM.',
              Colors.blue,
            ),
            _buildInsightItem(
              Icons.bedtime,
              'Sleep Connection',
              'Better sleep quality correlates with +15% higher cognitive scores.',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lifestyle Factors',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Track how different factors affect your cognitive performance:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            _buildFactorCorrelation('Sleep Quality', 0.78, Colors.blue),
            _buildFactorCorrelation('Exercise', 0.65, Colors.green),
            _buildFactorCorrelation('Stress Level', -0.52, Colors.red),
            _buildFactorCorrelation('Social Activity', 0.43, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorCorrelation(String factor, double correlation, Color color) {
    final isPositive = correlation > 0;
    final strength = correlation.abs();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(factor, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: strength,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? Colors.green : Colors.red,
            size: 16,
          ),
          Text(
            '${(correlation * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTests() {
    return const Center(
      child: Text('Quick Tests implementation would go here'),
    );
  }

  Widget _buildJournal() {
    return const Center(
      child: Text('Journal implementation would go here'),
    );
  }

  List<FlSpot> _getChartSpots(String type) {
    return entries.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final data = entry.value;

      final double value = switch (type) {
        'memory' => data.memoryScore.toDouble(),
        'attention' => data.attentionScore.toDouble(),
        'processing' => data.processingScore.toDouble(),
        _ => 0.0,
      };

      return FlSpot(index, value);
    }).toList();
  }

  List<FlSpot> _getDetailedChartSpots(String type) {
    return entries.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final data = entry.value;

      final double value = switch (type) {
        'memory' => data.memoryScore.toDouble(),
        'attention' => data.attentionScore.toDouble(),
        'processing' => data.processingScore.toDouble(),
        _ => 0.0,
      };

      return FlSpot(index, value);
    }).toList();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  void _handleQuickAction(String action) {
    // TODO: Implement quick actions (Share, Export, Print)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action feature coming soon!')),
    );
  }

  void _addNewEntry() {
    // TODO: Implement new entry form for manual cognitive tracking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New entry form coming soon!')),
    );
  }

  void _showInsights() {
    // TODO: Implement detailed insights page with trend analysis
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detailed insights coming soon!')),
    );
  }
}

class CognitiveEntry {

  CognitiveEntry({
    required this.date,
    required this.memoryScore,
    required this.attentionScore,
    required this.processingScore,
    required this.moodRating,
    required this.sleepQuality,
    required this.notes,
  });
  final DateTime date;
  final int memoryScore;
  final int attentionScore;
  final int processingScore;
  final int moodRating;
  final int sleepQuality;
  final String notes;
}

