import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../dialogs.dart';
import '../list_widgets.dart';
import '../section_card.dart';

class TriggersSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const TriggersSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'Triggers',
      sectionKey: 'triggers',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: PairList(
                sectionKey: 'triggers',
                items: vm.triggersList,
                emptyText: 'No triggers added',
                onDelete: vm.removeTrigger,
              ),
            ),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'ADD TRIGGER',
            semanticsLabel: 'add_trigger_button',
            onPressed: () async {
              final result = await showDialog<MapEntry<String, String>>(
                context: context,
                builder: (_) => const PairInputDialog(
                  title: 'Add Trigger',
                  keySemanticsLabel: 'trigger_key_input',
                  valueSemanticsLabel: 'trigger_value_input',
                  confirmSemanticsLabel: 'trigger_confirm_button',
                ),
              );
              if (result != null) {
                vm.addTrigger(result.key, result.value);
              }
            },
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'ADD MULTIPLE TRIGGERS',
            semanticsLabel: 'add_multiple_triggers_button',
            onPressed: () async {
              final result = await showDialog<Map<String, String>>(
                context: context,
                builder: (_) => const MultiPairInputDialog(
                  title: 'Add Multiple Triggers',
                ),
              );
              if (result != null) {
                vm.addTriggers(result);
              }
            },
          ),
          if (vm.triggersList.isNotEmpty) ...[
            AppSpacing.gapBox,
            DestructiveButton(
              label: 'REMOVE TRIGGERS',
              semanticsLabel: 'remove_triggers_button',
              onPressed: () async {
                final result = await showDialog<List<String>>(
                  context: context,
                  builder: (_) => MultiSelectRemoveDialog(
                    title: 'Remove Triggers',
                    items: vm.triggersList,
                  ),
                );
                if (result != null) {
                  vm.removeSelectedTriggers(result);
                }
              },
            ),
            AppSpacing.gapBox,
            DestructiveButton(
              label: 'CLEAR ALL TRIGGERS',
              semanticsLabel: 'clear_triggers_button',
              onPressed: vm.clearAllTriggers,
            ),
          ],
        ],
      ),
    );
  }
}
