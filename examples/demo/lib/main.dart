import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'repositories/onesignal_repository.dart';
import 'screens/home_screen.dart';
import 'services/onesignal_api_service.dart';
import 'services/preferences_service.dart';
import 'services/tooltip_helper.dart';
import 'theme.dart';
import 'viewmodels/app_viewmodel.dart';

const String _defaultAppId = '77e32082-ea27-42e3-a898-c72e141824ef';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('.env file not found, using defaults');
  }

  final prefs = PreferencesService();
  await prefs.init();

  final envAppId = dotenv.env['ONESIGNAL_APP_ID'];
  final appId = (envAppId != null && envAppId.isNotEmpty) ? envAppId : _defaultAppId;

  // Initialize OneSignal SDK
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.consentRequired(prefs.consentRequired);
  OneSignal.consentGiven(prefs.privacyConsent);
  await OneSignal.initialize(appId);

  OneSignal.LiveActivities.setupDefault(
    options: LiveActivitySetupOptions(
      enablePushToStart: true,
      enablePushToUpdate: true,
    ),
  );

  // Restore cached SDK states after init fully completes
  OneSignal.InAppMessages.paused(prefs.iamPaused);
  OneSignal.Location.setShared(prefs.locationShared);

  // Register IAM listeners
  OneSignal.InAppMessages.addWillDisplayListener((event) {
    debugPrint('IAM will display: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addDidDisplayListener((event) {
    debugPrint('IAM did display: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addWillDismissListener((event) {
    debugPrint('IAM will dismiss: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addDidDismissListener((event) {
    debugPrint('IAM did dismiss: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addClickListener((event) {
    debugPrint('IAM clicked: ${event.result.actionId}');
  });

  // Register notification listeners
  OneSignal.Notifications.addClickListener((event) {
    debugPrint('Notification clicked: ${event.notification.title}');
  });
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    debugPrint(
      'Notification foreground will display: ${event.notification.title}',
    );
    event.notification.display();
  });

  // Set up API service
  String apiKey = '';
  try {
    apiKey = dotenv.env['ONESIGNAL_API_KEY'] ?? '';
  } catch (_) {
    debugPrint('API key not found, continuing without it');
  }
  final apiService = OneSignalApiService()
    ..setAppId(appId)
    ..setApiKey(apiKey);
  final repository = OneSignalRepository(apiService);

  // Fetch tooltips in background
  TooltipHelper().init();

  debugPrint('OneSignal initialized with app ID: $appId');

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
