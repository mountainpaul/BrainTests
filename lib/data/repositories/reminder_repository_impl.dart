import 'package:drift/drift.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/database.dart';

class ReminderRepositoryImpl implements ReminderRepository {

  ReminderRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<Reminder>> getAllReminders() async {
    final reminders = await _database.select(_database.reminderTable).get();
    return reminders.map(_mapToEntity).toList();
  }

  @override
  Future<List<Reminder>> getActiveReminders() async {
    final reminders = await (_database.select(_database.reminderTable)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .get();
    return reminders.map(_mapToEntity).toList();
  }

  @override
  Future<List<Reminder>> getRemindersByType(ReminderType type) async {
    final reminders = await (_database.select(_database.reminderTable)
          ..where((t) => t.type.equals(type.name)))
        .get();
    return reminders.map(_mapToEntity).toList();
  }

  @override
  Future<List<Reminder>> getUpcomingReminders() async {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    final reminders = await (_database.select(_database.reminderTable)
          ..where((t) => t.isActive.equals(true) & 
                        t.isCompleted.equals(false) &
                        t.scheduledAt.isBetweenValues(now, endOfDay))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .get();
    return reminders.map(_mapToEntity).toList();
  }

  @override
  Future<List<Reminder>> getOverdueReminders() async {
    final now = DateTime.now();

    final reminders = await (_database.select(_database.reminderTable)
          ..where((t) => t.isActive.equals(true) &
                        t.isCompleted.equals(false) &
                        t.scheduledAt.isSmallerThanValue(now))
          ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
        .get();
    return reminders.map(_mapToEntity).toList();
  }

  @override
  Future<List<Reminder>> getCompletedReminders({int? limit}) async {
    var query = _database.select(_database.reminderTable)
          ..where((t) => t.isCompleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);

    if (limit != null) {
      query = query..limit(limit);
    }

    final reminders = await query.get();
    return reminders.map(_mapToEntity).toList();
  }

  @override
  Future<Reminder?> getReminderById(int id) async {
    final reminder = await (_database.select(_database.reminderTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return reminder != null ? _mapToEntity(reminder) : null;
  }

  @override
  Future<int> insertReminder(Reminder reminder) async {
    return await _database.into(_database.reminderTable).insert(
      ReminderTableCompanion.insert(
        title: reminder.title,
        description: Value(reminder.description),
        type: reminder.type,
        frequency: reminder.frequency,
        scheduledAt: reminder.scheduledAt,
        nextScheduled: Value(reminder.nextScheduled),
        isActive: Value(reminder.isActive),
        isCompleted: Value(reminder.isCompleted),
        createdAt: Value(reminder.createdAt),
        updatedAt: Value(reminder.updatedAt),
      ),
    );
  }

  @override
  Future<bool> updateReminder(Reminder reminder) async {
    if (reminder.id == null) return false;
    final rowsUpdated = await (_database.update(_database.reminderTable)
          ..where((t) => t.id.equals(reminder.id!)))
        .write(
      ReminderTableCompanion(
        title: Value(reminder.title),
        description: Value(reminder.description),
        type: Value(reminder.type),
        frequency: Value(reminder.frequency),
        scheduledAt: Value(reminder.scheduledAt),
        nextScheduled: Value(reminder.nextScheduled),
        isActive: Value(reminder.isActive),
        isCompleted: Value(reminder.isCompleted),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return rowsUpdated > 0;
  }

  @override
  Future<bool> deleteReminder(int id) async {
    final rowsDeleted = await (_database.delete(_database.reminderTable)
          ..where((t) => t.id.equals(id)))
        .go();
    return rowsDeleted > 0;
  }

  @override
  Future<bool> markReminderCompleted(int id) async {
    final rowsUpdated = await (_database.update(_database.reminderTable)
          ..where((t) => t.id.equals(id)))
        .write(
      ReminderTableCompanion(
        isCompleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return rowsUpdated > 0;
  }

  @override
  Future<bool> snoozeReminder(int id, Duration duration) async {
    final reminder = await getReminderById(id);
    if (reminder == null) return false;
    
    final newScheduledTime = reminder.scheduledAt.add(duration);
    final rowsUpdated = await (_database.update(_database.reminderTable)
          ..where((t) => t.id.equals(id)))
        .write(
      ReminderTableCompanion(
        scheduledAt: Value(newScheduledTime),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return rowsUpdated > 0;
  }

  Reminder _mapToEntity(ReminderEntry entry) {
    return Reminder(
      id: entry.id,
      title: entry.title,
      description: entry.description,
      type: entry.type,
      frequency: entry.frequency,
      scheduledAt: entry.scheduledAt,
      nextScheduled: entry.nextScheduled,
      isActive: entry.isActive,
      isCompleted: entry.isCompleted,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }
}