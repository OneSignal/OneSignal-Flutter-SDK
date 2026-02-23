import 'package:flutter/material.dart';

import '../theme.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onInfoTap;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.onInfoTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header (outside card, ALL CAPS like reference)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.gap),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.osGrey700,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                if (onInfoTap != null)
                  GestureDetector(
                    onTap: onInfoTap,
                    child: Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.osGrey500,
                    ),
                  ),
              ],
            ),
          ),
          // Card content
          child,
        ],
      ),
    );
  }
}
