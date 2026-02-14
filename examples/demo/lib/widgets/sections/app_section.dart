import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../dialogs.dart';
import '../action_button.dart';
import '../section_card.dart';
import '../toggle_row.dart';

class AppSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const AppSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return SectionCard(
      title: 'App',
      onInfoTap: onInfoTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App ID card (single row like reference)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Text('App ID', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SelectableText(
                      vm.appId,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Guidance banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add your own App ID, then rebuild to fully test all functionality.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => launchUrl(
                    Uri.parse('https://onesignal.com'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(
                    'Get your keys at onesignal.com',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Consent card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ToggleRow(
                    label: 'Consent Required',
                    description: 'Require consent before SDK processes data',
                    value: vm.consentRequired,
                    onChanged: vm.setConsentRequired,
                  ),
                  if (vm.consentRequired) ...[
                    const Divider(),
                    ToggleRow(
                      label: 'Privacy Consent',
                      description: 'Consent given for data collection',
                      value: vm.privacyConsentGiven,
                      onChanged: vm.setPrivacyConsent,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // USER section header
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'USER',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
            ),
          ),

          // User status card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      Text(
                        vm.isLoggedIn
                            ? (vm.externalUserId ?? '')
                            : '–',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Login / Switch User button
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
          const SizedBox(height: 8),

          // Logout button
          DestructiveButton(
            label: 'LOGOUT USER',
            onPressed: vm.logoutUser,
          ),
        ],
      ),
    );
  }
}
