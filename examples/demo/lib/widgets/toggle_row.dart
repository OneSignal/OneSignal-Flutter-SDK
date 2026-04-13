import 'package:flutter/material.dart';

import '../theme.dart';

class ToggleRow extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticsLabel;

  const ToggleRow({
    super.key,
    required this.label,
    this.description,
    required this.value,
    this.onChanged,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: description != null
          ? Text(
              description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.osGrey600,
                  ),
            )
          : null,
      value: value,
      onChanged: onChanged != null ? (v) => onChanged!(v) : null,
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
