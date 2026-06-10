import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/in_app_message_type.dart';
import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../section_card.dart';

class SendIamSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const SendIamSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();

    return SectionCard(
      title: 'Send In-App Message',
      sectionKey: 'send_iam',
      onInfoTap: onInfoTap,
      child: Column(
        spacing: AppSpacing.gap,
        children: InAppMessageType.values.map((type) {
          return PrimaryButton(
            label: type.label.toUpperCase(),
            onPressed: () => vm.sendInAppMessage(type),
            semanticsLabel: 'send_iam_${type.triggerValue}_button',
          );
        }).toList(),
      ),
    );
  }
}
