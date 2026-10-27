import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../dialogs.dart';
import '../action_button.dart';
import '../section_card.dart';

const _languageOptions = [
  ('Device Default', ''),
  ('English', 'en'),
  ('Arabic', 'ar'),
  ('Azerbaijani', 'az'),
  ('Bosnian', 'bs'),
  ('Catalan', 'ca'),
  ('Chinese (Simplified)', 'zh-Hans'),
  ('Chinese (Traditional)', 'zh-Hant'),
  ('Croatian', 'hr'),
  ('Czech', 'cs'),
  ('Danish', 'da'),
  ('Dutch', 'nl'),
  ('Estonian', 'et'),
  ('Finnish', 'fi'),
  ('French', 'fr'),
  ('Georgian', 'ka'),
  ('Bulgarian', 'bg'),
  ('German', 'de'),
  ('Greek', 'el'),
  ('Hindi', 'hi'),
  ('Hebrew', 'he'),
  ('Hungarian', 'hu'),
  ('Indonesian', 'id'),
  ('Italian', 'it'),
  ('Japanese', 'ja'),
  ('Korean', 'ko'),
  ('Latvian', 'lv'),
  ('Lithuanian', 'lt'),
  ('Malay', 'ms'),
  ('Norwegian', 'nb'),
  ('Persian', 'fa'),
  ('Polish', 'pl'),
  ('Portuguese', 'pt'),
  ('Punjabi', 'pa'),
  ('Romanian', 'ro'),
  ('Russian', 'ru'),
  ('Serbian', 'sr'),
  ('Slovak', 'sk'),
  ('Spanish', 'es'),
  ('Swedish', 'sv'),
  ('Thai', 'th'),
  ('Turkish', 'tr'),
  ('Ukrainian', 'uk'),
  ('Vietnamese', 'vi'),
];

class UserSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const UserSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'User',
      sectionKey: 'user',
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
                          vm.isLoggedIn ? (vm.externalUserId ?? '') : '—',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
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
                        'Language',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Semantics(
                        identifier: 'user_language_dropdown',
                        container: true,
                        child: DropdownButton<String>(
                          value:
                              _languageOptions.any((o) => o.$2 == vm.language)
                                  ? vm.language
                                  : '',
                          isDense: true,
                          menuMaxHeight: 320,
                          alignment: AlignmentDirectional.centerEnd,
                          underline: const SizedBox.shrink(),
                          style: Theme.of(context).textTheme.bodySmall,
                          items: [
                            for (final (name, code) in _languageOptions)
                              DropdownMenuItem(value: code, child: Text(name)),
                          ],
                          onChanged: (code) {
                            if (code != null) vm.setLanguage(code);
                          },
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
                await vm.loginUser(result);
              }
            },
          ),
          if (vm.isLoggedIn) ...[
            AppSpacing.gapBox,
            DestructiveButton(
              label: 'LOGOUT USER',
              semanticsLabel: 'logout_user_button',
              onPressed: () async {
                await vm.logoutUser();
              },
            ),
          ],
        ],
      ),
    );
  }
}
