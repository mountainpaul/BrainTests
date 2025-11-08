import 'package:flutter/material.dart';

/// Reusable loading indicator widget for async operations
///
/// Provides consistent loading UI across the app with:
/// - Large spinner suitable for elderly users (48dp minimum)
/// - Optional loading message
/// - Semantic labels for screen readers
/// - Consistent styling
class LoadingIndicator extends StatelessWidget {

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 48.0,
  });
  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Semantics(
              label: 'Loading',
              child: const CircularProgressIndicator(
                strokeWidth: 4.0,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen loading overlay
///
/// Use this when loading blocks the entire screen
class LoadingOverlay extends StatelessWidget {

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });
  final String? message;
  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: LoadingIndicator(message: message),
          ),
      ],
    );
  }
}

/// Inline loading indicator for list items
///
/// Smaller size for loading within list items or cards
class InlineLoadingIndicator extends StatelessWidget {

  const InlineLoadingIndicator({
    super.key,
    this.message,
  });
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3.0),
          ),
          if (message != null) ...[
            const SizedBox(width: 12),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
