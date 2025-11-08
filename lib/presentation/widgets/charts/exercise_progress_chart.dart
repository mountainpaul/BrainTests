import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/datasources/database.dart';
import '../../../domain/entities/cognitive_exercise.dart';

class ExerciseProgressChart extends StatelessWidget {

  const ExerciseProgressChart({
    super.key,
    required this.exercises,
    this.filterType,
  });
  final List<CognitiveExercise> exercises;
  final ExerciseType? filterType;

  @override
  Widget build(BuildContext context) {
    final filteredExercises = filterType != null
        ? exercises.where((e) => e.type == filterType && e.isCompleted).toList()
        : exercises.where((e) => e.isCompleted).toList();

    if (filteredExercises.isEmpty) {
      return const Center(
        child: Text('No exercise data available'),
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
                if (value.toInt() >= 0 && value.toInt() < filteredExercises.length) {
                  final exercise = filteredExercises[value.toInt()];
                  if (exercise.completedAt != null) {
                    return Text(
                      '${exercise.completedAt!.day}/${exercise.completedAt!.month}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
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
        maxX: (filteredExercises.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: _getExerciseSpots(filteredExercises),
            isCurved: true,
            color: _getColorForExerciseType(filterType),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: _getColorForExerciseType(filterType).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getExerciseSpots(List<CognitiveExercise> exercises) {
    return exercises.asMap().entries.map((entry) {
      final percentage = entry.value.percentage ?? 0;
      return FlSpot(entry.key.toDouble(), percentage);
    }).toList();
  }

  Color _getColorForExerciseType(ExerciseType? type) {
    if (type == null) return Colors.blue;
    
    switch (type) {
      case ExerciseType.memoryGame:
        return Colors.purple;
      case ExerciseType.wordPuzzle:
        return Colors.orange;
      case ExerciseType.wordSearch:
        return Colors.orange;
      case ExerciseType.spanishAnagram:
        return Colors.orange;
      case ExerciseType.mathProblem:
        return Colors.green;
      case ExerciseType.patternRecognition:
        return Colors.blue;
      case ExerciseType.sequenceRecall:
        return Colors.red;
      case ExerciseType.spatialAwareness:
        return Colors.teal;
    }
  }
}