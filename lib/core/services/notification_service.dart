import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/datasources/database.dart';
import '../../domain/entities/reminder.dart';

class NotificationService {
  // Allow injection for testing
  static FlutterLocalNotificationsPlugin? _testPlugin;

  static FlutterLocalNotificationsPlugin get _notifications {
    return _testPlugin ?? FlutterLocalNotificationsPlugin();
  }

  static bool _initialized = false;

  /// Set custom plugin for testing (package-private)
  @visibleForTesting
  static void setTestPlugin(FlutterLocalNotificationsPlugin? plugin) {
    _testPlugin = plugin;
    _initialized = plugin != null; // If plugin is set, mark as initialized
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings macOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      macOS: macOSSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions
    await _requestPermissions();

    // Initialize background task manager
    await _initializeBackgroundTasks();

    _initialized = true;
  }

  static Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  static Future<void> _initializeBackgroundTasks() async {
    // Only initialize background tasks on supported platforms
    if (Platform.isAndroid) {
      try {
        await AndroidAlarmManager.initialize();
      } catch (e) {
        // Fallback to Workmanager if AndroidAlarmManager fails
        // AndroidAlarmManager failed, no fallback available
        print('Background tasks not available: $e');
      }
    } else {
      // Background task plugins not supported on iOS/macOS/web
      print('Background tasks not supported on this platform');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      // Navigate to appropriate screen based on payload
      // This would be handled by your main app navigation
    }
  }

  static Future<void> scheduleReminder(Reminder reminder) async {
    if (!_initialized) await initialize();
    
    if (reminder.id == null) return;

    const androidDetails = AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Notifications for medication and appointment reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const macOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      macOS: macOSDetails,
    );

    await _notifications.zonedSchedule(
      reminder.id!,
      reminder.title,
      reminder.description ?? 'Brain Plan Reminder',
      _convertToTZDateTime(reminder.scheduledAt),
      notificationDetails,
      payload: 'reminder_${reminder.id}',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // Schedule recurring reminders if needed
    if (reminder.frequency != ReminderFrequency.once) {
      await _scheduleRecurringReminder(reminder);
    }
  }

  static Future<void> _scheduleRecurringReminder(Reminder reminder) async {
    if (reminder.id == null || !Platform.isAndroid) return;

    Duration interval;
    switch (reminder.frequency) {
      case ReminderFrequency.daily:
        interval = const Duration(days: 1);
        break;
      case ReminderFrequency.weekly:
        interval = const Duration(days: 7);
        break;
      case ReminderFrequency.monthly:
        interval = const Duration(days: 30);
        break;
      case ReminderFrequency.once:
        return; // No recurring needed
    }

    // Use background task for recurring reminders (Android only)
    try {
      await AndroidAlarmManager.periodic(
        interval,
        reminder.id!,
        _backgroundReminderCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: {
          'reminderId': reminder.id,
          'title': reminder.title,
          'description': reminder.description,
        },
      );
    } catch (e) {
      // AndroidAlarmManager failed, no fallback available
      print('Recurring reminders not available: $e');
    }
  }

  static Future<void> cancelReminder(int reminderId) async {
    await _notifications.cancel(reminderId);
    
    if (Platform.isAndroid) {
      try {
        await AndroidAlarmManager.cancel(reminderId);
      } catch (e) {
        print('Could not cancel Android alarm: $e');
      }
    }
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    
    // Note: AndroidAlarmManager doesn't have cancelAll, 
    // so individual IDs would need to be tracked and cancelled separately
    print('All local notifications cancelled');
  }

  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'immediate',
      'Immediate Notifications',
      channelDescription: 'Immediate notifications for app events',
      importance: Importance.high,
      priority: Priority.high,
    );

    const macOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      macOS: macOSDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Background callback for recurring reminders
  @pragma('vm:entry-point')
  static Future<void> _backgroundReminderCallback(int id, Map<String, dynamic> params) async {
    await showImmediateNotification(
      id: id,
      title: params['title'] as String? ?? 'Brain Plan Reminder',
      body: params['description'] as String? ?? 'You have a scheduled reminder',
      payload: 'reminder_$id',
    );
  }

  // Convert DateTime to TZDateTime using local timezone
  static tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.local;
    return tz.TZDateTime.from(dateTime, location);
  }
}

