import '../../data/datasources/database.dart';
import '../entities/reminder.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getAllReminders();
  Future<List<Reminder>> getActiveReminders();
  Future<List<Reminder>> getRemindersByType(ReminderType type);
  Future<List<Reminder>> getUpcomingReminders();
  Future<List<Reminder>> getOverdueReminders();
  Future<List<Reminder>> getCompletedReminders({int? limit});
  Future<Reminder?> getReminderById(int id);
  Future<int> insertReminder(Reminder reminder);
  Future<bool> updateReminder(Reminder reminder);
  Future<bool> deleteReminder(int id);
  Future<bool> markReminderCompleted(int id);
  Future<bool> snoozeReminder(int id, Duration duration);
}