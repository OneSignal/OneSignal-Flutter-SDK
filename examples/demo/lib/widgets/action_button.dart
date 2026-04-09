import 'package:flutter/material.dart';

import '../theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? semanticsLabel;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.osPrimary,
          foregroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
    if (semanticsLabel != null) {
      button = Semantics(label: semanticsLabel, child: button);
    }
    return button;
  }
}

class DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final String? semanticsLabel;

  const DestructiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.osPrimary,
          side: const BorderSide(color: AppColors.osPrimary),
        ),
        child: Text(label),
      ),
    );
    if (semanticsLabel != null) {
      button = Semantics(label: semanticsLabel, child: button);
    }
    return button;
  }
}
