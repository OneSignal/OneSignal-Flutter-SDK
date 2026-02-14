import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_type.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../dialogs.dart';
import '../section_card.dart';

class SendPushSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const SendPushSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();

    return SectionCard(
      title: 'Send Push Notification',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          PrimaryButton(
            label: 'SIMPLE',
            onPressed: () => vm.sendNotification(NotificationType.simple),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'WITH IMAGE',
            onPressed: () => vm.sendNotification(NotificationType.withImage),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'CUSTOM',
            onPressed: () async {
              final result = await showDialog<Map<String, String>>(
                context: context,
                builder: (_) => const CustomNotificationDialog(),
              );
              if (result != null) {
                vm.sendCustomNotification(result['title']!, result['body']!);
              }
            },
          ),
        ],
      ),
    );
  }
}
