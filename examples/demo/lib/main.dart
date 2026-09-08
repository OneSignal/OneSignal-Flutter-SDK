import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

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
  final appId =
      (envAppId != null && envAppId.isNotEmpty) ? envAppId : _defaultAppId;

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
    debugPrint('[OneSignal] IAM willDisplay: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addDidDisplayListener((event) {
    debugPrint('[OneSignal] IAM didDisplay: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addWillDismissListener((event) {
    debugPrint('[OneSignal] IAM willDismiss: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addDidDismissListener((event) {
    debugPrint('[OneSignal] IAM didDismiss: ${event.message.messageId}');
  });
  OneSignal.InAppMessages.addClickListener((event) {
    debugPrint('[OneSignal] IAM click: ${event.message.messageId}');
  });

  // Register notification listeners
  OneSignal.Notifications.addClickListener((event) {
    debugPrint(
      '[OneSignal] Notification click: ${event.notification.title ?? ''}',
    );

    // Uncomment to see the full event object.
    // debugPrint('[OneSignal] event: ${event.jsonRepresentation()}');
  });
  
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    debugPrint(
      '[OneSignal] Notification foregroundWillDisplay: '
      '${event.notification.title ?? ''}',
    );

    // Uncomment to test preventing the default display behavior.
    // event.preventDefault();

    // Can be called after preventDefault (within ~25 seconds) to force display.
    // event.notification.display();

    // Example with a delay (assumes preventDefault was called).
    // debugPrint('[OneSignal] Forcing notification display in 24 seconds');
    // () async {
    //   var seconds = 24;
    //   while (seconds > 0) {
    //     await Future<void>.delayed(const Duration(seconds: 1));
    //     seconds--;
    //     debugPrint('[OneSignal] Displaying notification in $seconds seconds');
    //   }
    //   event.notification.display();
    // }();
  });

  // Set up API service
  String apiKey = '';
  try {
    apiKey = dotenv.env['ONESIGNAL_API_KEY'] ?? '';
  } catch (_) {
    debugPrint('[OneSignal] API key not found, continuing without it');
  }
  final apiService =
      OneSignalApiService()
        ..setAppId(appId)
        ..setApiKey(apiKey);

  // Fetch tooltips in background
  TooltipHelper().init();

  debugPrint('[OneSignal] Initialized with app ID: $appId');

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final vm = AppViewModel(apiService, prefs);
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
