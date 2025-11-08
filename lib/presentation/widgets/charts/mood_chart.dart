import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/mood_entry.dart';

class MoodChart extends StatelessWidget {

  const MoodChart({
    super.key,
    required this.moodEntries,
  });
  final List<MoodEntry> moodEntries;

  @override
  Widget build(BuildContext context) {
    if (moodEntries.isEmpty) {
      return const Center(
        child: Text('No mood data available'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < moodEntries.length) {
                  final entry = moodEntries[value.toInt()];
                  return Text(
                    '${entry.entryDate.day}/${entry.entryDate.month}',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (moodEntries.length - 1).toDouble(),
        minY: 0,
        maxY: 10,
        lineBarsData: [
          // Overall Wellness Line
          LineChartBarData(
            spots: _getWellnessSpots(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
          // Energy Level Line
          LineChartBarData(
            spots: _getEnergySpots(),
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          // Stress Level Line (inverted for better visualization)
          LineChartBarData(
            spots: _getStressSpots(),
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          // Sleep Quality Line
          LineChartBarData(
            spots: _getSleepSpots(),
            isCurved: true,
            color: Colors.purple,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getWellnessSpots() {
    return moodEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.overallWellness);
    }).toList();
  }

  List<FlSpot> _getEnergySpots() {
    return moodEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.energyLevel.toDouble());
    }).toList();
  }

  List<FlSpot> _getStressSpots() {
    return moodEntries.asMap().entries.map((entry) {
      // Invert stress level for better visualization (lower stress = higher on chart)
      return FlSpot(entry.key.toDouble(), (11 - entry.value.stressLevel).toDouble());
    }).toList();
  }

  List<FlSpot> _getSleepSpots() {
    return moodEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.sleepQuality.toDouble());
    }).toList();
  }
}