import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: PairList(
                items: vm.triggersList,
                emptyText: 'No triggers added',
                onDelete: vm.removeTrigger,
              ),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'ADD',
            onPressed: () async {
              final result = await showDialog<MapEntry<String, String>>(
                context: context,
                builder: (_) => const PairInputDialog(title: 'Add Trigger'),
              );
              if (result != null) {
                vm.addTrigger(result.key, result.value);
              }
            },
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'ADD MULTIPLE',
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
            const SizedBox(height: 8),
            DestructiveButton(
              label: 'REMOVE SELECTED',
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
            const SizedBox(height: 8),
            DestructiveButton(
              label: 'CLEAR ALL',
              onPressed: vm.clearAllTriggers,
            ),
          ],
        ],
      ),
    );
  }
}
