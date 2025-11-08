import 'package:equatable/equatable.dart';
import '../../data/datasources/database.dart';

class Reminder extends Equatable {

  const Reminder({
    this.id,
    required this.title,
    this.description,
    required this.type,
    required this.frequency,
    required this.scheduledAt,
    this.nextScheduled,
    required this.isActive,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });
  final int? id;
  final String title;
  final String? description;
  final ReminderType type;
  final ReminderFrequency frequency;
  final DateTime scheduledAt;
  final DateTime? nextScheduled;
  final bool isActive;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPastDue => DateTime.now().isAfter(scheduledAt);

  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    ReminderType? type,
    ReminderFrequency? frequency,
    DateTime? scheduledAt,
    DateTime? nextScheduled,
    bool? isActive,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      nextScheduled: nextScheduled ?? this.nextScheduled,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    frequency,
    scheduledAt,
    nextScheduled,
    isActive,
    isCompleted,
    createdAt,
    updatedAt,
  ];
}