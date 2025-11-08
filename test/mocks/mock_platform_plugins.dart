import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

/// Mock implementations for platform plugins that require native code
///
/// These mocks allow unit tests to run without platform channels.
/// Use these in tests that would otherwise fail with MissingPluginException.

// Generate mocks with: dart run build_runner build
@GenerateMocks([
  FlutterSecureStorage,
  FlutterLocalNotificationsPlugin,
])
void main() {}

/// Setup mock secure storage with default behavior
FlutterSecureStorage setupMockSecureStorage() {
  final mock = MockFlutterSecureStorage();

  // Default behavior: return null (no stored value)
  when(mock.read(key: anyNamed('key')))
      .thenAnswer((_) async => null);

  when(mock.write(key: anyNamed('key'), value: anyNamed('value')))
      .thenAnswer((_) async => null);

  when(mock.delete(key: anyNamed('key')))
      .thenAnswer((_) async => null);

  when(mock.deleteAll())
      .thenAnswer((_) async => null);

  when(mock.containsKey(key: anyNamed('key')))
      .thenAnswer((_) async => false);

  return mock;
}

/// Setup mock secure storage with stored encryption key
FlutterSecureStorage setupMockSecureStorageWithKey(String key) {
  final mock = MockFlutterSecureStorage();

  when(mock.read(key: 'encryption_key'))
      .thenAnswer((_) async => key);

  when(mock.write(key: anyNamed('key'), value: anyNamed('value')))
      .thenAnswer((_) async => null);

  when(mock.containsKey(key: 'encryption_key'))
      .thenAnswer((_) async => true);

  when(mock.delete(key: anyNamed('key')))
      .thenAnswer((_) async => null);

  return mock;
}

/// Setup mock notifications plugin with default behavior
FlutterLocalNotificationsPlugin setupMockNotifications() {
  final mock = MockFlutterLocalNotificationsPlugin();

  // Default behavior: all operations succeed
  when(mock.initialize(
    any,
    onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
  )).thenAnswer((_) async => true);

  when(mock.show(
    any,
    any,
    any,
    any,
    payload: anyNamed('payload'),
  )).thenAnswer((_) async => null);

  when(mock.cancel(any))
      .thenAnswer((_) async => null);

  when(mock.cancelAll())
      .thenAnswer((_) async => null);

  when(mock.zonedSchedule(
    any,
    any,
    any,
    any,
    any,
    androidScheduleMode: anyNamed('androidScheduleMode'),
    uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
    payload: anyNamed('payload'),
  )).thenAnswer((_) async => null);

  when(mock.periodicallyShow(
    any,
    any,
    any,
    any,
    any,
    payload: anyNamed('payload'),
  )).thenAnswer((_) async => null);

  return mock;
}

// Note: Mockito will generate these classes when you run:
// dart run build_runner build --delete-conflicting-outputs
