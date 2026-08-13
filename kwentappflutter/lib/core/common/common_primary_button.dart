import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/common_loader.dart';

class CommonPrimaryButton extends StatelessWidget {
  const CommonPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: isLoading
            ? FilledButton.styleFrom(
                disabledBackgroundColor: theme.colorScheme.primary,
                disabledForegroundColor: theme.colorScheme.onPrimary,
              )
            : null,
        child: SizedBox(
          height: 22,
          child: isLoading
              ? CommonLoader(size: 18, color: theme.colorScheme.onPrimary)
              : Center(child: Text(label)),
        ),
      ),
    );
  }
}
