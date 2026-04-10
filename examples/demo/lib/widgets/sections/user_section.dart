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
                      Text('Status', style: Theme.of(context).textTheme.bodyMedium),
                      Semantics(
                        identifier: 'user_status_value',
                        container: true,
                        child: Text(
                          vm.isLoggedIn ? 'Logged In' : 'Anonymous',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                color: vm.isLoggedIn
                                    ? AppColors.osSuccess
                                    : AppColors.osGrey600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'External ID',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Semantics(
                        identifier: 'user_external_id_value',
                        container: true,
                        child: SelectableText(
                          vm.isLoggedIn ? (vm.externalUserId ?? '') : '–',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                        ),
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
            semanticsLabel: 'login_user_button',
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
              semanticsLabel: 'logout_user_button',
              onPressed: vm.logoutUser,
            ),
          ],
        ],
      ),
    );
  }
}
