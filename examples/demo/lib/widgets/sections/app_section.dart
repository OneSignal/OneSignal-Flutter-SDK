import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
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
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  Text('App ID', style: Theme.of(context).textTheme.bodyMedium),
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
          AppSpacing.gapBox,

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
                AppSpacing.gapBox,
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
          AppSpacing.gapBox,

          // Consent card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.cardPadding,
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
        ],
      ),
    );
  }
}
