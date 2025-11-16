import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/database.dart';

/// Reminder feature removed - this implementation returns empty data
class ReminderRepositoryImpl implements ReminderRepository {

  ReminderRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<Reminder>> getAllReminders() async => [];

  @override
  Future<List<Reminder>> getActiveReminders() async => [];

  @override
  Future<Reminder?> getReminderById(int id) async => null;

  @override
  Future<List<Reminder>> getRemindersByType(ReminderType type) async => [];

  @override
  Future<int> insertReminder(Reminder reminder) async => 0;

  @override
  Future<bool> updateReminder(Reminder reminder) async => false;

  @override
  Future<bool> deleteReminder(int id) async => false;

  @override
  Future<bool> toggleReminderActive(int id) async => false;

  @override
  Future<bool> markReminderCompleted(int id) async => false;

  @override
  Future<List<Reminder>> getUpcomingReminders() async => [];

  @override
  Future<List<Reminder>> getOverdueReminders() async => [];

  @override
  Future<List<Reminder>> getCompletedReminders({int? limit}) async => [];

  @override
  Future<bool> snoozeReminder(int id, Duration duration) async => false;
}
