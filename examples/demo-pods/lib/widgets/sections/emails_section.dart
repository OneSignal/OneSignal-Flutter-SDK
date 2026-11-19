import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
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
      sectionKey: 'emails',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: CollapsibleList(
                sectionKey: 'emails',
                items: vm.emailsList,
                emptyText: 'No emails added',
                loading: vm.isLoading,
                onDelete: vm.removeEmail,
              ),
            ),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'ADD EMAIL',
            semanticsLabel: 'add_email_button',
            onPressed: () async {
              final result = await showDialog<String>(
                context: context,
                builder:
                    (_) => const SingleInputDialog(
                      title: 'Add Email',
                      fieldLabel: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      semanticsLabel: 'email_input',
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
