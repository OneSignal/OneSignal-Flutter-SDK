import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/in_app_message_type.dart';
import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../section_card.dart';

class SendIamSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const SendIamSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();

    return SectionCard(
      title: 'Send In-App Message',
      onInfoTap: onInfoTap,
      child: Column(
        spacing: AppSpacing.gap,
        children: InAppMessageType.values.map((type) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => vm.sendInAppMessage(type),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9444E),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(type.icon, size: 18),
                  const SizedBox(width: 8),
                  Text(type.label.toUpperCase()),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
