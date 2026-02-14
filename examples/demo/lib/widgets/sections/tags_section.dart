import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: PairList(
                items: vm.tagsList,
                emptyText: 'No tags added',
                onDelete: vm.removeTag,
              ),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'ADD',
            onPressed: () async {
              final result = await showDialog<MapEntry<String, String>>(
                context: context,
                builder: (_) => const PairInputDialog(title: 'Add Tag'),
              );
              if (result != null) {
                vm.addTag(result.key, result.value);
              }
            },
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'ADD MULTIPLE',
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
            const SizedBox(height: 8),
            DestructiveButton(
              label: 'REMOVE SELECTED',
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
