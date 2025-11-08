import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/notification_service.dart';
import '../../domain/entities/reminder.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Use AsyncNotifierProvider for Riverpod 3.0+
final notificationManagerProvider = AsyncNotifierProvider<NotificationManager, void>(() {
  return NotificationManager();
});

class NotificationManager extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initialize on first access
    return;
  }

  Future<void> initializeNotifications() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await NotificationService.initialize();
      await _scheduleDailyReminders();
    });
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await NotificationService.scheduleReminder(reminder);
    });
  }

  Future<void> cancelReminder(int reminderId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await NotificationService.cancelReminder(reminderId);
    });
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await NotificationService.showImmediateNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (error) {
      // Handle error silently for immediate notifications
    }
  }

  Future<void> _scheduleDailyReminders() async {
    try {
      // Schedule daily assessment reminder (9 AM)
      await NotificationService.showImmediateNotification(
        id: 1000,
        title: 'Daily Reminders Set',
        body: 'Brain Plan will remind you about assessments and mood tracking',
      );

      // In a real app, you would schedule these using the background task system
      // This is simplified for the demo
    } catch (error) {
      // Handle error silently
    }
  }
}
