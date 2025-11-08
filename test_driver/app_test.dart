import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Brain Plan Integration Tests', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('should display home screen and navigate between tabs', () async {
      // Verify home screen loads
      await driver.waitFor(find.text('Welcome to Brain Plan'));
      
      // Test navigation to assessments
      await driver.tap(find.text('Assessments'));
      await driver.waitFor(find.text('Start New Assessment'));
      
      // Test navigation to reminders
      await driver.tap(find.text('Reminders'));
      await driver.waitFor(find.text('No active reminders'));
      
      // Test navigation to exercises
      await driver.tap(find.text('Exercises'));
      await driver.waitFor(find.text('Choose an Exercise'));
      
      // Test navigation to mood tracking
      await driver.tap(find.text('Mood'));
      await driver.waitFor(find.text('How are you feeling today?'));
      
      // Return to home
      await driver.tap(find.text('Home'));
      await driver.waitFor(find.text('Welcome to Brain Plan'));
    });

    test('should be able to create a reminder', () async {
      // Navigate to reminders screen
      await driver.tap(find.text('Reminders'));
      await driver.waitFor(find.text('No active reminders'));
      
      // Tap add reminder button
      await driver.tap(find.byIcon(Icons.add));
      await driver.waitFor(find.text('Add Reminder'));
      
      // Fill in reminder details
      await driver.tap(find.byValueKey('title_field'));
      await driver.enterText('Test Reminder');
      
      // Save reminder
      await driver.tap(find.text('Save'));
      
      // Verify reminder was created
      await driver.waitFor(find.text('Test Reminder'));
    });

    test('should display charts in reports screen', () async {
      // Navigate to reports
      await driver.tap(find.text('Reports'));
      await driver.waitFor(find.text('Reports & Analytics'));
      
      // Verify chart sections are present
      await driver.waitFor(find.text('Assessment Overview'));
      await driver.waitFor(find.text('Mood & Wellness Trends'));
    });
  });
}