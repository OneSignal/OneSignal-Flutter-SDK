import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../dialogs.dart';
import '../list_widgets.dart';
import '../section_card.dart';

class EmailsSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const EmailsSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'Emails',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: CollapsibleList(
                items: vm.emailsList,
                emptyText: 'No emails added',
                onDelete: vm.removeEmail,
              ),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'ADD EMAIL',
            onPressed: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (_) => const SingleInputDialog(
                  title: 'Add Email',
                  fieldLabel: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
              );
              if (result != null) {
                vm.addEmail(result);
              }
            },
          ),
        ],
      ),
    );
  }
}
