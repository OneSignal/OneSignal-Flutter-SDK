import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../section_card.dart';
import '../toggle_row.dart';

class LocationSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const LocationSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'Location',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ToggleRow(
                label: 'Location Shared',
                description: 'Share device location with OneSignal',
                value: vm.locationShared,
                onChanged: vm.setLocationShared,
              ),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'PROMPT LOCATION',
            onPressed: vm.promptLocation,
          ),
        ],
      ),
    );
  }
}
