import 'package:equatable/equatable.dart';
import 'enums.dart';

class MoodEntry extends Equatable {

  const MoodEntry({
    this.id,
    required this.mood,
    required this.energyLevel,
    required this.stressLevel,
    required this.sleepQuality,
    this.notes,
    required this.entryDate,
    required this.createdAt,
  });
  final int? id;
  final MoodLevel mood;
  final int energyLevel;
  final int stressLevel;
  final int sleepQuality;
  final String? notes;
  final DateTime entryDate;
  final DateTime createdAt;

  double get overallWellness {
    final moodScore = _getMoodScore();
    final adjustedStress = 11 - stressLevel; // Invert stress (higher stress = lower wellness)
    return (moodScore + energyLevel + adjustedStress + sleepQuality) / 4;
  }

  int _getMoodScore() {
    switch (mood) {
      case MoodLevel.veryLow:
        return 2;
      case MoodLevel.low:
        return 4;
      case MoodLevel.neutral:
        return 6;
      case MoodLevel.good:
        return 8;
      case MoodLevel.excellent:
        return 10;
    }
  }

  MoodEntry copyWith({
    int? id,
    MoodLevel? mood,
    int? energyLevel,
    int? stressLevel,
    int? sleepQuality,
    String? notes,
    DateTime? entryDate,
    DateTime? createdAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      notes: notes ?? this.notes,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    mood,
    energyLevel,
    stressLevel,
    sleepQuality,
    notes,
    entryDate,
    createdAt,
  ];
}