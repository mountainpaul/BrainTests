import 'package:flutter/material.dart';

/// Help button widget with ? icon
///
/// Provides contextual help throughout the app for elderly users
/// who may need guidance with cognitive impairments
class HelpButton extends StatelessWidget {

  const HelpButton({
    super.key,
    required this.helpText,
    required this.onTap,
  });
  final String helpText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Help',
      child: IconButton(
        icon: const Icon(Icons.help_outline),
        iconSize: 28.0,
        constraints: const BoxConstraints(
          minWidth: 48.0,
          minHeight: 48.0,
        ),
        onPressed: onTap,
      ),
    );
  }
}

/// Help dialog with instructions
///
/// Shows detailed help information with optional step-by-step instructions
class HelpDialog extends StatelessWidget {

  const HelpDialog({
    super.key,
    required this.title,
    required this.content,
    this.steps,
  });
  final String title;
  final String content;
  final List<String>? steps;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (steps != null && steps!.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...steps!.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      step,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )),
            ],
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(88, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text(
            'Close',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

/// Show help dialog helper function
void showHelp({
  required BuildContext context,
  required String title,
  required String content,
  List<String>? steps,
}) {
  showDialog(
    context: context,
    builder: (context) => HelpDialog(
      title: title,
      content: content,
      steps: steps,
    ),
  );
}
