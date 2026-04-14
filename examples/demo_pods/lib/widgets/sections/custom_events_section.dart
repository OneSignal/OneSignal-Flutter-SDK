import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
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
            final name = result['name'] as String;
            vm.trackEvent(
              name,
              result['properties'] as Map<String, dynamic>?,
            );
            if (context.mounted) {
              context.showSnackBar('Event tracked: $name');
            }
          }
        },
      ),
    );
  }
}
