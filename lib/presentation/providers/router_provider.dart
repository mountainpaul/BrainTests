import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/about_screen.dart';
import '../screens/assessments_screen.dart';
import '../screens/cambridge/cambridge_results_screen.dart';
import '../screens/cambridge/pal_test_screen.dart';
import '../screens/cambridge/avlt_test_screen.dart';
import '../screens/cambridge/ots_test_screen.dart';
import '../screens/cambridge/prm_test_screen.dart';
import '../screens/cambridge/rti_test_screen.dart';
import '../screens/cambridge/rvp_test_screen.dart';
import '../screens/cambridge/swm_test_screen.dart';
import '../screens/cambridge_assessments_screen.dart';
import '../screens/cognition_screen.dart';
import '../screens/exercises_screen.dart';
import '../screens/exports_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      // If not completed onboarding and not on onboarding screen, redirect to onboarding
      if (!onboardingCompleted && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }

      // If completed onboarding and on onboarding screen, redirect to home
      if (onboardingCompleted && state.matchedLocation == '/onboarding') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const CognitionScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      // Legacy routes for assessments and exercises (now part of cognition)
      GoRoute(
        path: '/assessments',
        name: 'assessments',
        builder: (context, state) => const AssessmentsScreen(),
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        builder: (context, state) => const ExercisesScreen(),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/exports',
        name: 'exports',
        builder: (context, state) => const ExportsScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/cambridge',
        name: 'cambridge',
        builder: (context, state) => const CambridgeAssessmentsScreen(),
      ),
      GoRoute(
        path: '/cambridge/pal',
        name: 'pal',
        builder: (context, state) => const PALTestScreen(),
      ),
      GoRoute(
        path: '/cambridge/avlt',
        name: 'cambridge_avlt',
        builder: (context, state) => const AVLTTestScreen(),
      ),
      GoRoute(
        path: '/cambridge/rvp',
        name: 'cambridge_rvp',
        builder: (context, state) => const RVPTestScreen(),
      ),
      GoRoute(
        path: '/cambridge/rti',
        name: 'cambridge_rti',
        builder: (context, state) => const RTITestScreen(),
      ),
      GoRoute(
        path: '/cambridge/swm',
        name: 'cambridge_swm',
        builder: (context, state) => const SWMTestScreen(),
      ),
      GoRoute(
        path: '/cambridge/ots',
        name: 'cambridge_ots',
        builder: (context, state) => const OTSTestScreen(),
      ),
      GoRoute(
        path: '/cambridge/prm',
        name: 'cambridge_prm',
        builder: (context, state) => const PRMTestScreen(),
      ),
      GoRoute(
        path: '/cambridge/results',
        name: 'cambridge_results',
        builder: (context, state) => const CambridgeResultsScreen(),
      ),
    ],
  );
});