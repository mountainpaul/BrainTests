import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/pdf_service.dart';
import '../providers/assessment_provider.dart';
import '../providers/cambridge_assessment_provider.dart';
import '../providers/cognitive_exercise_provider.dart';
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
              'Account & Sync',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(context, [
              _buildAccountTile(context, ref),
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
              _buildSettingsTile(
                context,
                'Debug Info',
                'Check Auth Status',
                Icons.bug_report,
                () => _showDebugInfo(context, ref),
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

  Widget _buildAccountTile(BuildContext context, WidgetRef ref) {
    final userEmailAsync = ref.watch(currentUserEmailProvider);
    final authService = ref.read(authServiceProvider);

    return userEmailAsync.when(
      data: (email) {
        final isSignedIn = email != null;
        return ListTile(
          leading: const Icon(Icons.cloud_sync),
          title: Text(isSignedIn ? 'Cloud Sync Active' : 'Sign in to Sync'),
          subtitle: Text(isSignedIn 
              ? 'Signed in as $email'
              : 'Sign in to backup your progress'),
          trailing: IconButton(
            icon: Icon(isSignedIn ? Icons.logout : Icons.login, size: 20),
            onPressed: () async {
              if (isSignedIn) {
                await authService.signOut();
                // Force refresh of provider
                ref.invalidate(currentUserEmailProvider);
              } else {
                final success = await authService.signIn();
                if (success) {
                  ref.invalidate(currentUserEmailProvider);
                }
              }
            },
            tooltip: isSignedIn ? 'Sign out' : 'Sign in',
          ),
        );
      },
      loading: () => const ListTile(
        leading: Icon(Icons.cloud_sync),
        title: Text('Checking status...'),
        trailing: CircularProgressIndicator(),
      ),
      error: (_, __) => const ListTile(title: Text('Error loading account status')),
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

  // ... (Removed old Google Drive methods)

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

  Future<void> _showDebugInfo(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    final supabaseService = ref.read(supabaseServiceProvider);
    
    String googleStatus = 'Not signed in';
    String idTokenStatus = 'N/A';
    String supabaseStatus = 'Not signed in';
    
    try {
      // Access private _googleSignIn via reflection or just use public API if possible?
      // AuthService doesn't expose the google sign in instance directly.
      // But we can assume if userEmail is set, Google is signed in.
      
      if (authService.userEmail != null) {
        googleStatus = 'Signed in as ${authService.userEmail}';
        // We can't easily get the token here without exposing it in AuthService.
        // But we can check Supabase.
      }
      
      final sbUser = supabaseService.client?.auth.currentUser;
      if (sbUser != null) {
        supabaseStatus = 'Signed in (ID: ${sbUser.id.substring(0, 8)}...)';
      } else {
        supabaseStatus = 'Not signed in (Client is ${supabaseService.client == null ? "null" : "ready"})';
      }
      
    } catch (e) {
      googleStatus = 'Error: $e';
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Google Auth:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(googleStatus),
            const SizedBox(height: 8),
            const Text('Supabase Auth:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(supabaseStatus),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}