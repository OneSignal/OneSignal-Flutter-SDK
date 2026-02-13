import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'repositories/onesignal_repository.dart';
import 'screens/home_screen.dart';
import 'services/log_manager.dart';
import 'services/onesignal_api_service.dart';
import 'services/preferences_service.dart';
import 'services/tooltip_helper.dart';
import 'theme.dart';
import 'viewmodels/app_viewmodel.dart';

const String oneSignalAppId = '77e32082-ea27-42e3-a898-c72e141824ef';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize preferences
  final prefs = PreferencesService();
  await prefs.init();

  final appId = prefs.appId ?? oneSignalAppId;

  // Initialize OneSignal SDK
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.consentRequired(prefs.consentRequired);
  OneSignal.consentGiven(prefs.privacyConsent);

  // Restore cached SDK states before initialize so they take effect immediately
  OneSignal.InAppMessages.paused(prefs.iamPaused);
  OneSignal.Location.setShared(prefs.locationShared);

  OneSignal.initialize(appId);

  // Register IAM listeners
  OneSignal.InAppMessages.addWillDisplayListener((event) {
    LogManager().i('IAM', 'Will display: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addDidDisplayListener((event) {
    LogManager().i('IAM', 'Did display: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addWillDismissListener((event) {
    LogManager().i('IAM', 'Will dismiss: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addDidDismissListener((event) {
    LogManager().i('IAM', 'Did dismiss: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addClickListener((event) {
    LogManager().i('IAM', 'Clicked: ${event.result.actionId}');
  });

  // Register notification listeners
  OneSignal.Notifications.addClickListener((event) {
    LogManager().i('Notification', 'Clicked: ${event.notification.title}');
  });
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    LogManager().i(
      'Notification',
      'Foreground will display: ${event.notification.title}',
    );
    event.notification.display();
  });

  // Set up API service
  final apiService = OneSignalApiService()..setAppId(appId);
  final repository = OneSignalRepository(apiService);

  // Fetch tooltips in background
  TooltipHelper().init();

  LogManager().i('App', 'OneSignal initialized with app ID: $appId');

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final vm = AppViewModel(repository, prefs);
        vm.setupObservers();
        vm.loadInitialState(appId);
        return vm;
      },
      child: const OneSignalDemoApp(),
    ),
  );
}

class OneSignalDemoApp extends StatelessWidget {
  const OneSignalDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSignal Demo',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
