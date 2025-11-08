import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/datasources/database.dart';

class OverviewPieChart extends StatelessWidget {

  const OverviewPieChart({
    super.key,
    required this.averageScores,
  });
  final Map<AssessmentType, double> averageScores;

  @override
  Widget build(BuildContext context) {
    if (averageScores.isEmpty) {
      return const Center(
        child: Text('No assessment data available'),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: _createPieSections(),
      ),
    );
  }

  List<PieChartSectionData> _createPieSections() {
    final List<PieChartSectionData> sections = [];
    
    for (final entry in averageScores.entries) {
      final color = _getColorForAssessmentType(entry.key);
      sections.add(
        PieChartSectionData(
          value: entry.value,
          title: '${entry.value.toStringAsFixed(1)}%',
          color: color,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Color _getColorForAssessmentType(AssessmentType type) {
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