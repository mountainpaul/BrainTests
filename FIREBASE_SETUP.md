# Firebase Integration Setup Guide

This guide explains how to configure Firebase Analytics, Crashlytics, and Performance Monitoring for the Brain Plan app.

## Overview
The app now includes production-ready Firebase integration with:
- **Firebase Analytics**: User behavior tracking and insights
- **Firebase Crashlytics**: Crash reporting and error monitoring
- **Firebase Performance**: Real-time performance monitoring and dashboards

## Setup Instructions

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing project
3. Enable Google Analytics for the project (recommended)

### 2. Add Android App to Project
1. In Firebase Console, click "Add app" → Android
2. Register app with package name: `com.example.brainplan` (or your app's package name)
3. Download `google-services.json`
4. Place `google-services.json` in `android/app/` directory

### 3. Enable Firebase Services
In Firebase Console, enable the following services:

#### Analytics
- Go to Analytics → Dashboard
- Analytics is automatically enabled with the SDK integration

#### Crashlytics
- Go to Crashlytics → Get Started
- Follow the setup wizard to enable crash reporting

#### Performance Monitoring
- Go to Performance → Get Started
- Enable Performance Monitoring for your app

### 4. Update Firebase Configuration
Replace the template values in `lib/firebase_options.dart` with your actual project configuration:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-android-api-key',
  appId: '1:123456789:android:your-actual-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  storageBucket: 'your-actual-project-id.appspot.com',
);
```

You can find these values in:
- Firebase Console → Project Settings → General → Your Apps
- Or in the `google-services.json` file

### 5. Build Configuration
The app automatically detects production vs debug environments:
- **Debug Mode**: Firebase services are disabled by default
- **Production Mode**: Firebase services are fully enabled

To test Firebase in debug mode:
```dart
await AnalyticsService.initialize(enableInDebug: true);
```

## Features Implemented

### Analytics Tracking
The app automatically tracks:
- Screen views and navigation
- Assessment completions with scores and timing
- Brain exercise completions
- Mood entries and wellness data
- Reminder interactions
- Performance issues

### Crash Reporting
Automatic crash reporting for:
- Flutter framework errors
- Unhandled exceptions
- Performance issues
- Custom error logging

### Performance Monitoring
Real-time tracking of:
- App startup time
- Screen load times
- Assessment performance metrics
- Database operation performance
- Network request performance
- Memory usage patterns

### Performance Dashboard
The `PerformanceDashboard` class provides:
- Performance metrics aggregation
- Statistical analysis (average, min, max, median)
- Historical performance data (last 100 data points per metric)
- Real-time performance insights

## Usage Examples

### Custom Event Logging
```dart
await AnalyticsService.logEvent('custom_event', parameters: {
  'user_action': 'button_pressed',
  'screen_name': 'assessment_screen',
  'value': 42,
});
```

### Performance Tracking
```dart
// Using the PerformanceTracker mixin
class MyService with PerformanceTracker {
  Future<void> performOperation() async {
    await trackOperation('my_operation', () async {
      // Your operation logic here
      await heavyComputation();
    });
  }
}
```

### Custom Performance Traces
```dart
await PerformanceMonitoringService.startTrace('custom_trace');
// Perform your operation
await PerformanceMonitoringService.stopTrace('custom_trace',
  attributes: {'operation_type': 'data_processing'});
```

## Testing
Run the Firebase integration tests:
```bash
flutter test test/unit/core/services/firebase_integration_test.dart
```

## Production Deployment
1. Ensure all Firebase services are enabled in console
2. Verify `google-services.json` is in place
3. Update `firebase_options.dart` with production values
4. Test with release build: `flutter build apk --release`
5. Monitor Firebase dashboards after deployment

## Monitoring and Analytics
Once deployed, monitor your app through:
- **Firebase Analytics Dashboard**: User engagement and behavior
- **Crashlytics Dashboard**: Crash reports and stability metrics
- **Performance Dashboard**: App performance metrics and trends

The app will automatically send telemetry data to Firebase when running in production mode.