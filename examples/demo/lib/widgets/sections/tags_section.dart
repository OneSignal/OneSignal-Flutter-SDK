import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../dialogs.dart';
import '../list_widgets.dart';
import '../section_card.dart';

class TagsSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const TagsSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'Tags',
      sectionKey: 'tags',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: PairList(
                sectionKey: 'tags',
                items: vm.tagsList,
                emptyText: 'No tags added',
                onDelete: vm.removeTag,
              ),
            ),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'ADD TAG',
            semanticsLabel: 'add_tag_button',
            onPressed: () async {
              final result = await showDialog<MapEntry<String, String>>(
                context: context,
                builder: (_) => const PairInputDialog(
                  title: 'Add Tag',
                  keySemanticsLabel: 'tag_key_input',
                  valueSemanticsLabel: 'tag_value_input',
                  confirmSemanticsLabel: 'tag_confirm_button',
                ),
              );
              if (result != null) {
                vm.addTag(result.key, result.value);
              }
            },
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'ADD MULTIPLE TAGS',
            onPressed: () async {
              final result = await showDialog<Map<String, String>>(
                context: context,
                builder: (_) =>
                    const MultiPairInputDialog(title: 'Add Multiple Tags'),
              );
              if (result != null) {
                vm.addTags(result);
              }
            },
          ),
          if (vm.tagsList.isNotEmpty) ...[
            AppSpacing.gapBox,
            DestructiveButton(
              label: 'REMOVE TAGS',
              onPressed: () async {
                final result = await showDialog<List<String>>(
                  context: context,
                  builder: (_) => MultiSelectRemoveDialog(
                    title: 'Remove Tags',
                    items: vm.tagsList,
                  ),
                );
                if (result != null) {
                  vm.removeSelectedTags(result);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
