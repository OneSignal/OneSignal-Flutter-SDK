import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../section_card.dart';
import '../toggle_row.dart';

class InAppSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const InAppSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'In-App Messaging',
      sectionKey: 'iam',
      onInfoTap: onInfoTap,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: ToggleRow(
            label: 'Pause In-App Messages',
            description: 'Toggle in-app message display',
            semanticsLabel: 'pause_iam_toggle',
            value: vm.iamPaused,
            onChanged: vm.setIamPaused,
          ),
        ),
      ),
    );
  }
}
