import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/resources/strings.dart';

class CommonErrorDialog {
  const CommonErrorDialog._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: theme.colorScheme.error,
        ),
        title: Text(title),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(Strings.okAction),
          ),
        ],
      ),
    );
  }
}
