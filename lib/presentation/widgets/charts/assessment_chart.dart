import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/datasources/database.dart';
import '../../../domain/entities/assessment.dart';

class AssessmentChart extends StatelessWidget {

  const AssessmentChart({
    super.key,
    required this.assessments,
    this.filterType,
  });
  final List<Assessment> assessments;
  final AssessmentType? filterType;

  @override
  Widget build(BuildContext context) {
    final filteredAssessments = filterType != null
        ? assessments.where((a) => a.type == filterType).toList()
        : assessments;

    if (filteredAssessments.isEmpty) {
      return const Center(
        child: Text('No assessment data available'),
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
                  '${value.toInt()}%',
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
                if (value.toInt() >= 0 && value.toInt() < filteredAssessments.length) {
                  final assessment = filteredAssessments[value.toInt()];
                  return Text(
                    '${assessment.completedAt.day}/${assessment.completedAt.month}',
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
        maxX: (filteredAssessments.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: _getAssessmentSpots(filteredAssessments),
            isCurved: true,
            color: _getColorForAssessmentType(filterType),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: _getColorForAssessmentType(filterType).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getAssessmentSpots(List<Assessment> assessments) {
    return assessments.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.percentage);
    }).toList();
  }

  Color _getColorForAssessmentType(AssessmentType? type) {
    if (type == null) return Colors.blue;
    
    switch (type) {
      case AssessmentType.memoryRecall:
        return Colors.purple;
      case AssessmentType.attentionFocus:
        return Colors.orange;
      case AssessmentType.executiveFunction:
        return Colors.green;
      case AssessmentType.languageSkills:
        return Colors.blue;
      case AssessmentType.visuospatialSkills:
        return Colors.red;
      case AssessmentType.processingSpeed:
        return Colors.teal;
    }
  }
}