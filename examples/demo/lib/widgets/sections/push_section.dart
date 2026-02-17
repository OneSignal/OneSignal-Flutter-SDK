import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../section_card.dart';
import '../toggle_row.dart';

class PushSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const PushSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'Push',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Push ID',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SelectableText(
                          vm.pushSubscriptionId ?? 'N/A',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ToggleRow(
                    label: 'Enabled',
                    value: vm.pushEnabled,
                    onChanged: vm.togglePush,
                  ),
                ],
              ),
            ),
          ),
          if (!vm.hasNotificationPermission) ...[
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'PROMPT PUSH',
              onPressed: vm.promptPush,
            ),
          ],
        ],
      ),
    );
  }
}
