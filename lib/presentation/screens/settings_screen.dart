import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/auto_backup_service.dart';
import '../../core/services/data_migration_service.dart';
import '../../core/services/google_drive_backup_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/pdf_service.dart';
import '../providers/assessment_provider.dart';
import '../providers/cambridge_assessment_provider.dart';
import '../providers/cognitive_exercise_provider.dart';
import '../providers/google_drive_provider.dart';
import '../providers/mood_entry_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup & Sync',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(context, [
              _buildGoogleDriveBackupTile(context, ref),
            ]),

            const SizedBox(height: 24),

            Text(
              'General',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(context, [
              _buildSettingsTile(
                context,
                'Notifications',
                'Manage reminder notifications',
                Icons.notifications,
                () => _showNotificationSettings(context),
              ),
              _buildSettingsTile(
                context,
                'Data Export',
                'Export your data as PDF',
                Icons.download,
                () => _exportData(context, ref),
              ),
              _buildSettingsTile(
                context,
                'Privacy',
                'Privacy and data settings',
                Icons.privacy_tip,
                () => _showPrivacySettings(context),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(context, [
              _buildSettingsTile(
                context,
                'Help & Support',
                'Get help using the app',
                Icons.help,
                () => _showHelp(context),
              ),
              _buildSettingsTile(
                context,
                'About Brain Plan',
                'Version 1.0.0',
                Icons.info,
                () => _showAbout(context),
              ),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildSettingsSection(BuildContext context, List<Widget> children) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildGoogleDriveBackupTile(BuildContext context, WidgetRef ref) {
    // Use provider instead of static getters to enable automatic rebuilds
    final isSignedIn = ref.watch(isGoogleDriveSignedInProvider);
    final userEmail = ref.watch(googleDriveUserEmailProvider);

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud),
          title: Text(isSignedIn ? 'Google Drive Backup' : 'Sign in to Google Drive'),
          subtitle: Text(isSignedIn && userEmail != null
              ? userEmail
              : 'Sign in to backup your data to the cloud'),
          trailing: IconButton(
            icon: Icon(isSignedIn ? Icons.logout : Icons.login, size: 20),
            onPressed: () => isSignedIn
                ? _signOutGoogleDrive(context)
                : _signInGoogleDrive(context),
            tooltip: isSignedIn ? 'Sign out' : 'Sign in',
          ),
        ),
        if (isSignedIn) ...[
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.backup, size: 20),
            title: const Text('Manual Backup'),
            subtitle: const Text('Backup now to Google Drive'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _manualBackup(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download, size: 20),
            title: const Text('Restore from Google Drive'),
            subtitle: const Text('Download your latest backup'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _restoreFromGoogleDrive(context),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _signInGoogleDrive(BuildContext context) async {
    try {
      final email = await GoogleDriveBackupService.signIn();
      if (email != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed in as $email'),
            backgroundColor: Colors.green,
          ),
        );

        // Check if backup exists and offer to restore
        final hasBackup = await GoogleDriveBackupService.hasBackup();
        if (hasBackup && context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Backup Found'),
              content: const Text(
                'A backup was found in your Google Drive. Would you like to restore it?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Not Now'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restoreFromGoogleDrive(context);
                  },
                  child: const Text('Restore'),
                ),
              ],
            ),
          );
        } else {
          // No backup found, offer to create one
          await DataMigrationService.backupDatabase();
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOutGoogleDrive(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? Your data will remain backed up in Google Drive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await GoogleDriveBackupService.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
          ),
        );
      }
    }
  }

  Future<void> _manualBackup(BuildContext context) async {
    if (!GoogleDriveBackupService.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to Google Drive first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backing up to Google Drive...')),
    );

    final success = await AutoBackupService.performBackup(
      source: 'manual_user_request',
      force: true,
    );

    if (context.mounted) {
      if (success) {
        final lastBackup = AutoBackupService.getLastBackupTime();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup completed successfully\n${lastBackup?.toString() ?? ""}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreFromGoogleDrive(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restoring from Google Drive...')),
    );

    final success = await GoogleDriveBackupService.downloadBackup();

    if (context.mounted) {
      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Successful'),
            content: const Text(
              'Your data has been restored from Google Drive. Please restart the app for changes to take effect.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restore failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNotificationSettings(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final mciEnabled = prefs.getBool('mci_reminder_enabled') ?? true;
    final exerciseEnabled = prefs.getBool('exercise_reminder_enabled') ?? true;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Notification Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cognitive Health Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Weekly MCI Tests'),
                  subtitle: const Text('Mondays at 9:00 AM'),
                  value: mciEnabled,
                  onChanged: (value) async {
                    setState(() {});
                    await prefs.setBool('mci_reminder_enabled', value);
                    if (value) {
                      await NotificationService.scheduleWeeklyMCITestReminder();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Weekly MCI test reminder enabled')),
                        );
                      }
                    } else {
                      await NotificationService.cancelWeeklyMCITestReminder();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Weekly MCI test reminder disabled')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Daily Brain Training'),
                  subtitle: const Text('Every day at 9:00 AM'),
                  value: exerciseEnabled,
                  onChanged: (value) async {
                    setState(() {});
                    await prefs.setBool('exercise_reminder_enabled', value);
                    if (value) {
                      await NotificationService.scheduleDailyExerciseReminder();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Daily exercise reminder enabled')),
                        );
                      }
                    } else {
                      await NotificationService.cancelDailyExerciseReminder();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Daily exercise reminder disabled')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Reminders help you stay consistent with your cognitive health routine.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating PDF report...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Fetch all data from providers
      final assessments = await ref.read(assessmentsProvider.future);
      final cambridgeResults = await ref.read(cambridgeAssessmentProvider.future);
      final exercises = await ref.read(cognitiveExercisesProvider.future);

      // Generate and share PDF report
      await PDFService.generateAndShareReport(
        assessments: assessments,
        cambridgeResults: cambridgeResults,
        exercises: exercises,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text('All data is stored locally on your device and is not shared with third parties.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Brain Plan helps you track your cognitive health through:'),
            SizedBox(height: 8),
            Text('• Regular assessments'),
            Text('• Brain training exercises'),
            Text('• Mood tracking'),
            Text('• Medication reminders'),
            Text('• Progress reports'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Brain Plan',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.psychology, size: 64),
      children: const [
        Text('A comprehensive app for cognitive health tracking and brain training.'),
      ],
    );
  }
}