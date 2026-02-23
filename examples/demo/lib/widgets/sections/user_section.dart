import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../dialogs.dart';
import '../action_button.dart';
import '../section_card.dart';

class UserSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const UserSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'User',
      onInfoTap: onInfoTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status', style: TextStyle(fontSize: 14)),
                      Text(
                        vm.isLoggedIn ? 'Logged In' : 'Anonymous',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: vm.isLoggedIn
                              ? AppColors.oneSignalGreen
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'External ID',
                        style: TextStyle(fontSize: 14),
                      ),
                      SelectableText(
                        vm.isLoggedIn ? (vm.externalUserId ?? '') : '–',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: vm.isLoggedIn ? 'SWITCH USER' : 'LOGIN USER',
            onPressed: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (_) => const LoginDialog(),
              );
              if (result != null && context.mounted) {
                vm.loginUser(result);
              }
            },
          ),
          if (vm.isLoggedIn) ...[
            AppSpacing.gapBox,
            DestructiveButton(
              label: 'LOGOUT USER',
              onPressed: vm.logoutUser,
            ),
          ],
        ],
      ),
    );
  }
}
