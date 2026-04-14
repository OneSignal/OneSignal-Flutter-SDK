import 'package:flutter/material.dart';

import '../theme.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onInfoTap;
  final String? sectionKey;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.onInfoTap,
    this.sectionKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: sectionKey != null ? '${sectionKey}_section' : null,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header (outside card, ALL CAPS like reference)
          Padding(
            padding: EdgeInsets.only(bottom: onInfoTap != null ? 0 : AppSpacing.gap),
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
                  Transform.translate(
                    offset: const Offset(16, 0),
                    child: Semantics(
                      identifier: sectionKey != null
                          ? '${sectionKey}_info_icon'
                          : null,
                      container: true,
                      child: IconButton(
                        onPressed: onInfoTap,
                        icon: Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.osGrey500,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Card content
          child,
        ],
      ),
      ),
    );
  }
}
