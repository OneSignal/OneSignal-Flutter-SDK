import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../dialogs.dart';
import '../list_widgets.dart';
import '../section_card.dart';

class SmsSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const SmsSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'SMS',
      sectionKey: 'sms',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: CollapsibleList(
                items: vm.smsNumbersList,
                emptyText: 'No SMS added',
                onDelete: vm.removeSms,
              ),
            ),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'ADD SMS',
            onPressed: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (_) => const SingleInputDialog(
                  title: 'Add SMS',
                  fieldLabel: 'SMS Number',
                  keyboardType: TextInputType.phone,
                ),
              );
              if (result != null) {
                vm.addSms(result);
              }
            },
          ),
        ],
      ),
    );
  }
}
