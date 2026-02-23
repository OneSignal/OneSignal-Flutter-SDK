import 'package:flutter/material.dart';

import '../theme.dart';

class ToggleRow extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ToggleRow({
    super.key,
    required this.label,
    this.description,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              if (description != null)
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.osGrey600,
                      ),
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
