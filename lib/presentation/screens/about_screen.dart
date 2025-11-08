import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widgets/custom_card.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Brain Plan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppInfoCard(),
          const SizedBox(height: 16),
          _buildFeaturesCard(),
          const SizedBox(height: 16),
          _buildPrivacyCard(),
          const SizedBox(height: 16),
          _buildDisclaimerCard(),
          const SizedBox(height: 16),
          _buildContactCard(),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Brain Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${packageInfo?.version ?? 'Loading...'} (${packageInfo?.buildNumber ?? ''})',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A comprehensive cognitive health tracking application designed to help monitor and maintain brain health through assessments, exercises, and lifestyle tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.assessment, 'Cognitive Assessments',
                'MMSE, MoCA, Cambridge assessments, GDS-15, ADAS-Cog'),
            _buildFeatureItem(Icons.fitness_center, 'Brain Exercises',
                'Memory games, word puzzles, math challenges'),
            _buildFeatureItem(Icons.mood, 'Mood Tracking',
                'Daily mood, energy, stress, and sleep quality'),
            _buildFeatureItem(Icons.notifications, 'Smart Reminders',
                'Medication, exercise, and assessment reminders'),
            _buildFeatureItem(Icons.bar_chart, 'Progress Reports',
                'Visual charts and trend analysis'),
            _buildFeatureItem(Icons.file_download, 'Data Export',
                'Export to PDF and CSV formats'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data Storage',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Brain Plan stores all your data locally on your device. No data is sent to external servers or cloud services.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data Collection',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We collect only the information you provide through the app:\n'
              '• Assessment results\n'
              '• Exercise performance data\n'
              '• Mood and wellness entries\n'
              '• Reminder and medication information\n'
              '• Personal profile information (name, age)',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data Sharing',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your data is never shared with third parties. Export features (PDF, CSV) are provided for your personal use and to share with your healthcare providers at your discretion.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data Deletion',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can delete your data at any time by uninstalling the app or clearing app data through your device settings.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Disclaimer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Brain Plan is designed for informational and educational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Important Notes:\n\n'
              '• Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.\n\n'
              '• Never disregard professional medical advice or delay in seeking it because of something you have read or tracked in this app.\n\n'
              '• The assessments provided are screening tools only and do not constitute a diagnosis.\n\n'
              '• If you think you may have a medical emergency, call your doctor or emergency services immediately.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact & Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.bug_report,
              'Report an Issue',
              'Found a bug? Let us know!',
              'https://github.com/your-repo/brain-plan/issues',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.star,
              'Rate the App',
              'Enjoying Brain Plan? Leave a review!',
              null,
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.code,
              'Open Source',
              'View source code on GitHub',
              'https://github.com/your-repo/brain-plan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
