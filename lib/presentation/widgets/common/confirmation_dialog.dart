import 'package:flutter/material.dart';

/// Confirmation dialog for destructive actions
///
/// Helps prevent accidental data loss by requiring confirmation
/// for destructive operations like delete, cancel, clear
class ConfirmationDialog extends StatelessWidget {

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = true,
  });
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        // Cancel button - always safe
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            minimumSize: const Size(88, 48), // Accessible touch target
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            cancelText,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        // Confirm button - styled based on destructiveness
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(88, 48), // Accessible touch target
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: isDestructive ? Colors.red : null,
            foregroundColor: isDestructive ? Colors.white : null,
          ),
          child: Text(
            confirmText,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  /// Show confirmation dialog
  ///
  /// Returns true if user confirmed, false if cancelled
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Require explicit choice
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () {}, // Handled by dialog return value
      ),
    );
    return result ?? false;
  }
}

/// Helper functions for common confirmation scenarios

Future<bool> confirmDelete(BuildContext context, String itemName) async {
  return await ConfirmationDialog.show(
    context: context,
    title: 'Delete $itemName?',
    message: 'This action cannot be undone. Are you sure you want to delete this $itemName?',
    confirmText: 'Delete',
    cancelText: 'Keep',
    isDestructive: true,
  );
}

Future<bool> confirmCancelTest(BuildContext context) async {
  return await ConfirmationDialog.show(
    context: context,
    title: 'Cancel Test?',
    message: 'Your progress will be lost if you cancel now. Are you sure you want to cancel?',
    confirmText: 'Yes, Cancel Test',
    cancelText: 'Continue Test',
    isDestructive: true,
  );
}

Future<bool> confirmClearData(BuildContext context, String dataType) async {
  return await ConfirmationDialog.show(
    context: context,
    title: 'Clear All $dataType?',
    message: 'This will permanently delete all your $dataType data. This action cannot be undone.',
    confirmText: 'Clear All',
    cancelText: 'Keep Data',
    isDestructive: true,
  );
}

Future<bool> confirmResetSettings(BuildContext context) async {
  return await ConfirmationDialog.show(
    context: context,
    title: 'Reset Settings?',
    message: 'This will restore all settings to their default values.',
    confirmText: 'Reset',
    cancelText: 'Cancel',
    isDestructive: true,
  );
}
