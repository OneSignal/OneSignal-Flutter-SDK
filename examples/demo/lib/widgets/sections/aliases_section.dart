import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../dialogs.dart';
import '../list_widgets.dart';
import '../section_card.dart';

class AliasesSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const AliasesSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'Aliases',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: PairList(
                items: vm.aliasesList,
                emptyText: 'No aliases added',
              ),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'ADD',
            onPressed: () async {
              final result = await showDialog<MapEntry<String, String>>(
                context: context,
                builder: (_) => const PairInputDialog(
                  title: 'Add Alias',
                  keyLabel: 'Label',
                  valueLabel: 'ID',
                ),
              );
              if (result != null) {
                vm.addAlias(result.key, result.value);
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
                  title: 'Add Multiple Aliases',
                  keyLabel: 'Label',
                  valueLabel: 'ID',
                ),
              );
              if (result != null) {
                vm.addAliases(result);
              }
            },
          ),
        ],
      ),
    );
  }
}
