import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

// Issue #1138 reproduction: top-level background handler required by FCM.
// On Android, registering ANY FirebaseMessagingService is enough to cause
// FCM (and FlutterFire) to intercept incoming push messages, which is what
// the affected users in #1138 reported alongside the OneSignal click
// listener failure.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM bg] received: ${message.messageId} data=${message.data}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('.env file not found, using defaults');
  }

  // Initialize Firebase + register FCM listeners BEFORE OneSignal so the
  // FirebaseMessagingService is registered in the manifest and starts
  // intercepting push payloads (matches the affected users' setup).
  try {
    await Firebase.initializeApp();
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('[FCM token] $fcmToken');
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint('[FCM token refresh] $token');
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM fg] received: ${message.messageId} data=${message.data}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM open] tapped: ${message.messageId} data=${message.data}');
    });
    debugPrint('Firebase initialized (issue #1138 repro)');
  } catch (e) {
    debugPrint('Firebase init failed (drop google-services.json into android/app): $e');
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

  // Issue #1138 repro: register the click listener as early as possible,
  // mirroring the snippet in the bug report.
  OneSignal.Notifications.addClickListener((event) {
    debugPrint(
      '[ISSUE-1138] addClickListener fired: title="${event.notification.title}" '
      'notifId=${event.notification.notificationId}',
    );
  });

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
    debugPrint('IAM clicked: ${event.message.messageId}');
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

  // Fetch tooltips in background
  TooltipHelper().init();

  debugPrint('OneSignal initialized with app ID: $appId');

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
