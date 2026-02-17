import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      onInfoTap: onInfoTap,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ToggleRow(
            label: 'Pause In-App Messages',
            description: 'Toggle in-app message display',
            value: vm.iamPaused,
            onChanged: vm.setIamPaused,
          ),
        ),
      ),
    );
  }
}
