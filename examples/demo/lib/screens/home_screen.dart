import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../services/tooltip_helper.dart';
import '../viewmodels/app_viewmodel.dart';
import '../widgets/dialogs.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/log_view.dart';
import '../widgets/sections/aliases_section.dart';
import '../widgets/sections/app_section.dart';
import '../widgets/sections/user_section.dart';
import '../widgets/sections/emails_section.dart';
import '../widgets/sections/in_app_section.dart';
import '../widgets/sections/live_activities_section.dart';
import '../widgets/sections/location_section.dart';
import '../widgets/sections/outcomes_section.dart';
import '../widgets/sections/push_section.dart';
import '../widgets/sections/send_iam_section.dart';
import '../widgets/sections/send_push_section.dart';
import '../widgets/sections/sms_section.dart';
import '../widgets/sections/tags_section.dart';
import '../widgets/sections/custom_events_section.dart';
import '../widgets/sections/triggers_section.dart';
import 'secondary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-prompt push permission after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppViewModel>().promptPush();
    });
  }

  void _showTooltipDialog(BuildContext context, String key) {
    final tooltip = TooltipHelper().getTooltip(key);
    if (tooltip != null) {
      showDialog(
        context: context,
        builder: (_) => TooltipDialog(tooltip: tooltip),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/onesignal_logo.svg',
              height: 22,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Flutter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: vm.isLoading,
        child: Column(
          children: [
            const LogView(),
            Expanded(
              child: Semantics(
                identifier: 'main_scroll_view',
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    const AppSection(),
                    const UserSection(),
                    PushSection(
                      onInfoTap: () => _showTooltipDialog(context, 'push'),
                    ),
                    SendPushSection(
                      onInfoTap: () =>
                          _showTooltipDialog(context, 'sendPushNotification'),
                    ),
                    InAppSection(
                      onInfoTap: () =>
                          _showTooltipDialog(context, 'inAppMessaging'),
                    ),
                    SendIamSection(
                      onInfoTap: () =>
                          _showTooltipDialog(context, 'sendInAppMessage'),
                    ),
                    AliasesSection(
                      onInfoTap: () => _showTooltipDialog(context, 'aliases'),
                    ),
                    EmailsSection(
                      onInfoTap: () => _showTooltipDialog(context, 'emails'),
                    ),
                    SmsSection(
                      onInfoTap: () => _showTooltipDialog(context, 'sms'),
                    ),
                    TagsSection(
                      onInfoTap: () => _showTooltipDialog(context, 'tags'),
                    ),
                    OutcomesSection(
                      onInfoTap: () =>
                          _showTooltipDialog(context, 'outcomes'),
                    ),
                    TriggersSection(
                      onInfoTap: () =>
                          _showTooltipDialog(context, 'triggers'),
                    ),
                    CustomEventsSection(
                      onInfoTap: () =>
                          _showTooltipDialog(context, 'trackEvent'),
                    ),
                    LocationSection(
                      onInfoTap: () =>
                          _showTooltipDialog(context, 'location'),
                    ),
                    if (defaultTargetPlatform == TargetPlatform.iOS)
                      LiveActivitiesSection(
                        onInfoTap: () =>
                            _showTooltipDialog(context, 'liveActivities'),
                      ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SecondaryScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.osPrimary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('NEXT ACTIVITY'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
