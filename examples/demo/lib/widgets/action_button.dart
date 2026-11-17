import 'package:flutter/material.dart';

import '../theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? semanticsLabel;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.semanticsLabel,
    this.padding,
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
          padding: padding,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          ),
        ),
      ),
    );
    if (semanticsLabel != null) {
      button = Semantics(identifier: semanticsLabel, container: true, child: button);
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
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      ),
    );
    if (semanticsLabel != null) {
      button = Semantics(identifier: semanticsLabel, container: true, child: button);
    }
    return button;
  }
}

/// Lays out buttons two per row in equal columns; an odd last button spans
/// both. Callers omit hidden buttons from [children] so the rest reflow.
class ButtonGrid extends StatelessWidget {
  final List<Widget> children;

  const ButtonGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.gap,
      children: [
        for (var i = 0; i < children.length; i += 2)
          if (i == children.length - 1)
            children[i]
          else
            Row(
              spacing: AppSpacing.gap,
              children: [
                Expanded(child: children[i]),
                Expanded(child: children[i + 1]),
              ],
            ),
      ],
    );
  }
}
