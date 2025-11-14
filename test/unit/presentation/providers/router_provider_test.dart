import 'package:brain_plan/presentation/providers/router_provider.dart';
import 'package:brain_plan/presentation/screens/about_screen.dart';
import 'package:brain_plan/presentation/screens/exports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Router Provider Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    });

    testWidgets('should have /exports route registered', (tester) async {
      // Arrange
      final container = ProviderContainer();
      final router = container.read(routerProvider);

      // Act - Navigate to /exports
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      router.go('/exports');
      await tester.pumpAndSettle();

      // Assert - ExportsScreen should be displayed
      expect(find.byType(ExportsScreen), findsOneWidget);
      expect(find.text('Export Your Data'), findsOneWidget);
    });

    testWidgets('should have /about route registered', (tester) async {
      // Arrange
      final container = ProviderContainer();
      final router = container.read(routerProvider);

      // Act - Navigate to /about
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      router.go('/about');
      await tester.pump(); // Don't use pumpAndSettle as PackageInfo is async

      // Assert - AboutScreen should be displayed
      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.text('About Brain Plan'), findsOneWidget);
    });

    test('router should have exports route name', () {
      // Arrange
      final container = ProviderContainer();
      final router = container.read(routerProvider);

      // Act & Assert - Check route exists
      final matchedRoute = router.configuration.routes
          .whereType<GoRoute>()
          .any((route) => route.name == 'exports' && route.path == '/exports');

      expect(matchedRoute, isTrue);
    });

    test('router should have about route name', () {
      // Arrange
      final container = ProviderContainer();
      final router = container.read(routerProvider);

      // Act & Assert - Check route exists
      final matchedRoute = router.configuration.routes
          .whereType<GoRoute>()
          .any((route) => route.name == 'about' && route.path == '/about');

      expect(matchedRoute, isTrue);
    });
  });
}
