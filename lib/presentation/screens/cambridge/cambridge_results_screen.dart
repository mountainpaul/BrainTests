import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/presentation/providers/database_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Cambridge Test Results Screen - Shows history and charts for all Cambridge tests
class CambridgeResultsScreen extends ConsumerStatefulWidget {
  const CambridgeResultsScreen({super.key});

  @override
  ConsumerState<CambridgeResultsScreen> createState() => _CambridgeResultsScreenState();
}

class _CambridgeResultsScreenState extends ConsumerState<CambridgeResultsScreen> {
  CambridgeTestType? _selectedTestType;
  List<CambridgeAssessmentEntry> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = ref.read(databaseProvider);
      final query = db.select(db.cambridgeAssessmentTable)
        ..orderBy([
          (t) => drift.OrderingTerm(expression: t.completedAt, mode: drift.OrderingMode.desc)
        ]);

      if (_selectedTestType != null) {
        query.where((t) => t.testType.equals(_selectedTestType!.name));
      }

      final results = await query.get();

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading Cambridge results: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectTestType(CambridgeTestType? testType) {
    setState(() {
      _selectedTestType = testType;
    });
    _loadResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambridge Test Results'),
        backgroundColor: Colors.deepPurple[700],
      ),
      body: Column(
        children: [
          _buildTestTypeFilter(),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_results.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No results yet. Complete some tests to see your progress!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_results.length >= 2) _buildAccuracyChart(),
                    if (_results.length >= 2) _buildLatencyChart(),
                    _buildResultsList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTestTypeFilter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Test Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All Tests'),
                selected: _selectedTestType == null,
                onSelected: (_) => _selectTestType(null),
              ),
              ...CambridgeTestType.values.map((testType) {
                return FilterChip(
                  label: Text(_getTestTypeLabel(testType)),
                  selected: _selectedTestType == testType,
                  onSelected: (_) => _selectTestType(testType),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyChart() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accuracy Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _results.length) {
                            final date = _results.reversed.toList()[value.toInt()].completedAt;
                            return Text(
                              DateFormat('M/d').format(date),
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
                  borderData: FlBorderData(show: true),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _results.reversed.toList().asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.accuracy);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatencyChart() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Response Time Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}ms', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _results.length) {
                            final date = _results.reversed.toList()[value.toInt()].completedAt;
                            return Text(
                              DateFormat('M/d').format(date),
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
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _results.reversed.toList().asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.meanLatencyMs);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._results.map(_buildResultCard),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(CambridgeAssessmentEntry result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          _getTestTypeIcon(result.testType),
          color: _getTestTypeColor(result.testType),
        ),
        title: Text(_getTestTypeLabel(result.testType)),
        subtitle: Text(
          DateFormat('MMM d, y - h:mm a').format(result.completedAt),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricRow('Accuracy', '${result.accuracy.toStringAsFixed(1)}%'),
                _buildMetricRow('Correct Trials', '${result.correctTrials}/${result.totalTrials}'),
                _buildMetricRow('Errors', '${result.errorCount}'),
                _buildMetricRow('Mean Response Time', '${result.meanLatencyMs.toStringAsFixed(0)}ms'),
                _buildMetricRow('Median Response Time', '${result.medianLatencyMs.toStringAsFixed(0)}ms'),
                _buildMetricRow('Duration', '${result.durationSeconds}s'),
                const Divider(height: 24),
                Text(
                  result.interpretation,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getInterpretationColor(result.accuracy),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getTestTypeLabel(CambridgeTestType testType) {
    switch (testType) {
      case CambridgeTestType.pal:
        return 'PAL - Memory';
      case CambridgeTestType.prm:
        return 'PRM - Pattern Recognition';
      case CambridgeTestType.swm:
        return 'SWM - Working Memory';
      case CambridgeTestType.rvp:
        return 'RVP - Sustained Attention';
      case CambridgeTestType.rti:
        return 'RTI - Reaction Time';
      case CambridgeTestType.ots:
        return 'OTS - Spatial Planning';
    }
  }

  IconData _getTestTypeIcon(CambridgeTestType testType) {
    switch (testType) {
      case CambridgeTestType.pal:
        return Icons.psychology;
      case CambridgeTestType.prm:
        return Icons.pattern;
      case CambridgeTestType.swm:
        return Icons.memory;
      case CambridgeTestType.rvp:
        return Icons.visibility;
      case CambridgeTestType.rti:
        return Icons.speed;
      case CambridgeTestType.ots:
        return Icons.architecture;
    }
  }

  Color _getTestTypeColor(CambridgeTestType testType) {
    switch (testType) {
      case CambridgeTestType.pal:
        return Colors.orange;
      case CambridgeTestType.prm:
        return Colors.indigo;
      case CambridgeTestType.swm:
        return Colors.purple;
      case CambridgeTestType.rvp:
        return Colors.red;
      case CambridgeTestType.rti:
        return Colors.blue;
      case CambridgeTestType.ots:
        return Colors.teal;
    }
  }

  Color _getInterpretationColor(double accuracy) {
    if (accuracy >= 85) return Colors.green;
    if (accuracy >= 70) return Colors.blue;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }
}
