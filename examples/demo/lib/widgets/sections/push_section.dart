import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
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
      sectionKey: 'push',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Push ID',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          identifier: 'push_id_value',
                          container: true,
                          child: SelectableText(
                            vm.pushSubscriptionId ?? 'N/A',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ToggleRow(
                    label: 'Enabled',
                    value: vm.pushEnabled,
                    semanticsLabel: 'push_enabled_toggle',
                    onChanged: vm.hasNotificationPermission
                        ? vm.togglePush
                        : null,
                  ),
                ],
              ),
            ),
          ),
          if (!vm.hasNotificationPermission) ...[
            AppSpacing.gapBox,
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
