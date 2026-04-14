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
      sectionKey: 'send_push',
      onInfoTap: onInfoTap,
      child: Column(
        children: [
          PrimaryButton(
            label: 'SIMPLE',
            semanticsLabel: 'send_simple_button',
            onPressed: () => vm.sendNotification(NotificationType.simple),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'WITH IMAGE',
            semanticsLabel: 'send_image_button',
            onPressed: () => vm.sendNotification(NotificationType.withImage),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'WITH SOUND',
            semanticsLabel: 'send_sound_button',
            onPressed: () => vm.sendNotification(NotificationType.withSound),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'CUSTOM',
            semanticsLabel: 'send_custom_button',
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
          AppSpacing.gapBox,
          DestructiveButton(
            label: 'CLEAR ALL',
            semanticsLabel: 'clear_all_button',
            onPressed: vm.clearAllNotifications,
          ),
        ],
      ),
    );
  }
}
