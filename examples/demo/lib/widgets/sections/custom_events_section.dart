import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../dialogs.dart';
import '../section_card.dart';

class CustomEventsSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const CustomEventsSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();

    return SectionCard(
      title: 'Custom Events',
      sectionKey: 'custom_events',
      onInfoTap: onInfoTap,
      child: PrimaryButton(
        label: 'TRACK EVENT',
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => const TrackEventDialog(),
          );
          if (result != null) {
            vm.trackEvent(
              result['name'] as String,
              result['properties'] as Map<String, dynamic>?,
            );
          }
        },
      ),
    );
  }
}
