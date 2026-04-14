import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
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
      sectionKey: 'aliases',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: PairList(
                sectionKey: 'aliases',
                items: vm.aliasesList,
                emptyText: 'No aliases added',
                loading: vm.isLoading,
              ),
            ),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'ADD ALIAS',
            onPressed: () async {
              final result = await showDialog<MapEntry<String, String>>(
                context: context,
                builder:
                    (_) => const PairInputDialog(
                      title: 'Add Alias',
                      keyLabel: 'Label',
                      valueLabel: 'ID',
                      keySemanticsLabel: 'alias_label_input',
                      valueSemanticsLabel: 'alias_id_input',
                      confirmSemanticsLabel: 'alias_confirm_button',
                    ),
              );
              if (result != null) {
                vm.addAlias(result.key, result.value);
              }
            },
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'ADD MULTIPLE ALIASES',
            onPressed: () async {
              final result = await showDialog<Map<String, String>>(
                context: context,
                builder:
                    (_) => const MultiPairInputDialog(
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
